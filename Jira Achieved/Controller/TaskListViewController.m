//
//  TaskListViewController.m
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 19/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TaskListViewController.h"
#import "TaskTypeViewController.h"
#import "MalcomLib.h"

@interface TaskListViewController ()

@end

@implementation TaskListViewController
@synthesize taskListTableView;
@synthesize taskListSearchBar;
@synthesize emptyTaskListBG;
@synthesize loadingTaskIndicator;
@synthesize overlaySearchButton;
@synthesize watchUnwatchIssuButton;
@synthesize finishOrAssignToMeIssueButton;
@synthesize startStopIssueProgressButton;
@synthesize configDAO;
@synthesize config;
@synthesize taskType;
@synthesize taskLoading;
@synthesize addingMoreLoading;
@synthesize receivedData;
@synthesize issueList;
@synthesize hasMoreElements;
@synthesize currentlyRevealedCell = _currentlyRevealedCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.configDAO = [ConfigDAO new];
        self.taskType = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [MalcomLib startBeaconWithName:@"Task List View"];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIBarButtonItem* revealTaskTypeView = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showTaskTypeMenu)];
    self.navigationItem.leftBarButtonItem = revealTaskTypeView;
    
    // No permitiremos la creación de tareas para la primera versión final
    // pero se activará en futuras versiones.
//    UIBarButtonItem* newTaskBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add.png"] style:UIBarButtonItemStylePlain target:self action:@selector(newTask)];
//    self.navigationItem.rightBarButtonItem = newTaskBarButton;
    
    // Cambiamos el color de la barra de navegación
    self.navigationItem.title = @"Task list";
    self.loadingTaskIndicator.hidden = YES;
    self.emptyTaskListBG.hidden = NO;
    
    if (refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.taskListTableView.bounds.size.height, self.view.frame.size.width, self.taskListTableView.bounds.size.height)];
		view.delegate = self;
		[self.taskListTableView addSubview:view];
		refreshHeaderView = view;
		[view release];
		
	}
    
	// update the last update date
	[refreshHeaderView refreshLastUpdatedDate];
    
    self.issueList = [[NSMutableArray alloc] init];
    
    self.taskListSearchBar.showsScopeBar = NO;
	[self.taskListSearchBar sizeToFit];
	[self.taskListSearchBar setShowsCancelButton:NO animated:NO];
}

- (void) newTask {
//    [[GreeFacade new] increaseStatisticByOne:1];
//    [[GreeFacade new] showUnlockedAchievements];
//    [[GreeFacade new] increaseScoreByValue:50];
}

- (UIView*) configQuickActionsView:(Issue*)issue {
    NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"QuickActionsView" owner:self options:nil];
    UIView* quickActionsView = nil;
    
    if (views.count == 1) {
        quickActionsView = (UIView*) [views objectAtIndex:0];
    }
    
    if (issue.isWatching) {
        [self.watchUnwatchIssuButton setImage:[UIImage imageNamed:@"unwatch.png"] forState:UIControlStateNormal];
    }
    
    if (issue.isStarted) {
        [self.startStopIssueProgressButton setImage:[UIImage imageNamed:@"stop.png"] forState:UIControlStateNormal];
    }
    
    if (!issue.isAssignedToMe) {
        [self.finishOrAssignToMeIssueButton setImage:[UIImage imageNamed:@"assignee.png"] forState:UIControlStateNormal];
        
        [self.startStopIssueProgressButton setEnabled:NO];
    }
    
    if (issue.isClosed || issue.isResolved) {
        [self.startStopIssueProgressButton setEnabled:NO];
        [self.finishOrAssignToMeIssueButton setEnabled:NO];
    }

    return quickActionsView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationController.view.layer.shadowOpacity = 0.75f;
    self.navigationController.view.layer.shadowRadius = 10.0f;
    self.navigationController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[TaskTypeViewController class]]) {
        TaskTypeViewController* taskTypeViewController = [[TaskTypeViewController alloc] initWithNibName:@"TaskTypeView" bundle:nil];
        taskTypeViewController.taskListViewController = self;
        UINavigationController* navigation = [[UINavigationController alloc] initWithRootViewController:taskTypeViewController];
        
        self.slidingViewController.underLeftViewController = navigation;
    }
    
    // Recuperamos la configuración de la aplicación
    self.config = [self.configDAO getConfig];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Si la app no está configurada, iniciamos el asistente.
    if (!self.config) {
        ConfigViewController* configWizard = [[ConfigViewController alloc] initWithNibName:@"ConfigView" bundle:nil];
        UINavigationController* wizard = [[UINavigationController alloc] initWithRootViewController:configWizard];
        wizard.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        [self presentModalViewController:wizard animated:YES];
    } else {
        // Pero si está configurada, configuramos login en Gree y no hemos iniciado sesión
        // lo hacemos.
        GreeFacade* facade = [GreeFacade new];
        if ([facade isLoginConfg] && ![GreePlatform sharedInstance].localUser) {
            [GreePlatform authorize];
        }
        [facade release];
        
        // Por defecto cargaremos las tareas ABIERTAS
        if (self.taskType == -1) {
            self.navigationItem.title = @"Open or In progress";
            [self reloadDataWithType:OPEN_TASK];
        } else {
            [self reloadDataWithType:self.taskType];
        }
    }
}

- (void)viewDidUnload
{
    [MalcomLib endBeaconWithName:@"Task List View"];
    
    self.config = nil;
    self.configDAO = nil;
    self.issueList = nil;
    [self setTaskListTableView:nil];
    [self setTaskListSearchBar:nil];
    [self setEmptyTaskListBG:nil];
    [self setLoadingTaskIndicator:nil];
    [self setOverlaySearchButton:nil];
    [self setWatchUnwatchIssuButton:nil];
    [self setFinishOrAssignToMeIssueButton:nil];
    [self setStartStopIssueProgressButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = self.issueList.count;
    
    if (rows == 0) {
        self.taskListSearchBar.hidden = YES;
        self.emptyTaskListBG.hidden = NO;
    } else {
        self.taskListSearchBar.hidden = NO;
        self.emptyTaskListBG.hidden = YES;
        
        if (self.hasMoreElements) {
            rows += 1;
        }
    }
    
    return rows;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* returnedCell = nil;
    
    ZKRevealingTableViewCell* cell = nil;
    
    if (indexPath.row == self.issueList.count && self.hasMoreElements) {
        returnedCell = [self.taskListTableView dequeueReusableCellWithIdentifier:@"moreIssuesCell"];
        
        if (!cell) {
            returnedCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"moreIssuesCell"] autorelease];
            returnedCell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
        
        returnedCell.textLabel.text = [NSString stringWithFormat:@"Load %d more issues", ELEMENT_PER_PAGE];
        returnedCell.textLabel.textAlignment = UITextAlignmentCenter;
        returnedCell.accessoryType = UITableViewCellAccessoryNone;
        returnedCell.accessoryView = nil;
    } else {
        ZKRevealingTableViewCell* cell = [self.taskListTableView dequeueReusableCellWithIdentifier:@"taskCell"];
        
        if (!cell) {
            cell = [[[ZKRevealingTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"taskCell"] autorelease];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.direction = ZKRevealingTableViewCellDirectionLeft;
            cell.shouldBounce = NO;
            cell.delegate = self;
        }
        
        if (indexPath.row >= 0 && indexPath.row < self.issueList.count) {
            Issue* issue = (Issue*) [self.issueList objectAtIndex:indexPath.row];
            
            cell.summary = issue.summary;
            cell.detail = issue.issueID;
            cell.backView = [self configQuickActionsView:issue];
            cell.badgeColor = [UIColor lightGrayColor];
            
            if (issue.isClosed || issue.isResolved) {
                if (issue.isClosed) {
                    cell.badgeText = @"Closed";
                } else if (issue.isResolved) {
                    cell.badgeText = @"Resolved";
                }
            } else {
                cell.badgeText = issue.priority;
            }
        }
        
        returnedCell = cell;
    }
    
    returnedCell.textLabel.textColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1] /*#666666*/;
    returnedCell.contentView.backgroundColor = [UIColor colorWithRed:0.902 green:0.902 blue:0.863 alpha:1] /*#e6e6dc*/;
                
    return returnedCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!reloading) {
        /*
         * Si la fila que señalamos es igual al número de tareas,
         * significa que estamo seleccionando la fila con el texto
         * "Load X more issues", ya que las tareas irán desde 0
         * a count - 1, nunca llegarán a count
         */
        if (indexPath.row == self.issueList.count) {
            // Indicamos que estamos cargando más elementos.
            self.addingMoreLoading = YES;
            self.taskListTableView.userInteractionEnabled = NO;
            
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            spinner.frame = CGRectMake(0, 0, 24, 24);
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryView = spinner;
            cell.textLabel.text = @"Loading...";
            [spinner startAnimating];
            [spinner release];
            
            // Cargamos más elementos.
            NSInteger type =  self.taskType;
            self.taskType = -1;
            [self addDataWithType:type];
        } else {
            [self showIssueDetails:[self.issueList objectAtIndex:indexPath.row]];
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)reloadTableViewDataSource{
    reloading = YES;

    NSInteger type = self.taskType;
    self.taskType = -1;
    
    [self reloadDataWithType:type];
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
    [self.taskListTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    
    if (reloading) {
        reloading = NO;
        [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.taskListTableView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	[refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
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

- (void)showTaskTypeMenu {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)showIssueDetails:(Issue*)issue {
    TaskDetailViewController* detailViewController = [[TaskDetailViewController alloc] initWithNibName:@"TaskDetailView" bundle:nil];
    detailViewController.issue = issue;
    detailViewController.config = self.config;
    detailViewController.taskListViewController = self;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)reloadDataWithType:(NSInteger)type {
    if (type != self.taskType) {
        [self.taskListTableView setUserInteractionEnabled:NO];
        [self.taskListSearchBar setUserInteractionEnabled:NO];
        
        [self.taskListSearchBar setText:@""];
        
        self.taskLoading = YES;
        [self.issueList removeAllObjects];
        
        if (!reloading) {
            [self.taskListTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            
            self.loadingTaskIndicator.hidden = NO;
            self.emptyTaskListBG.hidden = YES;
        }
            
        self.taskType = type;
        
        [[JiraFacade new] getIssueListOfType:type startingFrom:self.issueList.count withConfig:self.config andDelegateIn:self];
    }
}

- (void)addDataWithType:(NSInteger)type {
    self.taskLoading = YES;
    self.taskType = type;
    
    [[JiraFacade new] getIssueListOfType:type startingFrom:self.issueList.count withConfig:self.config andDelegateIn:self];
}

// Connection Delegat
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.loadingTaskIndicator.hidden = YES;
    self.taskListTableView.userInteractionEnabled = YES;
    self.addingMoreLoading = NO;
    
    if (self.issueList.count == 0) {
        self.emptyTaskListBG.hidden = NO;
    }
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*) response;
    
    if (httpResponse.statusCode == 200) {
        self.receivedData = [[NSMutableData alloc] init];
    } else {
        self.loadingTaskIndicator.hidden = YES;
        self.taskListTableView.userInteractionEnabled = YES;
        self.addingMoreLoading = NO;
        
        if (self.issueList.count == 0) {
            self.emptyTaskListBG.hidden = NO;
        }
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error getting issues. Try it again later" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString* json = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
    
    NSArray* newIssues = [[JiraFacade new] parseIssueResponseJSON:json withConfig:self.config];
    [self.issueList addObjectsFromArray:newIssues];
    
    if (!reloading) {
        self.taskLoading = NO;
        self.loadingTaskIndicator.hidden = YES;
    }
    
    if (self.issueList.count == 0) {
            self.emptyTaskListBG.hidden = NO;
    }
    
    if (newIssues.count == ELEMENT_PER_PAGE) {
        self.hasMoreElements = YES;
        
        // Si estábamos cargando más tareas y ha finalizado
        // se vuelve al estado original.
        if (addingMoreLoading) {
            [self.taskListTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        }
    } else {
        self.hasMoreElements = NO;
    }
    
    self.addingMoreLoading = NO;
    [self.taskListSearchBar setUserInteractionEnabled:YES];
    [self.taskListTableView setUserInteractionEnabled:YES];
    
    [self doneLoadingTableViewData];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [UIView beginAnimations:@"hide" context:nil];
    [UIView setAnimationDuration:0.1f];
    
    self.navigationController.navigationBarHidden = YES;
    [overlaySearchButton setHidden:NO];
    
    [UIView commitAnimations];
	
    searchBar.showsScopeBar = YES;
	[searchBar sizeToFit];
    [self.taskListSearchBar setShowsCancelButton:YES animated:YES];
    
	return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [UIView beginAnimations:@"show" context:nil];
    [UIView setAnimationDuration:0.1f];
    
    self.navigationController.navigationBarHidden = NO;
    [overlaySearchButton setHidden:YES];
    
    [UIView commitAnimations];
	
    searchBar.showsScopeBar = NO;
	[searchBar sizeToFit];
    [searchBar setShowsCancelButton:NO animated:YES];
    
	return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {                     // called when keyboard search button pressed
    [searchBar resignFirstResponder];
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.dimBackground = YES;
    HUD.delegate = self;
    HUD.labelText = @"Searching...";
    
    [HUD showWhileExecuting:@selector(searchIssueWithData:) onTarget:self withObject:[NSNumber numberWithInteger:searchBar.selectedScopeButtonIndex] animated:YES];
}

- (void)searchIssueWithData:(NSNumber*)type {
    NSArray* results = [[JiraFacade new] searchIssueWithData:self.taskListSearchBar.text ofType:type.integerValue inSection:self.taskType andConfig:self.config];
    
    if (results.count > 0) {
        self.hasMoreElements = NO;
        [self.issueList removeAllObjects];
        [self.issueList addObjectsFromArray:results];
        [self.taskListTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"No results" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    
    GreeFacade* facade = [GreeFacade new];
    [facade increaseStatisticByOne:5];
    [facade showUnlockedAchievements];
    [facade release];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {                    // called when cancel button pressed
    [self hideSearchBar:nil];
}

- (IBAction)hideSearchBar:(id)sender {
    [self.taskListSearchBar resignFirstResponder];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	[HUD release];
	HUD = nil;
}

#pragma mark - Accessors

- (ZKRevealingTableViewCell *)currentlyRevealedCell
{
	return _currentlyRevealedCell;
}

- (void)setCurrentlyRevealedCell:(ZKRevealingTableViewCell *)currentlyRevealedCell
{
	if (_currentlyRevealedCell == currentlyRevealedCell)
		return;
	
	[_currentlyRevealedCell setRevealing:NO];
	
	if (_currentlyRevealedCell)
		[_currentlyRevealedCell autorelease];
	
	[self willChangeValueForKey:@"currentlyRevealedCell"];
	_currentlyRevealedCell = [currentlyRevealedCell retain];
	[self didChangeValueForKey:@"currentlyRevealedCell"];
}

#pragma mark - ZKRevealingTableViewCellDelegate

- (BOOL)cellShouldReveal:(ZKRevealingTableViewCell *)cell
{
	return YES;
}

- (void)cellDidReveal:(ZKRevealingTableViewCell *)cell
{
	NSLog(@"Revealed Cell with title: %@", cell.textLabel.text);
	self.currentlyRevealedCell = cell;
}

- (void)cellDidBeginPan:(ZKRevealingTableViewCell *)cell
{
	if (cell != self.currentlyRevealedCell)
		self.currentlyRevealedCell = nil;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	self.currentlyRevealedCell = nil;
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
    Issue* selectedIssue = [self.issueList objectAtIndex:[self getSelectedIssuePosition]];
    NSString* confirmationQuestion = nil;
    
    if (selectedIssue.isAssignedToMe) {
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
    Issue* selectedIssue = [self.issueList objectAtIndex:[self getSelectedIssuePosition]];
    NSString* confirmationQuestion = nil;
    
    if (selectedIssue.isStarted) {
        confirmationQuestion = @"Do you want to stop progress to this issue?";
    } else {
        confirmationQuestion = @"Do you want to start progress to this issue?";
    }
    
    issueActionType = START_STOP_ACTION;
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:confirmationQuestion delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [alert show];
    [alert release];
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

- (void) updateJiraIssueWithAction:(NSNumber*)actionType {
    [self.taskListTableView setUserInteractionEnabled:NO];
    NSInteger selectedIssuePosition = [self getSelectedIssuePosition];
    
    Issue* issue = [self.issueList objectAtIndex:selectedIssuePosition];
    BOOL results = NO;
    
    if (actionType.integerValue == WATCH_UNWATCH_ACTION) {
        issue = [[JiraFacade new] watchUnwatchIssue:issue withConfig:self.config];
    } else if (actionType.integerValue == FINISH_ISSUE_ACTION) {
        issue = [[JiraFacade new] finishOrAssignIssue:issue withConfig:self.config];
    } else if (actionType.integerValue == ADD_HOURS_ACTION) {
        results = [[JiraFacade new] addHouseToIssue:issue withConfig:self.config];
        issue = nil;
    } else if (actionType.integerValue == START_STOP_ACTION) {
        issue = [[JiraFacade new] startStopIssueProgress:issue withConfig:self.config];
    }
    
    if (issue || results) {
        [self updateIssue:issue fromAction:actionType.integerValue];
        
        [self.taskListTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        
        HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"done.png"]] autorelease];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.dimBackground = NO;
        HUD.labelText = @"Done";
        sleep(1);
        
        GreeFacade* facade = [GreeFacade new];
        
        if (actionType.integerValue == WATCH_UNWATCH_ACTION && issue.isWatching) {
            [facade increaseStatisticByOne:9];
            [facade increaseScoreByValue:1];
            [facade showUnlockedAchievements];
        } else if (actionType.integerValue == FINISH_ISSUE_ACTION && issue.isClosed) {
            [facade increaseStatisticByOne:8];
            [facade increaseScoreByValue:5];
            [facade showUnlockedAchievements];
        } else if (actionType.integerValue == FINISH_ISSUE_ACTION && !issue.isClosed) {
            [facade increaseScoreByValue:3];
        } else if (actionType.integerValue == START_STOP_ACTION && issue.isStarted) {
            [facade increaseStatisticByOne:11];
            [facade increaseScoreByValue:2];
            [facade showUnlockedAchievements];
        }
        
        [facade release];
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Action cannot be done" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    
    [self.taskListTableView setUserInteractionEnabled:YES];
}

- (NSInteger) getSelectedIssuePosition {
    NSIndexPath* indexPath = [self.taskListTableView indexPathForCell:self.currentlyRevealedCell];
    
    return indexPath.row;
}

- (void) updateIssue:(Issue*)issue fromAction:(NSInteger)actionType {
    NSInteger position = [self.issueList indexOfObject:issue];
    
    if ((actionType == FINISH_ISSUE_ACTION && issue.isClosed && (self.taskType == OPEN_TASK))
        || (actionType == WATCH_UNWATCH_ACTION && !issue.isWatching && self.taskType == WHATCHING_TASK)) {
        [self.issueList removeObjectAtIndex:position];
    } else {
        if ([self.issueList containsObject:issue]) {
                [self.issueList replaceObjectAtIndex:position withObject:issue];
        }
    }
}

- (void)dealloc {
    [self.issueList release];
    [self.config release];
    [self.configDAO release];
    [taskListTableView release];
    [taskListSearchBar release];
    [emptyTaskListBG release];
    [loadingTaskIndicator release];
    [overlaySearchButton release];
    [watchUnwatchIssuButton release];
    [finishOrAssignToMeIssueButton release];
    [startStopIssueProgressButton release];
    [super dealloc];
}
@end
