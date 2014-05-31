//
//  Issue.m
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 28/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Issue.h"

NSInteger const ASSIGNED_TASK = 0;
NSInteger const OPEN_TASK = 1;
NSInteger const CLOSED_TASK = 2;
NSInteger const WHATCHING_TASK = 3;
NSInteger const ISSUE_KEY_TYPE = 1;
NSInteger const SUMMARY_TYPE = 0;
NSInteger const ELEMENT_PER_PAGE = 15;
NSInteger const WATCH_UNWATCH_ACTION = 0;
NSInteger const FINISH_ISSUE_ACTION = 1;
NSInteger const ADD_HOURS_ACTION = 2;
NSInteger const START_STOP_ACTION = 3;
NSInteger const COMMENT_ACTION = 4;

@implementation Issue

@synthesize issueID;
@synthesize summary;
@synthesize isWatching;
@synthesize isStarted;
@synthesize isClosed;
@synthesize isResolved;
@synthesize isAssignedToMe;
@synthesize priority;
@synthesize comments;
@synthesize created;
@synthesize description;
@synthesize issueType;
@synthesize project;
@synthesize status;
@synthesize assignedUser;

@end
