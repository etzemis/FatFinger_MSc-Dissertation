//
//  NFDTrial.h
//  FatFinger
//
//  Created by Evangelos Tzemis on 5/10/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface NFDTrial : NSManagedObject

@property (nonatomic, retain) NSNumber * hitInsideTarget;
@property (nonatomic, retain) NSNumber * n;
@property (nonatomic, retain) NSNumber * offset;
@property (nonatomic, retain) NSNumber * rawInputValue;
@property (nonatomic, retain) NSNumber * reEntries;
@property (nonatomic, retain) NSNumber * repetitionID;
@property (nonatomic, retain) NSNumber * reTouches;
@property (nonatomic, retain) NSNumber * target;
@property (nonatomic, retain) NSNumber * totalTime;
@property (nonatomic, retain) NSNumber * trialID;
@property (nonatomic, retain) User *whichUser;

@end
