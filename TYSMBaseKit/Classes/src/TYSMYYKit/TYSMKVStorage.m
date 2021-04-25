//
//  TYSMKVStorage.m
//  TYSMKit <https://github.com/ibireme/TYSMKit>
//
//  Created by ibireme on 15/4/22.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "TYSMKVStorage.h"
#import "UIApplication+TYSMAdd.h"
#import <UIKit/UIKit.h>
#import <time.h>

#if __has_include(<sqlite3.h>)
#import <sqlite3.h>
#else
#import "sqlite3.h"
#endif


static const NSUInteger kMaxErrorRetryCount = 8;
static const NSTimeInterval kMinRetryTimeInterval = 2.0;
static const int kPathLengthMax = PATH_MAX - 64;
static NSString *const kDBFileName = @"manifest.sqlite";
static NSString *const kDBShmFileName = @"manifest.sqlite-shm";
static NSString *const kDBWalFileName = @"manifest.sqlite-wal";
static NSString *const kDataDirectoryName = @"data";
static NSString *const kTrashDirectoryName = @"trash";

/*
 File:
 /path/
      /manifest.sqlite
      /manifest.sqlite-shm
      /manifest.sqlite-wal
      /data/
           /e10adc3949ba59abbe56e057f20f883e
           /e10adc3949ba59abbe56e057f20f883e
      /trash/
            /unused_file_or_folder
 
 SQL:
 create table if not exists manifest (
    key                 text,
    filename            text,
    size                integer,
    inline_data         blob,
    modification_time   integer,
    last_access_time    integer,
    extended_data       blob,
    primary key(key)
 ); 
 create index if not exists last_access_time_idx on manifest(last_access_time);
 */

@implementation TYSMKVStorageItem
@end

@implementation TYSMKVStorage {
    dispatch_queue_t _trashQueue;
    
    NSString *_path;
    NSString *_dbPath;
    NSString *_dataPath;
    NSString *_trashPath;
    
    sqlite3 *_db;
    CFMutableDictionaryRef _dbStmtCache;
    NSTimeInterval _dbLastOpenErrorTime;
    NSUInteger tysm__dbOpenErrorCount;
}


#pragma mark - db

- (BOOL)tysm__dbOpen {
    if (_db) return YES;
    
    int result = sqlite3_open(_dbPath.UTF8String, &_db);
    if (result == SQLITE_OK) {
        CFDictionaryKeyCallBacks keyCallbacks = kCFCopyStringDictionaryKeyCallBacks;
        CFDictionaryValueCallBacks valueCallbacks = {0};
        _dbStmtCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &keyCallbacks, &valueCallbacks);
        _dbLastOpenErrorTime = 0;
        tysm__dbOpenErrorCount = 0;
        return YES;
    } else {
        _db = NULL;
        if (_dbStmtCache) CFRelease(_dbStmtCache);
        _dbStmtCache = NULL;
        _dbLastOpenErrorTime = CACurrentMediaTime();
        tysm__dbOpenErrorCount++;
        
        if (_errorLogsEnabled) {
            NSLog(@"%s line:%d sqlite open failed (%d).", __FUNCTION__, __LINE__, result);
        }
        return NO;
    }
}

- (BOOL)tysm__dbClose {
    if (!_db) return YES;
    
    int  result = 0;
    BOOL retry = NO;
    BOOL stmtFinalized = NO;
    
    if (_dbStmtCache) CFRelease(_dbStmtCache);
    _dbStmtCache = NULL;
    
    do {
        retry = NO;
        result = sqlite3_close(_db);
        if (result == SQLITE_BUSY || result == SQLITE_LOCKED) {
            if (!stmtFinalized) {
                stmtFinalized = YES;
                sqlite3_stmt *stmt;
                while ((stmt = sqlite3_next_stmt(_db, nil)) != 0) {
                    sqlite3_finalize(stmt);
                    retry = YES;
                }
            }
        } else if (result != SQLITE_OK) {
            if (_errorLogsEnabled) {
                NSLog(@"%s line:%d sqlite close failed (%d).", __FUNCTION__, __LINE__, result);
            }
        }
    } while (retry);
    _db = NULL;
    return YES;
}

- (BOOL)tysm__dbCheck {
    if (!_db) {
        if (tysm__dbOpenErrorCount < kMaxErrorRetryCount &&
            CACurrentMediaTime() - _dbLastOpenErrorTime > kMinRetryTimeInterval) {
            return [self tysm__dbOpen] && [self  tysm__dbInitialize];
        } else {
            return NO;
        }
    }
    return YES;
}

- (BOOL)tysm__dbInitialize {
    NSString *sql = @"pragma journal_mode = wal; pragma synchronous = normal; create table if not exists manifest (key text, filename text, size integer, inline_data blob, modification_time integer, last_access_time integer, extended_data blob, primary key(key)); create index if not exists last_access_time_idx on manifest(last_access_time);";
    return [self tysm__dbExecute:sql];
}

- (void)tysm__dbCheckpoint {
    if (![self tysm__dbCheck]) return;
    // Cause a checkpoint to occur, merge `sqlite-wal` file to `sqlite` file.
    sqlite3_wal_checkpoint(_db, NULL);
}

- (BOOL)tysm__dbExecute:(NSString *)sql {
    if (sql.length == 0) return NO;
    if (![self tysm__dbCheck]) return NO;
    
    char *error = NULL;
    int result = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &error);
    if (error) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite exec error (%d): %s", __FUNCTION__, __LINE__, result, error);
        sqlite3_free(error);
    }
    
    return result == SQLITE_OK;
}

- (sqlite3_stmt *)tysm__dbPrepareStmt:(NSString *)sql {
    if (![self tysm__dbCheck] || sql.length == 0 || !_dbStmtCache) return NULL;
    sqlite3_stmt *stmt = (sqlite3_stmt *)CFDictionaryGetValue(_dbStmtCache, (__bridge const void *)(sql));
    if (!stmt) {
        int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
        if (result != SQLITE_OK) {
            if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite stmt prepare error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            return NULL;
        }
        CFDictionarySetValue(_dbStmtCache, (__bridge const void *)(sql), stmt);
    } else {
        sqlite3_reset(stmt);
    }
    return stmt;
}

- (NSString *)tysm__dbJoinedKeys:(NSArray *)keys {
    NSMutableString *string = [NSMutableString new];
    for (NSUInteger i = 0,max = keys.count; i < max; i++) {
        [string appendString:@"?"];
        if (i + 1 != max) {
            [string appendString:@","];
        }
    }
    return string;
}

- (void)tysm__dbBindJoinedKeys:(NSArray *)keys stmt:(sqlite3_stmt *)stmt fromIndex:(int)index{
    for (int i = 0, max = (int)keys.count; i < max; i++) {
        NSString *key = keys[i];
        sqlite3_bind_text(stmt, index + i, key.UTF8String, -1, NULL);
    }
}

- (BOOL)tysm__dbSaveWithKey:(NSString *)key value:(NSData *)value fileName:(NSString *)fileName extendedData:(NSData *)extendedData {
    NSString *sql = @"insert or replace into manifest (key, filename, size, inline_data, modification_time, last_access_time, extended_data) values (?1, ?2, ?3, ?4, ?5, ?6, ?7);";
    sqlite3_stmt *stmt = [self tysm__dbPrepareStmt:sql];
    if (!stmt) return NO;
    
    int timestamp = (int)time(NULL);
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    sqlite3_bind_text(stmt, 2, fileName.UTF8String, -1, NULL);
    sqlite3_bind_int(stmt, 3, (int)value.length);
    if (fileName.length == 0) {
        sqlite3_bind_blob(stmt, 4, value.bytes, (int)value.length, 0);
    } else {
        sqlite3_bind_blob(stmt, 4, NULL, 0, 0);
    }
    sqlite3_bind_int(stmt, 5, timestamp);
    sqlite3_bind_int(stmt, 6, timestamp);
    sqlite3_bind_blob(stmt, 7, extendedData.bytes, (int)extendedData.length, 0);
    
    int result = sqlite3_step(stmt);
    if (result != SQLITE_DONE) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite insert error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    return YES;
}

- (BOOL)tysm__dbUpdateAccessTimeWithKey:(NSString *)key {
    NSString *sql = @"update manifest set last_access_time = ?1 where key = ?2;";
    sqlite3_stmt *stmt = [self tysm__dbPrepareStmt:sql];
    if (!stmt) return NO;
    sqlite3_bind_int(stmt, 1, (int)time(NULL));
    sqlite3_bind_text(stmt, 2, key.UTF8String, -1, NULL);
    int result = sqlite3_step(stmt);
    if (result != SQLITE_DONE) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite update error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    return YES;
}

- (BOOL)tysm__dbUpdateAccessTimeWithKeys:(NSArray *)keys {
    if (![self tysm__dbCheck]) return NO;
    int t = (int)time(NULL);
     NSString *sql = [NSString stringWithFormat:@"update manifest set last_access_time = %d where key in (%@);", t, [self tysm__dbJoinedKeys:keys]];
    
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        if (_errorLogsEnabled)  NSLog(@"%s line:%d sqlite stmt prepare error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    
    [self tysm__dbBindJoinedKeys:keys stmt:stmt fromIndex:1];
    result = sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    if (result != SQLITE_DONE) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite update error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    return YES;
}

- (BOOL)tysm__dbDeleteItemWithKey:(NSString *)key {
    NSString *sql = @"delete from manifest where key = ?1;";
    sqlite3_stmt *stmt = [self tysm__dbPrepareStmt:sql];
    if (!stmt) return NO;
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    
    int result = sqlite3_step(stmt);
    if (result != SQLITE_DONE) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d db delete error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    return YES;
}

- (BOOL)tysm__dbDeleteItemWithKeys:(NSArray *)keys {
    if (![self tysm__dbCheck]) return NO;
    NSString *sql =  [NSString stringWithFormat:@"delete from manifest where key in (%@);", [self tysm__dbJoinedKeys:keys]];
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite stmt prepare error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    
    [self tysm__dbBindJoinedKeys:keys stmt:stmt fromIndex:1];
    result = sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    if (result == SQLITE_ERROR) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite delete error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    return YES;
}

- (BOOL)tysm__dbDeleteItemsWithSizeLargerThan:(int)size {
    NSString *sql = @"delete from manifest where size > ?1;";
    sqlite3_stmt *stmt = [self tysm__dbPrepareStmt:sql];
    if (!stmt) return NO;
    sqlite3_bind_int(stmt, 1, size);
    int result = sqlite3_step(stmt);
    if (result != SQLITE_DONE) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite delete error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    return YES;
}

- (BOOL)tysm__dbDeleteItemsWithTimeEarlierThan:(int)time {
    NSString *sql = @"delete from manifest where last_access_time < ?1;";
    sqlite3_stmt *stmt = [self tysm__dbPrepareStmt:sql];
    if (!stmt) return NO;
    sqlite3_bind_int(stmt, 1, time);
    int result = sqlite3_step(stmt);
    if (result != SQLITE_DONE) {
        if (_errorLogsEnabled)  NSLog(@"%s line:%d sqlite delete error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    return YES;
}

- (TYSMKVStorageItem *)tysm__dbGetItemFromStmt:(sqlite3_stmt *)stmt excludeInlineData:(BOOL)excludeInlineData {
    int i = 0;
    char *key = (char *)sqlite3_column_text(stmt, i++);
    char *filename = (char *)sqlite3_column_text(stmt, i++);
    int size = sqlite3_column_int(stmt, i++);
    const void *inline_data = excludeInlineData ? NULL : sqlite3_column_blob(stmt, i);
    int inline_data_bytes = excludeInlineData ? 0 : sqlite3_column_bytes(stmt, i++);
    int modification_time = sqlite3_column_int(stmt, i++);
    int last_access_time = sqlite3_column_int(stmt, i++);
    const void *extended_data = sqlite3_column_blob(stmt, i);
    int extended_data_bytes = sqlite3_column_bytes(stmt, i++);
    
    TYSMKVStorageItem *item = [TYSMKVStorageItem new];
    if (key) item.key = [NSString stringWithUTF8String:key];
    if (filename && *filename != 0) item.filename = [NSString stringWithUTF8String:filename];
    item.size = size;
    if (inline_data_bytes > 0 && inline_data) item.value = [NSData dataWithBytes:inline_data length:inline_data_bytes];
    item.modTime = modification_time;
    item.accessTime = last_access_time;
    if (extended_data_bytes > 0 && extended_data) item.extendedData = [NSData dataWithBytes:extended_data length:extended_data_bytes];
    return item;
}

- (TYSMKVStorageItem *)tysm__dbGetItemWithKey:(NSString *)key excludeInlineData:(BOOL)excludeInlineData {
    NSString *sql = excludeInlineData ? @"select key, filename, size, modification_time, last_access_time, extended_data from manifest where key = ?1;" : @"select key, filename, size, inline_data, modification_time, last_access_time, extended_data from manifest where key = ?1;";
    sqlite3_stmt *stmt = [self tysm__dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    
    TYSMKVStorageItem *item = nil;
    int result = sqlite3_step(stmt);
    if (result == SQLITE_ROW) {
        item = [self  tysm__dbGetItemFromStmt:stmt excludeInlineData:excludeInlineData];
    } else {
        if (result != SQLITE_DONE) {
            if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        }
    }
    return item;
}

- (NSMutableArray *)tysm__dbGetItemWithKeys:(NSArray *)keys excludeInlineData:(BOOL)excludeInlineData {
    if (![self tysm__dbCheck]) return nil;
    NSString *sql;
    if (excludeInlineData) {
        sql = [NSString stringWithFormat:@"select key, filename, size, modification_time, last_access_time, extended_data from manifest where key in (%@);", [self tysm__dbJoinedKeys:keys]];
    } else {
        sql = [NSString stringWithFormat:@"select key, filename, size, inline_data, modification_time, last_access_time, extended_data from manifest where key in (%@)", [self tysm__dbJoinedKeys:keys]];
    }
    
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite stmt prepare error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return nil;
    }
    
    [self tysm__dbBindJoinedKeys:keys stmt:stmt fromIndex:1];
    NSMutableArray *items = [NSMutableArray new];
    do {
        result = sqlite3_step(stmt);
        if (result == SQLITE_ROW) {
            TYSMKVStorageItem *item = [self  tysm__dbGetItemFromStmt:stmt excludeInlineData:excludeInlineData];
            if (item) [items addObject:item];
        } else if (result == SQLITE_DONE) {
            break;
        } else {
            if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            items = nil;
            break;
        }
    } while (1);
    sqlite3_finalize(stmt);
    return items;
}

- (NSData *)tysm__dbGetValueWithKey:(NSString *)key {
    NSString *sql = @"select inline_data from manifest where key = ?1;";
    sqlite3_stmt *stmt = [self tysm__dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    
    int result = sqlite3_step(stmt);
    if (result == SQLITE_ROW) {
        const void *inline_data = sqlite3_column_blob(stmt, 0);
        int inline_data_bytes = sqlite3_column_bytes(stmt, 0);
        if (!inline_data || inline_data_bytes <= 0) return nil;
        return [NSData dataWithBytes:inline_data length:inline_data_bytes];
    } else {
        if (result != SQLITE_DONE) {
            if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        }
        return nil;
    }
}

- (NSString *)tysm__dbGetFilenameWithKey:(NSString *)key {
    NSString *sql = @"select filename from manifest where key = ?1;";
    sqlite3_stmt *stmt = [self tysm__dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    int result = sqlite3_step(stmt);
    if (result == SQLITE_ROW) {
        char *filename = (char *)sqlite3_column_text(stmt, 0);
        if (filename && *filename != 0) {
            return [NSString stringWithUTF8String:filename];
        }
    } else {
        if (result != SQLITE_DONE) {
            if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        }
    }
    return nil;
}

- (NSMutableArray *)tysm__dbGetFilenameWithKeys:(NSArray *)keys {
    if (![self tysm__dbCheck]) return nil;
    NSString *sql = [NSString stringWithFormat:@"select filename from manifest where key in (%@);", [self tysm__dbJoinedKeys:keys]];
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite stmt prepare error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return nil;
    }
    
    [self tysm__dbBindJoinedKeys:keys stmt:stmt fromIndex:1];
    NSMutableArray *filenames = [NSMutableArray new];
    do {
        result = sqlite3_step(stmt);
        if (result == SQLITE_ROW) {
            char *filename = (char *)sqlite3_column_text(stmt, 0);
            if (filename && *filename != 0) {
                NSString *name = [NSString stringWithUTF8String:filename];
                if (name) [filenames addObject:name];
            }
        } else if (result == SQLITE_DONE) {
            break;
        } else {
            if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            filenames = nil;
            break;
        }
    } while (1);
    sqlite3_finalize(stmt);
    return filenames;
}

- (NSMutableArray *)tysm__dbGetFilenamesWithSizeLargerThan:(int)size {
    NSString *sql = @"select filename from manifest where size > ?1 and filename is not null;";
    sqlite3_stmt *stmt = [self tysm__dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_int(stmt, 1, size);
    
    NSMutableArray *filenames = [NSMutableArray new];
    do {
        int result = sqlite3_step(stmt);
        if (result == SQLITE_ROW) {
            char *filename = (char *)sqlite3_column_text(stmt, 0);
            if (filename && *filename != 0) {
                NSString *name = [NSString stringWithUTF8String:filename];
                if (name) [filenames addObject:name];
            }
        } else if (result == SQLITE_DONE) {
            break;
        } else {
            if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            filenames = nil;
            break;
        }
    } while (1);
    return filenames;
}

- (NSMutableArray *)tysm__dbGetFilenamesWithTimeEarlierThan:(int)time {
    NSString *sql = @"select filename from manifest where last_access_time < ?1 and filename is not null;";
    sqlite3_stmt *stmt = [self tysm__dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_int(stmt, 1, time);
    
    NSMutableArray *filenames = [NSMutableArray new];
    do {
        int result = sqlite3_step(stmt);
        if (result == SQLITE_ROW) {
            char *filename = (char *)sqlite3_column_text(stmt, 0);
            if (filename && *filename != 0) {
                NSString *name = [NSString stringWithUTF8String:filename];
                if (name) [filenames addObject:name];
            }
        } else if (result == SQLITE_DONE) {
            break;
        } else {
            if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            filenames = nil;
            break;
        }
    } while (1);
    return filenames;
}

- (NSMutableArray *)tysm__dbGetItemSizeInfoOrderByTimeAscWithLimit:(int)count {
    NSString *sql = @"select key, filename, size from manifest order by last_access_time asc limit ?1;";
    sqlite3_stmt *stmt = [self tysm__dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_int(stmt, 1, count);
    
    NSMutableArray *items = [NSMutableArray new];
    do {
        int result = sqlite3_step(stmt);
        if (result == SQLITE_ROW) {
            char *key = (char *)sqlite3_column_text(stmt, 0);
            char *filename = (char *)sqlite3_column_text(stmt, 1);
            int size = sqlite3_column_int(stmt, 2);
            NSString *keyStr = key ? [NSString stringWithUTF8String:key] : nil;
            if (keyStr) {
                TYSMKVStorageItem *item = [TYSMKVStorageItem new];
                item.key = key ? [NSString stringWithUTF8String:key] : nil;
                item.filename = filename ? [NSString stringWithUTF8String:filename] : nil;
                item.size = size;
                [items addObject:item];
            }
        } else if (result == SQLITE_DONE) {
            break;
        } else {
            if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            items = nil;
            break;
        }
    } while (1);
    return items;
}

- (int)tysm__dbGetItemCountWithKey:(NSString *)key {
    NSString *sql = @"select count(key) from manifest where key = ?1;";
    sqlite3_stmt *stmt = [self tysm__dbPrepareStmt:sql];
    if (!stmt) return -1;
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    int result = sqlite3_step(stmt);
    if (result != SQLITE_ROW) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return -1;
    }
    return sqlite3_column_int(stmt, 0);
}

- (int)tysm__dbGetTotalItemSize {
    NSString *sql = @"select sum(size) from manifest;";
    sqlite3_stmt *stmt = [self tysm__dbPrepareStmt:sql];
    if (!stmt) return -1;
    int result = sqlite3_step(stmt);
    if (result != SQLITE_ROW) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return -1;
    }
    return sqlite3_column_int(stmt, 0);
}

- (int)tysm__dbGetTotalItemCount {
    NSString *sql = @"select count(*) from manifest;";
    sqlite3_stmt *stmt = [self tysm__dbPrepareStmt:sql];
    if (!stmt) return -1;
    int result = sqlite3_step(stmt);
    if (result != SQLITE_ROW) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return -1;
    }
    return sqlite3_column_int(stmt, 0);
}


#pragma mark - file

- (BOOL)tysm__fileWriteWithName:(NSString *)filename data:(NSData *)data {
    NSString *path = [_dataPath stringByAppendingPathComponent:filename];
    return [data writeToFile:path atomically:NO];
}

- (NSData *)tysm__fileReadWithName:(NSString *)filename {
    NSString *path = [_dataPath stringByAppendingPathComponent:filename];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return data;
}

- (BOOL)tysm__fileDeleteWithName:(NSString *)filename {
    NSString *path = [_dataPath stringByAppendingPathComponent:filename];
    return [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

- (BOOL)tysm__fileMoveAllToTrash {
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuid = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    NSString *tmpPath = [_trashPath stringByAppendingPathComponent:(__bridge NSString *)(uuid)];
    BOOL suc = [[NSFileManager defaultManager] moveItemAtPath:_dataPath toPath:tmpPath error:nil];
    if (suc) {
        suc = [[NSFileManager defaultManager] createDirectoryAtPath:_dataPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    CFRelease(uuid);
    return suc;
}

- (void)tysm__fileEmptyTrashInBackground {
    NSString *trashPath = _trashPath;
    dispatch_queue_t queue = _trashQueue;
    dispatch_async(queue, ^{
        NSFileManager *manager = [NSFileManager new];
        NSArray *directoryContents = [manager contentsOfDirectoryAtPath:trashPath error:NULL];
        for (NSString *path in directoryContents) {
            NSString *fullPath = [trashPath stringByAppendingPathComponent:path];
            [manager removeItemAtPath:fullPath error:NULL];
        }
    });
}


#pragma mark - private

/**
 Delete all files and empty in background.
 Make sure the db is closed.
 */
- (void)tysm__reset {
    [[NSFileManager defaultManager] removeItemAtPath:[_path stringByAppendingPathComponent:kDBFileName] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[_path stringByAppendingPathComponent:kDBShmFileName] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[_path stringByAppendingPathComponent:kDBWalFileName] error:nil];
    [self tysm__fileMoveAllToTrash];
    [self tysm__fileEmptyTrashInBackground];
}

#pragma mark - public

- (instancetype)init {
    @throw [NSException exceptionWithName:@"TYSMKVStorage init error" reason:@"Please use the designated initializer and pass the 'path' and 'type'." userInfo:nil];
    return [self initWithPath:@"" type:TYSMKVStorageTypeFile];
}

- (instancetype)initWithPath:(NSString *)path type:(TYSMKVStorageType)type {
    if (path.length == 0 || path.length > kPathLengthMax) {
        NSLog(@"TYSMKVStorage init error: invalid path: [%@].", path);
        return nil;
    }
    if (type > TYSMKVStorageTypeMixed) {
        NSLog(@"TYSMKVStorage init error: invalid type: %lu.", (unsigned long)type);
        return nil;
    }
    
    self = [super init];
    _path = path.copy;
    _type = type;
    _dataPath = [path stringByAppendingPathComponent:kDataDirectoryName];
    _trashPath = [path stringByAppendingPathComponent:kTrashDirectoryName];
    _trashQueue = dispatch_queue_create("com.ibireme.cache.disk.trash", DISPATCH_QUEUE_SERIAL);
    _dbPath = [path stringByAppendingPathComponent:kDBFileName];
    _errorLogsEnabled = YES;
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error] ||
        ![[NSFileManager defaultManager] createDirectoryAtPath:[path stringByAppendingPathComponent:kDataDirectoryName]
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error] ||
        ![[NSFileManager defaultManager] createDirectoryAtPath:[path stringByAppendingPathComponent:kTrashDirectoryName]
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error]) {
        NSLog(@"TYSMKVStorage init error:%@", error);
        return nil;
    }
    
    if (![self tysm__dbOpen] || ![self  tysm__dbInitialize]) {
        // db file may broken...
        [self tysm__dbClose];
        [self  tysm__reset]; // rebuild
        if (![self tysm__dbOpen] || ![self  tysm__dbInitialize]) {
            [self tysm__dbClose];
            NSLog(@"TYSMKVStorage init error: fail to open sqlite db.");
            return nil;
        }
    }
    [self tysm__fileEmptyTrashInBackground]; // empty the trash if failed at last time
    return self;
}

- (void)dealloc {
    UIBackgroundTaskIdentifier taskID = [[UIApplication tysm_sharedExtensionApplication] beginBackgroundTaskWithExpirationHandler:^{}];
    [self tysm__dbClose];
    if (taskID != UIBackgroundTaskInvalid) {
        [[UIApplication tysm_sharedExtensionApplication] endBackgroundTask:taskID];
    }
}

- (BOOL)tysm_saveItem:(TYSMKVStorageItem *)item {
    return [self tysm_saveItemWithKey:item.key value:item.value filename:item.filename extendedData:item.extendedData];
}

- (BOOL)tysm_saveItemWithKey:(NSString *)key value:(NSData *)value {
    return [self tysm_saveItemWithKey:key value:value filename:nil extendedData:nil];
}

- (BOOL)tysm_saveItemWithKey:(NSString *)key value:(NSData *)value filename:(NSString *)filename extendedData:(NSData *)extendedData {
    if (key.length == 0 || value.length == 0) return NO;
    if (_type == TYSMKVStorageTypeFile && filename.length == 0) {
        return NO;
    }
    
    if (filename.length) {
        if (![self tysm__fileWriteWithName:filename data:value]) {
            return NO;
        }
        if (![self tysm__dbSaveWithKey:key value:value fileName:filename extendedData:extendedData]) {
            [self tysm__fileDeleteWithName:filename];
            return NO;
        }
        return YES;
    } else {
        if (_type != TYSMKVStorageTypeSQLite) {
            NSString *filename = [self tysm__dbGetFilenameWithKey:key];
            if (filename) {
                [self tysm__fileDeleteWithName:filename];
            }
        }
        return [self tysm__dbSaveWithKey:key value:value fileName:nil extendedData:extendedData];
    }
}

- (BOOL)tysm_removeItemForKey:(NSString *)key {
    if (key.length == 0) return NO;
    switch (_type) {
        case TYSMKVStorageTypeSQLite: {
            return [self tysm__dbDeleteItemWithKey:key];
        } break;
        case TYSMKVStorageTypeFile:
        case TYSMKVStorageTypeMixed: {
            NSString *filename = [self tysm__dbGetFilenameWithKey:key];
            if (filename) {
                [self tysm__fileDeleteWithName:filename];
            }
            return [self tysm__dbDeleteItemWithKey:key];
        } break;
        default: return NO;
    }
}

- (BOOL)tysm_removeItemForKeys:(NSArray *)keys {
    if (keys.count == 0) return NO;
    switch (_type) {
        case TYSMKVStorageTypeSQLite: {
            return [self  tysm__dbDeleteItemWithKeys:keys];
        } break;
        case TYSMKVStorageTypeFile:
        case TYSMKVStorageTypeMixed: {
            NSArray *filenames = [self tysm__dbGetFilenameWithKeys:keys];
            for (NSString *filename in filenames) {
                [self tysm__fileDeleteWithName:filename];
            }
            return [self  tysm__dbDeleteItemWithKeys:keys];
        } break;
        default: return NO;
    }
}

- (BOOL)tysm_removeItemsLargerThanSize:(int)size {
    if (size == INT_MAX) return YES;
    if (size <= 0) return [self tysm_removeAllItems];
    
    switch (_type) {
        case TYSMKVStorageTypeSQLite: {
            if ([self tysm__dbDeleteItemsWithSizeLargerThan:size]) {
                [self tysm__dbCheckpoint];
                return YES;
            }
        } break;
        case TYSMKVStorageTypeFile:
        case TYSMKVStorageTypeMixed: {
            NSArray *filenames = [self tysm__dbGetFilenamesWithSizeLargerThan:size];
            for (NSString *name in filenames) {
                [self tysm__fileDeleteWithName:name];
            }
            if ([self tysm__dbDeleteItemsWithSizeLargerThan:size]) {
                [self tysm__dbCheckpoint];
                return YES;
            }
        } break;
    }
    return NO;
}

- (BOOL)tysm_removeItemsEarlierThanTime:(int)time {
    if (time <= 0) return YES;
    if (time == INT_MAX) return [self tysm_removeAllItems];
    
    switch (_type) {
        case TYSMKVStorageTypeSQLite: {
            if ([self tysm__dbDeleteItemsWithTimeEarlierThan:time]) {
                [self tysm__dbCheckpoint];
                return YES;
            }
        } break;
        case TYSMKVStorageTypeFile:
        case TYSMKVStorageTypeMixed: {
            NSArray *filenames = [self tysm__dbGetFilenamesWithTimeEarlierThan:time];
            for (NSString *name in filenames) {
                [self tysm__fileDeleteWithName:name];
            }
            if ([self tysm__dbDeleteItemsWithTimeEarlierThan:time]) {
                [self tysm__dbCheckpoint];
                return YES;
            }
        } break;
    }
    return NO;
}

- (BOOL)tysm_removeItemsToFitSize:(int)maxSize {
    if (maxSize == INT_MAX) return YES;
    if (maxSize <= 0) return [self tysm_removeAllItems];
    
    int total = [self tysm__dbGetTotalItemSize];
    if (total < 0) return NO;
    if (total <= maxSize) return YES;
    
    NSArray *items = nil;
    BOOL suc = NO;
    do {
        int perCount = 16;
        items = [self tysm__dbGetItemSizeInfoOrderByTimeAscWithLimit:perCount];
        for (TYSMKVStorageItem *item in items) {
            if (total > maxSize) {
                if (item.filename) {
                    [self tysm__fileDeleteWithName:item.filename];
                }
                suc = [self tysm__dbDeleteItemWithKey:item.key];
                total -= item.size;
            } else {
                break;
            }
            if (!suc) break;
        }
    } while (total > maxSize && items.count > 0 && suc);
    if (suc) [self tysm__dbCheckpoint];
    return suc;
}

- (BOOL)tysm_removeItemsToFitCount:(int)maxCount {
    if (maxCount == INT_MAX) return YES;
    if (maxCount <= 0) return [self tysm_removeAllItems];
    
    int total = [self tysm__dbGetTotalItemCount];
    if (total < 0) return NO;
    if (total <= maxCount) return YES;
    
    NSArray *items = nil;
    BOOL suc = NO;
    do {
        int perCount = 16;
        items = [self tysm__dbGetItemSizeInfoOrderByTimeAscWithLimit:perCount];
        for (TYSMKVStorageItem *item in items) {
            if (total > maxCount) {
                if (item.filename) {
                    [self tysm__fileDeleteWithName:item.filename];
                }
                suc = [self tysm__dbDeleteItemWithKey:item.key];
                total--;
            } else {
                break;
            }
            if (!suc) break;
        }
    } while (total > maxCount && items.count > 0 && suc);
    if (suc) [self tysm__dbCheckpoint];
    return suc;
}

- (BOOL)tysm_removeAllItems {
    if (![self tysm__dbClose]) return NO;
    [self  tysm__reset];
    if (![self tysm__dbOpen]) return NO;
    if (![self  tysm__dbInitialize]) return NO;
    return YES;
}

- (void)tysm_removeAllItemsWithProgressBlock:(void(^)(int removedCount, int totalCount))progress
                               endBlock:(void(^)(BOOL error))end {
    
    int total = [self tysm__dbGetTotalItemCount];
    if (total <= 0) {
        if (end) end(total < 0);
    } else {
        int left = total;
        int perCount = 32;
        NSArray *items = nil;
        BOOL suc = NO;
        do {
            items = [self tysm__dbGetItemSizeInfoOrderByTimeAscWithLimit:perCount];
            for (TYSMKVStorageItem *item in items) {
                if (left > 0) {
                    if (item.filename) {
                        [self tysm__fileDeleteWithName:item.filename];
                    }
                    suc = [self tysm__dbDeleteItemWithKey:item.key];
                    left--;
                } else {
                    break;
                }
                if (!suc) break;
            }
            if (progress) progress(total - left, total);
        } while (left > 0 && items.count > 0 && suc);
        if (suc) [self tysm__dbCheckpoint];
        if (end) end(!suc);
    }
}

- (TYSMKVStorageItem *)tysm_getItemForKey:(NSString *)key {
    if (key.length == 0) return nil;
    TYSMKVStorageItem *item = [self tysm__dbGetItemWithKey:key excludeInlineData:NO];
    if (item) {
        [self tysm__dbUpdateAccessTimeWithKey:key];
        if (item.filename) {
            item.value = [self tysm__fileReadWithName:item.filename];
            if (!item.value) {
                [self tysm__dbDeleteItemWithKey:key];
                item = nil;
            }
        }
    }
    return item;
}

- (TYSMKVStorageItem *)tysm_getItemInfoForKey:(NSString *)key {
    if (key.length == 0) return nil;
    TYSMKVStorageItem *item = [self tysm__dbGetItemWithKey:key excludeInlineData:YES];
    return item;
}

- (NSData *)tysm_getItemValueForKey:(NSString *)key {
    if (key.length == 0) return nil;
    NSData *value = nil;
    switch (_type) {
        case TYSMKVStorageTypeFile: {
            NSString *filename = [self tysm__dbGetFilenameWithKey:key];
            if (filename) {
                value = [self tysm__fileReadWithName:filename];
                if (!value) {
                    [self tysm__dbDeleteItemWithKey:key];
                    value = nil;
                }
            }
        } break;
        case TYSMKVStorageTypeSQLite: {
            value = [self tysm__dbGetValueWithKey:key];
        } break;
        case TYSMKVStorageTypeMixed: {
            NSString *filename = [self tysm__dbGetFilenameWithKey:key];
            if (filename) {
                value = [self tysm__fileReadWithName:filename];
                if (!value) {
                    [self tysm__dbDeleteItemWithKey:key];
                    value = nil;
                }
            } else {
                value = [self tysm__dbGetValueWithKey:key];
            }
        } break;
    }
    if (value) {
        [self tysm__dbUpdateAccessTimeWithKey:key];
    }
    return value;
}

- (NSArray *)tysm_getItemForKeys:(NSArray *)keys {
    if (keys.count == 0) return nil;
    NSMutableArray *items = [self tysm__dbGetItemWithKeys:keys excludeInlineData:NO];
    if (_type != TYSMKVStorageTypeSQLite) {
        for (NSInteger i = 0, max = items.count; i < max; i++) {
            TYSMKVStorageItem *item = items[i];
            if (item.filename) {
                item.value = [self tysm__fileReadWithName:item.filename];
                if (!item.value) {
                    if (item.key) [self tysm__dbDeleteItemWithKey:item.key];
                    [items removeObjectAtIndex:i];
                    i--;
                    max--;
                }
            }
        }
    }
    if (items.count > 0) {
        [self tysm__dbUpdateAccessTimeWithKeys:keys];
    }
    return items.count ? items : nil;
}

- (NSArray *)tysm_getItemInfoForKeys:(NSArray *)keys {
    if (keys.count == 0) return nil;
    return [self tysm__dbGetItemWithKeys:keys excludeInlineData:YES];
}

- (NSDictionary *)tysm_getItemValueForKeys:(NSArray *)keys {
    NSMutableArray *items = (NSMutableArray *)[self tysm_getItemForKeys:keys];
    NSMutableDictionary *kv = [NSMutableDictionary new];
    for (TYSMKVStorageItem *item in items) {
        if (item.key && item.value) {
            [kv setObject:item.value forKey:item.key];
        }
    }
    return kv.count ? kv : nil;
}

- (BOOL)tysm_itemExistsForKey:(NSString *)key {
    if (key.length == 0) return NO;
    return [self tysm__dbGetItemCountWithKey:key] > 0;
}

- (int)tysm_getItemsCount {
    return [self tysm__dbGetTotalItemCount];
}

- (int)tysm_getItemsSize {
    return [self tysm__dbGetTotalItemSize];
}

@end
