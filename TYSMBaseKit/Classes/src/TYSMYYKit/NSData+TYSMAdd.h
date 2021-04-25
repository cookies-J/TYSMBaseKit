//
//  NSData+TYSMAdd.h
//  TYSMKit <https://github.com/ibireme/TYSMKit>
//
//  Created by ibireme on 13/4/4.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Provide hash, encrypt, encode and some common method for `NSData`.
 */
@interface NSData (TYSMAdd)

#pragma mark - Hash
///=============================================================================
/// @name Hash
///=============================================================================

/**
 Returns a lowercase NSString for md2 hash.
 */
- (NSString *)tysm_md2String;

/**
 Returns an NSData for md2 hash.
 */
- (NSData *)tysm_md2Data;

/**
 Returns a lowercase NSString for md4 hash.
 */
- (NSString *)tysm_md4String;

/**
 Returns an NSData for md4 hash.
 */
- (NSData *)tysm_md4Data;

/**
 Returns a lowercase NSString for md5 hash.
 */
- (NSString *)tysm_md5String;

/**
 Returns an NSData for md5 hash.
 */
- (NSData *)tysm_md5Data;

/**
 Returns a lowercase NSString for sha1 hash.
 */
- (NSString *)tysm_sha1String;

/**
 Returns an NSData for sha1 hash.
 */
- (NSData *)tysm_sha1Data;

/**
 Returns a lowercase NSString for sha224 hash.
 */
- (NSString *)tysm_sha224String;

/**
 Returns an NSData for sha224 hash.
 */
- (NSData *)tysm_sha224Data;

/**
 Returns a lowercase NSString for sha256 hash.
 */
- (NSString *)tysm_sha256String;

/**
 Returns an NSData for sha256 hash.
 */
- (NSData *)tysm_sha256Data;

/**
 Returns a lowercase NSString for sha384 hash.
 */
- (NSString *)tysm_sha384String;

/**
 Returns an NSData for sha384 hash.
 */
- (NSData *)tysm_sha384Data;

/**
 Returns a lowercase NSString for sha512 hash.
 */
- (NSString *)tysm_sha512String;

/**
 Returns an NSData for sha512 hash.
 */
- (NSData *)tysm_sha512Data;

/**
 Returns a lowercase NSString for hmac using algorithm md5 with key.
 @param key  The hmac key.
 */
- (NSString *)tysm_hmacMD5StringWithKey:(NSString *)key;

/**
 Returns an NSData for hmac using algorithm md5 with key.
 @param key  The hmac key.
 */
- (NSData *)tysm_hmacMD5DataWithKey:(NSData *)key;

/**
 Returns a lowercase NSString for hmac using algorithm sha1 with key.
 @param key  The hmac key.
 */
- (NSString *)tysm_hmacSHA1StringWithKey:(NSString *)key;

/**
 Returns an NSData for hmac using algorithm sha1 with key.
 @param key  The hmac key.
 */
- (NSData *)tysm_hmacSHA1DataWithKey:(NSData *)key;

/**
 Returns a lowercase NSString for hmac using algorithm sha224 with key.
 @param key  The hmac key.
 */
- (NSString *)tysm_hmacSHA224StringWithKey:(NSString *)key;

/**
 Returns an NSData for hmac using algorithm sha224 with key.
 @param key  The hmac key.
 */
- (NSData *)tysm_hmacSHA224DataWithKey:(NSData *)key;

/**
 Returns a lowercase NSString for hmac using algorithm sha256 with key.
 @param key  The hmac key.
 */
- (NSString *)tysm_hmacSHA256StringWithKey:(NSString *)key;

/**
 Returns an NSData for hmac using algorithm sha256 with key.
 @param key  The hmac key.
 */
- (NSData *)tysm_hmacSHA256DataWithKey:(NSData *)key;

/**
 Returns a lowercase NSString for hmac using algorithm sha384 with key.
 @param key  The hmac key.
 */
- (NSString *)tysm_hmacSHA384StringWithKey:(NSString *)key;

/**
 Returns an NSData for hmac using algorithm sha384 with key.
 @param key  The hmac key.
 */
- (NSData *)tysm_hmacSHA384DataWithKey:(NSData *)key;

/**
 Returns a lowercase NSString for hmac using algorithm sha512 with key.
 @param key  The hmac key.
 */
- (NSString *)tysm_hmacSHA512StringWithKey:(NSString *)key;

/**
 Returns an NSData for hmac using algorithm sha512 with key.
 @param key  The hmac key.
 */
- (NSData *)tysm_hmacSHA512DataWithKey:(NSData *)key;

/**
 Returns a lowercase NSString for crc32 hash.
 */
- (NSString *)tysm_crc32String;

/**
 Returns crc32 hash.
 */
- (uint32_t)tysm_crc32;


#pragma mark - Encrypt and Decrypt
///=============================================================================
/// @name Encrypt and Decrypt
///=============================================================================

/**
 Returns an encrypted NSData using AES.
 
 @param key   A key length of 16, 24 or 32 (128, 192 or 256bits).
 
 @param iv    An initialization vector length of 16(128bits).
              Pass nil when you don't want to use iv.
 
 @return      An NSData encrypted, or nil if an error occurs.
 */
- (nullable NSData *)tysm_aes256EncryptWithKey:(NSData *)key iv:(nullable NSData *)iv;

/**
 Returns an decrypted NSData using AES.
 
 @param key   A key length of 16, 24 or 32 (128, 192 or 256bits).
 
 @param iv    An initialization vector length of 16(128bits).
              Pass nil when you don't want to use iv.
 
 @return      An NSData decrypted, or nil if an error occurs.
 */
- (nullable NSData *)tysm_aes256DecryptWithkey:(NSData *)key iv:(nullable NSData *)iv;


#pragma mark - Encode and decode
///=============================================================================
/// @name Encode and decode
///=============================================================================

/**
 Returns string decoded in UTF8.
 */
- (nullable NSString *)tysm_utf8String;

/**
 Returns a uppercase NSString in HEX.
 */
- (nullable NSString *)tysm_hexString;

/**
 Returns an NSData from hex string.
 
 @param hexString   The hex string which is case insensitive.
 
 @return a new NSData, or nil if an error occurs.
 */
+ (nullable NSData *)dataWithHexString:(NSString *)hexString;

/**
 Returns an NSString for base64 encoded.
 */
- (nullable NSString *)tysm_base64EncodedString;

/**
 Returns an NSData from base64 encoded string.
 
 @warning This method has been implemented in iOS7.
 
 @param base64EncodedString  The encoded string.
 */
+ (nullable NSData *)dataWithBase64EncodedString:(NSString *)base64EncodedString;

/**
 Returns an NSDictionary or NSArray for decoded self.
 Returns nil if an error occurs.
 */
- (nullable id)tysm_jsonValueDecoded;


#pragma mark - Inflate and deflate
///=============================================================================
/// @name Inflate and deflate
///=============================================================================

/**
 Decompress data from gzip data.
 @return Inflated data.
 */
- (nullable NSData *)tysm_gzipInflate;

/**
 Comperss data to gzip in default compresssion level.
 @return Deflated data.
 */
- (nullable NSData *)tysm_gzipDeflate;

/**
 Decompress data from zlib-compressed data.
 @return Inflated data.
 */
- (nullable NSData *)tysm_zlibInflate;

/**
 Comperss data to zlib-compressed in default compresssion level.
 @return Deflated data.
 */
- (nullable NSData *)tysm_zlibDeflate;


#pragma mark - Others
///=============================================================================
/// @name Others
///=============================================================================

/**
 Create data from the file in main bundle (similar to [UIImage imageNamed:]).
 
 @param name The file name (in main bundle).
 
 @return A new data create from the file.
 */
+ (nullable NSData *)dataNamed:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
