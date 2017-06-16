# JPPD
JPPD理论上支持所有对象类型的任意组合形式的存取和删改
数据操作添加了线程安全机制，使用时不必考虑数据操作的安全问题
可以根据自身需要更改存储主路径
对于需要归档的对象类型(包括自定义类和系统的大部分类)，首先要实现NSCoding协议以及对应的方法才能正确存储
存储时，对于需要进行归档操作的对象类型，用户不需要自己去处理，存储的过程中会自动判断哪些需要进行归档操作
读取时，对于需要进行反归档操作的对象类型，用户也不需要自己去处理，读取的过程中会自动判断哪些需要进行反归档操作
对于集合类，除了NSArray、NSMutableArray、NSDictionary、NSMutableDictionary可以直接装入任意对象类型外，
其他的集合类，例如NSSet等，不能在其中装入需要归档的数据，只能装入"基本数据对象类型"
例如 [NSSet setWithObject:自定义对象类型] 不能被正确存储和读取
具体使用方法请参考ViewController.m文件中的方法
目前系统中不需要进行归档的类（基本数据对象类型）如下：
NSNumber
NSString
NSMutableString
NSArray class
NSMutableArray
NSDictionary
NSMutableDictionary
NSDate


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
