//
//  RepetitionStats.h
//  FatFinger
//
//  Created by Evangelos Tzemis on 5/8/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface RepetitionStats : NSManagedObject

@property (nonatomic, retain) NSNumber * repetitionID;
@property (nonatomic, retain) NSNumber * averageReEntries;
@property (nonatomic, retain) NSNumber * averageReTouches;
@property (nonatomic, retain) NSNumber * averageTrialTime;
@property (nonatomic, retain) NSNumber * totalTime;
@property (nonatomic, retain) User *whichUser;

@end
