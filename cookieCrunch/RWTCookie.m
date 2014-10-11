//
//  RWTCookie.m
//  cookieCrunch
//
//  Created by Ahmed Arif Khan on 2014-06-22.
//  Copyright (c) 2014 Ahmed Khan. All rights reserved.
//

#import "RWTCookie.h"

@implementation RWTCookie

-(NSString *)spriteName{
    static NSString * const spriteNames[] = {
        @"Croissant",
        @"Cupcake",
        @"Danish",
        @"Donut",
        @"Macaroon",
        @"SugarCookie",
    };
    
    return spriteNames[self.cookieType - 1];
}

-(NSString *)highlightedSpriteName{
    static NSString * const highlightedSpriteNames[] = {
        @"Croissant-Highlighted",
        @"Cupcake-Highlighted",
        @"Danish-Highlighted",
        @"Donut-Highlighted",
        @"Macaroon-Highlighted",
        @"SugarCookie-Highlighted",
    };
    
    return highlightedSpriteNames[self.cookieType -1];
    
    //return [NSString stringWithFormat:@"%@-Highlighted", [self spriteName]];
}

-(NSString *)description{
    return [NSString stringWithFormat:@"type:%ld square:(%ld,%ld)", (long)self.cookieType, (long)self.column, (long)self.row];
}

@end
