//
//  TrialInfo.h
//  FatFinger
//
//  Created by Evangelos Tzemis on 3/28/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrialInfo : NSObject
@property (nonatomic, retain) NSNumber * trialID;
@property (nonatomic, retain) NSNumber * n;
@property (nonatomic, retain) NSNumber * target;

@property (nonatomic, retain) NSNumber * finalOffset;
@property (nonatomic, retain) NSNumber * continuousTargetPosition;
@property (nonatomic) BOOL isDescrete;          //Defines the type of the experiment
@property (nonatomic) BOOL hasFeedback;         //Defines whether users will have visual feedback

// Parameters used to measure user performance
@property (nonatomic, retain) NSNumber * reEntries;
@property (nonatomic, retain) NSNumber * totalTime;
@property (nonatomic, retain) NSNumber * reTouches;

//No Feedback
@property (nonatomic, retain) NSNumber * hitInsideTarget;


@property (nonatomic, retain) NSNumber * rawInputValue;
@end
