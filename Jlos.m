//
//  Jlos.m
//  Released uner MIT License with attribution
//
//  Created by Salman Farmanfarmaian on 08/04/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "Jlos.h"


@implementation Jlos
#pragma mark initilisation and Saving
-(instancetype)init {
    self = [super init];
    if (self) {
        self.content = [[NSMutableDictionary alloc] init];
        self.fileReference = nil;
        self.relativePath = nil;
    }
    return self;
}
-(instancetype)initWithName: (NSString *) fileReference atPath: (NSString *) relativePath  withInitialDict:(NSMutableDictionary *)initialValues {
    self = [super init];
    if (self) {
        if (relativePath) {
            self.relativePath = [[NSString alloc] initWithString:relativePath];
        }
        if (initialValues) {
                self.initialValue =  [[NSMutableDictionary alloc] initWithDictionary:initialValues];
        } else {
            initialValues = [[NSMutableDictionary alloc] init];
        }
        if (fileReference) {
            self.fileReference = [[NSString alloc] initWithString:[self addExtIfNeededTo:fileReference forRelativepath:relativePath]];
            if (![self makeSureDirectoryExistsAt:relativePath]) {
                [Jlos logInternalError:[NSString stringWithFormat:@"jlos Initialization error - could not create relative path %@ for file %@- path set to root",relativePath, fileReference] ];
                relativePath = nil;
            }
            self.content = [[NSMutableDictionary alloc] initWithDictionary: [self getDictFromFileName:self.fileReference atPath:relativePath withInitialDict:initialValues]];
        } else if (initialValues) {
            self.content = initialValues;
        } else {
            self.content = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}


- (BOOL) save {
    BOOL sucessSave = [self makeSureDirectoryExistsAt:self.relativePath];
    if (sucessSave) {
        if([[self.fileReference pathExtension] isEqualToString:@"dict"]) {
            NSString *fullFilePath = [Jlos getFullPathfrom:self.relativePath fileNamed:self.fileReference];
            sucessSave = [self.content writeToFile:fullFilePath atomically:YES];
        } else if([[self.fileReference pathExtension] isEqualToString:@"json"]) {
            NSString * theContent = [self getJsonTxtFromDict:self.content];
            if (!theContent) {
                sucessSave = NO;
            } else {
                sucessSave = [Jlos makeTextFileAtPath:self.relativePath named:self.fileReference withContent:theContent];
            }
        } else {
            sucessSave = NO;
        }
    }
    if (!sucessSave) {
        [Jlos logInternalError:[NSString stringWithFormat:@"jlos Error in SAVE path %@ for file %@",self.relativePath, self.fileReference]];
    }
    return sucessSave;
}
- (BOOL) loadContentFromFile {
    self.content = [self getDictFromFileName:self.fileReference atPath:self.relativePath withInitialDict:self.initialValue];
    return [self save];
}
- (BOOL) resetToInitialValue {
    if (self.initialValue) {
        self.content = self.initialValue;
    } else {
        self.content = [[NSMutableDictionary alloc] init];
    }
    return [self save];
}

- (NSMutableDictionary *) getDictFromFileName: (NSString *) fileName atPath: (NSString *) relativePath withInitialDict:(NSMutableDictionary *)initialValues {
    NSMutableDictionary *tempReturn;
    if (![self makeSureDirectoryExistsAt:relativePath]) {
        [Jlos logInternalError:[NSString stringWithFormat:@"jlos error in getDictFromFileName - could not create relative path %@ for file %@- path set to root",relativePath, self.fileReference]];
        relativePath = nil;
    }
    NSString *fullPath = [Jlos getFullPathfrom:relativePath fileNamed:fileName];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if ([fileManager fileExistsAtPath:fullPath] ) {
        if ([[fileName pathExtension] isEqualToString:@"dict"]) {
            tempReturn = [NSMutableDictionary dictionaryWithContentsOfFile:fullPath];
        } else {
            tempReturn = [self getDictFromJsonFilenamed:fileName relativePath:relativePath];
        }
    }

    if (!tempReturn ) {
        if (initialValues) {
            tempReturn = initialValues;
        } else {
            tempReturn = [[NSMutableDictionary alloc] init];
        }
    }
    return tempReturn;
}


#pragma mark GETTER methods
- (NSNumber *) numAtKey:(NSString *) theKey{
    @try {
        return [self.content valueForKeyPath:theKey];
    } @catch (NSException * e) {
        [Jlos logInternalError:[NSString stringWithFormat:@"Error getting numAtKey %@ with eror: %@", theKey, e]];
        return nil;
    } @finally { }
}
- (int) intAtKey:(NSString *) theKey {
    return [[self numAtKey:theKey] intValue];
}
- (BOOL) isTrue:(NSString *) theKey{
    // returns NO even if not present
    return [self.content valueForKeyPath:theKey] && [@"true" isEqualToString:[self.content valueForKeyPath:theKey]];
}
- (NSString *) txtAtKey:(NSString *) theKey {
    @try {
        return (NSString *)[self.content valueForKeyPath:theKey];
    } @catch (NSException * e) {
        [Jlos logInternalError:[NSString stringWithFormat:@"Error getting txtAtKey: %@ with eror: %@", theKey, e]];
        return nil;
    } @finally { }
}
- (NSMutableArray *) listAtKey: (NSString *) theKey {
    @try {
        NSMutableArray *theArray = (NSMutableArray *)[self.content objectForKey:theKey];
        return theArray;
    } @catch (NSException * e) {
        [Jlos logInternalError:[NSString stringWithFormat:@"Error getting listAtKey: %@ with eror: %@", theKey, e]];
        return nil;
    } @finally { }
}

- (NSMutableDictionary *) dictAtKey: (NSString *) theKey {
    if (!theKey) {
        return self.content;
    } else {
        @try {
            NSMutableDictionary *theDict = (NSMutableDictionary *)[self.content objectForKey:theKey];
            return theDict;
        } @catch (NSException * e) {
            [Jlos logInternalError:[NSString stringWithFormat:@"Error getting dictAtKey: %@ with eror: %@", theKey, e]];
            return nil;
        } @finally { }
    }
}
- (NSDate *) dateAtKey: (NSString *) theKey {
    return [Jlos dateFromEpoch:[self numAtKey:theKey]];
}

+ (NSDate *) dateFromEpoch: (NSNumber *) dateInEpoch {
    if (dateInEpoch) {
        double dateNum =  [dateInEpoch doubleValue]/1000;
        return (NSDate *)[NSDate dateWithTimeIntervalSince1970:dateNum];
    } else {return nil;}
}

#pragma mark SETTER methods
- (BOOL) setInt: (    int   ) theInt atKey: (NSString *)theKey {
    return [self setNum:[NSNumber numberWithInt:theInt] atKey:theKey];
}
- (BOOL) setNum: (NSNumber *) theNum atKey: (NSString *)theKey {
    if (!theNum || !theKey) {
        return NO; // Cant set root to be a number
    } else if ([self.content valueForKeyPath:theKey]){
        [self.content setValue:theNum forKeyPath:theKey];
        return [self save];
    } else {
        NSMutableArray *keyPathArray = [NSMutableArray arrayWithArray:[theKey componentsSeparatedByString:@"."]];
        NSString *lastKey = [keyPathArray lastObject];
        [keyPathArray removeLastObject];
        
        [self RecusivelySetObject:theNum forNewKey:lastKey inkeyPathArray:keyPathArray];

        return [self save];
    }
}

- (BOOL) setTrue: (BOOL) isTrue atKey: (NSString *)theKey {
    NSString * trueString = isTrue? @"true": @"false";
    [self setTxt:trueString atKey:theKey];
    return [self save];
}
- (BOOL ) setTxt: (NSString *) theTxt atKey: (NSString *)theKey {
    if (!theTxt || !theKey) {
        return NO; // Cant set root to be a number
    } else if ([self.content valueForKeyPath:theKey]){
        [self.content setValue:theTxt forKeyPath:theKey];
        return [self save];
    } else {
        NSMutableArray *keyPathArray = [NSMutableArray arrayWithArray:[theKey componentsSeparatedByString:@"."]];
        NSString *lastKey = [keyPathArray lastObject];
        [keyPathArray removeLastObject];
        
        [self RecusivelySetObject:theTxt forNewKey:lastKey inkeyPathArray:keyPathArray];
        
        return [self save];
    }

}
- (BOOL ) setDict: (NSMutableDictionary *) theDict atKey: (NSString *) theKey{
    if (!theDict ) {
        return NO;
    } else if (!theKey) {
        // currently set so content cant be wiped out by mistake - to set content, so: yourJlos.content = theDict... or uncomment below and delete "return NO;"
        return NO;
        //self.content = theDict;
        //return [self save];
    } else {
        NSMutableArray *keyPathArray = [NSMutableArray arrayWithArray:[theKey componentsSeparatedByString:@"."]];
        NSString *lastKey = [keyPathArray lastObject];
        [keyPathArray removeLastObject];
        
        [self RecusivelySetObject:theDict forNewKey:lastKey inkeyPathArray:keyPathArray];
        
        return [self save];
    }
}
- (BOOL ) setList: (NSMutableArray *) theArray atKey: (NSString *) theKey {
    if (!theArray || !theKey) {
        return NO; // Cant set root to be a number
    } else {
        NSMutableArray *keyPathArray = [NSMutableArray arrayWithArray:[theKey componentsSeparatedByString:@"."]];
        NSString *lastKey = [keyPathArray lastObject];
        [keyPathArray removeLastObject];

        [self RecusivelySetObject:theArray forNewKey:lastKey inkeyPathArray:keyPathArray];
        
        return [self save];
    }
}
- (BOOL ) setDate: (NSDate *) theDate atKey: (NSString *) theKey {
    if (!theDate || !theKey) {
        return NO; // Cant set root to be a number
    } else {
        NSNumber * theDateNum = [NSNumber numberWithDouble:[theDate timeIntervalSince1970]*1000];
        return [self setNum:theDateNum atKey:theKey];
    }
}


#pragma mark keyPaths
-  (void) RecusivelySetObject: (id )anObject forNewKey:(NSString *)lastKey inkeyPathArray:(NSMutableArray *)keyPathArray {
    
    if ([keyPathArray count]== 0) {
        [self.content setValue:anObject forKey:lastKey];
    } else {
        NSString *newKeyPath = [keyPathArray componentsJoinedByString:@"."];
        if ([self.content valueForKeyPath:newKeyPath]) {
            NSMutableDictionary *lastDict = [self.content valueForKeyPath:newKeyPath];
            [lastDict setValue:anObject forKeyPath:lastKey];
            [self.content setValue:lastDict forKeyPath:newKeyPath];
        } else {
            
            NSMutableDictionary *lastDict = [[NSMutableDictionary alloc] init];
            [lastDict setValue:anObject forKey:lastKey];
            
            NSString *newLastKey = [keyPathArray lastObject];
            [keyPathArray removeLastObject];
            
            [self RecusivelySetObject:lastDict forNewKey:newLastKey inkeyPathArray:keyPathArray];
        }
    }
}


#pragma mark ARRAY related Methods
- (BOOL ) addDict: (NSMutableDictionary *) theDict toListKey: (NSString *) theKey {
    NSMutableArray *theArray = [self listAtKey:theKey];
    if (!theArray) {theArray = [[NSMutableArray alloc] init];}
    [theArray addObject:theDict];
    [self setList:theArray atKey:theKey];
    return [self save];
}
- (BOOL ) addTxtItem: (NSString *) theTxt toListKey: (NSString *) theKey {
    NSMutableArray *theArray = [self listAtKey:theKey];
    if (!theArray) {theArray = [[NSMutableArray alloc] init];}
    [theArray addObject:theTxt];
    [self setList:theArray atKey:theKey];
    return [self save];
}
- (BOOL) removeTxtItem:(NSString *)referenceStringToRemove fromListKey: (NSString *) theKey {
    
    NSMutableArray *theArray = [self listAtKey:theKey];
    if (!theArray) {theArray = [[NSMutableArray alloc] init];}
    [theArray removeObject:referenceStringToRemove];
    [self setList:theArray atKey:theKey];
    return [self save];
}
- (NSNumber *) numFromKey: (NSString *) objectKey fromList: (NSString *) listKey atIndex: (int) theIndex {
    NSMutableArray *theList = [self listAtKey:listKey];
    if (theList && ([theList count]>theIndex || theIndex == JLOS_LIST_LAST_OBJECT)) {
        // Todo add try catch?
        NSDictionary *theObject;
        if (theIndex == JLOS_LIST_LAST_OBJECT) {
            theObject = [theList lastObject];
        } else {
            theObject = (NSDictionary *)[theList objectAtIndex:theIndex];
        }
        return (NSNumber *)[theObject valueForKey:objectKey];
    } else {return nil;}
}
- (NSString *) txtFromKey: (NSString *) objectKey fromList: (NSString *) listKey atIndex: (int) theIndex{
    NSMutableArray *theList = [self listAtKey:listKey];
    if (theList && ([theList count]>theIndex || theIndex == JLOS_LIST_LAST_OBJECT)) {
        // Todo add try catch?
        NSDictionary *theObject;
        if (theIndex == JLOS_LIST_LAST_OBJECT) {
            theObject = [theList lastObject];
        } else {
            theObject = (NSDictionary *)[theList objectAtIndex:theIndex];
        }
        return (NSString *)[theObject valueForKey:objectKey];
    } else {return nil;}
}
- (NSDate *) dateFromKey: (NSString *) objectKey fromList: (NSString *) listKey atIndex: (int) theIndex{
    return [Jlos dateFromEpoch:[self numFromKey:objectKey fromList:listKey atIndex:theIndex]];
}

- (NSArray *) queryList: (NSString *) theKey forkey:(NSString *) lookUpkey withValue:(NSString *)theValue {
    NSMutableArray * tempResult = [[NSMutableArray alloc] init];
    
    // TODO TO DO!!
    
    return [NSArray arrayWithArray:tempResult];
}
#pragma mark Iterable Files
- (BOOL ) saveAsNewJlosDictAtFullPath:(NSString *)fullPath {
    BOOL sucessSave = fullPath && [self makeSureDirectoryExistsAt:self.relativePath];
    if (sucessSave) {
        sucessSave = [self.content writeToFile:fullPath atomically:YES];
    }
    if (!sucessSave) {
        [Jlos logInternalError:[NSString stringWithFormat:@"jlos Error in SAVE AS path %@",fullPath]];
    }
    return sucessSave;

    
}
+ (NSString *) getNextAvailableIterableFileNameWithPrefix: (NSString *)filePrefix
                                                 inPath: (NSString *)relativePath
                                                andDate: (NSDate *) theDate {
    // creates a new non existant file name to store the next set of data
    NSString *fileName;
    NSString *fullPath;
    
    if (!theDate) theDate = [NSDate date];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-dd"];
    [dateFormat setTimeZone:[NSTimeZone defaultTimeZone]];
    
    // Make sure directory exists - if not create it
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL isDir;
    
    if (filePrefix) {
        fullPath = [Jlos getFullPathfrom:relativePath fileNamed:nil];
        if (!([fileManager fileExistsAtPath:relativePath  isDirectory:&isDir] &&  isDir) ){
            [fileManager createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        // iterate file names until a new file name can be used.
        int fileNum = 0;
        do {
            fileName = [NSString stringWithFormat:@"%@-%@-%d.dict", filePrefix,[dateFormat stringFromDate: theDate], fileNum ];
            fullPath = [Jlos getFullPathfrom:relativePath fileNamed:fileName]; // @"rawdataFiles"
            fileNum += 1;
        } while ([fileManager fileExistsAtPath:fullPath]);
        
        return fullPath;
    } else {
        return nil;
    }
}
+ (NSString *) getFilePrefixFromIterableFileName:(NSString *)fileName {
    NSArray *nameArray = [fileName componentsSeparatedByString:@"-"];
    return nameArray[0];
}
+ (NSString *) addCurrentSuffixToFileName:(NSString *)filePrefix {
    if (filePrefix) {
        return [NSString stringWithFormat:@"%@-Current",filePrefix];
    } else {return nil;}
}
+ (NSString *) folderNameFromPrefix:(NSString *)filePrefix {
    if (filePrefix) {
        return [NSString stringWithFormat:@"%@Files",filePrefix];
    } else {return nil;}
}



#pragma mark file manager and file
- (NSString *) addExtIfNeededTo: (NSString *) fileRef forRelativepath:(NSString *) relativePath {
    // if fileRef already has an extension, no need to add one - if it doesn't, check to see if json file exists, and if it doesn't return a .dict
    // if has an extension, return the fileRef
    if (!fileRef) {
        return nil;
    } else if (![[fileRef pathExtension]  isEqual: @""]) {
        return fileRef;
    } else {
        NSString *fullPath = [Jlos getFullPathfrom:relativePath fileNamed:[fileRef stringByAppendingPathExtension:@"json"]];
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        if ([fileManager fileExistsAtPath:fullPath]) {
            return [fileRef stringByAppendingPathExtension:@"json"];
        } else {
            return [fileRef stringByAppendingPathExtension:@"dict"];
        }
    }
}
- (NSString *) getTextFromFileAtPath:(NSString *)relativePath
                         fileNamed:(NSString *)fileName {
    NSString *returnString = @"";
    
    NSFileManager *iosFileMgr = [NSFileManager defaultManager];
    
    NSString *fullPath = [Jlos getFullPathfrom:relativePath fileNamed:fileName];
    
    NSData *dataInFile = [iosFileMgr contentsAtPath:(NSString *)fullPath];
    
    returnString=[[NSString alloc] initWithBytes:dataInFile.bytes length:dataInFile.length encoding:NSUTF8StringEncoding];
    
    return returnString;
    
}
- (NSMutableDictionary *) getDictFromJsonText: (NSString *)jsonsText {
    
    NSData *jsonData = [jsonsText dataUsingEncoding:NSUTF8StringEncoding];
    
    //NSError *error = nil; todo throw error here
    NSMutableDictionary *theDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    
    if(!theDict) {
        return nil;
    } else {
        return theDict;
    }
}
- (NSMutableDictionary *) getDictFromJsonFilenamed: (NSString *) fileName relativePath:(NSString *) relativePath {
    return [self getDictFromJsonText:[self getTextFromFileAtPath:relativePath fileNamed:fileName]];
}
- (BOOL) makeSureDirectoryExistsAt: (NSString *) relativePath {
    
    NSFileManager *iosFileMgr = [NSFileManager defaultManager];
    BOOL isDir;
    if (relativePath) {
        NSString * fullPath = [Jlos getFullPathfrom:relativePath fileNamed:nil];
        if (!([iosFileMgr fileExistsAtPath:fullPath isDirectory:&isDir] && isDir)) {
            return [iosFileMgr createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
        } else {
            // Already exists
            return YES;
        }
    } else {
        return YES;
    }
}
- (NSString *) getJsonTxtFromDict: (NSMutableDictionary *) dict {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        return nil;
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

+ (NSString *) getFullPathfrom:(NSString *)relativepath
                     fileNamed:(NSString *)fileName {
    //NSLog(@"getfullpath from %@ %@",relativepath, fileName);
    NSString *fullPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    if (relativepath) {fullPath = [fullPath stringByAppendingPathComponent:relativepath];}
    if (fileName) {
        if (![fullPath hasSuffix:@"/"]) {fullPath = [fullPath stringByAppendingString:@"/"];}
        fullPath = [fullPath stringByAppendingString: fileName];
    }
    
    return fullPath;
}
+ (BOOL) makeTextFileAtPath:(NSString *)relativePath
                      named:(NSString *)fileName
                withContent:(NSString *)contentText {
    NSString *fullPath = [Jlos getFullPathfrom:fileName fileNamed:relativePath];
    return [contentText writeToFile:fullPath atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
}



#pragma mark logging and error logging
// A special jlos object that records errors that occur within this file - like saving errors
+ (void) logInternalError: (NSString *) theMsg {
    Jlos *errorLog = [[Jlos alloc] initWithName:JLOS_INTERNALERRORS_FILENAME atPath:nil withInitialDict:nil];
    
    NSMutableDictionary *lastError = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000],@"time",
                                      @"jLos INTERNAL",@"src",
                                      theMsg, @"msg",
                                      nil];
    [errorLog  addDict:lastError toListKey:JLOS_INTERNALERRORS_LIST];
    [errorLog save];
}

#pragma mark Methods todo later
// methods implemnted later when want to have an array in the keypath
- (NSMutableDictionary *) getRootObjectInKeypath: (NSString *) keyPath{
    if (keyPath) {
        NSMutableArray *keyPathArray = [NSMutableArray arrayWithArray:[keyPath componentsSeparatedByString:@"."]];
        return [self getRootObjectFrom:self.content ForkeyPathArray:keyPathArray];
    } else {
        return nil;
    }
}
- (NSMutableDictionary *) getRootObjectFrom: (NSMutableDictionary *) theDict ForkeyPathArray: (NSMutableArray *)keyPathArray {
    if (!keyPathArray) {
        // should not nromaly happen
        return nil;
    } else if ([keyPathArray count]==1) {
        // todo if it's an array eg item[3], then have to deal with it separately
        return theDict;
    } else {
        // todo if it's an array eg item[3], then have to deal with it separately
        theDict = [theDict objectForKey:keyPathArray[0]];
        [keyPathArray removeObjectAtIndex:0];
        return [self getRootObjectFrom:theDict ForkeyPathArray:keyPathArray];
    }
}


@end
