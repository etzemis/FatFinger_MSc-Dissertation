//
//  BlockInfo.m
//  FatFinger
//
//  Created by Evangelos Tzemis on 5/8/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//



#import "BlockInfo.h"

@interface BlockInfo()
@property (nonatomic, strong) NSMutableArray *trialCompletionTimes; //of NSNUMBER
@property (nonatomic, strong) NSMutableArray *trialReEntries; //of NSNUMBER
@property (nonatomic, strong) NSMutableArray *trialReTouches; //of NSNUMBER
@end

@implementation BlockInfo

-(void)addCompletionTimeOFTrial:(NSNumber *)totalTime
{
    [self.trialCompletionTimes addObject:totalTime];
}
-(void)addTargetReEntriesOFTrial:(NSNumber *)targetReentries
{
    [self.trialReEntries addObject:targetReentries];
}
-(void) addTargetReTouchesOFTrial:(NSNumber *)targetReTouches
{
    [self.trialReTouches addObject:targetReTouches];
}

-(NSNumber *)getAverageCompletionTime
{
    float sum = 0;
    for(NSNumber *trialTime in self.trialCompletionTimes)
    {
        sum += [trialTime floatValue];
    }
    return @(sum/[self.trialCompletionTimes count]);
}

-(NSNumber *)getAverageReEntries
{
    float sum = 0;
    for (NSNumber *trialReEntries in self.trialReEntries) {
        sum += [trialReEntries intValue];
    }
    return @(sum/[self.trialReEntries count]);
}

-(NSNumber *)getAverageReTouches
{
    float sum = 0;
    for (NSNumber *trialReTouches in self.trialReTouches) {
        sum += [trialReTouches intValue];
    }
    return @(sum/[self.trialReTouches count]);
}

-(NSNumber *)getTotalTime
{
    float sum = 0;
    for(NSNumber *trialTime in self.trialCompletionTimes)
    {
        sum += [trialTime floatValue];
    }
    return @(sum);
}

#pragma mark - Setters - Getters

-(NSMutableArray *)trialCompletionTimes
{
    if(!_trialCompletionTimes) _trialCompletionTimes = [[NSMutableArray alloc] init];
    return _trialCompletionTimes;
}

-(NSMutableArray *)trialReEntries
{
    if(!_trialReEntries) _trialReEntries = [[NSMutableArray alloc] init];
    return _trialReEntries;
}

-(NSMutableArray *)trialReTouches
{
    if(!_trialReTouches) _trialReTouches = [[NSMutableArray alloc] init];
    return _trialReTouches;
}

@end
