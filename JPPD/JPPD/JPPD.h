//
//  JPPD.h
//  JPPD
//
//  Created by 潘建磊 on 15/7/29.
//  Copyright © 2015年 JaryPan. All rights reserved.
//

/**
 *JPPD理论上支持所有对象类型的任意组合形式的存取和删改
 *数据操作添加了线程安全机制，使用时不必考虑数据操作的安全问题
 *可以根据自身需要更改存储主路径
 *对于需要归档的对象类型(包括自定义类和系统的大部分类)，首先要实现NSCoding协议以及对应的方法才能正确存储
 *存储时，对于需要进行归档操作的对象类型，用户不需要自己去处理，存储的过程中会自动判断哪些需要进行归档操作
 *读取时，对于需要进行反归档操作的对象类型，用户也不需要自己去处理，读取的过程中会自动判断哪些需要进行反归档操作
 *对于集合类，除了NSArray、NSMutableArray、NSDictionary、NSMutableDictionary可以直接装入任意对象类型外，
 其他的集合类，例如NSSet等，不能在其中装入需要归档的数据，只能装入"基本数据对象类型"
 例如 [NSSet setWithObject:自定义对象类型] 不能被正确存储和读取
 *具体使用方法请参考ViewController.m文件中的方法
 *目前系统中不需要进行归档的类（基本数据对象类型）如下：
 NSNumber
 NSString
 NSMutableString
 NSArray class
 NSMutableArray
 NSDictionary
 NSMutableDictionary
 NSDate
 */

#import <Foundation/Foundation.h>
#import "JPPDUtils.h"

/**
 *本地数据存储类，通过获取单例对象进行数据操作
 */
@interface JPPD : NSObject

/**
 *获取JPPD单例对象
 */
+ (nullable instancetype)sharedJPPD;

/**
 *文件存储目录类型，默认是 JPStorageDirectoryTypeCaches，建议不要更改
 */
@property (readwrite, assign, nonatomic) JPStorageDirectoryType type;

/**
 *当前文件保存主路径，默认是 Caches 文件夹所在的路径，与 JPStorageDirectoryType 的值有关
 */
@property (nonnull, readonly, copy, nonatomic) NSString *mainFilePath;


#pragma mark - ********** 保存数据 / 修改数据 **********

/**
 *保存一条数据 如果key存在，key对应的value会被覆盖(即修改数据)
 *@param value 要保存的对象，如果是自定义对象，该对象类需要先实现NSCoding协议，否则将会保存失败
 *@param key 被保存对象对应的键，读取数据时需要用到该值
 *@param table 保存数据的表格，读取数据时需要用到该值
 *@param completionHandler 操作完成之后的block回调，回调会回到主线程，error 为nil时代表保存成功
 */
- (void)saveValue:(nonnull id)value forKey:(nonnull NSString *)key inTable:(nonnull NSString *)table completionHandler:(void(^ _Nullable)(NSError * _Nullable error))completionHandler;

/**
 *保存多条数据 如果字典values中的某个key在本地表格中已存在，key对应的value会被覆盖
 *@param values 字典类型，格式为 "NSString:id"
 *@param table 保存数据的表格，读取数据时需要用到该值
 *@param completionHandler 操作完成之后的block回调，回调会回到主线程，error 为nil时代表保存成功
 */
- (void)saveValues:(nonnull NSDictionary<NSString *, id> *)values inTable:(nonnull NSString *)table completionHandler:(void(^ _Nullable)(NSError * _Nullable error))completionHandler;


#pragma mark - ********** 查看数据 **********

/**
 *查看一条数据
 *@param key 获取数据需要的键，该键值即为存储时用到的key
 *@param table 保存数据的表格
 *@param completionHandler 操作完成之后的block回调，回调会回到主线程，value不为nil(error为nil)时代表读取成功
 */
- (void)valueForKey:(nonnull NSString *)key inTable:(nonnull NSString *)table completionHandler:(void(^ _Nullable)(id _Nullable value, NSError * _Nullable error))completionHandler;
/**
 *查看一条数据，非多线程处理
 */
- (nullable id)valueForKey:(nonnull NSString *)key inTable:(nonnull NSString *)table;

/**
 *查看多条数据
 *@param keys 获取数据需要的键值数组，该键值数组即为存储时用到的key的数组集合
 *@param table 保存数据的表格
 *@param completionHandler 操作完成之后的block回调，回调会回到主线程，values不为nil(error为nil)时代表读取成功
 *unfoundKeys 找不到对应值的key数组集合，unfoundKeys若不为nil，代表存储的表格中没有找到这些key
 */
- (void)valuesForKeys:(nonnull NSArray<NSString *> *)keys inTable:(nonnull NSString *)table completionHandler:(void(^ _Nullable)(NSDictionary<NSString *, id> * _Nullable values, NSArray<NSString *> * _Nullable unfoundKeys, NSError * _Nullable error))completionHandler;
/**
 *查看多条数据，非多线程处理
 */
- (nullable NSDictionary<NSString *, id> *)valuesForKeys:(nonnull NSArray<NSString *> *)keys inTable:(nonnull NSString *)table;

/**
 *查看一个表格中的所有数据
 *@param table 保存数据的表格
 *@param completionHandler 操作完成之后的block回调，回调会回到主线程，values不为nil(error为nil)时代表读取成功
 */
- (void)allValuesInTable:(nonnull NSString *)table completionHandler:(void(^ _Nullable)(NSDictionary<NSString *, id> * _Nullable values, NSError * _Nullable error))completionHandler;
/**
 *查看一个表格中的所有数据，非多线程处理
 */
- (nullable NSDictionary<NSString *, id> *)allValuesInTable:(nonnull NSString *)table;


#pragma mark - ********** 删除数据 **********

/**
 *删除一条数据
 *@param key 被删除的value所对应的key
 *@param table 被删除的value所在的表格
 *@param completionHandler 操作完成之后的block回调，回调会回到主线程，error为nil代表删除成功
 */
- (void)deleteValueForKey:(nonnull NSString *)key inTable:(nonnull NSString *)table completionHandler:(void(^ _Nullable)(NSError * _Nullable error))completionHandler;

/**
 *删除多条数据
 *@param keys 被删除的value所对应的key数组
 *@param table 被删除的value所在的表格
 *@param completionHandler 操作完成之后的block回调，回调会回到主线程，error为nil代表删除成功
 *unfoundKeys 找不到对应值的key数组集合，unfoundKeys若不为nil，代表删除时在表格中没有找到这些key
 */
- (void)deleteValuesForKeys:(nonnull NSArray<NSString *> *)keys inTable:(nonnull NSString *)table completionHandler:(void(^ _Nullable)(NSArray<NSString *> * _Nullable unfoundKeys, NSError * _Nullable error))completionHandler;

/**
 *删除一个表格中的所有数据
 *@param table 被删除的value所在的表格
 *@param completionHandler 操作完成之后的block回调，回调会回到主线程，error为nil代表删除成功
 *该操作只是删除了数据，并不会删除表格
 *如果表格不存在，error不为空，JPErrorCode 为 JPErrorCodeNoSuchTable
 */
- (void)deleteAllValuesInTable:(nonnull NSString *)table completionHandler:(void(^ _Nullable)(NSError * _Nullable error))completionHandler;


#pragma mark - ********** 对表格的操作 **********

/**
 *获取表格大小
 *@param table 表格的名称
 *@param completionHandler 操作完成之后的block回调，回调会回到主线程
 *size 表格大小，单位为 B，如果表格不存在，size = 0
 */
- (void)sizeForTable:(nonnull NSString *)table completionHandler:(void(^ _Nullable)(unsigned long long size))completionHandler;
/**
 *获取表格大小，非多线程处理
 */
- (unsigned long long)sizeForTable:(nonnull NSString *)table;

/**
 *删除一个表格
 *@param table 表格的名称
 *@param completionHandler 操作完成之后的block回调，回调会回到主线程
 *success YES表示删除成功，NO表示删除失败，如果表格不存在，success = NO
 *error success为YES时error为nil，success为NO可以通过error查看错误原因
 */
- (void)deleteTable:(nonnull NSString *)table completionHandler:(void(^ _Nullable)(BOOL success, NSError * _Nullable error))completionHandler;

/**
 *创建一个表格
 *@param table 被创建的表格的名称
 *@param completionHandler 操作完成之后的block回调，回调会回到主线程
 *success YES表示创建成功，NO表示创建失败
 *写入数据时，如果表格不存在，会自动创建一个表格，所以不建议手动执行该方法
 */
- (void)createTable:(nonnull NSString *)table completionHandler:(void(^ _Nullable)(BOOL success))completionHandler;

@end
