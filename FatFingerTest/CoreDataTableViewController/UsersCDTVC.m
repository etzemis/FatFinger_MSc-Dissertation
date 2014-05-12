//
//  UsersCDTVC.m
//  FatFinger
//
//  Created by Evangelos Tzemis on 3/27/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import "UsersCDTVC.h"
#import "User.h"
#import "FDTrial.h"
#import "FNDTrial.h"
#import "NFDTrial.h"
#import "NFNDTrial.h"
#import "RepetitionStats.h"


@interface UsersCDTVC ()
- (IBAction)ExportDataToFile:(id)sender;

@end

@implementation UsersCDTVC

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.predicate = nil;        //all
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"userID"
                                                              ascending:YES
                                                               selector:@selector(compare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                    initWithFetchRequest:request
                                    managedObjectContext:self.managedObjectContext
                                    sectionNameKeyPath:nil
                                     cacheName:nil];
    self.debug = TRUE;

    
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"User Cell"];
    
    User *user =[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text =[NSString stringWithFormat:@"%@", user.userID];
    
    return cell;
    
}





#pragma mark - exprort user DB to csv file


- (IBAction)ExportDataToFile:(id)sender {
    
    //get the file
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
 
    
    //get the results you want to put inside
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.predicate = nil;        //all
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"userID"
                                                              ascending:YES
                                                               selector:@selector(compare:)]];
    NSError *error;
    NSArray * users = [self.managedObjectContext executeFetchRequest:request error:&error];
    

    for (User *user in users) {
        // Store User Trials in a seperate File
        [self exportTrialsforUser:user andFilename:[docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"TrialsForUser%@.csv", user.userID]]];
    }
    NSLog(@"info saved");
}







#pragma mark - Export user Trials

- (void)exportTrialsforUser:(User*) user andFilename:(NSString *) filename
{
    //create file
    if (![[NSFileManager defaultManager] fileExistsAtPath:filename]) {
        NSLog(@"file wasnt there");
        [[NSFileManager defaultManager] createFileAtPath:filename contents:nil attributes:nil];
    }
    else { //exists so recreate it
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:filename error:&error];
        if(error) {
            NSLog(@"Error at deleting file!");
        }
        [[NSFileManager defaultManager] createFileAtPath:filename contents:nil attributes:nil];
    }
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filename];
    [fileHandle seekToEndOfFile];
   

    
    //Save USer ID and MIN MAX Values
    NSString *userData = [NSString stringWithFormat:@"User Information\nUser ID, Min Area Value, Max Area Value\n"];
    [fileHandle writeData:[userData dataUsingEncoding:NSUTF8StringEncoding]];
    userData = [NSString stringWithFormat:@"%@, %@, %@\n", user.userID, user.minArea, user.maxArea];
    [fileHandle writeData:[userData dataUsingEncoding:NSUTF8StringEncoding]];
    

    
    // Repetition Summmary
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"RepetitionStats"];
    request.predicate = [NSPredicate predicateWithFormat:@"whichUser = %@", user];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"repetitionID"
                                                              ascending:YES
                                                               selector:@selector(compare:)]];
    NSArray *repetitionStatistics = [self.managedObjectContext executeFetchRequest:request error:nil];
    NSString *repetitionData = [NSString stringWithFormat:@"Repetition Statistics\nRepetition ID, Total Time, Average Trial Time, Average Trial Re-Entries, Average Trial Re-Touches\n"];
    [fileHandle writeData:[repetitionData dataUsingEncoding:NSUTF8StringEncoding]];
    for (RepetitionStats *r in repetitionStatistics) {
        NSString *repetData = [NSString stringWithFormat:@"%@, %@, %@, %@, %@\n", r.repetitionID, r.totalTime, r.averageTrialTime, r.averageReEntries, r.averageReTouches];
        [fileHandle writeData:[repetData dataUsingEncoding:NSUTF8StringEncoding]];
    }

    // FD Trials
    request = [NSFetchRequest fetchRequestWithEntityName:@"FDTrial"];
    request.predicate = [NSPredicate predicateWithFormat:@"whichUser = %@", user];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"trialID"
                                                              ascending:YES
                                                               selector:@selector(compare:)]];
    
    NSArray *fdtrials = [self.managedObjectContext executeFetchRequest:request error:nil];
    NSString *trialData = [NSString stringWithFormat:@"FeedBack - Discrete Trials\nTrialID, Repetition ID, Raw Data, N, Target, Total Time, re Entries, re Touches\n"];
    [fileHandle writeData:[trialData dataUsingEncoding:NSUTF8StringEncoding]];
    for (FDTrial *trial in fdtrials) {
        NSString *trialData = [NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@, %@, %@\n", trial.trialID, trial.repetitionID, trial.rawInputValue, trial.n, trial.target, trial.totalTime, trial.reEntries, trial.reTouches];
        [fileHandle writeData:[trialData dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // FND Trials
    request = [NSFetchRequest fetchRequestWithEntityName:@"FNDTrial"];
    request.predicate = [NSPredicate predicateWithFormat:@"whichUser = %@", user];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"trialID"
                                                              ascending:YES
                                                               selector:@selector(compare:)]];
    
    NSArray *fndtrials = [self.managedObjectContext executeFetchRequest:request error:nil];
    trialData = [NSString stringWithFormat:@"FeedBack - Non Discrete Trials\nTrialID, Repetition ID, Raw Data, N, Target, Total Time, re Entries, re Touches, Offset, Target Position\n"];
    [fileHandle writeData:[trialData dataUsingEncoding:NSUTF8StringEncoding]];
    for (FNDTrial *trial in fndtrials) {
        trialData = [NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@, %@, %@, %@, %@\n", trial.trialID, trial.repetitionID, trial.rawInputValue, trial.n, trial.target, trial.totalTime, trial.reEntries, trial.reTouches, trial.offset, trial.targetPosition];
        [fileHandle writeData:[trialData dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // NFD Trials
    request = [NSFetchRequest fetchRequestWithEntityName:@"NFDTrial"];
    request.predicate = [NSPredicate predicateWithFormat:@"whichUser = %@", user];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"trialID"
                                                              ascending:YES
                                                               selector:@selector(compare:)]];
    
    NSArray *nfdtrials = [self.managedObjectContext executeFetchRequest:request error:nil];
    trialData = [NSString stringWithFormat:@"No FeedBack - Discrete Trials\nTrialID, Repetition ID, Raw Data, N, Target, Total Time, re Entries, re Touches, Hit Inside Target, Offset\n"];
    [fileHandle writeData:[trialData dataUsingEncoding:NSUTF8StringEncoding]];
    for (NFDTrial *trial in nfdtrials) {
        trialData = [NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@, %@, %@, %@, %@\n", trial.trialID, trial.repetitionID, trial.rawInputValue, trial.n, trial.target, trial.totalTime, trial.reEntries, trial.reTouches, trial.hitInsideTarget, trial.offset];
        [fileHandle writeData:[trialData dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // NFND Trials
    request = [NSFetchRequest fetchRequestWithEntityName:@"NFNDTrial"];
    request.predicate = [NSPredicate predicateWithFormat:@"whichUser = %@", user];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"trialID"
                                                              ascending:YES
                                                               selector:@selector(compare:)]];
    
    NSArray *nfndtrials = [self.managedObjectContext executeFetchRequest:request error:nil];
    trialData = [NSString stringWithFormat:@"No FeedBack - Non Discrete Trials\nTrialID, Repetition ID, Raw Data, N, Target, Total Time, re Entries, re Touches, Hit Inside Target, Offset, Target Position\n"];
    [fileHandle writeData:[trialData dataUsingEncoding:NSUTF8StringEncoding]];
    for (NFNDTrial *trial in nfndtrials) {
        trialData = [NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@\n", trial.trialID, trial.repetitionID, trial.rawInputValue, trial.n, trial.target, trial.totalTime, trial.reEntries, trial.reTouches, trial.hitInsideTarget, trial.offset, trial.targetPosition];
        [fileHandle writeData:[trialData dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    
    [fileHandle closeFile];
    NSLog(@"trials for user saved");

    
}
@end
