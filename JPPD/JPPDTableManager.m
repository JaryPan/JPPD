//
//  JPPDTableManager.m
//  JPPD
//
//  Created by ovopark_iOS on 16/8/2.
//  Copyright © 2016年 JaryPan. All rights reserved.
//

#import "JPPDTableManager.h"

@implementation JPPDTableManager

#pragma mark - 获取保存路径
+ (NSString *)storagePathForType:(JPStorageDirectoryType)type
{
    NSString *storagePath = nil;
    
    switch (type) {
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

#pragma mark - 获取文件夹路径
+ (NSString *)filePath:(NSString *)detailedFileName withType:(JPStorageDirectoryType)type
{
    return [[self storagePathForType:type] stringByAppendingPathComponent:detailedFileName];
}
#pragma mark - 获取表格对应的路径
+ (NSString *)pathForTable:(NSString *)table withType:(JPStorageDirectoryType)type
{
    return [[self storagePathForType:type] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", table]];
}


#pragma mark - 创建一个文件夹
+ (NSError *)createOneFile:(NSString *)file forType:(JPStorageDirectoryType)type
{
    NSError *error = nil;
    NSString *filePath = [self filePath:file withType:type];
    [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:&error];
    return error;
}
+ (void)createOneFile:(NSString *)file forType:(JPStorageDirectoryType)type completedBlock:(void (^)(NSError *))block
{
    dispatch_async(dispatch_queue_create(nil, nil), ^{
        NSError *error = [self createOneFile:file forType:type];
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error);
            });
        }
    });
}

#pragma mark - 删除一个文件夹
+ (NSError *)deleteOneFile:(NSString *)file forType:(JPStorageDirectoryType)type
{
    NSError *error = nil;
    NSString *filePath = [self filePath:file withType:type];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    return error;
}
+ (void)deleteOneFile:(NSString *)file forType:(JPStorageDirectoryType)type completedBlock:(void (^)(NSError *))block
{
    dispatch_async(dispatch_queue_create(nil, nil), ^{
        NSError *error = [self deleteOneFile:file forType:type];
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error);
            });
        }
    });
}


#pragma mark - 创建一个表格
+ (BOOL)createOneTable:(NSString *)table forType:(JPStorageDirectoryType)type
{
    NSString *tablePath = [self pathForTable:table withType:type];
    BOOL success = [[NSDictionary dictionary] writeToFile:tablePath atomically:YES];
    return success;
}
+ (void)createOneTable:(NSString *)table forType:(JPStorageDirectoryType)type completedBlock:(void (^)(BOOL))block
{
    dispatch_async(dispatch_queue_create(nil, nil), ^{
        BOOL success = [self createOneTable:table forType:type];
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(success);
            });
        }
    });
}

#pragma mark - 删除一个表格
+ (NSError *)deleteOneTable:(NSString *)table forType:(JPStorageDirectoryType)type
{
    NSError *error = nil;
    NSString *tablePath = [self pathForTable:table withType:type];
    [[NSFileManager defaultManager] removeItemAtPath:tablePath error:&error];
    return error;
}
+ (void)deleteOneTable:(NSString *)table forType:(JPStorageDirectoryType)type completedBlock:(void (^)(NSError *))block
{
    dispatch_async(dispatch_queue_create(nil, nil), ^{
        NSError *error = [self deleteOneTable:table forType:type];
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error);
            });
        }
    });
}


#pragma mark - 获取表格大小
+ (unsigned long long)sizeForTable:(NSString *)table withType:(JPStorageDirectoryType)type
{
    // 获取表格路径
    NSString *tablePath = [self pathForTable:table withType:type];
    // 返回大小
    return [[[NSFileManager defaultManager] attributesOfItemAtPath:tablePath error:nil] fileSize];
}


@end
