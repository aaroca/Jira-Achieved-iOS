//
//  AcknowledgmentsViewController.m
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 30/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AcknowledgmentsViewController.h"
#import "MalcomLib.h"

@interface AcknowledgmentsViewController ()

@end

@implementation AcknowledgmentsViewController
@synthesize acknowledgmentsWebView;

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
    
    [MalcomLib startBeaconWithName:@"Acknowledgments View"];
	// Do any additional setup after loading the view.
    self.navigationItem.title = @"Acknowledgments";
    [self.acknowledgmentsWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"acknowledgments" ofType:@"html"]isDirectory:NO]]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    GreeFacade* facade = [GreeFacade new];
    [facade increaseStatisticByOne:4];
    [facade showUnlockedAchievements];}

- (void)viewDidUnload
{
    [MalcomLib endBeaconWithName:@"Acknowledgments View"];

    [self setAcknowledgmentsWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [acknowledgmentsWebView release];
    [super dealloc];
}
@end
