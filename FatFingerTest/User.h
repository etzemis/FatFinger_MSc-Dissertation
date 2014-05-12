//
//  User.h
//  FatFinger
//
//  Created by Evangelos Tzemis on 5/10/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FDTrial, FNDTrial, NFDTrial, NFNDTrial, RepetitionStats;

@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * maxArea;
@property (nonatomic, retain) NSNumber * minArea;
@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) NSSet *fdtrials;
@property (nonatomic, retain) NSSet *fndtrials;
@property (nonatomic, retain) NSSet *nfdtrials;
@property (nonatomic, retain) NSSet *nfndtrials;
@property (nonatomic, retain) NSSet *repetitionStats;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addFdtrialsObject:(FDTrial *)value;
- (void)removeFdtrialsObject:(FDTrial *)value;
- (void)addFdtrials:(NSSet *)values;
- (void)removeFdtrials:(NSSet *)values;

- (void)addFndtrialsObject:(FNDTrial *)value;
- (void)removeFndtrialsObject:(FNDTrial *)value;
- (void)addFndtrials:(NSSet *)values;
- (void)removeFndtrials:(NSSet *)values;

- (void)addNfdtrialsObject:(NFDTrial *)value;
- (void)removeNfdtrialsObject:(NFDTrial *)value;
- (void)addNfdtrials:(NSSet *)values;
- (void)removeNfdtrials:(NSSet *)values;

- (void)addNfndtrialsObject:(NFNDTrial *)value;
- (void)removeNfndtrialsObject:(NFNDTrial *)value;
- (void)addNfndtrials:(NSSet *)values;
- (void)removeNfndtrials:(NSSet *)values;

- (void)addRepetitionStatsObject:(RepetitionStats *)value;
- (void)removeRepetitionStatsObject:(RepetitionStats *)value;
- (void)addRepetitionStats:(NSSet *)values;
- (void)removeRepetitionStats:(NSSet *)values;

@end
