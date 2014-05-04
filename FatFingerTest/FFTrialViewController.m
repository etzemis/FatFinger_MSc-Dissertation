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

//types of Trials
#import "FDTrial.h"
#import "FNDTrial.h"
#import "NFDTrial.h"
#import "NFNDTrial.h"

@interface FFTrialViewController ()
@property (weak, nonatomic) IBOutlet FFTrialView *tview;
@property (nonatomic) SystemSoundID successSound;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *finishButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;
@property (nonatomic, strong) NSNumber *LastTrialID;
@property (nonatomic, strong) IBOutlet UIButton *startNextTrialButton;
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
    }
    // Show the Button and wait for user to press it
    self.tview.shouldShowStartNextTrialButton = YES;  // Draw Nothing
    [self.tview setNeedsDisplay];
    // add Button to the view
    [self.view addSubview:self.startNextTrialButton];

}



#pragma mark - Button Target Action

- (IBAction)startNewTrial:(id)sender
{
    
    TrialInfo *newTrial = [self.trialSequence getNextTrial];
    if (newTrial){        //it has next trial
        //Enable User Interaction in the Backround View
        self.tview.userInteractionEnabled = YES;
        
        //remove Button Frame
        self.tview.shouldShowStartNextTrialButton = NO;        
        [self.tview prepareForTrialWithN:newTrial.n
                                  Target:newTrial.target
                          inDescreteMode:newTrial.isDescrete
                            withFeedback:newTrial.hasFeedback];
        
        self.LastTrialID = newTrial.trialID;
    }
    else{  //we finished the experiment
        self.finishButton.enabled = TRUE;
        self.tview.shouldAnimateEndOfExperiment = YES;
        [self.tview setNeedsDisplay];
        self.navigationBar.title = @"Thank you for your participation!";
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:TrialComplitedNotification
                                                      object:nil];
    }
    //Remove button from View
    [self.startNextTrialButton removeFromSuperview];

    //Set Title of Navigation Bar
    if (!self.finishButton.enabled) {
        self.navigationBar.title = [NSString stringWithFormat:@"Experiment Trial No: %@", self.LastTrialID];
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
        NSLog(@"Adding FD Trial for user %@", self.user.name );
        fdtrial.reEntries = trialInfo.reEntries;
        fdtrial.totalTime = trialInfo.totalTime;
        fdtrial.reTouches = trialInfo.reTouches;
        fdtrial.trialID = self.LastTrialID;
        fdtrial.n = trialInfo.n;
        fdtrial.target = trialInfo.target;
    }
    else if (trialInfo.hasFeedback && !trialInfo.isDescrete) {
        FNDTrial *fndtrial = [NSEntityDescription insertNewObjectForEntityForName:@"FNDTrial"
                                                         inManagedObjectContext:self.user.managedObjectContext];
        fndtrial.whichUser = self.user;
        NSLog(@"Adding FND Trial for user %@", self.user.name );
        fndtrial.reEntries = trialInfo.reEntries;
        fndtrial.totalTime = trialInfo.totalTime;
        fndtrial.reTouches = trialInfo.reTouches;
        fndtrial.offset = trialInfo.finalOffset;
        fndtrial.targetPosition = trialInfo.continuousTargetPosition;
        fndtrial.trialID = self.LastTrialID;
        fndtrial.n = trialInfo.n;
        fndtrial.target = trialInfo.target;
    }
// No feedBack
    else if (!trialInfo.hasFeedback && trialInfo.isDescrete ) {
        NFDTrial *nfdtrial = [NSEntityDescription insertNewObjectForEntityForName:@"NFDTrial"
                                                             inManagedObjectContext:self.user.managedObjectContext];
        nfdtrial.whichUser = self.user;
        NSLog(@"Adding NFD Trial for user %@", self.user.name );
        nfdtrial.reEntries = trialInfo.reEntries;
        nfdtrial.totalTime = trialInfo.totalTime;
        nfdtrial.reTouches = trialInfo.reTouches;
        nfdtrial.offset = trialInfo.finalOffset;
        nfdtrial.hitInsideTarget = trialInfo.hitInsideTarget;
        nfdtrial.trialID = self.LastTrialID;
        nfdtrial.n = trialInfo.n;
        nfdtrial.target = trialInfo.target;
    }
    else if (!trialInfo.hasFeedback&& !trialInfo.isDescrete ) {
        NFNDTrial *nfndtrial = [NSEntityDescription insertNewObjectForEntityForName:@"NFNDTrial"
                                                           inManagedObjectContext:self.user.managedObjectContext];
        nfndtrial.whichUser = self.user;
        NSLog(@"Adding NFND Trial for user %@", self.user.name );
        nfndtrial.reEntries = trialInfo.reEntries;
        nfndtrial.totalTime = trialInfo.totalTime;
        nfndtrial.reTouches = trialInfo.reTouches;
        nfndtrial.offset = trialInfo.finalOffset;
        nfndtrial.targetPosition = trialInfo.continuousTargetPosition;
        nfndtrial.hitInsideTarget = trialInfo.hitInsideTarget;
        nfndtrial.trialID = self.LastTrialID;
        nfndtrial.n = trialInfo.n;
        nfndtrial.target = trialInfo.target;
    }

}



#pragma mark - setters - getters
- (UIButton *)startNextTrialButton
{
    if (!_startNextTrialButton) {
        self.startNextTrialButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.startNextTrialButton.frame = CGRectMake(325.5, 525, 126, 60); // position in the parent view and set the size of the button
        [self.startNextTrialButton setTitle:@"Next" forState:UIControlStateNormal];
        // add targets and actions
        [self.startNextTrialButton addTarget:self action:@selector(startNewTrial:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startNextTrialButton;
}


@end



