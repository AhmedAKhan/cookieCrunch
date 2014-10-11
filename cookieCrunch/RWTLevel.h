//
//  RWTLevel.h
//  cookieCrunch
//
//  Created by Ahmed Arif Khan on 2014-06-22.
//  Copyright (c) 2014 Ahmed Khan. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import "RWTCookie.h"
#import "RWTTile.h"
#import "RWTSwap.h"
#import "RWTChain.h"

static const NSUInteger NumColumns = 9;
static const NSUInteger NumRows = 9;


@interface RWTLevel : NSObject

@property (assign, nonatomic) NSInteger targetScore;
@property (assign, nonatomic) NSInteger maximumMoves;

-(instancetype)initWithFile:(NSString *)filename;
-(NSSet *)shuffle;
-(RWTCookie *)cookieAtColumn:(NSUInteger)column row:(NSUInteger)row;
-(RWTTile *)tileAtColumn:(NSUInteger)column row:(NSUInteger)row;
-(void)performSwap:(RWTSwap *)swap;
-(BOOL)isPossibleSwap:(RWTSwap *)swap;
-(NSSet *)removeMatches;

-(NSArray *)fillHoles;
-(NSArray *)topUpCookies;

-(void)detectPossibleSwaps;
-(void)resetComboMultiplier;

@end
