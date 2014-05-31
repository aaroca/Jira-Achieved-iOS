//
//  ProfileViewController.m
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 19/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewController.h"
#import "Config.h"
#import "MalcomLib.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

@synthesize config;
@synthesize achievements;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        dao = [AchievementsDAO new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [MalcomLib startBeaconWithName:@"Profile View"];
    
	// Do any additional setup after loading the view.
    self.navigationItem.title = @"Profile";
    
    UIBarButtonItem* closeBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close.png"] style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    self.navigationItem.rightBarButtonItem = closeBarButton;
    
    UIBarButtonItem* greeBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gree.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showGreeProfile)];
    self.navigationItem.leftBarButtonItem = greeBarButton;
    
    if (refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.view.bounds.size.height, self.view.frame.size.width, self.view.bounds.size.height)];
		view.delegate = self;
		refreshHeaderView = view;
	}
    
	// update the last update date
	[refreshHeaderView refreshLastUpdatedDate];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    updating = [GreeFacade isUpdating];
    updatingError = [GreeFacade isUpdatingError];
    
    if (![[GreeFacade new] isLoginConfg] || !updatingError) {
        forceSync = NO;
        [refreshHeaderView removeFromSuperview];
    } else {
        forceSync = YES;
        [self.view addSubview:refreshHeaderView];
    }
    
    self.achievements = [dao getAchievements];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self showWarnings];
}

- (void)showWarnings {
    GreeNotificationQueue* queue = [[GreeNotificationQueue alloc] initWithSettings:nil];
    
    if (updating) {
        GreeNotification* notificacion = [[GreeNotification alloc] initWithMessage:@"Synchronizing data with Gree account" displayType:GreeNotificationViewDisplayCloseType duration:2.0f];
        [queue addNotification:notificacion];
    }
    
    if (updatingError) {
        GreeNotification* notificacion = [[GreeNotification alloc] initWithMessage:@"Sychronization error. Pull down to force" displayType:GreeNotificationViewDisplayCloseType duration:2.0f];
        [queue addNotification:notificacion];
    }
}

- (void)viewDidUnload
{
    [MalcomLib endBeaconWithName:@"Profile View"];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (void)close {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)showGreeProfile {
    if([GreePlatform sharedInstance].localUser) {
        [self presentGreeDashboardWithParameters:nil animated:YES];
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You must config your Gree account first" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    
    switch (section) {
        case 0:
            rows = 1;
            break;
        case 1:
            rows = self.achievements.count;
            break;
    }
    
    return rows;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = nil;
    
    switch (indexPath.section) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"scoreCell"];
            
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"scoreCell"];
                cell.textLabel.textColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1] /*#666666*/;
            }
            
            cell.textLabel.text = @"Score";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", config.score];
            
            break;
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"achievementCell"];
            
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"achievementCell"];      
                cell.textLabel.textColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1] /*#666666*/;
            }
            
            Achievement* achievement = (Achievement*) [self.achievements objectAtIndex:indexPath.row];
            
            cell.textLabel.text = achievement.name;
            cell.detailTextLabel.text = achievement.description;
            
            if (achievement.done) {
                cell.imageView.image = [UIImage imageNamed:@"achieveEnable.png"];
            } else {
                cell.imageView.image = [UIImage imageNamed:@"achieveDisable.png"];
            }
            
            break;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {              // Default is 1 if not implemented
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {    // fixed font style. use custom view (UILabel) if you want something different
    NSString* header = nil;
    
    if (section == 1) {
        header = @"Achievements";
    }
    
    return header;
}

- (void)reloadTableViewDataSource{
    reloading = YES;
    [[GreeFacade new] synchronizeDataWithGreeFromView:self];
}

- (void)doneLoadingTableViewData {
    if (reloading) {
        reloading = NO;
        self.config = [[ConfigDAO new] getConfig];
        self.achievements = [dao getAchievements];
        [(UITableView*) self.view reloadData];
        [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:(UITableView*) self.view];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
    if (forceSync) {
        [refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (forceSync) {
        [refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
    [self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
    return reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
    return [NSDate date];
}


- (void)dealloc {
    [super dealloc];
}
@end
