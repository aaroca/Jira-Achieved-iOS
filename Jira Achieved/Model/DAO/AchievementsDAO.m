//
//  AchievementsDAO.m
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 01/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AchievementsDAO.h"

@implementation AchievementsDAO

-(NSArray*) getAchievements {
    NSMutableArray* achievements = [[NSMutableArray alloc] init];
    FMResultSet* resultSet = [self.databaseController executeQuery:@"SELECT * FROM achievements ORDER BY done DESC, id ASC", nil];
    
    while ([resultSet next]) {
        NSInteger ID = [resultSet intForColumn:@"id"];
        NSString* name = [resultSet stringForColumn:@"name"];
        NSString* description = [resultSet stringForColumn:@"description"];
        BOOL done = [resultSet boolForColumn:@"done"];
        NSInteger condition = [resultSet intForColumn:@"statistic_condition"];
        NSInteger statistic = [resultSet intForColumn:@"statistic_id"];
        
        Achievement* achievement = [Achievement new];
        achievement.ID = ID;
        achievement.name = name;
        achievement.description = description;
        achievement.done = done;
        achievement.condition = condition;
        achievement.statistic = statistic;
        
        [achievements addObject:achievement];
    }
    
    return achievements;
}

- (Achievement*) getAchievementWithID:(NSInteger)ID {
    Achievement* achievement = nil;
    FMResultSet* resultSet = [self.databaseController executeQueryWithFormat:@"SELECT * FROM achievements WHERE id = %d", ID, nil];
    
    while ([resultSet next]) {
        NSInteger ID = [resultSet intForColumn:@"id"];
        NSString* name = [resultSet stringForColumn:@"name"];
        NSString* description = [resultSet stringForColumn:@"description"];
        BOOL done = [resultSet boolForColumn:@"done"];
        NSInteger condition = [resultSet intForColumn:@"statistic_condition"];
        NSInteger statistic = [resultSet intForColumn:@"statistic_id"];
        
        achievement = [Achievement new];
        achievement.ID = ID;
        achievement.name = name;
        achievement.description = description;
        achievement.done = done;
        achievement.condition = condition;
        achievement.statistic = statistic;
    }
    
    return achievement;
}

- (void) increaseStatisticByOne:(NSInteger)statID {
    FMResultSet* resultSet = [self.databaseController executeQueryWithFormat:@"SELECT value FROM statistic WHERE id = %d", statID];
    
    while ([resultSet next]) {
        NSInteger value = [resultSet intForColumn:@"value"];
        value += 1;
        
        [self.databaseController executeUpdateWithFormat:@"UPDATE statistic SET value = %d WHERE id = %d", value, statID];
    }
}

- (void) increaseStatistic:(NSInteger)statID byValue:(NSInteger)value {
    FMResultSet* resultSet = [self.databaseController executeQueryWithFormat:@"SELECT value FROM statistic WHERE id = %d", statID];
    
    while ([resultSet next]) {
        NSInteger storedValue = [resultSet intForColumn:@"value"];
        storedValue += value;
        
        [self.databaseController executeUpdateWithFormat:@"UPDATE statistic SET value = %d WHERE id = %d", storedValue, statID];
    }
}

- (void) setStatistic:(NSInteger)statID byValue:(NSInteger)value {
    [self.databaseController executeUpdateWithFormat:@"UPDATE statistic SET value = %d WHERE id = %d", value, statID];
}

- (void) unlockAchievement:(Achievement*)achievement {
    // Actualizo el estado del logro a conseguido.
    [self.databaseController executeUpdateWithFormat:@"UPDATE achievements SET done =1 WHERE id = %d", achievement.ID];
    
    // Actualizo el valor de la estadística asociada si esta es 0 o menor al valor de statistics
    FMResultSet* resultSet = [self.databaseController executeQueryWithFormat:@"SELECT value FROM statistic WHERE id = %d", achievement.statistic];
    
    while ([resultSet next]) {
        NSInteger storedValue = [resultSet intForColumn:@"value"];
        
        if (storedValue == 0 || storedValue < achievement.condition) {
            [self.databaseController executeUpdateWithFormat:@"UPDATE statistic SET value = %d WHERE id = %d", achievement.condition, achievement.statistic];
        }
    }
}

- (NSArray*) getUnlockedAchievements {
    NSMutableArray* achievements = [[NSMutableArray alloc] init];
    
    FMResultSet* resultSet = [self.databaseController executeQueryWithFormat:@"SELECT achievements.id, achievements.name, achievements.description, achievements.done FROM achievements, statistic WHERE achievements.statistic_id = statistic.id AND statistic.value >= achievements.statistic_condition AND achievements.done = 0", nil];
    
    while ([resultSet next]) {
        NSInteger ID = [resultSet intForColumn:@"id"];
        NSString* name = [resultSet stringForColumn:@"name"];
        NSString* description = [resultSet stringForColumn:@"description"];
        BOOL done = [resultSet boolForColumn:@"done"];
        
        Achievement* achievement = [Achievement new];
        achievement.ID = ID;
        achievement.name = name;
        achievement.description = description;
        achievement.done = done;
        
        [self.databaseController executeUpdateWithFormat:@"UPDATE achievements SET done = 1 WHERE id = %d", ID];
        
        [achievements addObject:achievement];
    }
    
    return achievements;
}

- (NSInteger) increaseScoreByValue:(NSInteger)value {
    NSInteger storedValue = 0;
    FMResultSet* resultSet = [self.databaseController executeQuery:@"SELECT score FROM config", nil];
    
    while ([resultSet next]) {
        storedValue = [resultSet intForColumn:@"score"];
        storedValue += value;
        
        [self.databaseController executeUpdateWithFormat:@"UPDATE config SET score = %d", storedValue];
    }
    
    return storedValue;
}

- (void) setScoreByValue:(NSInteger)value {
    [self.databaseController executeUpdateWithFormat:@"UPDATE config SET score = %d", value];
}

@end
