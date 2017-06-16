//
//  TestObject.m
//  JPPD
//
//  Created by 潘建磊 on 15/7/29.
//  Copyright © 2015年 JaryPan. All rights reserved.
//

#import "TestObject.h"

@implementation TestObject

- (instancetype)initWithName:(NSString *)name
{
    if (self = [super init]) {
        _name = name;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"TestObject description ---- 'name' = %@", _name];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_name forKey:@"name"];
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _name = [aDecoder decodeObjectForKey:@"name"];
    }
    return self;
}

@end
