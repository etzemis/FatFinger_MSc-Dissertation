//
//  TrialSequence.m
//  FatFinger
//
//  Created by Evangelos Tzemis on 3/28/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import "TrialSequence.h"


@interface TrialSequence ()
@property (nonatomic, strong) NSMutableArray* trialSequence;    // of Trial info
@property (nonatomic, strong) NSMutableArray* trialWarmUpSequence;    // of Trial info
#define NUMBER_OF_WARMUP_TRIALS 2
@end

@implementation TrialSequence




#pragma mark - get next Trial
-(TrialInfo *)getNextTrial{
    TrialInfo *t  = [self.trialSequence firstObject];
    if(t) [self.trialSequence removeObjectAtIndex:0]; // if not nil;
    return t;
}

-(TrialInfo *)getNextWarmUpTrial
{
    TrialInfo *t  = [self.trialWarmUpSequence firstObject];
    if(t) [self.trialWarmUpSequence removeObjectAtIndex:0]; // if not nil;
    return t;
}

#pragma mark - Initialization
-(instancetype)init
{
    self = [super init];
    
    if (self){
        [self createTrialSequence];
        [self createWarmUpTrialSequence];
    }
    return self;
}

#pragma mark - create Trial Sequence
- (void)createTrialSequence
{
    int tID = 1;    //Trial ID
    for( int i = 0; i < [TrialSequence validRepetitions]; i++)      // for each repetition
    {
        NSMutableArray * DFTrials = [TrialSequence sequenceofTrailsforValidN_IsDescrete:YES hasFeedback:YES];
        NSMutableArray * NDFTrials = [TrialSequence sequenceofTrailsforValidN_IsDescrete:NO hasFeedback:YES];
        NSMutableArray * DNFTrials = [TrialSequence sequenceofTrailsforValidN_IsDescrete:YES hasFeedback:NO];
        NSMutableArray * NDNFTrials = [TrialSequence sequenceofTrailsforValidN_IsDescrete:NO hasFeedback:NO];
        
        
        NSMutableArray * allTrials = [NSMutableArray
                                      arrayWithCapacity:([DFTrials count] + [NDFTrials count]
                                                         + [DNFTrials count] + [NDNFTrials count])];
        [allTrials addObjectsFromArray:DFTrials];
        [allTrials addObjectsFromArray:NDFTrials];
        [allTrials addObjectsFromArray:DNFTrials];
        [allTrials addObjectsFromArray:NDNFTrials];
        
        while (true) {
            NSUInteger count = [allTrials count];  // how many left
            
            if (!count) break;                      // nothing left
            
            int r = arc4random()%count;             // choose randomly
            
            TrialInfo *trial = [allTrials objectAtIndex:r];
            trial.trialID = [NSNumber numberWithInt:tID++];
            [allTrials removeObjectAtIndex:r];
            
            [self.trialSequence addObject:trial];
        }
    }
}

//Randomly takes NUMBER_OF_WARMUP_TRIALS trilas from the trial Sequence
//and adds them to the WarmUp. Could be done differently

- (void)createWarmUpTrialSequence
{
    for (int i = 0; i < NUMBER_OF_WARMUP_TRIALS; i++) {
        
        int r = arc4random()%[self.trialSequence count];
        
        TrialInfo *trial = [self.trialSequence objectAtIndex:r];
        trial.trialID = [NSNumber numberWithInt:i+1];
        [self.trialWarmUpSequence addObject:trial];
    }
}

#pragma mark - Getters

-  (NSMutableArray * )trialSequence
{
    if(!_trialSequence) _trialSequence = [[NSMutableArray alloc] init];
    return _trialSequence;
}

-  (NSMutableArray * )trialWarmUpSequence
{
    if(!_trialWarmUpSequence) _trialWarmUpSequence = [[NSMutableArray alloc] init];
    return _trialWarmUpSequence;
}

#pragma mark - Class functions

+ (int)validRepetitions
{
    return 2;
}

+ (NSArray *)validN
{
    return @[@5];   //@[@2, @3, @4......]
}

# pragma mark - Trial Constructors

+ (NSMutableArray*)sequenceofTrailsforValidN_IsDescrete:(BOOL)isDescrete hasFeedback:(BOOL)hasFeedback
{
    
    NSMutableArray *trialSequence = [[NSMutableArray alloc] init];
    for (NSNumber *N in [TrialSequence validN])
    {
        //create the target for that N
        NSArray * targets  = [TrialSequence validTargetsForN:N];
        
        for (NSNumber *target in targets){
            //create Descrete
            TrialInfo *t1 = [[TrialInfo alloc] init];
            t1.n = N;
            t1.target = target;
            t1.isDescrete = isDescrete;
            t1.hasFeedback = hasFeedback;
            t1.trialID = @0;
            [trialSequence addObject:t1];
        }
    }
    return trialSequence;
}

//set targets for a specific N -- actually 1..N
+ (NSArray *)validTargetsForN:(NSNumber*)N{
    NSMutableArray *helper = [[NSMutableArray alloc] init];
    for (int i = 1; i<=[N integerValue]; i++) {
        [helper addObject:@(i)];
    }
    return [NSArray arrayWithArray:helper];
}


@end
