//
//  ProfileViewController.h
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 19/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+GreePlatform.h"
#import "GreePlatform.h"
#import "AchievementsDAO.h"
#import "GreeFacade.h"
#import "EGORefreshTableHeaderView.h"
#import "ConfigDAO.h"

@class Config;

@interface ProfileViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate> {
    @private
    AchievementsDAO* dao;
    EGORefreshTableHeaderView *refreshHeaderView;
    BOOL reloading;
    BOOL updating;
    BOOL updatingError;
    BOOL forceSync;
}

@property (retain, nonatomic) Config* config;
@property (retain, nonatomic) NSArray* achievements;

- (void)doneLoadingTableViewData;

@end
