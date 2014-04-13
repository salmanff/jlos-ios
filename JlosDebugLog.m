//
//  JlosDebugLog.m
//
//
//  Created by Salman Farmanfarmaian
//  Copyright (c) 2014. All rights reserved.
//

#import "JlosDebugLog.h"

static  NSString * const JLOS_CURRENT_DEBUGLOG_FILENAME = @"jlosDebugLog.dict";
static  NSString * const JLOS_DEBUGLOG_FILE_PREFIX = @"debuglog";
static  NSString * const JLOS_DEBUGLOG_ERRORLIST = @"errorLogList";
static  NSString * const JLOS_DEBUGLOG_DEBUGLIST = @"debugLogList";

// Maximum elements in debuglog before creating a new file
static const int MAX_ELEMENTS_IN_DEBUGLIST = 200;
static const int MAX_ELEMENTS_IN_ERRORLIST = 10;

@implementation JlosDebugLog

-(instancetype)init {
    self = [super initWithName:[Jlos addCurrentSuffixToFileName:JLOS_DEBUGLOG_FILE_PREFIX] atPath:nil withInitialDict:nil];
    if (self) {
        if (![self listAtKey:JLOS_DEBUGLOG_ERRORLIST]) {
            [self setList:[[NSMutableArray alloc] init] atKey:JLOS_DEBUGLOG_DEBUGLIST];
        }
        if (![self listAtKey:JLOS_DEBUGLOG_ERRORLIST]) {
            [self setList:[[NSMutableArray alloc] init] atKey:JLOS_DEBUGLOG_ERRORLIST];
        }
    }
    return self;
}


 - (void) addDebugLogLogItem:(NSString *)theMsg andSrc:(NSString *)theSource {
     [self addDict:[self debugLogDictWithMsg:theMsg andSrc:theSource]  toListKey:JLOS_DEBUGLOG_DEBUGLIST];
 }
 - (void) addDebugLogERROR:(NSString *)theMsg andSrc:(NSString *)theSource {
     [self addDict:[self debugLogDictWithMsg:theMsg andSrc:theSource]  toListKey:JLOS_DEBUGLOG_ERRORLIST];
 }


- (NSMutableDictionary *)debugLogDictWithMsg:(NSString *)theMsg andSrc:(NSString *) theSource {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd hh:mm:ss.ms"];
    
    NSMutableDictionary * tempret = [[NSMutableDictionary alloc] init];
    tempret = [NSMutableDictionary dictionaryWithObjectsAndKeys:
               [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000],@"time",
               theSource,@"src",
               theMsg, @"msg",
               [dateFormatter stringFromDate:[NSDate date]], @"thr",
               nil];
    NSLog(@"Made a log item %@",tempret);
    return tempret;
    
}

- (NSArray *) getErrorList {
    return [self listAtKey:JLOS_DEBUGLOG_ERRORLIST];
}
- (NSArray *) getDebugLogList{
    return [self listAtKey:JLOS_DEBUGLOG_DEBUGLIST];
}



- (NSString *) saveToNewFileIfNeededAndReturnPath {
    NSLog(@"num of items is debug:%lu err:%lu",(unsigned long)[[self listAtKey:JLOS_DEBUGLOG_DEBUGLIST] count] , (unsigned long)[[self listAtKey:JLOS_DEBUGLOG_ERRORLIST] count]);
    if (((int)[[self listAtKey:JLOS_DEBUGLOG_DEBUGLIST] count] > MAX_ELEMENTS_IN_DEBUGLIST) ||  ((int) [[self listAtKey:JLOS_DEBUGLOG_ERRORLIST] count] > MAX_ELEMENTS_IN_ERRORLIST)  ) {
        return [self saveToNewFileAndReturnPath];
    } else {
        return nil;
    }
    
}

- (NSString *) saveToNewFileAndReturnPath {
    // merge internal errors - returns nil if there is nothing logged
    if (((int)[[self listAtKey:JLOS_DEBUGLOG_DEBUGLIST] count] > 0) ||  ((int) [[self listAtKey:JLOS_DEBUGLOG_ERRORLIST] count] > 0)  ) {
        Jlos *internalErrorLog = [[Jlos alloc] initWithName:JLOS_INTERNALERRORS_FILENAME atPath:nil withInitialDict:nil];
        if (internalErrorLog && internalErrorLog.content && [internalErrorLog listAtKey:JLOS_INTERNALERRORS_LIST] && [[internalErrorLog listAtKey:JLOS_INTERNALERRORS_LIST] count]>0) {
            
            NSMutableArray *mergedList = [[NSMutableArray alloc] initWithArray:[internalErrorLog listAtKey:JLOS_INTERNALERRORS_LIST] copyItems:YES];
            [mergedList addObjectsFromArray:[self listAtKey:JLOS_DEBUGLOG_ERRORLIST]];
            [self setList:mergedList atKey:JLOS_DEBUGLOG_ERRORLIST];
            [self save];
            [internalErrorLog resetToInitialValue];
            NSLog(@"meged list is now %@",mergedList);
        } else {
            NSLog(@"NO MERGED LIST");
        }
        
        
        NSString *newFileName = [Jlos getNextAvailableIterableFileNameWithPrefix:JLOS_DEBUGLOG_FILE_PREFIX inPath:[Jlos folderNameFromPrefix:JLOS_DEBUGLOG_FILE_PREFIX] andDate:nil ];
        if ([self saveAsNewJlosDictAtFullPath:newFileName] && [self resetToInitialValue]) {
            return newFileName;
        } else {
            [self addDict:[self debugLogDictWithMsg:@"Could NOT CREATE NEW DEBUG FILE FOR UPLOAD " andSrc:@"saveToNewFileAndReturnPath"] toListKey:JLOS_DEBUGLOG_ERRORLIST];
            [self save];
            return nil;
        }
        
    } else {
        return nil;
    }
}


@end
