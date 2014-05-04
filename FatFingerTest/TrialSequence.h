//
//  TrialSequence.h
//  FatFinger
//
//  Created by Evangelos Tzemis on 3/28/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TrialInfo.h"
@interface TrialSequence : NSObject
-(TrialInfo *)getNextTrial;
-(TrialInfo *)getNextWarmUpTrial;
@end
