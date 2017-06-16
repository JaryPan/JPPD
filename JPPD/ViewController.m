//
//  ViewController.m
//  JPPD
//
//  Created by 潘建磊 on 15/7/29.
//  Copyright © 2015年 JaryPan. All rights reserved.
//

#import "ViewController.h"
#import "JPPD.h"
#import "TestObject.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    TestObject *obj1 = [[TestObject alloc] initWithName:@"obj1"];
    TestObject *obj2 = [[TestObject alloc] initWithName:@"obj2"];
    TestObject *obj3 = [[TestObject alloc] initWithName:@"obj3"];
    
    
    // 设置缓存主目录
    // 默认JPStorageDirectoryTypeCaches，建议不要更改
    [JPPD sharedJPPD].type = JPStorageDirectoryTypeCaches;
    
    // 1、存入基本数据对象
    [[JPPD sharedJPPD] saveValue:@{@"key":@"value"} forKey:@"key1" inTable:@"table" completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"存入一条基本数据对象失败 ---- error = %@", error);
        } else {
            NSLog(@"成功存入一条基本数据对象");
        }
    }];
    
    // 2、存入多个数据对象，包括基本数据对象和自定义数据对象，以及系统类(不可直接存储的类)
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    UIFont *font = [UIFont systemFontOfSize:15];
    NSDictionary *dic = @{
                          @"basic":@[[NSDate dateWithTimeIntervalSinceNow:0], @"string", @100, @[], @{}],
                          @"system":@[view, @{@"font":font}],
                          @"custom":@[obj1, @[obj2, obj3], @{@"obj3":obj3}]
                          };
    [[JPPD sharedJPPD] saveValues:@{@"key2":dic, @"key3":@"1234567890"} inTable:@"table" completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"存入多条数据对象失败 ---- error = %@", error);
        } else {
            NSLog(@"成功存入多条数据对象");
        }
    }];
    
    // 3、读取一条数据
    [[JPPD sharedJPPD] valueForKey:@"key1" inTable:@"table" completionHandler:^(id  _Nullable value, NSError * _Nullable error) {
        if (error) {
            NSLog(@"读取一条数据失败 ---- error = %@", error);
        } else {
            NSLog(@"成功读取一条数据 ---- value = %@", value);
        }
    }];
    
    // 4、读取多条数据(key4是不存在的)
    [[JPPD sharedJPPD] valuesForKeys:@[@"key1", @"key2", @"key4"] inTable:@"table" completionHandler:^(NSDictionary<NSString *,id> * _Nullable values, NSArray<NSString *> * _Nullable unfoundKeys, NSError * _Nullable error) {
        if (error) {
            NSLog(@"读取多条数据失败 ---- error = %@", error);
        } else {
            NSLog(@"成功读取多条数据 ---- values = %@ \n ---- unfoundKeys = %@", values, unfoundKeys);
        }
    }];
    
    // 5、读取表格中的全部数据
    [[JPPD sharedJPPD] allValuesInTable:@"table" completionHandler:^(NSDictionary<NSString *,id> * _Nullable values, NSError * _Nullable error) {
        if (error) {
            NSLog(@"读取所有数据失败 ---- error = %@", error);
        } else {
            NSLog(@"表格 'table' 中的所有数据 ---- values = %@", values);
        }
    }];
    
    // 6、删除一条数据
    [[JPPD sharedJPPD] deleteValueForKey:@"key1" inTable:@"table" completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"删除一条值失败");
        } else {
            NSLog(@"成功删除一条值");
        }
    }];
    
    // 7、删除多条数据(此时key1已经不存在了)
    [[JPPD sharedJPPD] deleteValuesForKeys:@[@"key1", @"key2"] inTable:@"table" completionHandler:^(NSArray<NSString *> * _Nullable unfoundKeys, NSError * _Nullable error) {
        if (error) {
            NSLog(@"删除多条值失败");
        } else {
            NSLog(@"成功删除多条值 ---- unfoundKeys = %@", unfoundKeys);
        }
    }];
    
    
    // 8、删除所有数据
    [[JPPD sharedJPPD] deleteAllValuesInTable:@"table" completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"删除所有数据失败 ---- error = %@", error);
        } else {
            NSLog(@"成功删除所有数据");
        }
    }];
    
    // 9、查看表格大小
    [[JPPD sharedJPPD] sizeForTable:@"table" completionHandler:^(unsigned long long size) {
        NSLog(@"表格大小为 %.2f kb", size/1024.0);
    }];
    
    // 10、删除表格
    [[JPPD sharedJPPD] deleteTable:@"table" completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"成功删除一个表格");
        } else {
            NSLog(@"删除一个表格失败 ---- error = %@", error);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
