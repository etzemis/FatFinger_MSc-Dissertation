//
//  FFWarmUpTrialViewController.m
//  FatFinger
//
//  Created by Evangelos Tzemis on 5/4/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import "FFWarmUpTrialViewController.h"
#import "FFTrialView.h"
#import "TrialComplitedNotification.h"
#import "TrialSequence.h"
#import "TrialInfo.h"
#import <AudioToolbox/AudioToolbox.h>
#import "FFTrialViewController.h"

//types of Trials
#import "FDTrial.h"
#import "FNDTrial.h"
#import "NFDTrial.h"
#import "NFNDTrial.h"

@interface FFWarmUpTrialViewController ()
@property (weak, nonatomic) IBOutlet FFTrialView *tview;
@property (nonatomic, strong) TrialSequence *trialSequence;
@property (nonatomic) SystemSoundID successSound;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *StartExperimentButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;
@property (nonatomic, strong) NSNumber *LastTrialID;
@property (nonatomic, strong) IBOutlet UIButton *startNextWarmUpTrialButton;
@end



@implementation FFWarmUpTrialViewController

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"start Experiment trials"]) {
        if ([segue.destinationViewController isKindOfClass:[FFTrialViewController class]]) {
            FFTrialViewController * tvc= (FFTrialViewController*) segue.destinationViewController;
            tvc.user = self.user;
            tvc.trialSequence = self.trialSequence;
            
        }
    }
}

#pragma mark - Initilizers
- (void)awakeFromNib
{
    //Tune in to notification
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
    
    self.StartExperimentButton.enabled = NO;
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
    }
    // Show the Button and wait for user to press it
    self.tview.shouldShowStartNextTrialButton = YES;  // Draw Nothing
    [self.tview setNeedsDisplay];
    // add Button to the view
    [self.view addSubview:self.startNextWarmUpTrialButton];
    
}


#pragma mark - Button Target Action

- (IBAction)startNewWarmUpTrial:(id)sender
{
    
    TrialInfo *newTrial = [self.trialSequence getNextWarmUpTrial];
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
        self.StartExperimentButton.enabled = TRUE;
        self.tview.shouldAnimateEndOfExperiment = YES;
        [self.tview setNeedsDisplay];
        self.navigationBar.title = @"Warm Up Finished";
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:TrialComplitedNotification
                                                      object:nil];
        //Watch this out!!
        self.tview = nil;
    }
    //Remove button from View
    [self.startNextWarmUpTrialButton removeFromSuperview];
    
    //Set Title of Navigation Bar
    if (!self.StartExperimentButton.enabled) {
        self.navigationBar.title = [NSString stringWithFormat:@"Warm-up Trial No: %@", self.LastTrialID];
    }
}


#pragma mark - setters - getters
- (TrialSequence *)trialSequence{
    if(!_trialSequence) _trialSequence = [[TrialSequence alloc] init];
    return _trialSequence;
}

- (UIButton *)startNextWarmUpTrialButton
{
    if (!_startNextWarmUpTrialButton) {
        self.startNextWarmUpTrialButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.startNextWarmUpTrialButton.frame = CGRectMake(325.5, 525, 126, 60); // position in the parent view and set the size of the button
        [self.startNextWarmUpTrialButton setTitle:@"NEXT WARM-UP TRIAL" forState:UIControlStateNormal];
        // add targets and actions
        [self.startNextWarmUpTrialButton addTarget:self action:@selector(startNewWarmUpTrial:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startNextWarmUpTrialButton;
}



@end
