//
//  RWTLevel.m
//  cookieCrunch
//
//  Created by Ahmed Arif Khan on 2014-06-22.
//  Copyright (c) 2014 Ahmed Khan. All rights reserved.
//

#import "RWTLevel.h"

@interface RWTLevel ()

@property (strong, nonatomic) NSSet * possibleSwaps;
@property (assign, nonatomic) NSUInteger comboMultiplier;

@end

@implementation RWTLevel
{
    RWTCookie * _cookies[NumColumns][NumRows];
    RWTTile * _tiles[NumColumns][NumRows];
}

-(instancetype)initWithFile:(NSString *)filename{
    self = [super init];
    if(self != nil){
        
        //get the dictionary
        NSDictionary * dictionary = [self loadJSON:filename];
        //enumerate through the rows
        [dictionary[@"tiles"] enumerateObjectsUsingBlock:^(NSArray * array, NSUInteger row, BOOL *stop){
            //enumerate through the columns
            [array enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger column, BOOL *stop){
                //reverse the rows because the first row you read from the JSON file coresponds to the last row of the table
                NSInteger tileRow = NumRows - row -1;
                //if the row is available then add it to the _tiles array
                if([value integerValue] ==1){
                    _tiles[column][tileRow] = [[RWTTile alloc] init];
                }//end if
                
            }];//end columns block
        }];//end rows blcok
        
        self.targetScore = [dictionary[@"targetScore"] unsignedIntegerValue];
        self.maximumMoves = [dictionary[@"moves"] unsignedIntegerValue];
        
    }//end if self != nil
    return self;
}//end func

-(RWTTile *)tileAtColumn:(NSUInteger)column row:(NSUInteger)row{
    NSAssert1(column >= 0 && column <= NumColumns, @"Invalid Columms: %ld", (long)column);
    NSAssert1(row >= 0 && row <= NumRows, @"Invalid Row: %ld", (long)row);
    
    return _tiles[column][row];
}

-(RWTCookie *)cookieAtColumn:(NSUInteger)column row:(NSUInteger)row{
    
    NSAssert1(column>= 0 && column < NumColumns, @"Invalid Colum: %ld", (long)column);
    NSAssert1(row >= 0 && row < NumRows, @"Invalid Ros: %ld", (long)row);
    
    return _cookies[column][row];
    
    
}

-(NSSet *)createInitialCookies{
    NSMutableSet * set = [NSMutableSet set];
    
    for (NSUInteger row = 0; row < NumRows; row++) {
        for (NSUInteger column = 0; column < NumColumns; column++) {
            if(_tiles[column][row] != nil){

                NSUInteger cookieType;
                do{
                    cookieType = arc4random_uniform(NumCookiesType)+1;
                }while ((column >= 2 &&
                         _cookies[column - 1][row].cookieType == cookieType &&
                         _cookies[column-2][row].cookieType == cookieType)
                        ||
                        (row >= 2 &&
                         _cookies[column][row-1].cookieType == cookieType &&
                         _cookies[column][row-2].cookieType == cookieType));
                
                RWTCookie * cookie = [self createCookieAtColumn:column row:row withType:cookieType];
                [set addObject:cookie];
            }//end if
            
        }//end column loop
    }//end row loop
    return set;
}

-(RWTCookie *)createCookieAtColumn:(NSUInteger)column row:(NSUInteger)row withType:(NSUInteger)cookieType{
    RWTCookie * cookie = [[RWTCookie alloc] init];
    cookie.cookieType = cookieType;
    cookie.column = column;
    cookie.row = row;
    _cookies[column][row] = cookie;
    return cookie;
}

-(NSDictionary *)loadJSON:(NSString *)filename{
    NSString * path = [[NSBundle mainBundle] pathForResource:filename ofType:@".json"];
    if (path == nil){
        NSLog(@"could not load JSON file");
        return nil;
    }
    
    NSError * error;
    NSData * data = [NSData dataWithContentsOfFile:path options:0 error:&error];
    if(data == nil){
        NSLog(@"could not load file: %@ error: %@", filename, error);
        return nil;
    }
    
    NSDictionary * dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if ( dictionary == nil || ![dictionary isKindOfClass:[NSDictionary class]]){
        NSLog(@"Level of file: %@ is not a valid JSON: %@", filename, error);
        return nil;
    }
    
    return dictionary;
}//end function

-(void)performSwap:(RWTSwap *)swap{
    
    NSUInteger columnA = swap.cookieA.column;
    NSUInteger rowA = swap.cookieA.row;
    NSUInteger columnB = swap.cookieB.column;
    NSUInteger rowB = swap.cookieB.row;
    
    _cookies[columnA][rowA] = swap.cookieB;
    swap.cookieB.column = columnA;
    swap.cookieB.row =rowA;
    
    _cookies[columnB][rowB] = swap.cookieA;
    swap.cookieA.column = columnB;
    swap.cookieA.row = rowB;
    
}

-(NSSet *)shuffle{
    NSSet * set;
    do{
        set = [self createInitialCookies];
        [self detectPossibleSwaps];
        
    }while([self.possibleSwaps count] == 0);
    
    return set;
}

-(BOOL)isPossibleSwap:(RWTSwap *)swap{
    return [self.possibleSwaps containsObject:swap];
}

-(void)detectPossibleSwaps{
    NSMutableSet * set = [NSMutableSet set];
    
    for (NSInteger row = 0; row < NumRows; row++) {
        for (NSInteger column = 0; column < NumColumns; column++) {
            RWTCookie * cookie = _cookies[column][row];
            if(cookie != nil){
                //swap this with the one on the right
                if(column < NumColumns -1){
                    RWTCookie * other = _cookies[column+1][row];
                    if(other != nil){
                        _cookies[column][row] = other;
                        _cookies[column+1][row] = cookie;
                        
                        if([self hasChainAtColumn:column+1 row:row] ||
                           [self hasChainAtColumn:column row:row]){
                            RWTSwap * swap = [[RWTSwap alloc] init];
                            swap.cookieA = cookie;
                            swap.cookieB = other;
                            [set addObject:swap];
                        }
                        
                        _cookies[column][row] = cookie;
                        _cookies[column+1][row] = other;
                        
                    }
                }//end if column < NumColumns
                
                if(row < NumRows -1){
                    RWTCookie * other = _cookies[column][row+1];
                    if(other != nil){
                        _cookies[column][row] = other;
                        _cookies[column][row+1] = cookie;
                        
                        if([self hasChainAtColumn:column row:row+1] ||
                           [self hasChainAtColumn:column row:row]){
                            RWTSwap * swap = [[RWTSwap alloc] init];
                            swap.cookieA = cookie;
                            swap.cookieB = other;
                            [set addObject:swap];
                        }
                        _cookies[column][row] = cookie;
                        _cookies[column][row+1] = other;
                        
                    }
                }
                
            }//end if cookie exists
        }//end column loop
    }//end row loop
    
    self.possibleSwaps = set;
}//end func

-(BOOL)hasChainAtColumn:(NSInteger)column row:(NSInteger)row{
    NSUInteger cookieType = _cookies[column][row].cookieType;
    
    NSUInteger horzLength = 1;
    for (NSInteger i = column - 1; i >= 0 && _cookies[i][row].cookieType == cookieType; i--, horzLength++);
    for (NSInteger i = column + 1; i < NumColumns && _cookies[i][row].cookieType == cookieType; i++, horzLength++) ;
    if(horzLength >= 3) return YES;
    
    NSUInteger vertLength = 1;
    for (NSInteger i = row - 1; i >= 0 && _cookies[column][i].cookieType == cookieType; i--, vertLength++);
    for (NSInteger i = row + 1; i < NumRows && _cookies[column][i].cookieType == cookieType; i++, vertLength++);
    return (vertLength >= 3);
}

-(NSSet *)detectHorizontalMatches{
    
    NSMutableSet * set = [NSMutableSet set];
    
    for (NSInteger row = 0; row < NumRows; row++) {
        for (NSInteger column = 0; column < NumColumns - 2;) {
            
            if(_cookies[column][row] != nil){
                NSUInteger matchType = _cookies[column][row].cookieType;
                
                if(_cookies[column+1][row].cookieType == matchType &&
                   _cookies[column+2][row].cookieType == matchType){
                    
                    RWTChain * chain = [[RWTChain alloc] init];
                    chain.chainType = ChainTypeHorizontal;
                    
                    do{
                        [chain addCookie:_cookies[column][row]];
                        column+=1;
                    }while(column < NumColumns && _cookies[column][row].cookieType == matchType);
                
                    [set addObject:chain];
                    continue;
                }//end if
            }//end if
            
            column += 1;
            
        }//end for
    }//end for
    return set;
}//end func

-(NSSet *)detectVerticalMatches{
    NSMutableSet * set = [NSMutableSet set];
    
    for (NSInteger column = 0; column < NumRows; column++) {
        for (NSInteger row = 0; row <  NumRows -2; ) {
            
            if(_cookies[column][row] != nil){
                NSUInteger matchType = _cookies[column][row].cookieType;
                
                if(_cookies[column][row+1].cookieType == matchType &&
                   _cookies[column][row+2].cookieType == matchType){
                    
                    RWTChain * chain = [[RWTChain alloc] init];
                    chain.chainType = ChainTypeVertical;
                    
                    do{
                        [chain addCookie:_cookies[column][row]];
                        row++;
                    }while(row < NumRows && _cookies[column][row].cookieType == matchType);
                    
                    [set addObject:chain];
                    continue;
                }//end if
            }//end if
            
            row++;
        
        }//end for row
    }//end for column
    
    return set;
}

-(NSSet *)removeMatches{
    NSSet * horizontalChains = [self detectHorizontalMatches];
    NSSet * verticalChains = [self detectVerticalMatches];
    
    [self removeCookies:horizontalChains];
    [self removeCookies:verticalChains];
    
    [self calculateScores:horizontalChains];
    [self calculateScores:verticalChains];
    
    return [horizontalChains setByAddingObjectsFromSet:verticalChains];
}

-(void)removeCookies:(NSSet *)chains{
    
    for (RWTChain * chain in chains) {
        for (RWTCookie * cookie in chain.cookies) {
            
            _cookies[cookie.column][cookie.row] = nil;
            
        }//end cookies loop
    }//end chain loop
    
}//end func

-(NSArray *)fillHoles{
    NSMutableArray * columns = [NSMutableArray array];
    
    for (NSInteger column = 0; column < NumColumns; column++) {
        
        NSMutableArray * array;
        for (NSInteger row =0; row < NumRows; row++) {
            
            if(_tiles[column][row] != nil && _cookies[column][row] == nil){
                
                for (NSInteger lookup = row+1; lookup < NumRows; lookup++) {
                    
                    RWTCookie * cookie = _cookies[column][lookup];
                    if(cookie != nil){
                        
                        _cookies[column][lookup] = nil;
                        _cookies[column][row] = cookie;
                        cookie.row = row;
                        
                        if(array == nil){
                            array = [NSMutableArray array];
                            [columns addObject:array];
                        }
                        [array addObject:cookie];
                        break;
                        
                    }
                }//end lookup loop
                
            }
            
        }//end for row
    }//end for columns
    return columns;
}//end func

-(NSArray *)topUpCookies{
    NSMutableArray * columns = [NSMutableArray array];
    NSUInteger cookieType = 0;
    
    for (NSInteger column = 0; column < NumColumns; column++) {
        NSMutableArray * array;
        for (NSInteger row = NumRows - 1; row >= 0 && _cookies[column][row] == nil; row--) {
            
            if(_tiles[column][row] != nil){
                
                NSUInteger newCookieType;
                do{
                    newCookieType = arc4random_uniform(NumCookiesType) + 1;
                }while(newCookieType == cookieType);
                cookieType = newCookieType;
                
                RWTCookie * cookie = [self createCookieAtColumn:column row:row withType:cookieType];
                if(array == nil){
                    array = [NSMutableArray array];
                    [columns addObject:array];
                }
                [array addObject:cookie];
            }//end if
                                      
        }//end for loop
    }//end for loop
    return columns;
}//end func

-(void)calculateScores:(NSSet *)chains{
    for (RWTChain * chain in chains) {
        chain.score = 60 * ([chain.cookies count] - 2) *self.comboMultiplier;
        self.comboMultiplier++;
    }//end for
}//end func

-(void)resetComboMultiplier{
    self.comboMultiplier = 1;
}

@end