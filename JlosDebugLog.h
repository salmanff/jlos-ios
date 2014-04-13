//
//  JlosDebugLog.h
//
//  Created by Salman Farmanfarmaian
//  Copyright (c) 2014. All rights reserved.
//

#import "Jlos.h"



@interface JlosDebugLog : Jlos

- (void) addDebugLogLogItem:(NSString *)theMsg andSrc:(NSString *)theSource;

- (void) addDebugLogERROR:(NSString *)theMsg andSrc:(NSString *)theSource;

- (NSString *) saveToNewFileIfNeededAndReturnPath;
- (NSString *) saveToNewFileAndReturnPath;

- (NSArray *) getErrorList;
- (NSArray *) getDebugLogList;

@end
