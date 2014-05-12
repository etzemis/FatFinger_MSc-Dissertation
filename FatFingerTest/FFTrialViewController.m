//
//  FFExperimentViewController.m
//  FatFingerTest
//
//  Created by Evangelos Tzemis on 2/20/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import "FFTrialViewController.h"
#import "FFTrialView.h"
#import "TrialComplitedNotification.h"
#import "TrialInfo.h"
#import <AudioToolbox/AudioToolbox.h>
#import "BlockInfo.h"
//types of Trials
#import "FDTrial.h"
#import "FNDTrial.h"
#import "NFDTrial.h"
#import "NFNDTrial.h"
#import "RepetitionStats.h"

@interface FFTrialViewController ()
@property (weak, nonatomic) IBOutlet FFTrialView *tview;
@property (nonatomic) SystemSoundID successSound;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *finishButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;
@property (nonatomic, strong) NSNumber *LastTrialID;
@property (nonatomic, strong) IBOutlet UIButton *startNextTrialButton;
//Retrieve Trials in  Repetitions
@property (nonatomic, strong) TrialSequence *trialSequence;
@property (nonatomic, strong) Repetition *currentRepetition;
@property (nonatomic, strong) TrialInfo *nextTrial;
// Store Repetition Info and Make Stats
//Initialized every time current Repetition changes
@property (nonatomic, strong) NSMutableArray* BlockInfos;  // of BlockInfo


@property (nonatomic) BOOL trainingFinished;
@end



@implementation FFTrialViewController


#pragma mark - initializers
- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(trialFinished:)
                                                 name:TrialComplitedNotification
                                               object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //set sound
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"successSound2" ofType:@"wav"];
	NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
	AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &_successSound);
    
    self.trainingFinished = NO ; // Its gonna Start Now
    self.finishButton.enabled = NO;
	// Initialize tview
    self.tview.min = self.user.minArea;
    self.tview.max = self.user.maxArea;
    self.tview.shouldAnimateEndOfExperiment = NO;
    self.tview.successSound = self.successSound;
    [self trialFinished:nil];
}

#pragma mark - TrialFinishedNotification Selector

- (void)trialFinished:(NSNotification *)notification
{
    //Disable User Interaction in the Backround View
    self.tview.userInteractionEnabled = NO;
    
    //Deal with the Trial
    if(notification) {      // if we actually received the Notification
        NSLog(@"ReceivedNotification");
        AudioServicesPlaySystemSound(self.successSound);
        TrialInfo *trialInfo = notification.userInfo[TrialComplitedNotificationResult];  //from Last Trial
        [self storeTrialToDB:trialInfo];
        [self addTrialInfoToBlockInfo:trialInfo];
    }
    // Show the Button and wait for user to press it
    self.tview.shouldShowStartNextTrialButton = YES;  // Draw Nothing
    [self.tview setNeedsDisplay];
    // add Button to the view
    [self.view addSubview:self.startNextTrialButton];
    
    self.nextTrial = [self getNextTrial];

}



#pragma mark - Button Target Action

- (IBAction)startNewTrial:(id)sender
{
    if (self.nextTrial){        //it has next trial
        //Enable User Interaction in the Backround View
        self.tview.userInteractionEnabled = YES;
        
        //remove Button Frame
        self.tview.shouldShowStartNextTrialButton = NO;        
        [self.tview prepareForTrialWithN:self.nextTrial.n
                                  Target:self.nextTrial.target
                          inDescreteMode:self.nextTrial.isDescrete
                            withFeedback:self.nextTrial.hasFeedback];
        
        self.LastTrialID = self.nextTrial.trialID;
    }
    else{  //we finished the experiment
//        for (BlockInfo* bi in self.BlockInfos) {
//            NSLog(@"Repetition %@  has average time = %f  and average target Reentries %f", bi.id, [[bi getAverageCompletionTime] floatValue], [[bi getAverageReEntries] floatValue]);
//        }
        self.finishButton.enabled = TRUE;
        self.tview.shouldAnimateEndOfExperiment = YES;
        [self.tview setNeedsDisplay];
        self.navigationBar.title = @"Thank you for your participation!";
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:TrialComplitedNotification
                                                      object:nil];
        [self storeRepetitionStatsToDB];
    }
    //Remove button from View
    [self.startNextTrialButton removeFromSuperview];

    //Set Title of Navigation Bar
    if (!self.finishButton.enabled) {
        self.navigationBar.title = [NSString stringWithFormat:@"Experiment Trial No: %@", self.LastTrialID];
    }
}

# pragma mark - Trial Repetition Manipulation
//Return nill only if Nothing else nowhere
-(TrialInfo *)getNextTrial
{
    if(!self.currentRepetition){  // Initialize everything
        self.currentRepetition = [self.trialSequence getNextRepetition];
    }
    TrialInfo *nextTrial = [self.currentRepetition getNextTrial];
    if(!nextTrial) {   // if nil then check next Repetition
        self.currentRepetition = [self.trialSequence getNextRepetition];
        if(!self.trainingFinished)  // We were Still in trainng
        {
            self.trainingFinished = YES;
            //Show Alert
            [[[UIAlertView alloc] initWithTitle:@"Learning Phase Just Finished"
                                        message:@"Press Ok, to proceed to the Experiment"
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil] show];
        }
        if(!self.currentRepetition)     // No more Repetitions
        {
            return nil;
        }
        nextTrial = [self.currentRepetition getNextTrial];
    }
    return nextTrial;

}

#pragma mark - Block Info Insert

-(void)addTrialInfoToBlockInfo:(TrialInfo *)trialInfo
{
    if(self.BlockInfos)  //double check null
    {
        [[self.BlockInfos lastObject] addCompletionTimeOFTrial:trialInfo.totalTime];
        [[self.BlockInfos lastObject] addTargetReEntriesOFTrial:trialInfo.reEntries];
    }
}

# pragma mark - Core Data Access


- (void)storeTrialToDB:(TrialInfo *)trialInfo
{
    
// FeedBack
    if (trialInfo.hasFeedback && trialInfo.isDescrete) {
        FDTrial *fdtrial = [NSEntityDescription insertNewObjectForEntityForName:@"FDTrial"
                                      inManagedObjectContext:self.user.managedObjectContext];
        fdtrial.whichUser = self.user;
        NSLog(@"Adding FD Trial for user %@", self.user.userID );
        fdtrial.reEntries = trialInfo.reEntries;
        fdtrial.totalTime = trialInfo.totalTime;
        fdtrial.reTouches = trialInfo.reTouches;
        fdtrial.trialID = self.LastTrialID;
        fdtrial.n = trialInfo.n;
        fdtrial.target = trialInfo.target;
        fdtrial.repetitionID = @([self.BlockInfos count]);
        fdtrial.rawInputValue = trialInfo.rawInputValue;
    }
    else if (trialInfo.hasFeedback && !trialInfo.isDescrete) {
        FNDTrial *fndtrial = [NSEntityDescription insertNewObjectForEntityForName:@"FNDTrial"
                                                         inManagedObjectContext:self.user.managedObjectContext];
        fndtrial.whichUser = self.user;
        NSLog(@"Adding FND Trial for user %@", self.user.userID );
        fndtrial.reEntries = trialInfo.reEntries;
        fndtrial.totalTime = trialInfo.totalTime;
        fndtrial.reTouches = trialInfo.reTouches;
        fndtrial.offset = trialInfo.finalOffset;
        fndtrial.targetPosition = trialInfo.continuousTargetPosition;
        fndtrial.trialID = self.LastTrialID;
        fndtrial.n = trialInfo.n;
        fndtrial.target = trialInfo.target;
        fndtrial.repetitionID = @([self.BlockInfos count]);
        fndtrial.rawInputValue = trialInfo.rawInputValue;
    }
// No feedBack
    else if (!trialInfo.hasFeedback && trialInfo.isDescrete ) {
        NFDTrial *nfdtrial = [NSEntityDescription insertNewObjectForEntityForName:@"NFDTrial"
                                                             inManagedObjectContext:self.user.managedObjectContext];
        nfdtrial.whichUser = self.user;
        NSLog(@"Adding NFD Trial for user %@", self.user.userID );
        nfdtrial.reEntries = trialInfo.reEntries;
        nfdtrial.totalTime = trialInfo.totalTime;
        nfdtrial.reTouches = trialInfo.reTouches;
        nfdtrial.offset = trialInfo.finalOffset;
        nfdtrial.hitInsideTarget = trialInfo.hitInsideTarget;
        nfdtrial.trialID = self.LastTrialID;
        nfdtrial.n = trialInfo.n;
        nfdtrial.target = trialInfo.target;
        nfdtrial.repetitionID = @([self.BlockInfos count]);
        nfdtrial.rawInputValue = trialInfo.rawInputValue;
    }
    else if (!trialInfo.hasFeedback&& !trialInfo.isDescrete ) {
        NFNDTrial *nfndtrial = [NSEntityDescription insertNewObjectForEntityForName:@"NFNDTrial"
                                                           inManagedObjectContext:self.user.managedObjectContext];
        nfndtrial.whichUser = self.user;
        NSLog(@"Adding NFND Trial for user %@", self.user.userID );
        nfndtrial.reEntries = trialInfo.reEntries;
        nfndtrial.totalTime = trialInfo.totalTime;
        nfndtrial.reTouches = trialInfo.reTouches;
        nfndtrial.offset = trialInfo.finalOffset;
        nfndtrial.targetPosition = trialInfo.continuousTargetPosition;
        nfndtrial.hitInsideTarget = trialInfo.hitInsideTarget;
        nfndtrial.trialID = self.LastTrialID;
        nfndtrial.n = trialInfo.n;
        nfndtrial.target = trialInfo.target;
        nfndtrial.repetitionID = @([self.BlockInfos count]);
        nfndtrial.rawInputValue = trialInfo.rawInputValue;
    }

}

- (void)storeRepetitionStatsToDB
{
    for (BlockInfo* bi in self.BlockInfos) {

        RepetitionStats* repetitionStats = [NSEntityDescription insertNewObjectForEntityForName:@"RepetitionStats"
                                                         inManagedObjectContext:self.user.managedObjectContext];
    
    
        repetitionStats.whichUser = self.user;
        NSLog(@"Adding Repetition Statistics for Repetition# %@", bi.id );
        repetitionStats.repetitionID = bi.id;
        repetitionStats.totalTime = [bi getTotalTime];
        repetitionStats.averageReEntries = [bi getAverageReEntries];
        repetitionStats.averageReTouches = [bi getAverageReTouches];
        repetitionStats.averageTrialTime = [bi getAverageCompletionTime];
        
    }
    
}

#pragma mark - setters - getters
- (UIButton *)startNextTrialButton
{
    if (!_startNextTrialButton) {
        self.startNextTrialButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.startNextTrialButton.frame = CGRectMake(325.5, 525, 126, 60); // position in the parent view and set the size of the button
        [self.startNextTrialButton setTitle:@"Next Trial" forState:UIControlStateNormal];
        // add targets and actions
        [self.startNextTrialButton addTarget:self action:@selector(startNewTrial:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startNextTrialButton;
}

- (TrialSequence *)trialSequence{
    if(!_trialSequence) _trialSequence = [[TrialSequence alloc] init];
    return _trialSequence;
}

-(NSMutableArray *)BlockInfos
{
    if(!_BlockInfos) _BlockInfos = [[NSMutableArray alloc] init];
    return _BlockInfos;
}
//Whenever we move to a new Repetition the Create A Block Info Object to count Data of this whole Repetition
-(void) setCurrentRepetition:(Repetition *)currentRepetition
{
    _currentRepetition = currentRepetition;
    if(_currentRepetition){
        BlockInfo *bi =[[BlockInfo alloc] init];
        bi.id = @([self.BlockInfos count] + 1);   //1, 2, 3, 4
        [self.BlockInfos addObject:bi];
    }
}


@end



