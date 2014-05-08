//
//  Repetition.m
//  FatFinger
//
//  Created by Evangelos Tzemis on 5/8/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import "Repetition.h"
#import "TrialInfo.h"

@interface Repetition()
@property (nonatomic, strong) NSMutableArray* trialSequence;    // of Trial info
@end
@implementation Repetition


#pragma mark - get next Trial
-(TrialInfo *)getNextTrial{
    TrialInfo *t  = [self.trialSequence firstObject];
    if(t) [self.trialSequence removeObjectAtIndex:0]; // if not nil;
    return t;
}



-(void)addTrial:(TrialInfo *)trial
{
    [self.trialSequence addObject:trial];
}

#pragma mark - Getters

-  (NSMutableArray * )trialSequence
{
    if(!_trialSequence) _trialSequence = [[NSMutableArray alloc] init];
    return _trialSequence;
}


@end
