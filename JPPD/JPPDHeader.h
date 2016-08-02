//
//  JPPDHeader.h
//  JPPD
//
//  Created by ovopark_iOS on 16/8/2.
//  Copyright © 2016年 JaryPan. All rights reserved.
//


typedef NS_ENUM(NSInteger, JPStorageDirectoryType) {
    JPStorageDirectoryTypeDocuments = -1000,
    JPStorageDirectoryTypeLibrary,
    JPStorageDirectoryTypeCaches = 0,
    JPStorageDirectoryTypePreferences,
    JPStorageDirectoryTypeDefault = JPStorageDirectoryTypeCaches,
}; // 存储目录类型

typedef NS_ENUM(NSInteger, JPErrorCode) {
    JPErrorCodeNoSuchTable = 1000, // 找不到对应的表格
    JPErrorCodeNoSuchKey, // 找不到对应的key
    
    JPErrorCodeStorageValueCannotBeNil = 1000, // 存储值不能为空
    JPErrorCodeKeyForStorageValueCannotBeNil, // 存储值对应的key不能为空
    JPErrorCodeStorageValuesDictionaryCannotBeNil, // 存储的字典不能为空
    JPErrorCodeStoreFailed, // 存储失败
    
    JPErrorCodeSomeKeysForUpdatingNotFound, // 更新数据时部分key没有找到
    JPErrorCodeUpdateFailed, // 更新失败
    
    JPErrorCodeKeyForReadingCannotBeNil, // 读取一条数据时key不能为空
    JPErrorCodeNoValueForProvidedKey, // 找不到所提供的key对用的value
    JPErrorCodeKeysArrayForReadingCannotBeNil, // 读取多个数据时key数组不能为空
    JPErrorCodeSomeKeysForReadingNotFound, // 读取多个数据时部分key没有找到
    
    JPErrorCodeKeyForDeletingCannotBeNil, // 删除数据时的key不能为空
    JPErrorCodeKeysArrayForDeletingCannotBeNil, // 删除数据时key数组不能为空
    JPErrorCodeDeleteFailed, // 删除数据失败
}; // 错误类型

