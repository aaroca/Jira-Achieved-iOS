//
//  ConfigDAO.m
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 18/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConfigDAO.h"

@implementation ConfigDAO

-(id) init {
    if (self = [super init]) {

    }
    
    return self;
}

-(Config*) getConfig {
    Config* returnedConfig = nil;
    FMResultSet* resultSet = [self.databaseController executeQuery:@"SELECT * FROM config", nil];
    
    while ([resultSet next]) {
        NSInteger ID = [resultSet intForColumn:@"id"];
        NSString* jiraUsername = [resultSet stringForColumn:@"jira_username"];
        NSString* jiraPassword = [resultSet stringForColumn:@"jira_password"];
        NSString* jiraURL = [resultSet stringForColumn:@"jira_url"];
        NSInteger score = [resultSet intForColumn:@"score"];
        
        returnedConfig = [Config new];
        returnedConfig.ID = ID;
        returnedConfig.jiraUsername = jiraUsername;
        returnedConfig.jiraPassword = jiraPassword;
        returnedConfig.jiraURL = jiraURL;
        returnedConfig.score = score;
    }
    
    return returnedConfig;
}

-(void) createConfig:(Config*)config {
    [self.databaseController executeUpdateWithFormat:@"INSERT INTO config(jira_username, jira_password, jira_url) VALUES (%@, %@, %@)", config.jiraUsername, config.jiraPassword, config.jiraURL];
}

-(void) updateConfig:(Config*)config {
    [self.databaseController executeUpdateWithFormat:@"UPDATE config SET jira_username = %@, jira_password = %@, jira_url = %@, score = %d WHERE id = %d", config.jiraUsername, config.jiraPassword, config.jiraURL, config.ID, config.score];
}

@end
