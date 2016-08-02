//
//  ViewController.m
//  JPPD
//
//  Created by ovopark_iOS on 16/7/29.
//  Copyright © 2016年 JaryPan. All rights reserved.
//

#import "ViewController.h"
#import "JPPD.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
