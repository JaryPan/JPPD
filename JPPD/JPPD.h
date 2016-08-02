//
//  JPPD.h
//  JPPD
//
//  Created by ovopark_iOS on 16/7/29.
//  Copyright © 2016年 JaryPan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPPDKit.h"
#import "JPPDTableManager.h"

@interface JPPD : NSObject

#pragma mark - 单例方法
+ (instancetype)sharedJPPD;

// 文件存储目录类型 (default is JPStorageDirectoryTypeCaches)
@property (assign, nonatomic) JPStorageDirectoryType type;

// 获取当前保存路径
@property (copy, nonatomic, readonly) NSString *currentPath;


#pragma mark - 保存数据
// 保存一条轻量级数据（如果key存在，其原来对应的value会被覆盖，不考虑key对应的原始数据是不是轻量级数据）
- (NSError *)writeOneLightweightValue:(id)value forKey:(NSString *)key inTable:(NSString *)table;
- (void)writeOneLightweightValue:(id)value forKey:(NSString *)key inTable:(NSString *)table completedBlock:(void(^)(NSError *error))block;

// 保存多条轻量级数据
- (NSError *)writeManyLightweightValues:(NSDictionary *)valuesDic inTable:(NSString *)table;
- (void)writeManyLightweightValues:(NSDictionary *)valuesDic inTable:(NSString *)table completedBlock:(void(^)(NSError *error))block;

// 保存一条重量级数据
- (NSError *)writeOneHeavyweightValue:(id)value forKey:(NSString *)key inTable:(NSString *)table;
- (void)writeOneHeavyweightValue:(id)value forKey:(NSString *)key inTable:(NSString *)table completedBlock:(void(^)(NSError *error))block;

// 保存多条重量级数据
- (NSError *)writeManyHeavyweightValues:(NSDictionary *)valuesDic inTable:(NSString *)table;
- (void)writeManyHeavyweightValues:(NSDictionary *)valuesDic inTable:(NSString *)table completedBlock:(void(^)(NSError *error))block;


#pragma mark - 修改数据
// 修改一条轻量级数据（不考虑key对应的原始数据是不是轻量级数据）
- (NSError *)updateOneLightweightValue:(id)newValue forKey:(NSString *)key inTable:(NSString *)table;
- (void)updateOneLightweightValue:(id)newValue forKey:(NSString *)key inTable:(NSString *)table completedBlock:(void(^)(NSError *error))block;

// 修改多条轻量级数据
- (JPErrorAndUnfoundKeys *)updateManyLightweightValues:(NSDictionary *)valuesDic inTable:(NSString *)table;
- (void)updateManyLightweightValues:(NSDictionary *)valuesDic inTable:(NSString *)table completedBlock:(void(^)(NSError *error, NSArray *unfindKeys))block;

// 修改一条重量级数据
- (NSError *)updateOneHeavyweightValue:(id)newValue forKey:(NSString *)key inTable:(NSString *)table;
- (void)updateOneHeavyweightValue:(id)newValue forKey:(NSString *)key inTable:(NSString *)table completedBlock:(void(^)(NSError *error))block;

// 修改多条重量级数据
- (JPErrorAndUnfoundKeys *)updateManyHeavyweightValues:(NSDictionary *)valuesDic inTable:(NSString *)table;
- (void)updateManyHeavyweightValues:(NSDictionary *)valuesDic inTable:(NSString *)table completedBlock:(void(^)(NSError *error, NSArray *unfindKeys))block;


#pragma mark - 查看数据
// 查看一条数据
- (JPValueAndError *)valueForKey:(NSString *)key inTable:(NSString *)table;
- (void)valueForKey:(NSString *)key inTable:(NSString *)table completedBlock:(void(^)(id value, NSError *error))block;

// 查看多条数据
- (JPFoundValusUnfoundKeysAndError *)valuesForKeys:(NSArray *)keys inTable:(NSString *)table;
- (void)valuesForKeys:(NSArray *)keys inTable:(NSString *)table completedBlock:(void(^)(NSDictionary *foundValues, NSArray *unfoundKeys, NSError *error))block;

// 查看所有数据
- (JPValueAndError *)allValuesInTable:(NSString *)table;
- (void)allValuesInTable:(NSString *)table completedBlock:(void(^)(NSDictionary *values, NSError *error))block;


#pragma mark - 删除数据
// 删除一条数据
- (NSError *)deleteOneValueForKey:(NSString *)key inTable:(NSString *)table;
- (void)deleteOneValueForKey:(NSString *)key inTable:(NSString *)table completedBlock:(void(^)(NSError *error))block;

// 删除多条数据
- (JPErrorAndUnfoundKeys *)deleteValuesForKeys:(NSArray *)keys inTable:(NSString *)table;
- (void)deleteValuesForKeys:(NSArray *)keys inTable:(NSString *)table completedBlock:(void(^)(NSError *error, NSArray *unfindKeys))block;

// 删除所有数据
- (NSError *)deleteAllValuesInTable:(NSString *)table;
- (void)deleteAllValuesInTable:(NSString *)table completedBlock:(void(^)(NSError *error))block;


#pragma mark - 删除一个表格
- (NSError *)deleteOneTable:(NSString *)table;
- (void)deleteOneTable:(NSString *)table completedBlock:(void(^)(NSError *error))block;

#pragma mark - 创建一个表格
- (BOOL)createOneTable:(NSString *)table;
- (void)createOneTable:(NSString *)table completedBlock:(void(^)(BOOL success))block;


#pragma mark - 获取表格的大小
- (unsigned long long)sizeForTable:(NSString *)table;


@end
