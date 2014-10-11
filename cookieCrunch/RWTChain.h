//
//  RWTChain.h
//  cookieCrunch
//
//  Created by Ahmed Arif Khan on 2014-06-24.
//  Copyright (c) 2014 Ahmed Khan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RWTCookie;

typedef NS_ENUM(NSUInteger, ChainType) {
    ChainTypeHorizontal,
    ChainTypeVertical,
};

@interface RWTChain : NSObject

@property (strong, nonatomic, readonly) NSArray * cookies;
@property (assign, nonatomic) ChainType chainType;
@property (assign, nonatomic) NSUInteger score;

-(void)addCookie:(RWTCookie *)cookie;

@end
