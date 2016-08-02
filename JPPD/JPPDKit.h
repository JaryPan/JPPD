//
//  JPPDKit.h
//  JPPD
//
//  Created by ovopark_iOS on 16/8/1.
//  Copyright © 2016年 JaryPan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPErrorAndUnfoundKeys : NSObject

- (instancetype)initWithError:(NSError *)error
               andUnfoundKeys:(NSArray *)unfoundKeys;

@property (strong, nonatomic) NSError *error;
@property (strong, nonatomic) NSArray *unfoundKeys;

@end


@interface JPValueAndError : NSObject

- (instancetype)initWithValue:(id)value
                     andError:(NSError *)error;

@property (strong, nonatomic) id value;
@property (strong, nonatomic) NSError *error;

@end


@interface JPFoundValusUnfoundKeysAndError : NSObject

- (instancetype)initWithFoundValus:(NSDictionary *)foundValus
                          unfoundKeys:(NSArray *)unfoundKeys
                             andError:(NSError *)error;

@property (strong, nonatomic) NSDictionary *foundValus;
@property (strong, nonatomic) NSArray *unfoundKeys;
@property (strong, nonatomic) NSError *error;

@end


