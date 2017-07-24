//
//  JPPD.m
//  JPPD
//
//  Created by 潘建磊 on 15/7/29.
//  Copyright © 2015年 JaryPan. All rights reserved.
//


#import "JPPD.h"

static JPPD *instance = nil;

@interface JPPD ()

@property (strong, nonatomic) dispatch_queue_t queue;

@end

@implementation JPPD

// 获取数据操作的线程
static void operateQueue(void(^block)()) {
    dispatch_barrier_sync(instance.queue, block);
}

// 获取主线程
static void mainQueue(void(^block)()) {
    dispatch_async(dispatch_get_main_queue(), block);
}

#pragma mark - 单例方法
+ (instancetype)sharedJPPD
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JPPD alloc] init];
        [instance commonInit];
    });
    return instance;
}
// 重写init方法，保证单例地址不变
- (void)commonInit
{
    self.queue = dispatch_queue_create("JPPD_data_operate_QUEUE", DISPATCH_QUEUE_CONCURRENT);
    instance.type = JPStorageDirectoryTypeCaches;
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"JPPD"];
    [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
}


#pragma mark - 当前文件保存主路径
- (NSString *)mainFilePath
{
    return [JPPDUtils storagePath];
}


#pragma mark - 获取表格对应的路径
- (NSString *)pathForTable:(NSString *)table
{
    return [self.mainFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"JPPD/%@.plist", table]];
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





#pragma mark - ********** 保存数据 / 修改数据 **********

#pragma mark - 保存一条数据
- (void)saveValue:(id)value forKey:(NSString *)key inTable:(NSString *)table completionHandler:(void (^)(NSError * _Nullable))completionHandler
{
    operateQueue(^{
        if (!value) {
            if (completionHandler) {
                mainQueue(^{
                    completionHandler([JPPDUtils errorWithDomain:@"value will be stored can not be nil" andCode:JPErrorCodeValueCannotBeNull]);
                });
            }
            return;
        }
        if (!key || key.length == 0) {
            if (completionHandler) {
                mainQueue(^{
                    completionHandler([JPPDUtils errorWithDomain:@"key for storing can not be nil" andCode:JPErrorCodeKeyCannotBeNull]);
                });
            }
            return;
        }
        if (!table || table.length == 0) {
            if (completionHandler) {
                mainQueue(^{
                    completionHandler([JPPDUtils errorWithDomain:@"table for storing can not be nil" andCode:JPErrorCodeTableNameCannotBeNull]);
                });
            }
            return;
        }
        
        // 获取文件路径
        NSString *tablePath = [self pathForTable:table];
        // 判断文件是否存在
        if (![[NSFileManager defaultManager] fileExistsAtPath:tablePath]) {
            BOOL success = [[NSFileManager defaultManager] createFileAtPath:tablePath contents:nil attributes:nil];
            if (!success) {
                if (completionHandler) {
                    mainQueue(^{
                        completionHandler([JPPDUtils errorWithDomain:@"create table failed" andCode:JPErrorCodeCreateTableFailed]);
                    });
                }
                return;
            }
        }
        // 拿到路径下的字典
        NSMutableDictionary *tempDic = [self mutDictionaryForTable:table];
        // 写入传进来的数据
        [tempDic setValue:[JPPDUtils storableValue:value withKey:key] forKey:key];
        // 存到本地
        BOOL success = [tempDic writeToFile:tablePath atomically:YES];
        // 判断结果
        NSError *error = nil;
        if (!success) {
            error = [JPPDUtils errorWithDomain:@"store failed" andCode:JPErrorCodeStoreFailed];
        }
        // 实现block
        if (completionHandler) {
            mainQueue(^{
                completionHandler(error);
            });
        }
    });
}

#pragma mark - 保存多条数据
- (void)saveValues:(NSDictionary<NSString *,id> *)values inTable:(NSString *)table completionHandler:(void (^)(NSError * _Nullable))completionHandler
{
    operateQueue(^{
        if (!values || [[values allKeys] count] == 0) {
            if (completionHandler) {
                mainQueue(^{
                    completionHandler([JPPDUtils errorWithDomain:@"values will be stored can not be nil or empty dictionary" andCode:JPErrorCodeValueCannotBeNull]);
                });
            }
            return;
        }
        if (!table || table.length == 0) {
            if (completionHandler) {
                mainQueue(^{
                    completionHandler([JPPDUtils errorWithDomain:@"table for storing can not be nil" andCode:JPErrorCodeTableNameCannotBeNull]);
                });
            }
            return;
        }
        
        // 获取文件路径
        NSString *tablePath = [self pathForTable:table];
        // 判断文件是否存在
        if (![[NSFileManager defaultManager] fileExistsAtPath:tablePath]) {
            BOOL success = [[NSFileManager defaultManager] createFileAtPath:tablePath contents:nil attributes:nil];
            if (!success) {
                if (completionHandler) {
                    mainQueue(^{
                        completionHandler([JPPDUtils errorWithDomain:@"create table failed" andCode:JPErrorCodeCreateTableFailed]);
                    });
                }
                return;
            }
        }
        // 拿到路径下的字典
        NSMutableDictionary *tempDic = [self mutDictionaryForTable:table];
        // 写入传进来的数据
        for (NSString *key in [values allKeys]) {
            id value = [JPPDUtils storableValue:values[key] withKey:key];
            [tempDic setValue:value forKey:key];
        }
        // 存到本地
        BOOL success = [tempDic writeToFile:tablePath atomically:YES];
        // 判断结果
        NSError *error = nil;
        if (!success) {
            error = [JPPDUtils errorWithDomain:@"store failed" andCode:JPErrorCodeStoreFailed];
        }
        // 实现block
        if (completionHandler) {
            mainQueue(^{
                completionHandler(error);
            });
        }
    });
}


#pragma mark - ********** 查看数据 **********

#pragma mark - 查看一条数据
- (void)valueForKey:(NSString *)key inTable:(NSString *)table completionHandler:(void (^ _Nullable)(id _Nullable, NSError * _Nullable))completionHandler
{
    operateQueue(^{
        if (!key || key.length == 0) {
            if (completionHandler) {
                mainQueue(^{
                    completionHandler(nil, [JPPDUtils errorWithDomain:@"key for reading can not be nil" andCode:JPErrorCodeKeyCannotBeNull]);
                });
            }
            return;
        }
        if (!table || table.length == 0) {
            if (completionHandler) {
                mainQueue(^{
                    completionHandler(nil, [JPPDUtils errorWithDomain:@"table for reading can not be nil" andCode:JPErrorCodeTableNameCannotBeNull]);
                });
            }
            return;
        }
        
        // 获取文件路径
        NSString *tablePath = [self pathForTable:table];
        // 判断文件是否存在
        if ([[NSFileManager defaultManager] fileExistsAtPath:tablePath]) {
            // 拿到路径下的字典
            NSMutableDictionary *tempDic = [self mutDictionaryForTable:table];
            // 判断是否有对应的key
            if ([[tempDic allKeys] containsObject:key]) {
                // 数据反归档
                id value = [JPPDUtils readableValue:tempDic[key] withKey:key];
                // 判断值是否为空
                if (value) {
                    if (completionHandler) {
                        mainQueue(^{
                            completionHandler(value, nil);
                        });
                    }
                } else {
                    // 字典中找不到对应的值
                    if (completionHandler) {
                        mainQueue(^{
                            completionHandler(nil, [JPPDUtils errorWithDomain:[NSString stringWithFormat:@"value for key '%@' does not exist'", key] andCode:JPErrorCodeValueForProvidedKeyNotFound]);
                        });
                    }
                }
            } else {
                // 存储的字典中并没有对应的值
                if (completionHandler) {
                    mainQueue(^{
                        completionHandler(nil, [JPPDUtils errorWithDomain:[NSString stringWithFormat:@"key '%@' does not exist in table '%@'", key, table] andCode:JPErrorCodeInvalidKey]);
                    });
                }
            }
        } else {
            // 表格不存在
            if (completionHandler) {
                mainQueue(^{
                    completionHandler(nil, [JPPDUtils errorWithDomain:[NSString stringWithFormat:@"table '%@' does not exist", table] andCode:JPErrorCodeNoSuchTable]);
                });
            }
        }
    });
}
- (id)valueForKey:(NSString *)key inTable:(NSString *)table
{
    // 暂停子线程
    dispatch_suspend(self.queue);
    
    if (!key || key.length == 0 || !table || table.length == 0) {
        // 恢复子线程
        dispatch_resume(self.queue);
        return nil;
    }
    
    // 获取文件路径
    NSString *tablePath = [self pathForTable:table];
    // 判断文件是否存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:tablePath]) {
        // 拿到路径下的字典
        NSMutableDictionary *tempDic = [self mutDictionaryForTable:table];
        // 判断是否有对应的key
        if ([[tempDic allKeys] containsObject:key]) {
            // 数据反归档
            id value = [JPPDUtils readableValue:tempDic[key] withKey:key];
            // 恢复子线程
            dispatch_resume(self.queue);
            // 返回数据
            return value;
        } else {
            // 存储的字典中并没有对应的值
            // 恢复子线程
            dispatch_resume(self.queue);
            return nil;
        }
    } else {
        // 表格不存在
        // 恢复子线程
        dispatch_resume(self.queue);
        return nil;
    }
}

#pragma mark - 查看多条数据
- (void)valuesForKeys:(NSArray<NSString *> *)keys inTable:(NSString *)table completionHandler:(void (^)(NSDictionary<NSString *,id> * _Nullable, NSArray<NSString *> * _Nullable, NSError * _Nullable))completionHandler
{
    operateQueue(^{
        if (!keys || keys.count == 0) {
            if (completionHandler) {
                mainQueue(^{
                    completionHandler(nil, nil, [JPPDUtils errorWithDomain:@"keys for reading can not be nil or empty" andCode:JPErrorCodeKeyCannotBeNull]);
                });
            }
            return;
        }
        if (!table || table.length == 0) {
            if (completionHandler) {
                mainQueue(^{
                    completionHandler(nil, nil, [JPPDUtils errorWithDomain:@"table for reading can not be nil" andCode:JPErrorCodeTableNameCannotBeNull]);
                });
            }
            return;
        }
        
        // 获取文件路径
        NSString *tablePath = [self pathForTable:table];
        // 判断文件是否存在
        if ([[NSFileManager defaultManager] fileExistsAtPath:tablePath]) {
            // 拿到路径下的字典
            NSMutableDictionary *tempDic = [self mutDictionaryForTable:table];
            // 将存在key的值装进准备好的字典中
            NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
            NSMutableArray *unfoundKeys = [NSMutableArray array];
            NSArray *tempDicKeys = [tempDic allKeys];
            for (NSString *key in keys) {
                if ([tempDicKeys containsObject:key]) {
                    id value = [JPPDUtils readableValue:tempDic[key] withKey:key];
                    if (value) {
                        [returnDic setValue:value forKey:key];
                    } else {
                        [unfoundKeys addObject:key];
                    }
                } else {
                    [unfoundKeys addObject:key];
                }
            }
            
            if (completionHandler) {
                NSError *error = nil;
                if ([returnDic allKeys].count == 0) {
                    returnDic = nil;
                    error = [JPPDUtils errorWithDomain:@"keys are all invalid" andCode:JPErrorCodeInvalidKey];
                }
                if (unfoundKeys.count == 0) {
                    unfoundKeys = nil;
                }
                mainQueue(^{
                    completionHandler(returnDic, unfoundKeys, error);
                });
            }
        } else {
            // 表格不存在
            if (completionHandler) {
                mainQueue(^{
                    completionHandler(nil, nil, [JPPDUtils errorWithDomain:[NSString stringWithFormat:@"table '%@' does not exist", table] andCode:JPErrorCodeNoSuchTable]);
                });
            }
        }
    });
}
- (NSDictionary<NSString *,id> *)valuesForKeys:(NSArray<NSString *> *)keys inTable:(NSString *)table
{
    // 暂停子线程
    dispatch_suspend(self.queue);
    
    if (!keys || keys.count == 0 || !table || table.length == 0) {
        // 恢复子线程
        dispatch_resume(self.queue);
        return nil;
    }
    
    // 获取文件路径
    NSString *tablePath = [self pathForTable:table];
    // 判断文件是否存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:tablePath]) {
        // 拿到路径下的字典
        NSMutableDictionary *tempDic = [self mutDictionaryForTable:table];
        // 将存在key的值装进准备好的字典中
        NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
        NSArray *tempDicKeys = [tempDic allKeys];
        for (NSString *key in keys) {
            if ([tempDicKeys containsObject:key]) {
                id value = [JPPDUtils readableValue:tempDic[key] withKey:key];
                if (value) {
                    [returnDic setValue:value forKey:key];
                }
            }
        }
        
        /// 恢复子线程
        dispatch_resume(self.queue);
        return returnDic;
    } else {
        // 表格不存在
        // 恢复子线程
        dispatch_resume(self.queue);
        return nil;
    }
}

#pragma mark - 查看一个表格中的所有数据
- (void)allValuesInTable:(NSString *)table completionHandler:(void (^ _Nullable)(NSDictionary<NSString *,id> * _Nullable, NSError * _Nullable))completionHandler
{
    operateQueue(^{
        if (!table || table.length == 0) {
            if (completionHandler) {
                mainQueue(^{
                    completionHandler(nil, [JPPDUtils errorWithDomain:@"table for reading can not be nil" andCode:JPErrorCodeTableNameCannotBeNull]);
                });
            }
            return;
        }
        
        // 获取文件路径
        NSString *tablePath = [self pathForTable:table];
        // 判断文件是否存在
        if ([[NSFileManager defaultManager] fileExistsAtPath:tablePath]) {
            // 拿到路径下的字典
            NSMutableDictionary *tempDic = [self mutDictionaryForTable:table];
            // 将存在key的值装进准备好的字典中
            NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
            for (NSString *key in [tempDic allKeys]) {
                id value = [JPPDUtils readableValue:tempDic[key] withKey:key];
                if (value) {
                    [returnDic setValue:value forKey:key];
                }
            }
            
            if (completionHandler) {
                NSError *error = nil;
                if ([returnDic allKeys].count == 0) {
                    returnDic = nil;
                    error = [JPPDUtils errorWithDomain:[NSString stringWithFormat:@"table '%@' contains no value", table] andCode:JPErrorCodeTableContainsNoValue];
                }
                mainQueue(^{
                    completionHandler(returnDic, error);
                });
            }
        } else {
            // 表格不存在
            if (completionHandler) {
                mainQueue(^{
                    completionHandler(nil, [JPPDUtils errorWithDomain:[NSString stringWithFormat:@"table '%@' does not exist", table] andCode:JPErrorCodeNoSuchTable]);
                });
            }
        }
    });
}
- (NSDictionary<NSString *,id> *)allValuesInTable:(NSString *)table
{
    // 暂停子线程
    dispatch_suspend(self.queue);
    
    if (!table || table.length == 0) {
        // 恢复子线程
        dispatch_resume(self.queue);
        return nil;
    }
    
    // 获取文件路径
    NSString *tablePath = [self pathForTable:table];
    // 判断文件是否存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:tablePath]) {
        // 拿到路径下的字典
        NSMutableDictionary *tempDic = [self mutDictionaryForTable:table];
        // 将存在key的值装进准备好的字典中
        NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
        for (NSString *key in [tempDic allKeys]) {
            id value = [JPPDUtils readableValue:tempDic[key] withKey:key];
            if (value) {
                [returnDic setValue:value forKey:key];
            }
        }
        
        // 恢复子线程
        dispatch_resume(self.queue);
        return returnDic;
    } else {
        // 表格不存在
        // 恢复子线程
        dispatch_resume(self.queue);
        return nil;
    }
}

#pragma mark - ********** 删除数据 **********

#pragma mark - 删除一条数据
- (void)deleteValueForKey:(NSString *)key inTable:(NSString *)table completionHandler:(void (^)(NSError * _Nullable))completionHandler
{
    operateQueue(^{
        if (!key || key.length == 0) {
            if (completionHandler) {
                mainQueue(^{
                    completionHandler([JPPDUtils errorWithDomain:@"key for deleting can not be nil" andCode:JPErrorCodeKeyCannotBeNull]);
                });
            }
            return;
        }
        if (!table || table.length == 0) {
            if (completionHandler) {
                mainQueue(^{
                    completionHandler([JPPDUtils errorWithDomain:@"table for deleting can not be nil" andCode:JPErrorCodeTableNameCannotBeNull]);
                });
            }
            return;
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
                if (completionHandler) {
                    completionHandler(success?nil:[JPPDUtils errorWithDomain:[NSString stringWithFormat:@"delete value for key '%@' failed", key] andCode:JPErrorCodeDeleteFailed]);
                }
            } else {
                if (completionHandler) {
                    completionHandler([JPPDUtils errorWithDomain:[NSString stringWithFormat:@"key '%@' for deleting value does not exist", key] andCode:JPErrorCodeNoSuchKey]);
                }
            }
        } else {
            // 表格不存在
            if (completionHandler) {
                mainQueue(^{
                    completionHandler([JPPDUtils errorWithDomain:[NSString stringWithFormat:@"table '%@' does not exist", table] andCode:JPErrorCodeNoSuchTable]);
                });
            }
        }
    });
}

#pragma mark - 删除多条数据
- (void)deleteValuesForKeys:(NSArray<NSString *> *)keys inTable:(NSString *)table completionHandler:(void (^)(NSArray<NSString *> * _Nullable, NSError * _Nullable))completionHandler
{
    operateQueue(^{
        if (!keys || keys.count == 0) {
            if (completionHandler) {
                mainQueue(^{
                    completionHandler(nil, [JPPDUtils errorWithDomain:@"keys for deleting can not be nil" andCode:JPErrorCodeKeyCannotBeNull]);
                });
            }
            return;
        }
        if (!table || table.length == 0) {
            if (completionHandler) {
                mainQueue(^{
                    completionHandler(nil, [JPPDUtils errorWithDomain:@"table for deleting can not be nil" andCode:JPErrorCodeTableNameCannotBeNull]);
                });
            }
            return;
        }
        
        // 获取表格路径
        NSString *tablePath = [self pathForTable:table];
        // 判断表格是否存在
        if ([[NSFileManager defaultManager] fileExistsAtPath:tablePath]) {
            // 拿到路径下的字典
            NSMutableDictionary *tempDic = [self mutDictionaryForTable:table];
            // 删除对应的value
            NSMutableArray *unfoundKeys = [NSMutableArray array];
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
            if (completionHandler) {
                completionHandler(unfoundKeys, success?nil:[JPPDUtils errorWithDomain:[NSString stringWithFormat:@"delete value for keys '%@' failed", keys] andCode:JPErrorCodeDeleteFailed]);
            }
        } else {
            // 表格不存在
            if (completionHandler) {
                mainQueue(^{
                    completionHandler(nil, [JPPDUtils errorWithDomain:[NSString stringWithFormat:@"table '%@' does not exist", table] andCode:JPErrorCodeNoSuchTable]);
                });
            }
        }
    });
}

#pragma mark - 删除一个表格中的所有数据
- (void)deleteAllValuesInTable:(NSString *)table completionHandler:(void (^)(NSError * _Nullable))completionHandler
{
    operateQueue(^{
        if (!table || table.length == 0) {
            if (completionHandler) {
                mainQueue(^{
                    completionHandler([JPPDUtils errorWithDomain:@"table for deleting can not be nil" andCode:JPErrorCodeTableNameCannotBeNull]);
                });
            }
            return;
        }
        
        // 获取表格路径
        NSString *tablePath = [self pathForTable:table];
        // 判断表格是否存在
        if ([[NSFileManager defaultManager] fileExistsAtPath:tablePath]) {
            // 拿到路径下的字典
            NSMutableDictionary *tempDic = [self mutDictionaryForTable:table];
            // 删除所有数据
            [tempDic removeAllObjects];
            // 写入本地
            BOOL success = [tempDic writeToFile:tablePath atomically:YES];
            // 判断是否成功
            if (completionHandler) {
                completionHandler(success?nil:[JPPDUtils errorWithDomain:[NSString stringWithFormat:@"delete all values in table '%@' failed", table] andCode:JPErrorCodeDeleteFailed]);
            }
        } else {
            // 表格不存在
            if (completionHandler) {
                mainQueue(^{
                    completionHandler([JPPDUtils errorWithDomain:[NSString stringWithFormat:@"table '%@' does not exist", table] andCode:JPErrorCodeNoSuchTable]);
                });
            }
        }
    });
}

#pragma mark - ********** 对表格的操作 **********

#pragma mark - 获取表格大小
- (void)sizeForTable:(NSString *)table completionHandler:(void (^)(unsigned long long))completionHandler
{
    operateQueue(^{
        // 获取表格路径
        NSString *tablePath = [self pathForTable:table];
        // 获取表格大小
        unsigned long long size = [[[NSFileManager defaultManager] attributesOfItemAtPath:tablePath error:nil] fileSize];
        if (completionHandler) {
            mainQueue(^{
                completionHandler(size);
            });
        }
    });
}
- (unsigned long long)sizeForTable:(NSString *)table
{
    // 获取表格路径
    NSString *tablePath = [self pathForTable:table];
    // 获取表格大小
    unsigned long long size = [[[NSFileManager defaultManager] attributesOfItemAtPath:tablePath error:nil] fileSize];
    return size;
}

#pragma mark - 删除一个表格
- (void)deleteTable:(NSString *)table completionHandler:(void (^)(BOOL, NSError * _Nullable))completionHandler
{
    operateQueue(^{
        NSString *tablePath = [self pathForTable:table];
        NSError *error = nil;
        BOOL success =[[NSFileManager defaultManager] removeItemAtPath:tablePath error:&error];
        if (completionHandler) {
            mainQueue(^{
                completionHandler(success, error);
            });
        }
    });
}

#pragma mark - 创建一个表格
- (void)createTable:(NSString *)table completionHandler:(void (^)(BOOL))completionHandler
{
    operateQueue(^{
        NSString *tablePath = [self pathForTable:table];
        BOOL success = [[NSFileManager defaultManager] createFileAtPath:tablePath contents:nil attributes:nil];
        if (completionHandler) {
            mainQueue(^{
                completionHandler(success);
            });
        }
    });
}

@end
