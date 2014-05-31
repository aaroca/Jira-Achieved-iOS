//
//  TaskTypeViewController.h
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 19/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import "ConfigViewController.h"
#import "ProfileViewController.h"
#import "ConfigDAO.h"
#import "Config.h"

@class TaskListViewController;

@interface TaskTypeViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (retain, nonatomic) ConfigDAO* configDAO;
@property (retain, nonatomic) NSArray* taskTypes;
@property (assign, nonatomic) TaskListViewController* taskListViewController;

@end
