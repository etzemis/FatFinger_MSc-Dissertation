//
//  TrialSequence.m
//  FatFinger
//
//  Created by Evangelos Tzemis on 3/28/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import "TrialSequence.h"
#import "TrialInfo.h"


@interface TrialSequence ()
@property (nonatomic, strong) NSMutableArray* repetitions;    // of Trial info
@end

@implementation TrialSequence


#pragma mark - Initialization
-(instancetype)init
{
    self = [super init];
    
    if (self){
        [self createTrialSequence];
    }
    return self;
}


#pragma mark - get next Trial
-(Repetition *)getNextRepetition{
    Repetition *r  = [self.repetitions firstObject];
    if(r) [self.repetitions removeObjectAtIndex:0]; // if not nil;
    return r;
}



#pragma mark - create Trial Sequence
- (void)createTrialSequence
{
    int tID = 1;    //Trial ID
    for( int i = 0; i < [TrialSequence validRepetitions]; i++)      // for each repetition
    {
        Repetition *currentRepetition = [[Repetition alloc] init];
        [self.repetitions addObject:currentRepetition];
        
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
            
            [currentRepetition addTrial:trial];
        }
    }
}



#pragma mark - Getters




-  (NSMutableArray * )repetitions
{
    if(!_repetitions) _repetitions = [[NSMutableArray alloc] init];
    return _repetitions;
}


#pragma mark - Class functions

+ (int)validRepetitions
{
    return 2;
}

+ (NSArray *)validN
{
    return @[@2];   //@[@2, @3, @4......]
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
