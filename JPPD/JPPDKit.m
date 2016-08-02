//
//  JPPDKit.m
//  JPPD
//
//  Created by ovopark_iOS on 16/8/1.
//  Copyright © 2016年 JaryPan. All rights reserved.
//

#import "JPPDKit.h"


@implementation JPErrorAndUnfoundKeys

- (instancetype)initWithError:(NSError *)error andUnfoundKeys:(NSArray *)unfoundKeys
{
    if (self = [super init]) {
        self.error = error;
        self.unfoundKeys = unfoundKeys;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"error=%@, unfoundKeys=%@", self.error, self.unfoundKeys];
}

@end


@implementation JPValueAndError

- (instancetype)initWithValue:(id)value andError:(NSError *)error
{
    if (self = [super init]) {
        self.value = value;
        self.error = error;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"value=%@, error=%@", self.value, self.error];
}

@end


@implementation JPFoundValusUnfoundKeysAndError

- (instancetype)initWithFoundValus:(NSDictionary *)foundValus unfoundKeys:(NSArray *)unfoundKeys andError:(NSError *)error
{
    if (self = [super init]) {
        self.foundValus = foundValus;
        self.unfoundKeys = unfoundKeys;
        self.error = error;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"foundValus=%@, unfoundKeys=%@, error=%@", self.foundValus, self.unfoundKeys, self.error];
}

@end


