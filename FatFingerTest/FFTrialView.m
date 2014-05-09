//
//  FFTrialView.m
//  FatFinger
//
//  Created by Evangelos Tzemis on 3/24/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import "FFTrialView.h"
#import "TrialComplitedNotification.h"

@interface FFTrialView ()

//Experiment Types
@property (nonatomic) BOOL isDescrete;
@property (nonatomic) BOOL hasFeedback;

//Target Depedent
@property (nonatomic, strong) NSNumber *rangeOfTarget;  //N depedent

@property (nonatomic, strong) NSNumber *startOfTargetRegion;
@property (nonatomic, strong) NSNumber *startOfTargetRegionInRad;

@property (nonatomic, strong) NSNumber *endOfTargetRegion;
@property (nonatomic, strong) NSNumber *endOfTargetRegionInRad;

@property (nonatomic, strong) NSNumber *lastIndexPosition;
@property (nonatomic, strong) NSNumber *lastIndexPositionInRad;

//Continuous Trial Additional Types
@property (nonatomic, strong) NSNumber *continuousTarget;
@property (nonatomic, readonly) NSNumber *continuousTargetInRad;

// Helper properties
@property (nonatomic, strong) NSNumber *timesWentOutside;
@property (nonatomic, strong) NSDate *startTimeOfTrial;
@property (nonatomic) BOOL shouldResetParametersInFirstTouch;
@property (nonatomic) BOOL isInsideTarget;

//parameters to Measure
@property (nonatomic) int targetReentries;
@property (nonatomic) int reTouches;


//No Feedback Trial Additional Types
@property (nonatomic, strong) NSMutableArray *NFPastIndexes;  //of NSNumber (float)
@property (nonatomic) BOOL NFShowFinalSelectedRangeAfterComplitingNFTrial;
@property (nonatomic) BOOL NFWaitingForUserTapScreenToConfirmFeedBackWasSeen;
@property (nonatomic, strong) NSNumber *NFFinalIndexToShow;

//Last Trials info
@property (nonatomic, strong) TrialInfo *lastTrialInfo;


#define TIMES_TO_DIVIDE_EACH_CONCRETE_TARGET 100 //Each target is idvided in those segments and one is chosen randomly
#define OFFSET_FOR_CONTINUOUS_TARGET 0.015      // How easy is to hit the continuous target

#define DELAY_UNTIL_CONFIRMING_SELECTION_WITH_FEEDBACK 1
//#define DELAY_UNTIL_CONFIRMING_SELECTION_WITHOUT_FEEDBACK 0.5
@end




@implementation FFTrialView


#pragma mark - Touch Events

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if(self.NFWaitingForUserTapScreenToConfirmFeedBackWasSeen){       // I set it back to NO only when we start the new trial----To Reject rest of input
        //Reject new Events
        self.userInteractionEnabled = NO;
        
        // Notify that last Trial Ended
        NSDictionary *userInfo =@{ TrialComplitedNotificationResult: self.lastTrialInfo};
        [[NSNotificationCenter defaultCenter] postNotificationName:TrialComplitedNotification
                                                            object:self
                                                          userInfo:userInfo];
        self.NFShowFinalSelectedRangeAfterComplitingNFTrial = NO;
    }
    else{
        if( self.shouldResetParametersInFirstTouch) {        //Reset Parameters in very first Touch
            self.shouldResetParametersInFirstTouch = NO;
            
            self.startTimeOfTrial = [NSDate date];
            self.targetReentries = 0;
            self.reTouches = 0;
            self.timesWentOutside = @0;
            //No FeedBack
            self.NFShowFinalSelectedRangeAfterComplitingNFTrial = NO;
        }
        
        NSArray *touch = [touches allObjects];
        UITouch *index = [touch firstObject];
        self.lastIndexPosition = [index valueForKey:@"_pathMajorRadius"];
        //NSLog(@"%.2f", [indexval floatValue]);
        NSNumber *pr = @( ([self.lastIndexPosition floatValue] - [_min floatValue])/ ([_max floatValue]-[_min floatValue]));
        self.lastIndexPositionInRad = @([pr floatValue]*360);
        
        if (self.hasFeedback) {
            if ([self isInsideTarget:self.lastIndexPosition] && !self.isInsideTarget) {
                //NSLog(@"We Went IN");
                self.isInsideTarget = YES;
                [NSTimer scheduledTimerWithTimeInterval:DELAY_UNTIL_CONFIRMING_SELECTION_WITH_FEEDBACK
                                                 target:self
                                               selector:@selector(checkIfStillInsideTarget:)
                                               userInfo:nil
                                                repeats:NO];
            }
        }
        else if (!self.hasFeedback) {
            [self.NFPastIndexes addObject:self.lastIndexPosition];
            NSLog(@"Index With size inserted %@", self.lastIndexPosition);
            if ([self isInsideTarget:self.lastIndexPosition] && !self.isInsideTarget) self.isInsideTarget = YES;
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    // if User is Observing The FeedBack Then reject input
    if(!self.NFWaitingForUserTapScreenToConfirmFeedBackWasSeen){
        NSArray *touch = [touches allObjects];
        UITouch *index = [touch firstObject];
        self.lastIndexPosition = [index valueForKey:@"_pathMajorRadius"];
        //NSLog(@"%.2f", [indexval floatValue]);
        NSNumber *pr = @( ([self.lastIndexPosition floatValue] - [_min floatValue])/ ([_max floatValue]-[_min floatValue]));
        self.lastIndexPositionInRad = @([pr floatValue]*360);
        
        if (self.hasFeedback) {
            //check if target is beeing hit succesfully
            if ([self isInsideTarget:self.lastIndexPosition] && !self.isInsideTarget) {
                //NSLog(@"We Went IN");
                self.isInsideTarget = YES;
                [NSTimer scheduledTimerWithTimeInterval:DELAY_UNTIL_CONFIRMING_SELECTION_WITH_FEEDBACK
                                                 target:self
                                               selector:@selector(checkIfStillInsideTarget:)
                                               userInfo:nil
                                                repeats:NO];
            }
            else if(![self isInsideTarget:self.lastIndexPosition] && self.isInsideTarget){  // we were inside
                //NSLog(@"We Went Out");
                self.isInsideTarget = NO;
                self.timesWentOutside = @([self.timesWentOutside integerValue]+1);
                self.targetReentries++;
            }
        }
        else if (!self.hasFeedback) {
            [self.NFPastIndexes addObject:self.lastIndexPosition];
            NSLog(@"Index With size inserted %@", self.lastIndexPosition);
            
            //Count re-Entries in No FeedBack
            if ([self isInsideTarget:self.lastIndexPosition] && !self.isInsideTarget) {
                //NSLog(@"We Went IN");
                self.isInsideTarget = YES;
            }
            else if(![self isInsideTarget:self.lastIndexPosition] && self.isInsideTarget){  // we were inside
                //NSLog(@"We Went Out");
                self.isInsideTarget = NO;
                self.targetReentries++;
            }
            
        }
    }
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    // if User is Observing The FeedBack Then reject input
    if(!self.NFWaitingForUserTapScreenToConfirmFeedBackWasSeen){
        if(self.hasFeedback){
            self.lastIndexPositionInRad = @(0);
            self.reTouches++;
            self.isInsideTarget = NO; // when release hand and first target...dont select it
        }
        else if (!self.hasFeedback)
        {
            self.lastIndexPositionInRad = @(0);
            [self noFeedBackSelector];
        }
    }
}




#pragma mark - Feedback Timer Selector

- (void)checkIfStillInsideTarget:(NSTimer *)timer{
    if (self.isInsideTarget && [self.timesWentOutside integerValue] <= 0) {
        self.timesWentOutside = @0; //reset it
        
        // Gather all relevant information for this Trial into an Object
        NSTimeInterval totalTimeOfTrial = [self.startTimeOfTrial timeIntervalSinceNow];
        
        self.lastTrialInfo = [[TrialInfo alloc] init];        //ID is filled in superView
        self.lastTrialInfo.n = self.N;
        self.lastTrialInfo.target = self.target;
        self.lastTrialInfo.isDescrete = self.isDescrete;
        self.lastTrialInfo.hasFeedback  = self.hasFeedback;
        self.lastTrialInfo.rawInputValue = self.lastIndexPosition;
        
        
        self.lastTrialInfo.totalTime = @(-1*totalTimeOfTrial);
        self.lastTrialInfo.reEntries = @(self.targetReentries);
        self.lastTrialInfo.reTouches = @(self.reTouches);
        
        
        if(!self.isDescrete) {
            self.lastTrialInfo.finalOffset = @(([self.lastIndexPosition floatValue] - [self.continuousTarget floatValue]) / ([_max floatValue]-[_min floatValue]));  // percentage of Offset compared to whole range
            // <0 if before target and the opposite
            self.lastTrialInfo.continuousTargetPosition = self.continuousTarget;
        }
        
        NSDictionary *userInfo =@{ TrialComplitedNotificationResult: self.lastTrialInfo };
        [[NSNotificationCenter defaultCenter] postNotificationName:TrialComplitedNotification
                                                            object:self
                                                          userInfo:userInfo];
        
        [self setNeedsDisplay];  //FeedBack So Whenever is Clicked just dismiss the drawing
        
    }
    else self.timesWentOutside = @([self.timesWentOutside integerValue]-1);  // otherwise refine the counter
}

#pragma mark - No FeedBack Timer Selector

- (void)noFeedBackSelector{
    

    self.NFWaitingForUserTapScreenToConfirmFeedBackWasSeen = YES;
    
    NSTimeInterval totalTimeOfTrial = [self.startTimeOfTrial timeIntervalSinceNow];
    
    // Remove last three indexes from NFPastIndexes
    [self.NFPastIndexes removeLastObject];
    [self.NFPastIndexes removeLastObject];
    
    // Get Last Valid Position
    
    NSNumber *lastIndexBeforeTouchEnded = [self.NFPastIndexes lastObject];
    if (!lastIndexBeforeTouchEnded) {
        lastIndexBeforeTouchEnded = self.min;           // if nill move it to min value
    }
    NSLog(@"Last index is  %@", lastIndexBeforeTouchEnded);
    

    self.lastTrialInfo= [[TrialInfo alloc] init];
    //ID is filled in superView
    self.lastTrialInfo.n = self.N;
    self.lastTrialInfo.target = self.target;
    self.lastTrialInfo.hasFeedback = self.hasFeedback;
    self.lastTrialInfo.isDescrete = self.isDescrete;
    self.lastTrialInfo.rawInputValue = lastIndexBeforeTouchEnded;
    
    self.lastTrialInfo.reTouches = @(self.reTouches);
    self.lastTrialInfo.reEntries = @(self.targetReentries);
    self.lastTrialInfo.totalTime = @(-1 * totalTimeOfTrial);
    
    //check if Last position is inside Target
    self.lastTrialInfo.hitInsideTarget = @([self isInsideTarget:lastIndexBeforeTouchEnded]);
    if (self.isDescrete) { //NFD
        NSNumber *middleOfTargetRegion = @([self.startOfTargetRegion floatValue] + [self.rangeOfTarget floatValue]/2);
        self.lastTrialInfo.finalOffset = @(([lastIndexBeforeTouchEnded floatValue] - [middleOfTargetRegion floatValue]) / ([_max floatValue]-[_min floatValue]));  // percentage of Offset compared to whole range
        // <0 if before target middle and the opposite
    }
    else if(!self.isDescrete){      // NFND
        self.lastTrialInfo.finalOffset = @(([lastIndexBeforeTouchEnded floatValue] - [self.continuousTarget floatValue]) / ([_max floatValue]-[_min floatValue]));  // percentage of Offset compared to whole range
        // <0 if before target and the opposite
        self.lastTrialInfo.continuousTargetPosition = self.continuousTarget;
    }
    
    
    //Set The Animation for the User FeedBack
    self.NFShowFinalSelectedRangeAfterComplitingNFTrial = TRUE;    // value set back to No in dispatch
    self.NFFinalIndexToShow  = @((([lastIndexBeforeTouchEnded floatValue] - [_min floatValue])/ ([_max floatValue]-[_min floatValue])) * 360);

    [self setNeedsDisplay];  //Show the last index
    //Play Sound
    AudioServicesPlaySystemSound(self.successSound);
    
    
/* Uncomment this if you want To Wait for a specific amount of time
 *instead pf waiting for an extra tap
 */
//    // wait For a second to Show the animation
//    // and the send the notification to SuperView
//    int64_t delayInSeconds = 1;
//    
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        
//        NSDictionary *userInfo =@{ TrialComplitedNotificationResult: trialInfo };
//        [[NSNotificationCenter defaultCenter] postNotificationName:TrialComplitedNotification
//                                                            object:self
//                                                          userInfo:userInfo];
//        self.NFShowFinalSelectedRangeAfterComplitingNFTrial = NO;
//        
//    });
    
}


#pragma mark - Helper Functions
-(BOOL)isInsideTarget:(NSNumber *)indexval
{
        if ([indexval floatValue] > [self.max floatValue]) {
            indexval = self.max;
        }
        if([indexval floatValue] >= [self.startOfTargetRegion floatValue] && ([indexval floatValue] <= [self.endOfTargetRegion floatValue])){
            return YES;
        }
        return NO;

}

#pragma mark - Trial Initializer

- (void)prepareForTrialWithN:(NSNumber *)N Target:(NSNumber *)target inDescreteMode:(BOOL)isDescrete withFeedback:(BOOL)hasFeedback
{
    self.isInsideTarget = NO;  // reset it now to prevent color malfunctioning
    self.NFWaitingForUserTapScreenToConfirmFeedBackWasSeen = NO;
    
    if (isDescrete) {       
        self.N = N;
        self.target = target;
        self.isDescrete = YES;
        self.hasFeedback = hasFeedback;
        
        self.rangeOfTarget = @(([self.max floatValue] - [self.min floatValue]) / [_N integerValue]);
        self.startOfTargetRegion = @([self.min floatValue] + (([self.target integerValue] - 1) * [self.rangeOfTarget floatValue]));
        self.endOfTargetRegion = @([self.min floatValue] + (([self.target integerValue]) * [self.rangeOfTarget floatValue]));
        
        self.shouldResetParametersInFirstTouch = YES;
        
        [self setNeedsDisplay];
    }
    else if (!isDescrete) {
        self.N = N;
        self.target = target;
        self.isDescrete = NO;
        self.hasFeedback = hasFeedback;
        
        // Get Discrete Target
        self.rangeOfTarget = @(([self.max floatValue] - [self.min floatValue]) / [_N integerValue]);
        self.startOfTargetRegion = @([self.min floatValue] + (([self.target integerValue] - 1) * [self.rangeOfTarget floatValue]));
        // Get random point in it
        int randomTargetPosition  = arc4random()%TIMES_TO_DIVIDE_EACH_CONCRETE_TARGET;
        self.continuousTarget = @([self.startOfTargetRegion floatValue] + (randomTargetPosition * ([self.rangeOfTarget floatValue] / TIMES_TO_DIVIDE_EACH_CONCRETE_TARGET)));
        
        //Re - Define  start and end of Target Region
        
        self.startOfTargetRegion = @([self.continuousTarget floatValue] - (OFFSET_FOR_CONTINUOUS_TARGET * ([self.max floatValue] - [self.min floatValue])));
        self.endOfTargetRegion = @([self.continuousTarget floatValue] + (OFFSET_FOR_CONTINUOUS_TARGET * ([self.max floatValue] - [self.min floatValue])));
        

        // Calibrate Values
        if ([self.startOfTargetRegion floatValue] < [self.min floatValue]) {
            self.startOfTargetRegion = self.min;
        }
        if ([self.endOfTargetRegion floatValue] > [self.max floatValue]) {
            self.endOfTargetRegion = self.max;
        }

        self.shouldResetParametersInFirstTouch = YES;
        
        [self setNeedsDisplay];
    }
    
}

#pragma mark - Setters-Getters

// if it exceed min and mac value then reformat it
-(void)setLastIndexPositionInRad:(NSNumber *)currentSize{
    if ([currentSize floatValue] > 360) {
        _lastIndexPositionInRad = @360;
    }
    else if ([currentSize floatValue]<0){
        _lastIndexPositionInRad= @0;
    }
    else{
        _lastIndexPositionInRad = currentSize;
    }
    [self setNeedsDisplay];
}

-(NSNumber *)continuousTargetInRad
{
    if (_continuousTarget) {        //if continuous Target exists
        NSNumber *pr = @( ([_continuousTarget floatValue] - [_min floatValue])/ ([_max floatValue]-[_min floatValue]));
        return @([pr floatValue]*360);
    }
    else return nil;
}

-(NSNumber *)startOfTargetRegionInRad
{
    if (_startOfTargetRegion) {        //if continuous Target exists
        NSNumber *pr = @( ([_startOfTargetRegion floatValue] - [_min floatValue])/ ([_max floatValue]-[_min floatValue]));
        return @([pr floatValue]*360);
    }
    else return nil;
}

-(NSNumber *)endOfTargetRegionInRad
{
    if (_endOfTargetRegion) {        //if continuous Target exists
        NSNumber *pr = @( ([_endOfTargetRegion floatValue] - [_min floatValue])/ ([_max floatValue]-[_min floatValue]));
        return @([pr floatValue]*360);
    }
    else return nil;
}

- (NSMutableArray *)NFPastIndexes
{
    if(!_NFPastIndexes) _NFPastIndexes = [[NSMutableArray alloc] init];
    return _NFPastIndexes;
}


#pragma mark - Drawing
- (void)drawRect:(CGRect)rect
{
    if(!self.shouldAnimateEndOfExperiment ){
        // Show Button Frame
        if(self.shouldShowStartNextTrialButton){
            [self drawButtonFrame];
        }
        //Show Experiment Structure
        else{

            if (self.hasFeedback) {
                //// Draw the User Input Circle (white)
                [self drawUserFeedbackRegion];
                //// Draw the User Input FeedBack
                [self drawUserCurrentIndexFeedBack];
            }
            else if (!self.hasFeedback) {
                // Place Code Here
                if(self.NFShowFinalSelectedRangeAfterComplitingNFTrial){
                    //// Draw the User Input Circle (white)
                    [self drawUserFeedbackRegion];
                    [self drawUserIndexFinalFeedBack];
                }
                
            }
            
            if (self.isDescrete) {
                //// Draw Segments
                [self drawSegmentedTargets];
            }
            else if (!self.isDescrete) {
                //Draw Continuous Target
                [self drawContinuousTarget];
            }
            
            //// Draw Circle in the Center
            [self drawTouchRegionCircle];
            [self drawTouchRegionRectangle];
        }
        
    }
}

#pragma mark - Drawing Helper Functions

- (void)drawButtonFrame
{
    UIBezierPath* ovalTouchRegionCenter = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(168.5, 265.5, 440, 440)];
    [[UIColor whiteColor] setFill];
    [ovalTouchRegionCenter fill];
    [[UIColor blueColor] setStroke];
    ovalTouchRegionCenter.lineWidth = 2;
    [ovalTouchRegionCenter stroke];
}


- (void)drawUserFeedbackRegion{ //white
    CGRect ovalRectForFeedbackRegion = CGRectMake(22.5, 15.5, 721, 721);
    UIBezierPath* ovalPathForFeedBackRegion = [UIBezierPath bezierPath];
    [ovalPathForFeedBackRegion addArcWithCenter: CGPointMake(CGRectGetMidX(ovalRectForFeedbackRegion), CGRectGetMidY(ovalRectForFeedbackRegion)) radius: CGRectGetWidth(ovalRectForFeedbackRegion) / 2 startAngle: 0 * M_PI/180 endAngle: 360 * M_PI/180 clockwise: YES];
    [ovalPathForFeedBackRegion addLineToPoint: CGPointMake(CGRectGetMidX(ovalRectForFeedbackRegion), CGRectGetMidY(ovalRectForFeedbackRegion))];
    [ovalPathForFeedBackRegion closePath];
    
    [[UIColor whiteColor] setFill];
    [ovalPathForFeedBackRegion fill];
    [[UIColor blackColor] setStroke];
    ovalPathForFeedBackRegion.lineWidth = 2;
    [ovalPathForFeedBackRegion stroke];
}


- (void)drawUserCurrentIndexFeedBack
{
    UIColor* colorOFUserFeedback = [UIColor colorWithRed: 0.114 green: 0.114 blue: 1 alpha: 1];
    
    CGRect ovalRectCurrentIndex = CGRectMake(22.5, 15.5, 721, 721);
    UIBezierPath* ovalPathCurrentIndex = [UIBezierPath bezierPath];
    [ovalPathCurrentIndex addArcWithCenter: CGPointMake(CGRectGetMidX(ovalRectCurrentIndex), CGRectGetMidY(ovalRectCurrentIndex)) radius: CGRectGetWidth(ovalRectCurrentIndex) / 2 startAngle: 0 * M_PI/180 endAngle: [self.lastIndexPositionInRad intValue] * M_PI/180 clockwise: YES];
    [ovalPathCurrentIndex addLineToPoint: CGPointMake(CGRectGetMidX(ovalRectCurrentIndex), CGRectGetMidY(ovalRectCurrentIndex))];
    [ovalPathCurrentIndex closePath];
    
    [colorOFUserFeedback setFill];
    [ovalPathCurrentIndex fill];
    [colorOFUserFeedback setStroke];
    if ([self.lastIndexPositionInRad integerValue] == 0) {
        ovalPathCurrentIndex.lineWidth = 6;
    }
    else{
        ovalPathCurrentIndex.lineWidth = 2;
    }
    [ovalPathCurrentIndex stroke];
}

//Only in NF Trials-- Called at the very End
- (void)drawUserIndexFinalFeedBack
{
    UIColor* colorOFUserFeedback = [UIColor colorWithRed: 0.114 green: 0.114 blue: 1 alpha: 1];
    
    CGRect ovalRectCurrentIndex = CGRectMake(22.5, 15.5, 721, 721);
    UIBezierPath* ovalPathCurrentIndex = [UIBezierPath bezierPath];
    [ovalPathCurrentIndex addArcWithCenter: CGPointMake(CGRectGetMidX(ovalRectCurrentIndex), CGRectGetMidY(ovalRectCurrentIndex))
                                    radius: CGRectGetWidth(ovalRectCurrentIndex) / 2
                                startAngle: 0 * M_PI/180
                                  endAngle: [self.NFFinalIndexToShow intValue] * M_PI/180
                                 clockwise: YES];
    [ovalPathCurrentIndex addLineToPoint: CGPointMake(CGRectGetMidX(ovalRectCurrentIndex), CGRectGetMidY(ovalRectCurrentIndex))];
    [ovalPathCurrentIndex closePath];
    
    [colorOFUserFeedback setFill];
    [ovalPathCurrentIndex fill];
    [colorOFUserFeedback setStroke];
    if ([self.lastIndexPositionInRad integerValue] == 0) {
        ovalPathCurrentIndex.lineWidth = 6;
    }
    else{
        ovalPathCurrentIndex.lineWidth = 2;
    }
    [ovalPathCurrentIndex stroke];
}

- (void)drawSegmentedTargets
{
    UIColor* colorFornInactiveTargets = [UIColor colorWithRed: 0.942 green: 0.942 blue: 0.942 alpha: 1];
    
    for(int i=[self.N intValue]; i>0; i--) {
        CGRect ovalRectForTargets = CGRectMake(90.5, 83.5, 585, 585);
        UIBezierPath* ovalPathForTargets = [UIBezierPath bezierPath];
        [ovalPathForTargets addArcWithCenter: CGPointMake(CGRectGetMidX(ovalRectForTargets), CGRectGetMidY(ovalRectForTargets))
                                      radius: CGRectGetWidth(ovalRectForTargets) / 2
                                  startAngle: ((i-1)*360/[self.N integerValue]) * M_PI/180
                                    endAngle: (i*360/[self.N integerValue]) * M_PI/180
                                   clockwise: YES];
        [ovalPathForTargets addLineToPoint: CGPointMake(CGRectGetMidX(ovalRectForTargets), CGRectGetMidY(ovalRectForTargets))];
        [ovalPathForTargets closePath];
        
        if (i>[self.target integerValue]) {
            [colorFornInactiveTargets setFill];
        }
        else if(i == [self.target integerValue]) {
            //self.isInsideTarget ? [[UIColor greenColor] setFill] : [[UIColor redColor] setFill];
            [[UIColor redColor] setFill];
        }
        else {
            [colorFornInactiveTargets setFill];
        }
        [ovalPathForTargets fill];
        [[UIColor blackColor] setStroke];
        ovalPathForTargets.lineWidth = 2;
        [ovalPathForTargets stroke];
    }
}


-(void) drawContinuousTarget
{
    //Draw Targets Region
    CGRect TargetRegion = CGRectMake(90.5, 83.5, 585, 585);
    UIBezierPath* ovalPathForTargetRegion = [UIBezierPath bezierPath];
    [ovalPathForTargetRegion addArcWithCenter: CGPointMake(CGRectGetMidX(TargetRegion), CGRectGetMidY(TargetRegion))
                                  radius: CGRectGetWidth(TargetRegion) / 2
                              startAngle: 0
                                endAngle: 2 * M_PI
                               clockwise: YES];
    [ovalPathForTargetRegion addLineToPoint: CGPointMake(CGRectGetMidX(TargetRegion), CGRectGetMidY(TargetRegion))];
    [ovalPathForTargetRegion closePath];
    
    [[UIColor whiteColor] setFill];
    [ovalPathForTargetRegion fill];
    [[UIColor blackColor] setStroke];
    ovalPathForTargetRegion.lineWidth = 2;
    [ovalPathForTargetRegion stroke];
    
    //Draw Continuous Target
    
    CGRect ovalRectForTargets = CGRectMake(90.5, 83.5, 585, 585);
    UIBezierPath* ovalPathForTargets = [UIBezierPath bezierPath];
    [ovalPathForTargets addArcWithCenter: CGPointMake(CGRectGetMidX(ovalRectForTargets), CGRectGetMidY(ovalRectForTargets))
                                  radius: CGRectGetWidth(ovalRectForTargets) / 2
                              startAngle: [self.continuousTargetInRad floatValue] * M_PI/180
                                endAngle: [self.continuousTargetInRad floatValue]* M_PI/180
                               clockwise: YES];
    [ovalPathForTargets addLineToPoint: CGPointMake(CGRectGetMidX(ovalRectForTargets), CGRectGetMidY(ovalRectForTargets))];
    [ovalPathForTargets closePath];
    
    //self.isInsideTarget ? [[UIColor greenColor] setFill] : [[UIColor redColor] setFill];
    [[UIColor redColor] setFill];
    [ovalPathForTargets fill];
    
    //self.isInsideTarget ? [[UIColor greenColor] setFill] : [[UIColor redColor] setStroke];
    [[UIColor redColor] setStroke];
    ovalPathForTargets.lineWidth = 3;
    [ovalPathForTargets stroke];
    
    [self drawContinuousTargetOffsetIndicators];
    
    
}

-(void) drawContinuousTargetOffsetIndicators
{
    
    // DRAW START
    CGRect ovalRectForTargets = CGRectMake(90.5, 83.5, 585, 585);
    UIBezierPath* ovalPathForStartOffset = [UIBezierPath bezierPath];
    [ovalPathForStartOffset addArcWithCenter: CGPointMake(CGRectGetMidX(ovalRectForTargets), CGRectGetMidY(ovalRectForTargets))
                                  radius: CGRectGetWidth(ovalRectForTargets) / 2
                              startAngle: [self.startOfTargetRegionInRad floatValue] * M_PI/180
                                endAngle: [self.startOfTargetRegionInRad floatValue]* M_PI/180
                               clockwise: YES];
    [ovalPathForStartOffset addLineToPoint: CGPointMake(CGRectGetMidX(ovalRectForTargets), CGRectGetMidY(ovalRectForTargets))];
    [ovalPathForStartOffset closePath];

    [[UIColor yellowColor] setStroke];
    ovalPathForStartOffset.lineWidth = 2;
    [ovalPathForStartOffset stroke];
    
    
    //DRAW END
    
    UIBezierPath* ovalPathForEndOffset = [UIBezierPath bezierPath];
    [ovalPathForEndOffset addArcWithCenter: CGPointMake(CGRectGetMidX(ovalRectForTargets), CGRectGetMidY(ovalRectForTargets))
                                  radius: CGRectGetWidth(ovalRectForTargets) / 2
                              startAngle: [self.endOfTargetRegionInRad floatValue] * M_PI/180
                                endAngle: [self.endOfTargetRegionInRad floatValue]* M_PI/180
                               clockwise: YES];
    [ovalPathForEndOffset addLineToPoint: CGPointMake(CGRectGetMidX(ovalRectForTargets), CGRectGetMidY(ovalRectForTargets))];
    [ovalPathForEndOffset closePath];
    ovalPathForEndOffset.lineWidth = 2;
    [ovalPathForEndOffset stroke];
    
    

}


-(void) drawTouchRegionCircle
{
    
    UIBezierPath* ovalTouchRegionCenter = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(163.5, 155.5, 440, 440)];
    if (self.NFShowFinalSelectedRangeAfterComplitingNFTrial) {
        [[UIColor whiteColor] setFill];
    }
    else{
        [self.backgroundColor setFill];
    }
    [ovalTouchRegionCenter fill];
    [[UIColor blackColor] setStroke];
    ovalTouchRegionCenter.lineWidth = 2;
    [ovalTouchRegionCenter stroke];
}

-(void) drawTouchRegionRectangle
{
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(21.5, 756.5, 721, 167) cornerRadius:8];
    
    [[UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.3] setFill];
    [rectanglePath fill];
    [[UIColor whiteColor] setStroke];
    rectanglePath.lineWidth = 3;
    [rectanglePath stroke];
}




@end






