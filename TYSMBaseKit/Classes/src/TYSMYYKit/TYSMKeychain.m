//
//  TYSMKeychain.m
//  TYSMKit <https://github.com/ibireme/TYSMKit>
//
//  Created by ibireme on 14/10/15.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "TYSMKeychain.h"
#import "UIDevice+TYSMAdd.h"
#import "TYSMKitMacro.h"
#import <Security/Security.h>


static TYSMKeychainErrorCode TYSMKeychainErrorCodeFromOSStatus(OSStatus status) {
    switch (status) {
        case errSecUnimplemented: return TYSMKeychainErrorUnimplemented;
        case errSecIO: return TYSMKeychainErrorIO;
        case errSecOpWr: return TYSMKeychainErrorOpWr;
        case errSecParam: return TYSMKeychainErrorParam;
        case errSecAllocate: return TYSMKeychainErrorAllocate;
        case errSecUserCanceled: return TYSMKeychainErrorUserCancelled;
        case errSecBadReq: return TYSMKeychainErrorBadReq;
        case errSecInternalComponent: return TYSMKeychainErrorInternalComponent;
        case errSecNotAvailable: return TYSMKeychainErrorNotAvailable;
        case errSecDuplicateItem: return TYSMKeychainErrorDuplicateItem;
        case errSecItemNotFound: return TYSMKeychainErrorItemNotFound;
        case errSecInteractionNotAllowed: return TYSMKeychainErrorInteractionNotAllowed;
        case errSecDecode: return TYSMKeychainErrorDecode;
        case errSecAuthFailed: return TYSMKeychainErrorAuthFailed;
        default: return 0;
    }
}

static NSString *TYSMKeychainErrorDesc(TYSMKeychainErrorCode code) {
    switch (code) {
        case TYSMKeychainErrorUnimplemented:
            return @"Function or operation not implemented.";
        case TYSMKeychainErrorIO:
            return @"I/O error (bummers)";
        case TYSMKeychainErrorOpWr:
            return @"ile already open with with write permission.";
        case TYSMKeychainErrorParam:
            return @"One or more parameters passed to a function where not valid.";
        case TYSMKeychainErrorAllocate:
            return @"Failed to allocate memory.";
        case TYSMKeychainErrorUserCancelled:
            return @"User canceled the operation.";
        case TYSMKeychainErrorBadReq:
            return @"Bad parameter or invalid state for operation.";
        case TYSMKeychainErrorInternalComponent:
            return @"Inrernal Component";
        case TYSMKeychainErrorNotAvailable:
            return @"No keychain is available. You may need to restart your computer.";
        case TYSMKeychainErrorDuplicateItem:
            return @"The specified item already exists in the keychain.";
        case TYSMKeychainErrorItemNotFound:
            return @"The specified item could not be found in the keychain.";
        case TYSMKeychainErrorInteractionNotAllowed:
            return @"User interaction is not allowed.";
        case TYSMKeychainErrorDecode:
            return @"Unable to decode the provided data.";
        case TYSMKeychainErrorAuthFailed:
            return @"The user name or passphrase you entered is not";
        default:
            break;
    }
    return nil;
}

static NSString *TYSMKeychainAccessibleStr(TYSMKeychainAccessible e) {
    switch (e) {
        case TYSMKeychainAccessibleWhenUnlocked:
            return (__bridge NSString *)(kSecAttrAccessibleWhenUnlocked);
        case TYSMKeychainAccessibleAfterFirstUnlock:
            return (__bridge NSString *)(kSecAttrAccessibleAfterFirstUnlock);
        case TYSMKeychainAccessibleAlways:
            return (__bridge NSString *)(kSecAttrAccessibleAlways);
        case TYSMKeychainAccessibleWhenPasscodeSetThisDeviceOnly:
            return (__bridge NSString *)(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly);
        case TYSMKeychainAccessibleWhenUnlockedThisDeviceOnly:
            return (__bridge NSString *)(kSecAttrAccessibleWhenUnlockedThisDeviceOnly);
        case TYSMKeychainAccessibleAfterFirstUnlockThisDeviceOnly:
            return (__bridge NSString *)(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly);
        case TYSMKeychainAccessibleAlwaysThisDeviceOnly:
            return (__bridge NSString *)(kSecAttrAccessibleAlwaysThisDeviceOnly);
        default:
            return nil;
    }
}

static TYSMKeychainAccessible TYSMKeychainAccessibleEnum(NSString *s) {
    if ([s isEqualToString:(__bridge NSString *)kSecAttrAccessibleWhenUnlocked])
        return TYSMKeychainAccessibleWhenUnlocked;
    if ([s isEqualToString:(__bridge NSString *)kSecAttrAccessibleAfterFirstUnlock])
        return TYSMKeychainAccessibleAfterFirstUnlock;
    if ([s isEqualToString:(__bridge NSString *)kSecAttrAccessibleAlways])
        return TYSMKeychainAccessibleAlways;
    if ([s isEqualToString:(__bridge NSString *)kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly])
        return TYSMKeychainAccessibleWhenPasscodeSetThisDeviceOnly;
    if ([s isEqualToString:(__bridge NSString *)kSecAttrAccessibleWhenUnlockedThisDeviceOnly])
        return TYSMKeychainAccessibleWhenUnlockedThisDeviceOnly;
    if ([s isEqualToString:(__bridge NSString *)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly])
        return TYSMKeychainAccessibleAfterFirstUnlockThisDeviceOnly;
    if ([s isEqualToString:(__bridge NSString *)kSecAttrAccessibleAlwaysThisDeviceOnly])
        return TYSMKeychainAccessibleAlwaysThisDeviceOnly;
    return TYSMKeychainAccessibleNone;
}

static id TYSMKeychainQuerySynchonizationID(TYSMKeychainQuerySynchronizationMode mode) {
    switch (mode) {
        case TYSMKeychainQuerySynchronizationModeAny:
            return (__bridge id)(kSecAttrSynchronizableAny);
        case TYSMKeychainQuerySynchronizationModeNo:
            return (__bridge id)kCFBooleanFalse;
        case TYSMKeychainQuerySynchronizationModeYes:
            return (__bridge id)kCFBooleanTrue;
        default:
            return (__bridge id)(kSecAttrSynchronizableAny);
    }
}

static TYSMKeychainQuerySynchronizationMode TYSMKeychainQuerySynchonizationEnum(NSNumber *num) {
    if ([num isEqualToNumber:@NO]) return TYSMKeychainQuerySynchronizationModeNo;
    if ([num isEqualToNumber:@YES]) return TYSMKeychainQuerySynchronizationModeYes;
    return TYSMKeychainQuerySynchronizationModeAny;
}

@interface TYSMKeychainItem ()
@property (nonatomic, readwrite, strong) NSDate *modificationDate;
@property (nonatomic, readwrite, strong) NSDate *creationDate;
@end

@implementation TYSMKeychainItem


- (void)tysm_setPasswordObject:(id <NSCoding> )object {
    self.passwordData = [NSKeyedArchiver archivedDataWithRootObject:object];
}

- (id <NSCoding> )tysm_passwordObject {
    if ([self.passwordData length]) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:self.passwordData];
    }
    return nil;
}

- (void)tysm_setPassword:(NSString *)password {
    self.passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)tysm_password {
    if ([self.passwordData length]) {
        return [[NSString alloc] initWithData:self.passwordData encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (NSMutableDictionary *)tysm_queryDic {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    dic[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    
    if (self.account) dic[(__bridge id)kSecAttrAccount] = self.account;
    if (self.service) dic[(__bridge id)kSecAttrService] = self.service;
    
    if (![UIDevice currentDevice].tysm_isSimulator) {
        // Remove the access group if running on the iPhone simulator.
        //
        // Apps that are built for the simulator aren't signed, so there's no keychain access group
        // for the simulator to check. This means that all apps can see all keychain items when run
        // on the simulator.
        //
        // If a SecItem contains an access group tysm_attribute, SecItemAdd and SecItemUpdate on the
        // simulator will return -25243 (errSecNoAccessForItem).
        //
        // The access group tysm_attribute will be included in items returned by SecItemCopyMatching,
        // which is why we need to remove it before updating the item.
        if (self.accessGroup) dic[(__bridge id)kSecAttrAccessGroup] = self.accessGroup;
    }
    
    if (kiOS7Later) {
        dic[(__bridge id)kSecAttrSynchronizable] = TYSMKeychainQuerySynchonizationID(self.synchronizable);
    }
    
    return dic;
}

- (NSMutableDictionary *)tysm_dic {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    dic[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    
    if (self.account) dic[(__bridge id)kSecAttrAccount] = self.account;
    if (self.service) dic[(__bridge id)kSecAttrService] = self.service;
    if (self.label) dic[(__bridge id)kSecAttrLabel] = self.label;
    
    if (![UIDevice currentDevice].tysm_isSimulator) {
        // Remove the access group if running on the iPhone simulator.
        //
        // Apps that are built for the simulator aren't signed, so there's no keychain access group
        // for the simulator to check. This means that all apps can see all keychain items when run
        // on the simulator.
        //
        // If a SecItem contains an access group tysm_attribute, SecItemAdd and SecItemUpdate on the
        // simulator will return -25243 (errSecNoAccessForItem).
        //
        // The access group tysm_attribute will be included in items returned by SecItemCopyMatching,
        // which is why we need to remove it before updating the item.
        if (self.accessGroup) dic[(__bridge id)kSecAttrAccessGroup] = self.accessGroup;
    }
    
    if (kiOS7Later) {
        dic[(__bridge id)kSecAttrSynchronizable] = TYSMKeychainQuerySynchonizationID(self.synchronizable);
    }
    
    if (self.accessible) dic[(__bridge id)kSecAttrAccessible] = TYSMKeychainAccessibleStr(self.accessible);
    if (self.passwordData) dic[(__bridge id)kSecValueData] = self.passwordData;
    if (self.type) dic[(__bridge id)kSecAttrType] = self.type;
    if (self.creater) dic[(__bridge id)kSecAttrCreator] = self.creater;
    if (self.comment) dic[(__bridge id)kSecAttrComment] = self.comment;
    if (self.descr) dic[(__bridge id)kSecAttrDescription] = self.descr;
    
    return dic;
}

- (instancetype)initWithDic:(NSDictionary *)dic {
    if (dic.count == 0) return nil;
    self = self.init;
    
    self.service = dic[(__bridge id)kSecAttrService];
    self.account = dic[(__bridge id)kSecAttrAccount];
    self.passwordData = dic[(__bridge id)kSecValueData];
    self.label = dic[(__bridge id)kSecAttrLabel];
    self.type = dic[(__bridge id)kSecAttrType];
    self.creater = dic[(__bridge id)kSecAttrCreator];
    self.comment = dic[(__bridge id)kSecAttrComment];
    self.descr = dic[(__bridge id)kSecAttrDescription];
    self.modificationDate = dic[(__bridge id)kSecAttrModificationDate];
    self.creationDate = dic[(__bridge id)kSecAttrCreationDate];
    self.accessGroup = dic[(__bridge id)kSecAttrAccessGroup];
    self.accessible = TYSMKeychainAccessibleEnum(dic[(__bridge id)kSecAttrAccessible]);
    self.synchronizable = TYSMKeychainQuerySynchonizationEnum(dic[(__bridge id)kSecAttrSynchronizable]);
    
    return self;
}

- (id)tysm_copyWithZone:(NSZone *)zone {
    TYSMKeychainItem *item = [TYSMKeychainItem new];
    item.service = self.service;
    item.account = self.account;
    item.passwordData = self.passwordData;
    item.label = self.label;
    item.type = self.type;
    item.creater = self.creater;
    item.comment = self.comment;
    item.descr = self.descr;
    item.modificationDate = self.modificationDate;
    item.creationDate = self.creationDate;
    item.accessGroup = self.accessGroup;
    item.accessible = self.accessible;
    item.synchronizable = self.synchronizable;
    return item;
}

- (NSString *)tysm_description {
    NSMutableString *str = @"".mutableCopy;
    [str appendString:@"TYSMKeychainItem:{\n"];
    if (self.service) [str appendFormat:@"  service:%@,\n", self.service];
    if (self.account) [str appendFormat:@"  service:%@,\n", self.account];
    if (self.password) [str appendFormat:@"  service:%@,\n", self.password];
    if (self.label) [str appendFormat:@"  service:%@,\n", self.label];
    if (self.type) [str appendFormat:@"  service:%@,\n", self.type];
    if (self.creater) [str appendFormat:@"  service:%@,\n", self.creater];
    if (self.comment) [str appendFormat:@"  service:%@,\n", self.comment];
    if (self.descr) [str appendFormat:@"  service:%@,\n", self.descr];
    if (self.modificationDate) [str appendFormat:@"  service:%@,\n", self.modificationDate];
    if (self.creationDate) [str appendFormat:@"  service:%@,\n", self.creationDate];
    if (self.accessGroup) [str appendFormat:@"  service:%@,\n", self.accessGroup];
    [str appendString:@"}"];
    return str;
}

@end



@implementation TYSMKeychain

+ (NSString *)getPasswordForService:(NSString *)serviceName
                            account:(NSString *)account
                              error:(NSError **)error {
    if (!serviceName || !account) {
        if (error) *error = [TYSMKeychain errorWithCode:errSecParam];
        return nil;
    }
    
    TYSMKeychainItem *item = [TYSMKeychainItem new];
    item.service = serviceName;
    item.account = account;
    TYSMKeychainItem *result = [self selectOneItem:item error:error];
    return result.password;
}

+ (nullable NSString *)getPasswordForService:(NSString *)serviceName
                                     account:(NSString *)account {
    return [self getPasswordForService:serviceName account:account error:NULL];
}

+ (BOOL)deletePasswordForService:(NSString *)serviceName
                         account:(NSString *)account
                           error:(NSError **)error {
    if (!serviceName || !account) {
        if (error) *error = [TYSMKeychain errorWithCode:errSecParam];
        return NO;
    }
    
    TYSMKeychainItem *item = [TYSMKeychainItem new];
    item.service = serviceName;
    item.account = account;
    return [self deleteItem:item error:error];
}

+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account {
    return [self deletePasswordForService:serviceName account:account error:NULL];
}

+ (BOOL)setPassword:(NSString *)password
         forService:(NSString *)serviceName
            account:(NSString *)account
              error:(NSError **)error {
    if (!password || !serviceName || !account) {
        if (error) *error = [TYSMKeychain errorWithCode:errSecParam];
        return NO;
    }
    TYSMKeychainItem *item = [TYSMKeychainItem new];
    item.service = serviceName;
    item.account = account;
    TYSMKeychainItem *result = [self selectOneItem:item error:NULL];
    if (result) {
        result.password = password;
        return [self updateItem:result error:error];
    } else {
        item.password = password;
        return [self insertItem:item error:error];
    }
}

+ (BOOL)setPassword:(NSString *)password
         forService:(NSString *)serviceName
            account:(NSString *)account {
    return [self setPassword:password forService:serviceName account:account error:NULL];
}

+ (BOOL)insertItem:(TYSMKeychainItem *)item error:(NSError **)error {
    if (!item.service || !item.account || !item.passwordData) {
        if (error) *error = [TYSMKeychain errorWithCode:errSecParam];
        return NO;
    }
    
    NSMutableDictionary *query = [item tysm_dic];
    OSStatus status = status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    if (status != errSecSuccess) {
        if (error) *error = [TYSMKeychain errorWithCode:status];
        return NO;
    }
    
    return YES;
}

+ (BOOL)insertItem:(TYSMKeychainItem *)item {
    return [self insertItem:item error:NULL];
}

+ (BOOL)updateItem:(TYSMKeychainItem *)item error:(NSError **)error {
    if (!item.service || !item.account || !item.passwordData) {
        if (error) *error = [TYSMKeychain errorWithCode:errSecParam];
        return NO;
    }
    
    NSMutableDictionary *query = [item tysm_queryDic];
    NSMutableDictionary *update = [item tysm_dic];
    [update removeObjectForKey:(__bridge id)kSecClass];
    if (!query || !update) return NO;
    OSStatus status = status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)update);
    if (status != errSecSuccess) {
        if (error) *error = [TYSMKeychain errorWithCode:status];
        return NO;
    }
    
    return YES;
}

+ (BOOL)updateItem:(TYSMKeychainItem *)item {
    return [self updateItem:item error:NULL];
}

+ (BOOL)deleteItem:(TYSMKeychainItem *)item error:(NSError **)error {
    if (!item.service || !item.account) {
        if (error) *error = [TYSMKeychain errorWithCode:errSecParam];
        return NO;
    }
    
    NSMutableDictionary *query = [item tysm_dic];
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    if (status != errSecSuccess) {
        if (error) *error = [TYSMKeychain errorWithCode:status];
        return NO;
    }
    
    return YES;
}

+ (BOOL)deleteItem:(TYSMKeychainItem *)item {
    return [self deleteItem:item error:NULL];
}

+ (TYSMKeychainItem *)selectOneItem:(TYSMKeychainItem *)item error:(NSError **)error {
    if (!item.service || !item.account) {
        if (error) *error = [TYSMKeychain errorWithCode:errSecParam];
        return nil;
    }
    
    NSMutableDictionary *query = [item tysm_dic];
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    query[(__bridge id)kSecReturnAttributes] = @YES;
    query[(__bridge id)kSecReturnData] = @YES;
    
    OSStatus status;
    CFTypeRef result = NULL;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status != errSecSuccess) {
        if (error) *error = [[self class] errorWithCode:status];
        return nil;
    }
    if (!result) return nil;
    
    NSDictionary *dic = nil;
    if (CFGetTypeID(result) == CFDictionaryGetTypeID()) {
        dic = (__bridge NSDictionary *)(result);
    } else if (CFGetTypeID(result) == CFArrayGetTypeID()){
        dic = [(__bridge NSArray *)(result) firstObject];
        if (![dic isKindOfClass:[NSDictionary class]]) dic = nil;
    }
    if (!dic.count) return nil;
    return [[TYSMKeychainItem alloc] initWithDic:dic];
}

+ (TYSMKeychainItem *)selectOneItem:(TYSMKeychainItem *)item {
    return [self selectOneItem:item error:NULL];
}

+ (NSArray *)selectItems:(TYSMKeychainItem *)item error:(NSError **)error {
    NSMutableDictionary *query = [item tysm_dic];
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitAll;
    query[(__bridge id)kSecReturnAttributes] = @YES;
    query[(__bridge id)kSecReturnData] = @YES;
    
    OSStatus status;
    CFTypeRef result = NULL;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status != errSecSuccess && error != NULL) {
        *error = [[self class] errorWithCode:status];
        return nil;
    }
    
    NSMutableArray *res = [NSMutableArray new];
    NSDictionary *dic = nil;
    if (CFGetTypeID(result) == CFDictionaryGetTypeID()) {
        dic = (__bridge NSDictionary *)(result);
        TYSMKeychainItem *item = [[TYSMKeychainItem alloc] initWithDic:dic];
        if (item) [res addObject:item];
    } else if (CFGetTypeID(result) == CFArrayGetTypeID()){
        for (NSDictionary *dic in (__bridge NSArray *)(result)) {
            TYSMKeychainItem *item = [[TYSMKeychainItem alloc] initWithDic:dic];
            if (item) [res addObject:item];
        }
    }
    
    return res;
}

+ (NSArray *)selectItems:(TYSMKeychainItem *)item {
    return [self selectItems:item error:NULL];
}

+ (NSError *)errorWithCode:(OSStatus)osCode {
    TYSMKeychainErrorCode code = TYSMKeychainErrorCodeFromOSStatus(osCode);
    NSString *desc = TYSMKeychainErrorDesc(code);
    NSDictionary *userInfo = desc ? @{ NSLocalizedDescriptionKey : desc } : nil;
    return [NSError errorWithDomain:@"com.ibireme.TYSMkit.keychain" code:code userInfo:userInfo];
}

@end
