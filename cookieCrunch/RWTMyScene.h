//
//  RWTMyScene.h
//  cookieCrunch
//

//  Copyright (c) 2014 Ahmed Khan. All rights reserved.
//

//#import <SpriteKit/SpriteKit.h>
@import SpriteKit;

@class RWTSwap;
@class RWTLevel;

@interface RWTMyScene : SKScene

@property (copy, nonatomic) void (^swipeHandler)(RWTSwap * swap);
@property (strong, nonatomic) RWTLevel *level;

-(void)addSpriteForCookies:(NSSet *)cookies;
-(void)addTiles;

-(void)animateSwap:(RWTSwap *)swap completion:(dispatch_block_t)completion;
-(void)animateInvalidSwap:(RWTSwap *)swap completion:(dispatch_block_t)completion;

-(void)animateMatchedCookies:(NSSet *)chains completion:(dispatch_block_t)completion;
-(void)animateFallingCookies:(NSArray *)columns completion:(dispatch_block_t)completion;
-(void)animateNewCookies:(NSArray *)columns completion:(dispatch_block_t)completion;

-(void)animateGameBegin;
-(void)animateGameOver;

-(void)removeAllCookieSprite;

@end