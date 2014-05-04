//
//  FFExperimentViewController.h
//  FatFingerTest
//
//  Created by Evangelos Tzemis on 2/20/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "TrialSequence.h"

@interface FFTrialViewController : UIViewController
@property (nonatomic, strong) User *user;
// It is passed from WarmUpTrialViewController
@property (nonatomic, strong) TrialSequence *trialSequence;

@end
