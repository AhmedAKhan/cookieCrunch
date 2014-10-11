//
//  RWTCookie.h
//  cookieCrunch
//
//  Created by Ahmed Arif Khan on 2014-06-22.
//  Copyright (c) 2014 Ahmed Khan. All rights reserved.
//

//#import <Foundation/Foundation.h>
@import SpriteKit;

static const NSUInteger NumCookiesType = 6;

@interface RWTCookie : NSObject

@property (assign, nonatomic) NSInteger column;
@property (assign, nonatomic) NSInteger row;
@property (assign, nonatomic) NSUInteger cookieType;
@property (assign, nonatomic) SKSpriteNode * sprite;

-(NSString *)spriteName;
-(NSString *)highlightedSpriteName;


@end
