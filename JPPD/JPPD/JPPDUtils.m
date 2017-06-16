//
//  JPPDUtils.m
//  JPPD
//
//  Created by 潘建磊 on 15/7/29.
//  Copyright © 2015年 JaryPan. All rights reserved.
//

#import "JPPDUtils.h"
#import "JPPD.h"

@implementation JPPDUtils

#pragma mark - 获取保存主路径
+ (NSString *)storagePath
{
    NSString *storagePath = nil;
    
    switch ([JPPD sharedJPPD].type) {
        case JPStorageDirectoryTypeDocuments:
            storagePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            break;
            
        case JPStorageDirectoryTypeLibrary:
            storagePath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
            break;
            
        case JPStorageDirectoryTypeCaches:
            storagePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
            break;
            
        case JPStorageDirectoryTypePreferences:
            storagePath = [NSSearchPathForDirectoriesInDomains(NSPreferencePanesDirectory, NSUserDomainMask, YES) firstObject];
            break;
            
        default:
            break;
    }
    
    return storagePath;
}


#pragma mark - 创建NSError对象
+ (NSError *)errorWithDomain:(NSString *)domain andCode:(JPErrorCode)code
{
    NSString *codeString = nil;
    switch (code) {
        case JPErrorCodeCreateTableFailed:
            codeString = @"JPErrorCodeCreateTableFailed";
            break;
            
        case JPErrorCodeKeyCannotBeNull:
            codeString = @"JPErrorCodeKeyCannotBeNull";
            break;
            
        case JPErrorCodeValueCannotBeNull:
            codeString = @"JPErrorCodeValueCannotBeNull";
            break;
            
        case JPErrorCodeTableNameCannotBeNull:
            codeString = @"JPErrorCodeTableNameCannotBeNull";
            break;
            
        case JPErrorCodeStoreFailed:
            codeString = @"JPErrorCodeStoreFailed";
            break;
            
        case JPErrorCodeNoSuchKey:
            codeString = @"JPErrorCodeNoSuchKey";
            break;
            
        case JPErrorCodeNoSuchTable:
            codeString = @"JPErrorCodeNoSuchTable";
            break;
            
        case JPErrorCodeInvalidKey:
            codeString = @"JPErrorCodeInvalidKey";
            break;
            
        case JPErrorCodeValueForProvidedKeyNotFound:
            codeString = @"JPErrorCodeValueForProvidedKeyNotFound";
            break;
            
        case JPErrorCodeDeleteFailed:
            codeString = @"JPErrorCodeDeleteFailed";
            break;
            
        default:
            break;
    }
    
    NSError *error = [NSError errorWithDomain:domain code:code userInfo:@{@"Domain":domain, @"code":codeString}];
    return error;
}


#pragma mark - 数据归档
+ (NSData *)ArchiveObject:(id)object forKey:(NSString *)key
{
    // 准备可变data
    NSMutableData *data = [NSMutableData data];
    // 准备归档工具
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    // 开始归档
    [archiver encodeObject:object forKey:key];
    // 完成归档
    [archiver finishEncoding];
    // 返回归档后的数据
    return data;
}
#pragma mark - 数据反归档
+ (id)unArchiveData:(id)data forKey:(NSString *)key
{
    // 判断是不是NSData数据，不是的话返回原数据，否则可能造成崩溃
    if ([data isKindOfClass:[NSData class]] || [data isKindOfClass:[NSMutableData class]]) {
        // 准备反归档工具
        NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
        // 开始反归档
        id object = [unArchiver decodeObjectForKey:key];
        // 结束反归档
        [unArchiver finishDecoding];
        // 返回反归档后的数据
        return object;
    } else {
        return data;
    }
}


#pragma mark - 将数据转换为可存储的类型(自动区分value的内容哪些需要归档处理)
+ (id)storableValue:(id)value withKey:(NSString *)key
{
    if ([value isKindOfClass:[NSArray class]] ||
        [value isKindOfClass:[NSMutableArray class]]) {
        NSMutableArray *tempArray = [NSMutableArray array];
        
        for (id tempValue in value) {
            id transformValue = [self storableValue:tempValue withKey:key];
            [tempArray addObject:transformValue];
        }
        
        return tempArray;
    }
    if ([value isKindOfClass:[NSDictionary class]] ||
        [value isKindOfClass:[NSMutableDictionary class]]) {
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        
        for (NSString *tempKey in [value allKeys]) {
            id transformValue = [self storableValue:value[tempKey] withKey:key];
            [tempDic setValue:transformValue forKey:tempKey];
        }
        
        return tempDic;
    }
    if ([value isKindOfClass:[NSNumber class]] ||
        [value isKindOfClass:[NSString class]] ||
        [value isKindOfClass:[NSMutableString class]] ||
        [value isKindOfClass:[NSDate class]]) {
        
        return value;
    }
    
    return [self ArchiveObject:value forKey:key];
}
#pragma mark - 将数据转换为可读取的类型(自动将value中包含归档数据反归档)
+ (id)readableValue:(id)value withKey:(NSString *)key
{
    if ([value isKindOfClass:[NSArray class]] ||
        [value isKindOfClass:[NSMutableArray class]]) {
        NSMutableArray *tempArray = [NSMutableArray array];
        
        for (id tempValue in value) {
            id transformValue = [self readableValue:tempValue withKey:key];
            [tempArray addObject:transformValue];
        }
        
        return tempArray;
    }
    if ([value isKindOfClass:[NSDictionary class]] ||
        [value isKindOfClass:[NSMutableDictionary class]]) {
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        
        for (NSString *tempKey in [value allKeys]) {
            id transformValue = [self readableValue:value[tempKey] withKey:key];
            [tempDic setValue:transformValue forKey:tempKey];
        }
        
        return tempDic;
    }
    
    if ([value isKindOfClass:[NSNumber class]] ||
        [value isKindOfClass:[NSString class]] ||
        [value isKindOfClass:[NSMutableString class]] ||
        [value isKindOfClass:[NSDate class]]) {
        
        return value;
    }
    
    return [self unArchiveData:value forKey:key];
}

@end
