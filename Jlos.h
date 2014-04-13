//
//  Jlos.h
//  Released uner MIT License with attribution
//
//  Created by Salman Farmanfarmaian on 08/04/14.
//  Copyright (c) 2014 All rights reserved.
//
/* * * * * * * * * * * * * * * * * * * * * * * * * * *
 
 Current Limitations:
 - Lists (ie arrays) work well only at top level
 - dictionaries can be one level deep
 - dicts within dicts within arrays dont work well now but can be added later with some recursive functions
 - Error catching and checking needs much improvement
 
 * * * * * * * * */


#import <Foundation/Foundation.h>


static  NSString * const JLOS_INTERNALERRORS_FILENAME = @"jlosInternalErrs.dict";
static  NSString * const JLOS_INTERNALERRORS_LIST = @"internalErrors";

static const int JLOS_LIST_LAST_OBJECT = -1;

@interface Jlos : NSObject
@property (strong, nonatomic) NSMutableDictionary *content;

@property (strong, nonatomic) NSString *fileReference;
@property (strong, nonatomic) NSString *relativePath;
@property (strong, nonatomic) NSMutableDictionary *initialValue;


-(instancetype)initWithName: (NSString *) fileReference atPath: (NSString *) relativePath  withInitialDict:(NSMutableDictionary *)initialValues;
- (BOOL ) save;
- (BOOL ) resetToInitialValue;
- (BOOL ) loadContentFromFile;

// GETTING VALUES
- (NSNumber *) numAtKey: (NSString *) theKey;
- (NSString *) txtAtKey: (NSString *) theKey;
- (NSDate   *) dateAtKey:(NSString *) theKey;
- (int       ) intAtKey: (NSString *) theKey;
- (BOOL      ) isTrue:   (NSString *) theKey;
- (NSMutableDictionary *) dictAtKey: (NSString *) theKey;

// SETTING VALUES
- (BOOL ) setNum: (NSNumber *) theStr  atKey: (NSString *)theKey;
- (BOOL ) setTxt: (NSString *) theTxt  atKey: (NSString *)theKey;
- (BOOL ) setDate:(NSDate *  ) theDate atKey: (NSString *) theKey;
- (BOOL ) setInt: (int       ) theInt  atKey: (NSString *)theKey;
- (BOOL ) setTrue:(BOOL      ) isTrue  atKey: (NSString *)theKey;
- (BOOL ) setDict:(NSMutableDictionary *) theDict  atKey: (NSString *) theKey;

// ARRAY SPECIFIC
- (NSMutableArray *) listAtKey: (NSString *) theKey;

- (BOOL ) setList:      (NSMutableArray *     ) theArray    atKey: (NSString *) theKey;
- (BOOL ) addDict:      (NSMutableDictionary *) theDict toListKey: (NSString *) theKey ;
- (BOOL ) addTxtItem:   (NSString            *) theTxt  toListKey: (NSString *) theKey;
- (BOOL ) removeTxtItem:(NSString *)referenceStringToRemove fromListKey: (NSString *) theKey;
- (NSNumber *) numFromKey:  (NSString *) objectKey fromList: (NSString *) listKey atIndex: (int) theIndex;
- (NSString *) txtFromKey:  (NSString *) objectKey fromList: (NSString *) listKey atIndex: (int) theIndex;
- (NSDate   *) dateFromKey: (NSString *) objectKey fromList: (NSString *) listKey atIndex: (int) theIndex;

- (NSArray *) queryList: (NSString *) theKey forkey:(NSString *) lookUpkey withValue:(NSString *)theValue;
// INCOMPETE - todo (BOOL) removeFromDict:


// File Management and iterable file names
+ (NSString *) getFullPathfrom:(NSString *)relativepath
                     fileNamed:(NSString *)fileName;
+ (BOOL) makeTextFileAtPath:(NSString *)relativePath
                      named:(NSString *)fileName
                withContent:(NSString *)contentText;

- (BOOL      ) saveAsNewJlosDictAtFullPath: (NSString *)fullPath;
+ (NSString *) getNextAvailableIterableFileNameWithPrefix: (NSString *)filePrefix
                                                 inPath: (NSString *)relativePath
                                                andDate: (NSDate *) theDate;
+ (NSString *) getFilePrefixFromIterableFileName:(NSString *)fileName;
+ (NSString *) addCurrentSuffixToFileName:(NSString *)filePrefix;
+ (NSString *) folderNameFromPrefix:(NSString *)filePrefix;

+ (NSDate   *) dateFromEpoch: (NSNumber *) dateInEpoch;



// DEBUGGING
+ (void) logInternalError: (NSString *) theMsg;

@end
