//
//  TYSMKeychain.h
//  TYSMKit <https://github.com/ibireme/TYSMKit>
//
//  Created by ibireme on 14/10/15.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>

@class TYSMKeychainItem;

NS_ASSUME_NONNULL_BEGIN

/**
 A wrapper for system keychain API.
 
 Inspired by [SSKeychain](https://github.com/soffes/sskeychain) 😜
 */
@interface TYSMKeychain : NSObject

#pragma mark - Convenience method for keychain
///=============================================================================
/// @name Convenience method for keychain
///=============================================================================

/**
 Returns the password for a given account and service, or `nil` if not found or
 an error occurs.
 
 @param serviceName The service for which to return the corresponding password.
 This value must not be nil.
 
 @param account The account for which to return the corresponding password.
 This value must not be nil.
 
 @param error   On input, a pointer to an error object. If an error occurs,
 this pointer is set to an actual error object containing the error information. 
 You may specify nil for this parameter if you do not want the error information.
 See `TYSMKeychainErrorCode`.
 
 @return Password string, or nil when not found or error occurs.
 */
+ (nullable NSString *)getPasswordForService:(NSString *)serviceName
                                     account:(NSString *)account
                                       error:(NSError **)error;
+ (nullable NSString *)getPasswordForService:(NSString *)serviceName
                                     account:(NSString *)account;

/**
 Deletes a password from the Keychain.
 
 @param serviceName The service for which to return the corresponding password.
 This value must not be nil.
 
 @param account The account for which to return the corresponding password.
 This value must not be nil.
 
 @param error   On input, a pointer to an error object. If an error occurs,
 this pointer is set to an actual error object containing the error information.
 You may specify nil for this parameter if you do not want the error information.
 See `TYSMKeychainErrorCode`.
 
 @return Whether succeed.
 */
+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error;
+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account;

/**
 Insert or update the password for a given account and service.
 
 @param password    The new password.
 
 @param serviceName The service for which to return the corresponding password.
 This value must not be nil.
 
 @param account The account for which to return the corresponding password.
 This value must not be nil.
 
 @param error   On input, a pointer to an error object. If an error occurs,
 this pointer is set to an actual error object containing the error information.
 You may specify nil for this parameter if you do not want the error information.
 See `TYSMKeychainErrorCode`.
 
 @return Whether succeed.
 */
+ (BOOL)setPassword:(NSString *)password
         forService:(NSString *)serviceName
            account:(NSString *)account
              error:(NSError **)error;
+ (BOOL)setPassword:(NSString *)password
         forService:(NSString *)serviceName
            account:(NSString *)account;


#pragma mark - Full query for keychain (SQL-like)
///=============================================================================
/// @name Full query for keychain (SQL-like)
///=============================================================================

/**
 Insert an item into keychain.
 
 @discussion The service,account,password is required. If there's item exist
 already, an error occurs and insert fail.
 
 @param item  The item to insert.
 
 @param error On input, a pointer to an error object. If an error occurs,
 this pointer is set to an actual error object containing the error information.
 You may specify nil for this parameter if you do not want the error information.
 See `TYSMKeychainErrorCode`.
 
 @return Whether succeed.
 */
+ (BOOL)insertItem:(TYSMKeychainItem *)item error:(NSError **)error;
+ (BOOL)insertItem:(TYSMKeychainItem *)item;

/**
 Update item in keychain.
 
 @discussion The service,account,password is required. If there's no item exist
 already, an error occurs and insert fail.
 
 @param item  The item to insert.
 
 @param error On input, a pointer to an error object. If an error occurs,
 this pointer is set to an actual error object containing the error information.
 You may specify nil for this parameter if you do not want the error information.
 See `TYSMKeychainErrorCode`.
 
 @return Whether succeed.
 */
+ (BOOL)updateItem:(TYSMKeychainItem *)item error:(NSError **)error;
+ (BOOL)updateItem:(TYSMKeychainItem *)item;

/**
 Delete items from keychain.
 
 @discussion The service,account,password is required. If there's item exist
 already, an error occurs and insert fail.
 
 @param item  The item to update.
 
 @param error On input, a pointer to an error object. If an error occurs,
 this pointer is set to an actual error object containing the error information.
 You may specify nil for this parameter if you do not want the error information.
 See `TYSMKeychainErrorCode`.
 
 @return Whether succeed.
 */
+ (BOOL)deleteItem:(TYSMKeychainItem *)item error:(NSError **)error;
+ (BOOL)deleteItem:(TYSMKeychainItem *)item;

/**
 Find an item from keychain.
 
 @discussion The service,account is optinal. It returns only one item if there
 exist multi.
 
 @param item  The item for query.
 
 @param error On input, a pointer to an error object. If an error occurs,
 this pointer is set to an actual error object containing the error information.
 You may specify nil for this parameter if you do not want the error information.
 See `TYSMKeychainErrorCode`.
 
 @return An item or nil.
 */
+ (nullable TYSMKeychainItem *)selectOneItem:(TYSMKeychainItem *)item error:(NSError **)error;
+ (nullable TYSMKeychainItem *)selectOneItem:(TYSMKeychainItem *)item;

/**
 Find all items matches the query.
 
 @discussion The service,account is optinal. It returns all item matches by the
 query.
 
 @param item  The item for query.
 
 @param error On input, a pointer to an error object. If an error occurs,
 this pointer is set to an actual error object containing the error information.
 You may specify nil for this parameter if you do not want the error information.
 See `TYSMKeychainErrorCode`.
 
 @return An array of TYSMKeychainItem.
 */
+ (nullable NSArray<TYSMKeychainItem *> *)selectItems:(TYSMKeychainItem *)item error:(NSError **)error;
+ (nullable NSArray<TYSMKeychainItem *> *)selectItems:(TYSMKeychainItem *)item;

@end




#pragma mark - Const

/**
 Error code in TYSMKeychain API.
 */
typedef NS_ENUM (NSUInteger, TYSMKeychainErrorCode) {
    TYSMKeychainErrorUnimplemented = 1, ///< Function or operation not implemented.
    TYSMKeychainErrorIO, ///< I/O error (bummers)
    TYSMKeychainErrorOpWr, ///< File already open with with write permission.
    TYSMKeychainErrorParam, ///< One or more parameters passed to a function where not valid.
    TYSMKeychainErrorAllocate, ///< Failed to allocate memory.
    TYSMKeychainErrorUserCancelled, ///< User cancelled the operation.
    TYSMKeychainErrorBadReq, ///< Bad parameter or invalid state for operation.
    TYSMKeychainErrorInternalComponent, ///< Internal...
    TYSMKeychainErrorNotAvailable, ///< No keychain is available. You may need to restart your computer.
    TYSMKeychainErrorDuplicateItem, ///< The specified item already exists in the keychain.
    TYSMKeychainErrorItemNotFound, ///< The specified item could not be found in the keychain.
    TYSMKeychainErrorInteractionNotAllowed, ///< User interaction is not allowed.
    TYSMKeychainErrorDecode, ///< Unable to decode the provided data.
    TYSMKeychainErrorAuthFailed, ///< The user name or passphrase you entered is not.
};


/**
 When query to return the item's data, the error
 errSecInteractionNotAllowed will be returned if the item's data is not
 available until a device unlock occurs.
 */
typedef NS_ENUM (NSUInteger, TYSMKeychainAccessible) {
    TYSMKeychainAccessibleNone = 0, ///< no value
    
    /** Item data can only be accessed
     while the device is unlocked. This is recommended for items that only
     need be accesible while the application is in the foreground.  Items
     with this tysm_attribute will migrate to a new device when using encrypted
     backups. */
    TYSMKeychainAccessibleWhenUnlocked,
    
    /** Item data can only be
     accessed once the device has been unlocked after a restart.  This is
     recommended for items that need to be accesible by background
     applications. Items with this tysm_attribute will migrate to a new device
     when using encrypted backups.*/
    TYSMKeychainAccessibleAfterFirstUnlock,
    
    /** Item data can always be accessed
     regardless of the lock state of the device.  This is not recommended
     for anything except system use. Items with this tysm_attribute will migrate
     to a new device when using encrypted backups.*/
    TYSMKeychainAccessibleAlways,
    
    /** Item data can
     only be accessed while the device is unlocked. This class is only
     available if a passcode is set on the device. This is recommended for
     items that only need to be accessible while the application is in the
     foreground. Items with this tysm_attribute will never migrate to a new
     device, so after a backup is restored to a new device, these items
     will be missing. No items can be stored in this class on devices
     without a passcode. Disabling the device passcode will cause all
     items in this class to be deleted.*/
    TYSMKeychainAccessibleWhenPasscodeSetThisDeviceOnly,
    
    /** Item data can only
     be accessed while the device is unlocked. This is recommended for items
     that only need be accesible while the application is in the foreground.
     Items with this tysm_attribute will never migrate to a new device, so after
     a backup is restored to a new device, these items will be missing. */
    TYSMKeychainAccessibleWhenUnlockedThisDeviceOnly,
    
    /** Item data can
     only be accessed once the device has been unlocked after a restart.
     This is recommended for items that need to be accessible by background
     applications. Items with this tysm_attribute will never migrate to a new
     device, so after a backup is restored to a new device these items will
     be missing.*/
    TYSMKeychainAccessibleAfterFirstUnlockThisDeviceOnly,
    
    /** Item data can always
     be accessed regardless of the lock state of the device.  This option
     is not recommended for anything except system use. Items with this
     tysm_attribute will never migrate to a new device, so after a backup is
     restored to a new device, these items will be missing.*/
    TYSMKeychainAccessibleAlwaysThisDeviceOnly,
};

/**
 Whether the item in question can be synchronized.
 */
typedef NS_ENUM (NSUInteger, TYSMKeychainQuerySynchronizationMode) {
    
    /** Default, Don't care for synchronization  */
    TYSMKeychainQuerySynchronizationModeAny = 0,
    
    /** Is not synchronized */
    TYSMKeychainQuerySynchronizationModeNo,
    
    /** To add a new item which can be synced to other devices, or to obtain 
     synchronized results from a query*/
    TYSMKeychainQuerySynchronizationModeYes,
} NS_AVAILABLE_IOS (7_0);


#pragma mark - Item

/**
 Wrapper for keychain item/query.
 */
@interface TYSMKeychainItem : NSObject <NSCopying>

@property (nullable, nonatomic, copy) NSString *service; ///< kSecAttrService
@property (nullable, nonatomic, copy) NSString *account; ///< kSecAttrAccount
@property (nullable, nonatomic, copy) NSData *passwordData; ///< kSecValueData
@property (nullable, nonatomic, copy) NSString *password; ///< shortcut for `passwordData`
@property (nullable, nonatomic, copy) id <NSCoding> passwordObject; ///< shortcut for `passwordData`

@property (nullable, nonatomic, copy) NSString *label; ///< kSecAttrLabel
@property (nullable, nonatomic, copy) NSNumber *type; ///< kSecAttrType (FourCC)
@property (nullable, nonatomic, copy) NSNumber *creater; ///< kSecAttrCreator (FourCC)
@property (nullable, nonatomic, copy) NSString *comment; ///< kSecAttrComment
@property (nullable, nonatomic, copy) NSString *descr; ///< kSecAttrDescription
@property (nullable, nonatomic, readonly, strong) NSDate *modificationDate; ///< kSecAttrModificationDate
@property (nullable, nonatomic, readonly, strong) NSDate *creationDate; ///< kSecAttrCreationDate
@property (nullable, nonatomic, copy) NSString *accessGroup; ///< kSecAttrAccessGroup

@property (nonatomic) TYSMKeychainAccessible accessible; ///< kSecAttrAccessible
@property (nonatomic) TYSMKeychainQuerySynchronizationMode synchronizable NS_AVAILABLE_IOS(7_0); ///< kSecAttrSynchronizable

@end

NS_ASSUME_NONNULL_END
