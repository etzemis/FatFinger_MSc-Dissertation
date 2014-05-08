//
//  BlockInfo.h
//  FatFinger
//
//  Created by Evangelos Tzemis on 5/8/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 * BlockInfo contains information about each block - repetition
 */
@interface BlockInfo : NSObject
@property (nonatomic, strong) NSNumber *id;


-(void)addCompletionTimeOFTrial:(NSNumber *)totalTime;
-(void)addTargetReEntriesOFTrial:(NSNumber *)targetReentries;
-(void)addTargetReTouchesOFTrial:(NSNumber *)targetReTouches;
-(NSNumber *)getAverageCompletionTime;
-(NSNumber *)getAverageReEntries;
-(NSNumber *)getAverageReTouches;
-(NSNumber *)getTotalTime;
@end
