//
//  JPPDUtils.h
//  JPPD
//
//  Created by 潘建磊 on 15/7/29.
//  Copyright © 2015年 JaryPan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JPStorageDirectoryType) {
    JPStorageDirectoryTypeDocuments = -1000,
    JPStorageDirectoryTypeLibrary,
    JPStorageDirectoryTypeCaches = 0,
    JPStorageDirectoryTypePreferences,
    JPStorageDirectoryTypeDefault = JPStorageDirectoryTypeCaches,
}; // 存储目录类型

typedef NS_ENUM(NSInteger, JPErrorCode) {
    JPErrorCodeCreateTableFailed = 1000, // 表格创建失败
    JPErrorCodeValueCannotBeNull, // value不能为空
    JPErrorCodeKeyCannotBeNull, // key不能为空
    JPErrorCodeTableNameCannotBeNull, // table名称不能为空
    JPErrorCodeStoreFailed, // 存储失败
    
    JPErrorCodeNoSuchKey = 2000, // 找不到对应的key
    JPErrorCodeNoSuchTable, // 找不到对应的表格
    JPErrorCodeInvalidKey, // 无效的key
    JPErrorCodeValueForProvidedKeyNotFound, // 找不到所提供的key对用的value
    JPErrorCodeTableContainsNoValue, // 表格没有数据
    
    JPErrorCodeDeleteFailed = 3000, // 删除数据失败
}; // 错误类型

@interface JPPDUtils : NSObject

/**
 *获取保存主路径
 */
+ (nullable NSString *)storagePath;

/**
 *创建NSError对象
 */
+ (nullable NSError *)errorWithDomain:(nonnull NSString *)domain andCode:(JPErrorCode)code;

/**
 *数据归档
 */
+ (nullable NSData *)ArchiveObject:(nonnull id)object forKey:(nonnull NSString *)key;
/**
 *数据反归档
 */
+ (nullable id)unArchiveData:(nonnull id)data forKey:(nonnull NSString *)key;

/**
 *将数据转换为可存储的类型(自动区分value的内容哪些需要归档处理)
 */
+ (nullable id)storableValue:(nonnull id)value withKey:(nonnull NSString *)key;
/**
 *将数据转换为可读取的类型(自动将value中包含归档数据反归档)
 */
+ (nullable id)readableValue:(nonnull id)value withKey:(nonnull NSString *)key;

@end
