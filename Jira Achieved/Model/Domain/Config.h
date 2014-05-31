//
//  Config.h
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 18/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Config : NSObject

@property (nonatomic) NSInteger ID;
@property (retain, nonatomic) NSString* jiraUsername;
@property (retain, nonatomic) NSString* jiraPassword;
@property (retain, nonatomic) NSString* jiraURL;
@property (assign, nonatomic) NSInteger score;

@end
