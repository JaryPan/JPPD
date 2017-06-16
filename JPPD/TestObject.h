//
//  TestObject.h
//  JPPD
//
//  Created by 潘建磊 on 15/7/29.
//  Copyright © 2015年 JaryPan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestObject : NSObject <NSCoding>
{
    NSString *_name;
}

- (instancetype)initWithName:(NSString *)name;

@end
