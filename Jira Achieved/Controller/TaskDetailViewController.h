//
//  TaskDetailViewController.h
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 20/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Issue.h"
#import "Config.h"
#import "MBProgressHUD.h"
#import "JiraFacade.h"
#import "MGScrollView.h"
#import "MGStyledBox.h"
#import "MGBoxLine.h"
#import "YIPopupTextView.h"
#import "GreeFacade.h"

@class TaskListViewController;

@interface TaskDetailViewController : UIViewController<UIAlertViewDelegate,MBProgressHUDDelegate,YIPopupTextViewDelegate> {
    MBProgressHUD *HUD;
    NSInteger issueActionType;
}

@property (retain, nonatomic) Issue* issue;
@property (retain, nonatomic) Issue* workingIssue;
@property (retain, nonatomic) Config* config;
@property (retain, nonatomic) MGScrollView* detailScrollView;
@property (assign, nonatomic) TaskListViewController* taskListViewController;
@property (retain, nonatomic) NSString* addCommentText;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *addCommentButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *watchUnwatchIssueButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *finishOrAssignToMeIssueButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *startStopIssueButton;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)watchUnwatchIssue:(id)sender;
- (IBAction)finishOrAssignToMeIssue:(id)sender;
- (IBAction)startStopIssueProgress:(id)sender;
- (IBAction)addComment:(id)sender;

@end
