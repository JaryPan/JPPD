//
//  JPPD.m
//  JPPD
//
//  Created by ovopark_iOS on 16/7/29.
//  Copyright © 2016年 JaryPan. All rights reserved.
//

#import "JPPD.h"

static JPPD *instance = nil;

@implementation JPPD

#pragma mark - 单例方法
+ (instancetype)sharedJPPD
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JPPD alloc] init];
    });
    return instance;
}
// 重写init方法，保证单例地址不变
- (instancetype)init
{
    if (!instance) {
        instance = [super init];
    }
    return instance;
}


#pragma mark - 获取保存路径
- (NSString *)storagePath
{
    NSString *storagePath = nil;
    
    switch (self.type) {
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

#pragma mark - 获取当前所处的文件路径
- (NSString *)currentPath
{
    return [self storagePath];
}


#pragma mark - 获取表格对应的路径
- (NSString *)pathForTable:(NSString *)table
{
    return [[self storagePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", table]];
}

#pragma mark - 获取路径下表格对应的的字典
- (NSMutableDictionary *)mutDictionaryForTable:(NSString *)table
{
    // 获取表格路径
    NSString *tablePath = [self pathForTable:table];
    // 拿出原来的数据
    NSDictionary *originalDic = [NSDictionary dictionaryWithContentsOfFile:tablePath];
    // 将数据转移到可变字典中
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
    [mutDic addEntriesFromDictionary:originalDic];
    // 返回可变字典
    return mutDic;
}


#pragma mark - 数据归档
- (NSData *)ArchiveObject:(id)object forKey:(NSString *)key
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
#pragma mark - 反归档
- (id)unArchiveData:(id)data forKey:(NSString *)key
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


#pragma mark - 保存数据
// 保存一条轻量级数据
- (NSError *)writeOneLightweightValue:(id)value forKey:(NSString *)key inTable:(NSString *)table
{
    NSError *error = nil;
    if (!value) {
        NSString *domain = @"value can not be nil";
        error = [NSError errorWithDomain:domain code:JPErrorCodeStorageValueCannotBeNil userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeStorageValueCannotBeNil"}];
        return error;
    }
    if (!key) {
        NSString *domain = @"key can not be nil";
        error = [NSError errorWithDomain:domain code:JPErrorCodeKeyForStorageValueCannotBeNil userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeKeyForStorageValueCannotBeNil"}];
        return error;
    }
    
    // 获取表格路径
    NSString *tablePath = [self pathForTable:table];
    // 拿到路径下的字典
    NSMutableDictionary *tempDic = [self mutDictionaryForTable:table];
    // 写入传进来的数据
    [tempDic setValue:value forKey:key];
    // 存到本地
    BOOL success = [tempDic writeToFile:tablePath atomically:YES];
    
    if (!success) {
        NSString *domain = @"store failed";
        error = [NSError errorWithDomain:domain code:JPErrorCodeStoreFailed userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeStoreFailed"}];
    }
    
    return error;
}
- (void)writeOneLightweightValue:(id)value forKey:(NSString *)key inTable:(NSString *)table completedBlock:(void (^)(NSError *))block
{
    dispatch_async(dispatch_queue_create(nil, nil), ^{
        // 写入数据
        NSError *error =[self writeOneLightweightValue:value forKey:key inTable:table];
        // 判断是否实现block
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error);
            });
        }
    });
}

// 保存多条轻量级数据
- (NSError *)writeManyLightweightValues:(NSDictionary *)valuesDic inTable:(NSString *)table
{
    NSError *error = nil;
    if (!valuesDic) {
        NSString *domain = @"valuesDictionary can not be nil";
        error = [NSError errorWithDomain:domain code:JPErrorCodeStorageValuesDictionaryCannotBeNil userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeStorageValuesDictionaryCannotBeNil"}];
        return error;
    }
    
    // 获取表格路径
    NSString *tablePath = [self pathForTable:table];
    // 拿到路径下的字典
    NSMutableDictionary *tempDic = [self mutDictionaryForTable:table];
    // 写入传进来的数据
    [tempDic addEntriesFromDictionary:valuesDic];
    // 存到本地
    BOOL success = [tempDic writeToFile:tablePath atomically:YES];
    
    if (!success) {
        NSString *domain = @"store failed";
        error = [NSError errorWithDomain:domain code:JPErrorCodeStoreFailed userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeStoreFailed"}];
    }
    
    return error;
}
- (void)writeManyLightweightValues:(NSDictionary *)valuesDic inTable:(NSString *)table completedBlock:(void (^)(NSError *))block
{
    dispatch_async(dispatch_queue_create(nil, nil), ^{
        // 写入数据
        NSError *error =[self writeManyLightweightValues:valuesDic inTable:table];
        // 判断是否实现block
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error);
            });
        }
    });
}

// 保存一条重量级数据
- (NSError *)writeOneHeavyweightValue:(id)value forKey:(NSString *)key inTable:(NSString *)table
{
    NSError *error = nil;
    if (!value) {
        NSString *domain = @"value can not be nil";
        error = [NSError errorWithDomain:domain code:JPErrorCodeStorageValueCannotBeNil userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeStorageValueCannotBeNil"}];
        return error;
    }
    if (!key) {
        NSString *domain = @"key can not be nil";
        error = [NSError errorWithDomain:domain code:JPErrorCodeKeyForStorageValueCannotBeNil userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeKeyForStorageValueCannotBeNil"}];
        return error;
    }
    
    // 获取表格路径
    NSString *tablePath = [self pathForTable:table];
    // 拿到路径下的字典
    NSMutableDictionary *tempDic = [self mutDictionaryForTable:table];
    // 数据归档
    NSData *data = [self ArchiveObject:value forKey:key];
    // 写入归档后的数据
    [tempDic setValue:data forKey:key];
    // 存到本地
    BOOL success = [tempDic writeToFile:tablePath atomically:YES];
    
    if (!success) {
        NSString *domain = @"store failed";
        error = [NSError errorWithDomain:domain code:JPErrorCodeStoreFailed userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeStoreFailed"}];
    }
    
    return error;
}
- (void)writeOneHeavyweightValue:(id)value forKey:(NSString *)key inTable:(NSString *)table completedBlock:(void (^)(NSError *))block
{
    dispatch_async(dispatch_queue_create(nil, nil), ^{
        // 写入数据
        NSError *error =[self writeOneHeavyweightValue:value forKey:key inTable:table];
        // 判断是否实现block
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error);
            });
        }
    });
}

// 保存多条重量级数据
- (NSError *)writeManyHeavyweightValues:(NSDictionary *)valuesDic inTable:(NSString *)table
{
    NSError *error = nil;
    if (!valuesDic) {
        NSString *domain = @"valuesDictionary can not be nil";
        error = [NSError errorWithDomain:domain code:JPErrorCodeStorageValuesDictionaryCannotBeNil userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeStorageValuesDictionaryCannotBeNil"}];
        return error;
    }
    
    // 获取表格路径
    NSString *tablePath = [self pathForTable:table];
    // 拿到路径下的字典
    NSMutableDictionary *tempDic = [self mutDictionaryForTable:table];
    // 数据归档并存入字典中
    for (NSString *key in [valuesDic allKeys]) {
        NSData *data = [self ArchiveObject:valuesDic[key] forKey:key];
        [tempDic setValue:data forKey:key];
    }
    // 存到本地
    BOOL success = [tempDic writeToFile:tablePath atomically:YES];
    
    if (!success) {
        NSString *domain = @"store failed";
        error = [NSError errorWithDomain:domain code:JPErrorCodeStoreFailed userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeStoreFailed"}];
    }
    
    return error;
}
- (void)writeManyHeavyweightValues:(NSDictionary *)valuesDic inTable:(NSString *)table completedBlock:(void (^)(NSError *))block
{
    dispatch_async(dispatch_queue_create(nil, nil), ^{
        // 写入数据
        NSError *error = [self writeManyHeavyweightValues:valuesDic inTable:table];
        // 判断是否实现block
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error);
            });
        }
    });
}


#pragma mark - 修改数据
// 修改一条轻量级数据
- (NSError *)updateOneLightweightValue:(id)newValue forKey:(NSString *)key inTable:(NSString *)table
{
    NSError *error = nil;
    if (!newValue) {
        NSString *domain = @"value can not be nil";
        error = [NSError errorWithDomain:domain code:JPErrorCodeStorageValueCannotBeNil userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeStorageValueCannotBeNil"}];
        return error;
    }
    if (!key) {
        NSString *domain = @"key can not be nil";
        error = [NSError errorWithDomain:domain code:JPErrorCodeKeyForStorageValueCannotBeNil userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeKeyForStorageValueCannotBeNil"}];
        return error;
    }
    
    // 获取表格路径
    NSString *tablePath = [self pathForTable:table];
    // 判断表格是否存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:tablePath]) {
        // 拿到路径下的字典
        NSMutableDictionary *tempDic = [self mutDictionaryForTable:table];
        // 判断是否有对应的key
        if ([[tempDic allKeys] containsObject:key]) {
            // 修改数据
            [tempDic setValue:newValue forKey:key];
            // 写入本地
            BOOL success = [tempDic writeToFile:tablePath atomically:YES];
            
            if (!success) {
                NSString *domain = @"update failed";
                error = [NSError errorWithDomain:domain code:JPErrorCodeUpdateFailed userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeUpdateFailed"}];
            }
        } else {
            NSString *domain = [NSString stringWithFormat:@"key '%@' does not exist", key];
            error = [NSError errorWithDomain:domain code:JPErrorCodeNoSuchKey userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeNoSuchKey"}];
        }
    } else {
        NSString *domain = [NSString stringWithFormat:@"table '%@' does not exist", table];
        error = [NSError errorWithDomain:domain code:JPErrorCodeNoSuchTable userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeNoSuchTable"}];
    }
    
    return error;
}
- (void)updateOneLightweightValue:(id)newValue forKey:(NSString *)key inTable:(NSString *)table completedBlock:(void (^)(NSError *))block
{
    dispatch_async(dispatch_queue_create(nil, nil), ^{
        // 写入数据
        NSError *error = [self updateOneLightweightValue:newValue forKey:key inTable:table];
        // 判断是否实现block
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error);
            });
        }
    });
}

// 修改多条轻量级数据
- (JPErrorAndUnfoundKeys *)updateManyLightweightValues:(NSDictionary *)valuesDic inTable:(NSString *)table
{
    if (!valuesDic) {
        NSString *domain = @"valuesDictionary can not be nil";
        NSError *error = [NSError errorWithDomain:domain code:JPErrorCodeStorageValuesDictionaryCannotBeNil userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeStorageValuesDictionaryCannotBeNil"}];
        return [[JPErrorAndUnfoundKeys alloc] initWithError:error andUnfoundKeys:nil];
    }
    
    // 获取表格路径
    NSString *tablePath = [self pathForTable:table];
    // 判断表格是否存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:tablePath]) {
        // 拿到路径下的字典
        NSMutableDictionary *tempDic = [self mutDictionaryForTable:table];
        // 初始化一个可变数组
        NSMutableArray *unfoundKeys = [NSMutableArray array];
        // 修改数据并将原本不存在的key剥离出来
        for (NSString *key in [valuesDic allKeys]) {
            if ([[tempDic allKeys] containsObject:key]) {
                [tempDic setValue:valuesDic[key] forKey:key];
            } else {
                [unfoundKeys addObject:key];
            }
        }
        // 保存数据
        BOOL success = [tempDic writeToFile:tablePath atomically:YES];
        
        if (!success) {
            NSString *domain = @"update failed";
            NSError *error = [NSError errorWithDomain:domain code:JPErrorCodeUpdateFailed userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeUpdateFailed"}];
            if (unfoundKeys.count == 0) {
                unfoundKeys = nil;
            }
            return [[JPErrorAndUnfoundKeys alloc] initWithError:error andUnfoundKeys:unfoundKeys];
        } else {
            NSError *error = nil;
            if (unfoundKeys.count == 0) {
                unfoundKeys = nil;
            } else {
                NSString *domain = @"some keys for updating not found";
                error = [NSError errorWithDomain:domain code:JPErrorCodeSomeKeysForUpdatingNotFound userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeSomeKeysForUpdatingNotFound"}];
            }
            return [[JPErrorAndUnfoundKeys alloc] initWithError:nil andUnfoundKeys:unfoundKeys];
        }
    } else {
        NSString *domain = [NSString stringWithFormat:@"table '%@' does not exist", table];
        NSError *error = [NSError errorWithDomain:domain code:JPErrorCodeNoSuchTable userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeNoSuchTable"}];
        return [[JPErrorAndUnfoundKeys alloc] initWithError:error andUnfoundKeys:nil];
    }
}
- (void)updateManyLightweightValues:(NSDictionary *)valuesDic inTable:(NSString *)table completedBlock:(void (^)(NSError *, NSArray *))block
{
    dispatch_async(dispatch_queue_create(nil, nil), ^{
        // 写入数据
        JPErrorAndUnfoundKeys *eau = [self updateManyLightweightValues:valuesDic inTable:table];
        // 判断是否实现block
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(eau.error, eau.unfoundKeys);
            });
        }
    });
}

// 修改一条重量级数据
- (NSError *)updateOneHeavyweightValue:(id)newValue forKey:(NSString *)key inTable:(NSString *)table
{
    NSError *error = nil;
    if (!newValue) {
        NSString *domain = @"value can not be nil";
        error = [NSError errorWithDomain:domain code:JPErrorCodeStorageValueCannotBeNil userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeStorageValueCannotBeNil"}];
        return error;
    }
    if (!key) {
        NSString *domain = @"key can not be nil";
        error = [NSError errorWithDomain:domain code:JPErrorCodeKeyForStorageValueCannotBeNil userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeKeyForStorageValueCannotBeNil"}];
        return error;
    }
    
    // 获取表格路径
    NSString *tablePath = [self pathForTable:table];
    // 判断表格是否存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:tablePath]) {
        // 拿到路径下的字典
        NSMutableDictionary *tempDic = [self mutDictionaryForTable:table];
        // 判断是否有对应的key
        if ([[tempDic allKeys] containsObject:key]) {
            // 归档数据
            NSData *data = [self ArchiveObject:newValue forKey:key];
            // 修改数据
            [tempDic setValue:data forKey:key];
            // 写入本地
            BOOL success = [tempDic writeToFile:tablePath atomically:YES];
            
            if (!success) {
                NSString *domain = @"update failed";
                error = [NSError errorWithDomain:domain code:JPErrorCodeUpdateFailed userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeUpdateFailed"}];
            }
        } else {
            NSString *domain = [NSString stringWithFormat:@"key '%@' does not exist", key];
            error = [NSError errorWithDomain:domain code:JPErrorCodeNoSuchKey userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeNoSuchKey"}];
        }
    } else {
        NSString *domain = [NSString stringWithFormat:@"table '%@' does not exist", table];
        error = [NSError errorWithDomain:domain code:JPErrorCodeNoSuchTable userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeNoSuchTable"}];
    }
    
    return error;
}
- (void)updateOneHeavyweightValue:(id)newValue forKey:(NSString *)key inTable:(NSString *)table completedBlock:(void (^)(NSError *))block
{
    dispatch_async(dispatch_queue_create(nil, nil), ^{
        // 写入数据
        NSError *error = [self updateOneHeavyweightValue:newValue forKey:key inTable:table];
        // 判断是否实现block
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error);
            });
        }
    });
}

// 修改多条重量级数据
- (JPErrorAndUnfoundKeys *)updateManyHeavyweightValues:(NSDictionary *)valuesDic inTable:(NSString *)table
{
    if (!valuesDic) {
        NSString *domain = @"valuesDictionary can not be nil";
        NSError *error = [NSError errorWithDomain:domain code:JPErrorCodeStorageValuesDictionaryCannotBeNil userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeStorageValuesDictionaryCannotBeNil"}];
        return [[JPErrorAndUnfoundKeys alloc] initWithError:error andUnfoundKeys:nil];
    }
    
    // 获取表格路径
    NSString *tablePath = [self pathForTable:table];
    // 判断表格是否存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:tablePath]) {
        // 拿到路径下的字典
        NSMutableDictionary *tempDic = [self mutDictionaryForTable:table];
        // 初始化一个可变数组
        NSMutableArray *unfoundKeys = [NSMutableArray array];
        // 修改数据并将原本不存在的key剥离出来
        for (NSString *key in [valuesDic allKeys]) {
            if ([[tempDic allKeys] containsObject:key]) {
                // 归档数据
                NSData *data = [self ArchiveObject:valuesDic[key] forKey:key];
                // 修改数据
                [tempDic setValue:data forKey:key];
            } else {
                [unfoundKeys addObject:key];
            }
        }
        // 保存数据
        BOOL success = [tempDic writeToFile:tablePath atomically:YES];
        
        if (!success) {
            NSString *domain = @"update failed";
            NSError *error = [NSError errorWithDomain:domain code:JPErrorCodeUpdateFailed userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeUpdateFailed"}];
            if (unfoundKeys.count == 0) {
                unfoundKeys = nil;
            }
            return [[JPErrorAndUnfoundKeys alloc] initWithError:error andUnfoundKeys:unfoundKeys];
        } else {
            NSError *error = nil;
            if (unfoundKeys.count == 0) {
                unfoundKeys = nil;
            } else {
                NSString *domain = @"some keys for updating not found";
                error = [NSError errorWithDomain:domain code:JPErrorCodeSomeKeysForUpdatingNotFound userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeSomeKeysForUpdatingNotFound"}];
            }
            return [[JPErrorAndUnfoundKeys alloc] initWithError:nil andUnfoundKeys:unfoundKeys];
        }
    } else {
        NSString *domain = [NSString stringWithFormat:@"table '%@' does not exist", table];
        NSError *error = [NSError errorWithDomain:domain code:JPErrorCodeNoSuchTable userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeNoSuchTable"}];
        return [[JPErrorAndUnfoundKeys alloc] initWithError:error andUnfoundKeys:nil];
    }
}
- (void)updateManyHeavyweightValues:(NSDictionary *)valuesDic inTable:(NSString *)table completedBlock:(void (^)(NSError *, NSArray *))block
{
    dispatch_async(dispatch_queue_create(nil, nil), ^{
        // 写入数据
        JPErrorAndUnfoundKeys *eau = [self updateManyHeavyweightValues:valuesDic inTable:table];
        // 判断是否实现block
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(eau.error, eau.unfoundKeys);
            });
        }
    });
}


#pragma mark - 查看数据
// 查看一条数据
- (JPValueAndError *)valueForKey:(NSString *)key inTable:(NSString *)table
{
    if (!key) {
        NSString *domain = @"key for reading can not be nil";
        NSError *error = [NSError errorWithDomain:domain code:JPErrorCodeKeyForReadingCannotBeNil userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeKeyForReadingCannotBeNil"}];
        return [[JPValueAndError alloc] initWithValue:nil andError:error];
    }
    
    // 获取表格路径
    NSString *tablePath = [self pathForTable:table];
    // 判断表格是否存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:tablePath]) {
        // 拿到路径下的字典
        NSMutableDictionary *tempDic = [self mutDictionaryForTable:table];
        // 判断是否有对应的key
        if ([[tempDic allKeys] containsObject:key]) {
            // 数据反归档
            id value = [self unArchiveData:tempDic[key] forKey:key];
            // 判断值是否为空
            if (value) {
                return [[JPValueAndError alloc] initWithValue:value andError:nil];
            } else {
                NSString *domain = [NSString stringWithFormat:@"valueForkey'%@' does not exist", key];
                NSError *error = [NSError errorWithDomain:domain code:JPErrorCodeNoValueForProvidedKey userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeNoValueForProvidedKey"}];
                return [[JPValueAndError alloc] initWithValue:nil andError:error];
            }
        } else {
            NSString *domain = [NSString stringWithFormat:@"key '%@' does not exist", key];
            NSError *error = [NSError errorWithDomain:domain code:JPErrorCodeNoSuchKey userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeNoSuchKey"}];
            return [[JPValueAndError alloc] initWithValue:nil andError:error];
        }
    } else {
        NSString *domain = [NSString stringWithFormat:@"table '%@' does not exist", table];
        NSError *error = [NSError errorWithDomain:domain code:JPErrorCodeNoSuchTable userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeNoSuchTable"}];
        return [[JPValueAndError alloc] initWithValue:nil andError:error];
    }
}
- (void)valueForKey:(NSString *)key inTable:(NSString *)table completedBlock:(void (^)(id, NSError *))block
{
    dispatch_async(dispatch_queue_create(nil, nil), ^{
        // 读取数据
        JPValueAndError *vae = [self valueForKey:key inTable:table];
        // 判断是否实现block
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(vae.value, vae.error);
            });
        }
    });
}

// 查看多条数据
- (JPFoundValusUnfoundKeysAndError *)valuesForKeys:(NSArray *)keys inTable:(NSString *)table
{
    if (!keys) {
        NSString *domain = @"keys(array) for reading cannot be nil";
        NSError *error = [NSError errorWithDomain:domain code:JPErrorCodeKeysArrayForReadingCannotBeNil userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeKeysArrayForReadingCannotBeNil"}];
        return [[JPFoundValusUnfoundKeysAndError alloc] initWithFoundValus:nil unfoundKeys:nil andError:error];
    }
    
    // 获取表格路径
    NSString *tablePath = [self pathForTable:table];
    // 判断表格是否存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:tablePath]) {
        // 拿到路径下的字典
        NSMutableDictionary *tempDic = [self mutDictionaryForTable:table];
        // 准备可变字典和可变数组
        NSMutableDictionary *foundValues = [NSMutableDictionary dictionary];
        NSMutableArray *unfoundKeys = [NSMutableArray array];
        // 装入找到的数据并将不存的key剥离出来
        for (NSString *key in keys) {
            if ([[tempDic allKeys] containsObject:key]) {
                // 数据反归档
                id value = [self unArchiveData:tempDic[key] forKey:key];
                // 判断值是否为空
                if (value) {
                    [foundValues setValue:value forKey:key];
                } else {
                    // 如果拿到的数据为空，也认为不存在这样的key值
                    [unfoundKeys addObject:key];
                }
            } else {
                [unfoundKeys addObject:key];
            }
        }
        
        if ([foundValues allKeys].count == 0) {
            foundValues = nil;
        }
        if (unfoundKeys.count == 0) {
            unfoundKeys = nil;
        }
        
        if (unfoundKeys) {
            NSString *domain = @"some keys for reading are invalid";
            NSError *error = [NSError errorWithDomain:domain code:JPErrorCodeSomeKeysForReadingNotFound userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeSomeKeysForReadingNotFound"}];
            return [[JPFoundValusUnfoundKeysAndError alloc] initWithFoundValus:foundValues unfoundKeys:unfoundKeys andError:error];
        } else {
            return [[JPFoundValusUnfoundKeysAndError alloc] initWithFoundValus:foundValues unfoundKeys:unfoundKeys andError:nil];
        }
    } else {
        NSString *domain = [NSString stringWithFormat:@"table '%@' does not exist", table];
        NSError *error = [NSError errorWithDomain:domain code:JPErrorCodeNoSuchTable userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeNoSuchTable"}];
        return [[JPFoundValusUnfoundKeysAndError alloc] initWithFoundValus:nil unfoundKeys:nil andError:error];
    }
}
- (void)valuesForKeys:(NSArray *)keys inTable:(NSString *)table completedBlock:(void (^)(NSDictionary *, NSArray *, NSError *))block
{
    dispatch_async(dispatch_queue_create(nil, nil), ^{
        // 读取数据
        JPFoundValusUnfoundKeysAndError *fuae = [self valuesForKeys:keys inTable:table];
        // 判断是否实现block
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(fuae.foundValus, fuae.unfoundKeys, fuae.error);
            });
        }
    });
}

// 查看所有数据
- (JPValueAndError *)allValuesInTable:(NSString *)table
{
    // 获取表格路径
    NSString *tablePath = [self pathForTable:table];
    // 判断表格是否存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:tablePath]) {
        // 拿到路径下的字典
        NSMutableDictionary *tempDic = [self mutDictionaryForTable:table];
        return [[JPValueAndError alloc] initWithValue:tempDic andError:nil];
    } else {
        NSString *domain = [NSString stringWithFormat:@"table '%@' does not exist", table];
        NSError *error = [NSError errorWithDomain:domain code:JPErrorCodeNoSuchTable userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeNoSuchTable"}];
        return [[JPValueAndError alloc] initWithValue:nil andError:error];
    }
}
- (void)allValuesInTable:(NSString *)table completedBlock:(void (^)(NSDictionary *, NSError *))block
{
    dispatch_async(dispatch_queue_create(nil, nil), ^{
        // 读取数据
        JPValueAndError *vae = [self allValuesInTable:table];
        // 判断是否实现block
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(vae.value, vae.error);
            });
        }
    });
}


#pragma mark - 删除数据
// 删除一条数据
- (NSError *)deleteOneValueForKey:(NSString *)key inTable:(NSString *)table
{
    NSError *error = nil;
    if (!key) {
        NSString *domain = @"key for deleting cannot be nil";
        error = [NSError errorWithDomain:domain code:JPErrorCodeKeyForDeletingCannotBeNil userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeKeyForDeletingCannotBeNil"}];
        return error;
    }
    
    // 获取表格路径
    NSString *tablePath = [self pathForTable:table];
    // 判断表格是否存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:tablePath]) {
        // 拿到路径下的字典
        NSMutableDictionary *tempDic = [self mutDictionaryForTable:table];
        // 判断是否包含key
        if ([[tempDic allKeys] containsObject:key]) {
            // 删除数据
            [tempDic removeObjectForKey:key];
            // 写入本地
            BOOL success = [tempDic writeToFile:tablePath atomically:YES];
            // 判断是否成功
            if (!success) {
                NSString *domain = @"delete failed";
                error = [NSError errorWithDomain:domain code:JPErrorCodeDeleteFailed userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeDeleteFailed"}];
            }
            
            return error;
        } else {
            NSString *domain = [NSString stringWithFormat:@"key '%@' for deleting value does not exist", key];
            error = [NSError errorWithDomain:domain code:JPErrorCodeNoSuchKey userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeNoSuchKey"}];
            return error;
        }
    } else {
        NSString *domain = [NSString stringWithFormat:@"table '%@' does not exist", table];
        error = [NSError errorWithDomain:domain code:JPErrorCodeNoSuchTable userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeNoSuchTable"}];
        return error;
    }
}
- (void)deleteOneValueForKey:(NSString *)key inTable:(NSString *)table completedBlock:(void (^)(NSError *))block
{
    dispatch_async(dispatch_queue_create(nil, nil), ^{
        // 删除数据
        NSError *error = [self deleteOneValueForKey:key inTable:table];
        // 判断是否实现block
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error);
            });
        }
    });
}

// 删除多条数据
- (JPErrorAndUnfoundKeys *)deleteValuesForKeys:(NSArray *)keys inTable:(NSString *)table
{
    if (!keys) {
        NSString *domain = @"keys(array) for deleting cannot be nil";
        NSError *error = [NSError errorWithDomain:domain code:JPErrorCodeKeysArrayForDeletingCannotBeNil userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeKeysArrayForDeletingCannotBeNil"}];
        return [[JPErrorAndUnfoundKeys alloc] initWithError:error andUnfoundKeys:nil];;
    }
    
    // 获取表格路径
    NSString *tablePath = [self pathForTable:table];
    // 判断表格是否存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:tablePath]) {
        // 拿到路径下的字典
        NSMutableDictionary *tempDic = [self mutDictionaryForTable:table];
        // 准备可变字典
        NSMutableArray *unfoundKeys = [NSMutableArray array];
        // 删除数据并将不存在的key剥离出来
        for (NSString *key in keys) {
            if ([[tempDic allKeys] containsObject:key]) {
                // 删除数据
                [tempDic removeObjectForKey:key];
            } else {
                [unfoundKeys addObject:key];
            }
        }
        
        if (unfoundKeys.count == 0) {
            unfoundKeys = nil;
        }
        
        // 写入本地
        BOOL success = [tempDic writeToFile:tablePath atomically:YES];
        // 判断是否成功
        if (success) {
            return [[JPErrorAndUnfoundKeys alloc] initWithError:nil andUnfoundKeys:unfoundKeys];
        } else {
            NSString *domain = @"delete failed";
            NSError *error = [NSError errorWithDomain:domain code:JPErrorCodeDeleteFailed userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeDeleteFailed"}];
            return [[JPErrorAndUnfoundKeys alloc] initWithError:error andUnfoundKeys:unfoundKeys];
        }
    } else {
        NSString *domain = [NSString stringWithFormat:@"table '%@' does not exist", table];
        NSError *error = [NSError errorWithDomain:domain code:JPErrorCodeNoSuchTable userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeNoSuchTable"}];
        return [[JPErrorAndUnfoundKeys alloc] initWithError:error andUnfoundKeys:nil];;
    }
}
- (void)deleteValuesForKeys:(NSArray *)keys inTable:(NSString *)table completedBlock:(void (^)(NSError *, NSArray *))block
{
    dispatch_async(dispatch_queue_create(nil, nil), ^{
        // 删除数据
        JPErrorAndUnfoundKeys *eau = [self deleteValuesForKeys:keys inTable:table];
        // 判断是否实现block
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(eau.error, eau.unfoundKeys);
            });
        }
    });
}

// 删除所有数据
- (NSError *)deleteAllValuesInTable:(NSString *)table
{
    NSError *error = nil;
    
    // 获取表格路径
    NSString *tablePath = [self pathForTable:table];
    // 判断表格是否存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:tablePath]) {
        // 拿到路径下的字典
        NSMutableDictionary *tempDic = [self mutDictionaryForTable:table];
        [tempDic removeAllObjects];
        // 写入数据
        BOOL success = [tempDic writeToFile:tablePath atomically:YES];
        // 判断写入是否成功
        if (success) {
            return nil;
        } else {
            NSString *domain = @"delete failed";
            error = [NSError errorWithDomain:domain code:JPErrorCodeDeleteFailed userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeDeleteFailed"}];
            return error;
        }
    } else {
        NSString *domain = [NSString stringWithFormat:@"table '%@' does not exist", table];
        error = [NSError errorWithDomain:domain code:JPErrorCodeNoSuchTable userInfo:@{@"domain":domain, @"errorCode":@"JPErrorCodeNoSuchTable"}];
        return error;
    }
}
- (void)deleteAllValuesInTable:(NSString *)table completedBlock:(void (^)(NSError *))block
{
    dispatch_async(dispatch_queue_create(nil, nil), ^{
        // 删除数据
        NSError *error = [self deleteAllValuesInTable:table];
        // 判断是否实现block
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(error);
            });
        }
    });
}


#pragma mark - 删除一个表格
- (NSError *)deleteOneTable:(NSString *)table
{
    return [JPPDTableManager deleteOneTable:table forType:self.type];
}
- (void)deleteOneTable:(NSString *)table completedBlock:(void (^)(NSError *))block
{
    [JPPDTableManager deleteOneTable:table forType:self.type completedBlock:^(NSError *error) {
        if (block) {
            block(error);
        }
    }];
}

#pragma mark - 创建一个表格
- (BOOL)createOneTable:(NSString *)table
{
    return [JPPDTableManager createOneTable:table forType:self.type];
}
- (void)createOneTable:(NSString *)table completedBlock:(void (^)(BOOL))block
{
    [JPPDTableManager createOneTable:table forType:self.type completedBlock:^(BOOL success) {
        if (block) {
            block(success);
        }
    }];
}


#pragma mark - 获取表格的大小
- (unsigned long long)sizeForTable:(NSString *)table
{
    return [JPPDTableManager sizeForTable:table withType:self.type];
}


@end
