# JPPD
封装了常用的数据持久化操作方法，包括：保存、修改、查看、删除等操作；
结合了GCD多线程技术并融合了block回调方法，可选择同步或异步执行数据操作；
保存路径可随时切换，操作方法十分简单；
保存数据类型支持所有NSObject对象。

    
    // 设置缓存主目录
    // 默认JPStorageDirectoryTypeCaches
    [JPPD sharedJPPD].type = JPStorageDirectoryTypeCaches;
    
    // 保存数据
    [[JPPD sharedJPPD] writeManyLightweightValues:@{@"key1":@"value1", @"key2":@"value2", @"key3":@"value3", @"key4":@"value4"} inTable:@"test"];
    
    // 修改数据
    [[JPPD sharedJPPD] updateManyHeavyweightValues:@{@"key4":@[@"1", @"2", @"3"]} inTable:@"test"];
    
    // 查看数据
    NSLog(@"表格‘test’中的所有数据 = %@", [[JPPD sharedJPPD] allValuesInTable:@"test"].value);
    
    // 删除数据
    [[JPPD sharedJPPD] deleteOneValueForKey:@"key4" inTable:@"test"];
    
    // 查看表格大小
    NSLog(@"表格‘test’大小：%llu B", [[JPPD sharedJPPD] sizeForTable:@"test"]);
    
    // 创建表格
    [[JPPD sharedJPPD] createOneTable:@"1234567890" completedBlock:^(BOOL success) {
        if (success) {
            NSLog(@"表格‘1234567890’创建成功");
            // 删除表格
            [[JPPD sharedJPPD] deleteOneTable:@"1234567890" completedBlock:^(NSError *error) {
                if (!error) {
                    NSLog(@"表格‘1234567890’删除成功");
                }
            }];
        }
    }];
