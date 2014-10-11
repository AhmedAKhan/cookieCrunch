//
//  RWTSwap.m
//  cookieCrunch
//
//  Created by Ahmed Arif Khan on 2014-06-24.
//  Copyright (c) 2014 Ahmed Khan. All rights reserved.
//

#import "RWTSwap.h"
#import "RWTCookie.h"

@implementation RWTSwap

-(NSString *)description{
    return [NSString stringWithFormat:@"%@ swap %@ with %@", [super description], self.cookieA, self.cookieB];
}

-(NSUInteger)hash{
    return [self.cookieA hash] ^[self.cookieB hash];
}

-(BOOL)isEqual:(id)object{
    if (![object isKindOfClass:[RWTSwap class]]) return NO;
    
    RWTSwap * other = (RWTSwap *)object;
    return ((other.cookieA == self.cookieA && other.cookieB == self.cookieB )||
            (other.cookieA == self.cookieB && other.cookieB == self.cookieA));
}//end func

@end
