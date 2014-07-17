//
//  SearchEngine.h
//  Listen
//
//  Created by Dai Hovey on 02/10/2013.
//  Copyright (c) 2013 14lox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchEngine : NSObject

@property (nonatomic) __block BOOL isProcessingSearch;

+ (SearchEngine *)shared;

-(void) displayAllTracksWithCallback:(void(^)())callback;
-(void) searchWithString:(NSString*)query callback:(void(^)())callback;
-(void) clearSearchArraysCallback:(void(^)())callback;

@end
