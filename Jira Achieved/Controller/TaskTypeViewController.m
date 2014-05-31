//
//  TaskTypeViewController.m
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 19/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TaskTypeViewController.h"
#import "TaskListViewController.h"

@interface TaskTypeViewController ()

@end

@implementation TaskTypeViewController

@synthesize configDAO;
@synthesize taskTypes;
@synthesize taskListViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.configDAO = [ConfigDAO new];
        self.taskTypes = [NSArray arrayWithObjects:@"Assigned", @"Open or In progress", @"Closed or Resolved", @"Watching", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIBarButtonItem* configButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"config.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showConfig)];
    
    self.navigationItem.rightBarButtonItem =  configButton;
    
    UIBarButtonItem* userButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"user.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showProfile)];
    
    self.navigationItem.leftBarButtonItem = userButton;
    
    self.navigationItem.title = @"Issue status";
    
    [self.slidingViewController setAnchorRightRevealAmount:270.0f];
    self.slidingViewController.underLeftWidthLayout = ECFixedRevealWidth;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (void)showConfig {
    ConfigViewController* configViewController = [[ConfigViewController alloc] initWithNibName:@"ConfigView" bundle:nil];
    UINavigationController* navigation = [[UINavigationController alloc] initWithRootViewController:configViewController];
    navigation.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    // Recuperamos la configuración de la aplicación
    Config* config = [self.configDAO getConfig];
    configViewController.appConfig = config;
    
    [self presentModalViewController:navigation animated:YES];
}

- (void)showProfile {
    ProfileViewController* profileViewController = [[ProfileViewController alloc] initWithNibName:@"ProfileView" bundle:nil];
    profileViewController.config = [self.configDAO getConfig];
    UINavigationController* navigation = [[UINavigationController alloc] initWithRootViewController:profileViewController];
    navigation.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentModalViewController:navigation animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.taskTypes.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* taskTypeCell = [tableView dequeueReusableCellWithIdentifier:@"taskTypeCell"];
    
    if (!taskTypeCell) {
        taskTypeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"taskTypeCell"];
        taskTypeCell.textLabel.textColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1] /*#666666*/;
    }
    
    taskTypeCell.textLabel.text = [self.taskTypes objectAtIndex:indexPath.row];
    
    return taskTypeCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.taskListViewController.navigationItem.title = [self.taskTypes objectAtIndex:indexPath.row];
    [self.taskListViewController reloadDataWithType:indexPath.row];
    [self.slidingViewController resetTopView];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
