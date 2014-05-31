//
//  TaskDetailViewController.m
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 20/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TaskDetailViewController.h"
#import "TaskListViewController.h"
#import "MalcomLib.h"

@interface TaskDetailViewController ()

@end

@implementation TaskDetailViewController

@synthesize issue;
@synthesize workingIssue;
@synthesize config;
@synthesize addCommentText;
@synthesize detailScrollView;
@synthesize taskListViewController;
@synthesize addCommentButton;
@synthesize watchUnwatchIssueButton;
@synthesize finishOrAssignToMeIssueButton;
@synthesize startStopIssueButton;
@synthesize activityIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [MalcomLib startBeaconWithName:@"Task Detail View"];
	// Do any additional setup after loading the view.
    
    self.navigationItem.title = @"Issue detail";
    self.detailScrollView = [[MGScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 372)];
    [self.view addSubview:self.detailScrollView];
}

- (void)viewDidAppear:(BOOL)animated {
    [self loadIssue];
}

- (void)loadIssue {
    // Si hemos indicado una tarea, completamos la vista.
    if (issue) {
        self.activityIndicator.hidden = NO;
        
        self.workingIssue = [[JiraFacade new] getIssueDetails:self.issue withConfig:self.config];
        
        self.activityIndicator.hidden = YES;
        
        if (self.workingIssue) {
            [self configToolBar];
            [self renderIssue];
            
            GreeFacade* facade = [GreeFacade new];
            [facade increaseStatisticByOne:6];
            [facade showUnlockedAchievements];
            [facade release];
        } else {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error loading issue details" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }
    }
}

- (void)configToolBar {
    if (self.issue) {
        if (self.issue.isWatching) {
            self.watchUnwatchIssueButton.image = [UIImage imageNamed:@"unwatch.png"];
        } else {
            self.watchUnwatchIssueButton.image = [UIImage imageNamed:@"watch.png"];
        }
        [self.watchUnwatchIssueButton setEnabled:YES];
        
        if (self.issue.isStarted) {
            self.startStopIssueButton.image = [UIImage imageNamed:@"stop.png"];
        } else {
            self.startStopIssueButton.image = [UIImage imageNamed:@"start.png"];
        }
        [self.startStopIssueButton setEnabled:YES];
        
        if (!self.issue.isAssignedToMe) {
            self.finishOrAssignToMeIssueButton.image = [UIImage imageNamed:@"assignee.png"];
            
            [self.startStopIssueButton setEnabled:NO];
        } else {
            self.finishOrAssignToMeIssueButton.image = [UIImage imageNamed:@"done.png"];
            
            [self.startStopIssueButton setEnabled:YES];
        }
        
        if (self.issue.isClosed || self.issue.isResolved) {
            [self.startStopIssueButton setEnabled:NO];
            [self.finishOrAssignToMeIssueButton setEnabled:NO];
        } else {
            [self.finishOrAssignToMeIssueButton setEnabled:YES];            
        }
        
        [self.addCommentButton setEnabled:YES];
    }
}

- (void)renderIssue {
    UIFont* rightFont = [UIFont fontWithName:@"HelveticaNeue" size:14];
    UIFont* leftFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    UIImage* commentImage = [UIImage imageNamed:@"commentBlack.png"];
    
    // Build Issue header.
    MGStyledBox *summary = [MGStyledBox box];
    [self.detailScrollView.boxes addObject:summary];
    
    MGBoxLine *issueSummary = [MGBoxLine multilineWithText:self.workingIssue.summary font:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16] padding:24];
    [summary.topLines addObject:issueSummary];
    
    MGBoxLine* issueID = [MGBoxLine lineWithLeft:@"ID" right:self.workingIssue.issueID];
    issueID.font = leftFont;
    issueID.rightFont = rightFont;
    [summary.topLines addObject:issueID];
    
    MGBoxLine* issueAssigned = [MGBoxLine lineWithLeft:@"Assigned to" right:self.workingIssue.assignedUser];
    issueAssigned.font = leftFont;
    issueAssigned.rightFont = rightFont;
    [summary.topLines addObject:issueAssigned]; 
    
    MGBoxLine* issuePriority = [MGBoxLine lineWithLeft:@"Priority" right:self.workingIssue.priority];
    issuePriority.font = leftFont;
    issuePriority.rightFont = rightFont;
    [summary.topLines addObject:issuePriority];    
    
    MGBoxLine* issueType = [MGBoxLine lineWithLeft:@"Type" right:self.workingIssue.issueType];
    issueType.font = leftFont;
    issueType.rightFont = rightFont;
    [summary.topLines addObject:issueType];  
    
    MGBoxLine* issueStatus = [MGBoxLine lineWithLeft:@"Status" right:self.workingIssue.status];
    issueStatus.font = leftFont;
    issueStatus.rightFont = rightFont;
    [summary.topLines addObject:issueStatus];  
    
    // Build Issue description.
    MGStyledBox *description = [MGStyledBox box];
    [self.detailScrollView.boxes addObject:description];
    
    MGBoxLine *descriptionTitle = [MGBoxLine lineWithLeft:@"Description" right:nil];
    descriptionTitle.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    [description.topLines addObject:descriptionTitle];
    
    MGBoxLine* issueDescription = [MGBoxLine multilineWithText:self.workingIssue.description font:rightFont padding:24];
    [description.topLines addObject:issueDescription]; 
    
    // Build Issue comments.
    MGStyledBox *comments = [MGStyledBox box];
    [self.detailScrollView.boxes addObject:comments];
    
    MGBoxLine *commentsTitle = [MGBoxLine lineWithLeft:[NSString stringWithFormat:@"Comments (%d)", self.workingIssue.comments.count] right:nil];
    commentsTitle.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    [comments.topLines addObject:commentsTitle];
    
    for (Comment* comment in self.workingIssue.comments) {
        NSArray *commentHeader = [NSArray arrayWithObjects:commentImage, comment.author, nil];
        
        MGBoxLine *commentBody = [MGBoxLine lineWithLeft:commentHeader right:nil];
        commentBody.font = leftFont;
        [comments.topLines addObject:commentBody];

        MGBoxLine *commentText = [MGBoxLine multilineWithText:comment.body font:rightFont padding:24];
        [comments.topLines addObject:commentText];
    }
    
    // Draw table
    [self.detailScrollView drawBoxesWithSpeed:0.3];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.taskListViewController.taskListTableView reloadData];
}

- (void)viewDidUnload
{
    [MalcomLib endBeaconWithName:@"Task Detail View"];
    
    [self setAddCommentButton:nil];
    [self setWatchUnwatchIssueButton:nil];
    [self setFinishOrAssignToMeIssueButton:nil];
    [self setStartStopIssueButton:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)watchUnwatchIssue:(id)sender {
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.dimBackground = YES;
    HUD.delegate = self;
    HUD.labelText = @"Performing action...";
    
    [HUD showWhileExecuting:@selector(updateJiraIssueWithAction:) onTarget:self withObject:[NSNumber numberWithInteger:WATCH_UNWATCH_ACTION] animated:YES];
}

- (IBAction)finishOrAssignToMeIssue:(id)sender {
    NSString* confirmationQuestion = nil;
    
    if (self.issue.isAssignedToMe) {
        confirmationQuestion = @"Do you want to resolve this issue?";
    } else {
        confirmationQuestion = @"Do you want to assign to you this issue?";
    }
    
    issueActionType = FINISH_ISSUE_ACTION;
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:confirmationQuestion delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [alert show];
    [alert release];
}

- (IBAction)startStopIssueProgress:(id)sender {
    NSString* confirmationQuestion = nil;
    
    if (self.issue.isStarted) {
        confirmationQuestion = @"Do you want to stop progress to this issue?";
    } else {
        confirmationQuestion = @"Do you want to start progress to this issue?";
    }
    
    issueActionType = START_STOP_ACTION;
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:confirmationQuestion delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [alert show];
    [alert release];
}

- (IBAction)addComment:(id)sender {
    [UIView beginAnimations:@"hide" context:nil];
    [UIView setAnimationDuration:0.1f];
    
    self.navigationController.navigationBarHidden = YES;
    
    [UIView commitAnimations];    
    
    YIPopupTextView* popupTextView = [[YIPopupTextView alloc] initWithPlaceHolder:@"" maxCount:2000];
    popupTextView.text = self.addCommentText;
    popupTextView.delegate = self;
    [popupTextView showInView:self.view];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.dimBackground = YES;
        HUD.delegate = self;
        HUD.labelText = @"Performing action...";
        
        [HUD showWhileExecuting:@selector(updateJiraIssueWithAction:) onTarget:self withObject:[NSNumber numberWithInteger:issueActionType] animated:YES];  
    }
}

- (void)popupTextView:(YIPopupTextView *)textView willDismissWithText:(NSString *)text
{
    [UIView beginAnimations:@"show" context:nil];
    [UIView setAnimationDuration:0.1f];
    
    self.navigationController.navigationBarHidden = NO;
    
    [UIView commitAnimations];
    
    if (text.length > 0) {
        self.addCommentText = text;
        issueActionType = COMMENT_ACTION;
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Do you want to post this comment?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        [alert show];
        [alert release];
    }
}

- (void)popupTextView:(YIPopupTextView *)textView didDismissWithText:(NSString *)text
{
    NSLog(@"did dismiss");
}

- (void) updateJiraIssueWithAction:(NSNumber*)actionType {
    Issue* returnedIssue = self.workingIssue;
    BOOL results = NO;
    
    if (actionType.integerValue == WATCH_UNWATCH_ACTION) {
        returnedIssue = [[JiraFacade new] watchUnwatchIssue:issue withConfig:self.config];
    } else if (actionType.integerValue == FINISH_ISSUE_ACTION) {
        returnedIssue = [[JiraFacade new] finishOrAssignIssue:issue withConfig:self.config];
    } else if (actionType.integerValue == ADD_HOURS_ACTION) {
        results = [[JiraFacade new] addHouseToIssue:issue withConfig:self.config];
        returnedIssue = nil;
    } else if (actionType.integerValue == START_STOP_ACTION) {
        returnedIssue = [[JiraFacade new] startStopIssueProgress:issue withConfig:self.config];
    } else if (actionType.integerValue == COMMENT_ACTION) {
        Comment* comment = [Comment new];
        comment.username = self.config.jiraUsername;
        comment.body = self.addCommentText;

        returnedIssue =  [[JiraFacade new] addComment:comment toIssue:issue withConfig:self.config];
    }
    
    if (returnedIssue || results) {
        self.issue = returnedIssue;
        self.addCommentText = @"";
        [self configToolBar];
        [self.taskListViewController updateIssue:self.issue fromAction:actionType.integerValue];
        
        HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"done.png"]] autorelease];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.dimBackground = NO;
        HUD.labelText = @"Done";
        sleep(1);
        
        GreeFacade* facade = [GreeFacade new];
        
        if (actionType.integerValue == WATCH_UNWATCH_ACTION && returnedIssue.isWatching) {
            [facade increaseStatisticByOne:9];
            [facade increaseScoreByValue:1];
            [facade showUnlockedAchievements];
        } else if (actionType.integerValue == FINISH_ISSUE_ACTION && returnedIssue.isClosed) {
            [facade increaseStatisticByOne:8];
            [facade increaseScoreByValue:5];
            [facade showUnlockedAchievements];
        } else if (actionType.integerValue == FINISH_ISSUE_ACTION && !returnedIssue.isClosed) {
            [facade increaseScoreByValue:3];
        } else if (actionType.integerValue == START_STOP_ACTION && returnedIssue.isStarted) {
            [facade increaseStatisticByOne:11];
            [facade increaseScoreByValue:2];
            [facade showUnlockedAchievements];
        } else if (actionType.integerValue == COMMENT_ACTION) {
            [facade increaseStatisticByOne:7];
            [facade setStatistic:10 byValue:self.addCommentText.length];
            [facade increaseScoreByValue:1];
            [facade showUnlockedAchievements];
        }
        
        [facade release];
        
        if (actionType.integerValue == FINISH_ISSUE_ACTION || actionType.integerValue == START_STOP_ACTION ||
            actionType.integerValue == COMMENT_ACTION) {
            [self.detailScrollView.boxes removeAllObjects];
            [self loadIssue];
        }
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Action cannot be done" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	[HUD release];
	HUD = nil;
}

- (void)dealloc {
    [addCommentButton release];
    [watchUnwatchIssueButton release];
    [finishOrAssignToMeIssueButton release];
    [startStopIssueButton release];
    [activityIndicator release];
    [super dealloc];
}
@end
