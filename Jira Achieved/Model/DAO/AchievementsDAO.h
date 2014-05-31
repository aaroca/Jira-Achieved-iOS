//
//  AchievementsDAO.h
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 01/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GenericDAO.h"
#import "Achievement.h"

@interface AchievementsDAO : GenericDAO

- (NSArray*) getAchievements;
- (Achievement*) getAchievementWithID:(NSInteger)ID;
- (void) increaseStatisticByOne:(NSInteger)statID;
- (void) increaseStatistic:(NSInteger)statID byValue:(NSInteger)value;
- (void) setStatistic:(NSInteger)statID byValue:(NSInteger)value;
- (void) unlockAchievement:(Achievement*)achievement;
- (NSArray*) getUnlockedAchievements;
- (NSInteger) increaseScoreByValue:(NSInteger)value;
- (void) setScoreByValue:(NSInteger)value;

@end
