//
//  FFTrialView.h
//  FatFinger
//
//  Created by Evangelos Tzemis on 3/24/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrialInfo.h"
#import <AudioToolbox/AudioToolbox.h>

@interface FFTrialView : UIView

@property (nonatomic, strong) NSNumber *N;  // number of segments
@property (nonatomic, strong) NSNumber *target; //Which Segment We will hit
@property NSNumber *min;
@property NSNumber *max;
@property (nonatomic) BOOL shouldAnimateEndOfExperiment;
@property (nonatomic) BOOL shouldShowStartNextTrialButton;

//soundFile
@property (nonatomic) SystemSoundID successSound;

- (void)prepareForTrialWithN:(NSNumber *)N
                      Target:(NSNumber *)target
              inDescreteMode:(BOOL)isDescrete
                withFeedback:(BOOL)hasFeedback;
@end
