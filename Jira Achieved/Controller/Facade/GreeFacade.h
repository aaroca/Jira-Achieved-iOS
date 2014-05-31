//
//  GreeFacade.h
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 23/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AchievementsDAO.h"
#import "GreeNotification.h"
#import "GreeNotificationQueue.h"
#import "GreeScore.h"
#import "GreeAchievement.h"

@class ProfileViewController;

@interface GreeFacade : NSObject {
    NSString* loginStateConfigFile;
    GreeLeaderboard* leaderboard;
}

- (void)saveLoginConfigState:(BOOL)login;
- (BOOL)isLoginConfg;
- (void) increaseStatisticByOne:(NSInteger)statID;
- (void) increaseStatistic:(NSInteger)statID byValue:(NSInteger)value;
- (void) setStatistic:(NSInteger)statID byValue:(NSInteger)value;
- (void) showUnlockedAchievements;
- (void) increaseScoreByValue:(NSInteger)value;
- (void) synchronizeDataWithGreeFromView:(ProfileViewController*)viewController;
+ (BOOL) isUpdating;
+ (BOOL) isUpdatingError;

@end
