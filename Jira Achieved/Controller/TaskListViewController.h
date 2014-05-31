//
//  TaskListViewController.h
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 19/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ECSlidingViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "TaskDetailViewController.h"
#import "ConfigDAO.h"
#import "Config.h"
#import "ConfigViewController.h"
#import "GreeFacade.h"
#import "JiraFacade.h"
#import "MBProgressHUD.h"
#import "ZKRevealingTableViewCell.h"

@class TaskTypeViewController;

@interface TaskListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate, UISearchBarDelegate,MBProgressHUDDelegate, ZKRevealingTableViewCellDelegate, UIAlertViewDelegate> {
    MBProgressHUD *HUD;
    EGORefreshTableHeaderView *refreshHeaderView;
    NSInteger issueActionType;
    BOOL reloading;
}

@property (assign, nonatomic) NSInteger taskType;
@property (assign, nonatomic) BOOL taskLoading;
@property (assign, nonatomic) BOOL addingMoreLoading;
@property (assign, nonatomic) BOOL hasMoreElements;
@property (retain, nonatomic) IBOutlet UITableView *taskListTableView;
@property (retain, nonatomic) IBOutlet UISearchBar *taskListSearchBar;
@property (retain, nonatomic) IBOutlet UIImageView *emptyTaskListBG;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingTaskIndicator;
@property (retain, nonatomic) IBOutlet UIButton *overlaySearchButton;
@property (retain, nonatomic) IBOutlet UIButton *watchUnwatchIssuButton;
@property (retain, nonatomic) IBOutlet UIButton *finishOrAssignToMeIssueButton;
@property (retain, nonatomic) IBOutlet UIButton *startStopIssueProgressButton;
@property (retain, nonatomic) ConfigDAO* configDAO;
@property (retain, nonatomic) Config* config;
@property (retain, nonatomic) NSMutableData* receivedData;
@property (retain, nonatomic) NSMutableArray* issueList;
@property (nonatomic, retain) ZKRevealingTableViewCell *currentlyRevealedCell;

- (void)reloadDataWithType:(NSInteger)type;
- (IBAction)hideSearchBar:(id)sender;
- (IBAction)watchUnwatchIssue:(id)sender;
- (IBAction)finishOrAssignToMeIssue:(id)sender;
- (IBAction)startStopIssueProgress:(id)sender;
- (void) updateIssue:(Issue*)issue fromAction:(NSInteger)actionType;

@end
