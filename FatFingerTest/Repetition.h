//
//  Repetition.h
//  FatFinger
//
//  Created by Evangelos Tzemis on 5/8/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TrialInfo.h"
@interface Repetition : NSObject
-(TrialInfo *)getNextTrial;
-(void)addTrial:(TrialInfo *)trial;
@end
