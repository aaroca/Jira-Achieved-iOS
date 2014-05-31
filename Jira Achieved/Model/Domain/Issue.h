//
//  Issue.h
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 28/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Comment.h"

extern NSInteger const ASSIGNED_TASK;
extern NSInteger const OPEN_TASK;
extern NSInteger const CLOSED_TASK;
extern NSInteger const WHATCHING_TASK;
extern NSInteger const ISSUE_KEY_TYPE;
extern NSInteger const SUMMARY_TYPE;
extern NSInteger const ELEMENT_PER_PAGE;
extern NSInteger const WATCH_UNWATCH_ACTION;
extern NSInteger const FINISH_ISSUE_ACTION;
extern NSInteger const ADD_HOURS_ACTION;
extern NSInteger const START_STOP_ACTION;
extern NSInteger const COMMENT_ACTION;

@interface Issue : NSObject

@property (retain, nonatomic) NSString* issueID;
@property (retain, nonatomic) NSString* summary;
@property (assign, nonatomic) BOOL isWatching;
@property (assign, nonatomic) BOOL isStarted;
@property (assign, nonatomic) BOOL isClosed;
@property (assign, nonatomic) BOOL isResolved;
@property (assign, nonatomic) BOOL isAssignedToMe;
@property (assign, nonatomic) NSString* priority;
@property (retain, nonatomic) NSArray* comments;
@property (retain, nonatomic) NSDate* created;
@property (retain, nonatomic) NSString* description;
@property (retain, nonatomic) NSString* issueType;
@property (retain, nonatomic) NSString* project;
@property (retain, nonatomic) NSString* status;
@property (retain, nonatomic) NSString* assignedUser;

@end
