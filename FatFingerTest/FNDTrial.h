//
//  FNDTrial.h
//  FatFinger
//
//  Created by Evangelos Tzemis on 5/8/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface FNDTrial : NSManagedObject

@property (nonatomic, retain) NSNumber * n;
@property (nonatomic, retain) NSNumber * offset;
@property (nonatomic, retain) NSNumber * reEntries;
@property (nonatomic, retain) NSNumber * reTouches;
@property (nonatomic, retain) NSNumber * target;
@property (nonatomic, retain) NSNumber * targetPosition;
@property (nonatomic, retain) NSNumber * totalTime;
@property (nonatomic, retain) NSNumber * trialID;
@property (nonatomic, retain) User *whichUser;

@end
