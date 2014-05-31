//
//  AppDelegate.h
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 18/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import "TaskListViewController.h"
#import "CustomAppearance.h"
#import "GreePlatform.h"
#import "GreePlatformSettings.h"
#import "GreeFacade.h"

@interface AppDelegate : UIResponder<UIApplicationDelegate, GreePlatformDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) TaskListViewController* taskListViewController;

@end
