//
//  JPPDTableManager.h
//  JPPD
//
//  Created by ovopark_iOS on 16/8/2.
//  Copyright © 2016年 JaryPan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPPDHeader.h"

@interface JPPDTableManager : NSObject

#pragma mark - 创建一个文件夹
+ (NSError *)createOneFile:(NSString *)file forType:(JPStorageDirectoryType)type;
+ (void)createOneFile:(NSString *)file forType:(JPStorageDirectoryType)type completedBlock:(void(^)(NSError *error))block;

#pragma mark - 删除一个文件夹
+ (NSError *)deleteOneFile:(NSString *)file forType:(JPStorageDirectoryType)type;
+ (void)deleteOneFile:(NSString *)file forType:(JPStorageDirectoryType)type completedBlock:(void(^)(NSError *error))block;


#pragma mark - 创建一个表格
+ (BOOL)createOneTable:(NSString *)table forType:(JPStorageDirectoryType)type;
+ (void)createOneTable:(NSString *)table forType:(JPStorageDirectoryType)type completedBlock:(void(^)(BOOL success))block;

#pragma mark - 删除一个表格
+ (NSError *)deleteOneTable:(NSString *)table forType:(JPStorageDirectoryType)type;
+ (void)deleteOneTable:(NSString *)table forType:(JPStorageDirectoryType)type completedBlock:(void(^)(NSError *error))block;


#pragma mark - 获取表格的大小
+ (unsigned long long)sizeForTable:(NSString *)table withType:(JPStorageDirectoryType)type;


@end
