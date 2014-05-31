//
//  JiraFacade.m
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 23/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JiraFacade.h"

@implementation JiraFacade

@synthesize service = _service;
@synthesize asynchronousService = _asynchronousService;

- (id)init
{
    self = [super init];
    if (self) {
        self.service = [RESTservice new];
        self.asynchronousService = [AsynchronousRESTservice new];
    }
    return self;
}

- (NSString*) validateUser:(Config*) config {
    NSString* messageError = nil;
    NSString* requestURL = [NSString stringWithFormat:@"%@rest/api/2/user?username=%@", config.jiraURL, config.jiraUsername];
    NSDictionary* requestHeader = [self getAuthorizationHeader:config];
    
    Response* response = [self.service httpCallWithURL:requestURL andHeader:requestHeader andHttpMethod:@"GET"];
    
    if (response.responseCode == 200) {
        NSDictionary* jsonResponse = [response.responseMessage JSONValue];
        
        if (jsonResponse) {
            BOOL active = [[jsonResponse objectForKey:@"active"] boolValue];
            
            if (!active) {
                messageError = @"User inactive";
            }
        } else {
            messageError = @"Username or password are incorrect";
        }
    } else if (response.responseCode == 401) {
        messageError = @"Username or password are incorrect";
    } else if (response.responseCode == 404) {
        messageError = @"Invalid username";
    } else if (response.responseCode == -1) {
        messageError = response.responseMessage;
    } else {
        messageError = @"Unknow error";
    }
    
    return messageError;
}

- (BOOL) validatePermission:(Config*) config {
    BOOL valid = YES;
    NSString* requestURL = [NSString stringWithFormat:@"%@rest/api/2/mypermissions", config.jiraURL];
    NSDictionary* requestHeader = [self getAuthorizationHeader:config];
    
    Response* response = [self.service httpCallWithURL:requestURL andHeader:requestHeader andHttpMethod:@"GET"];
    
    if (response.responseCode == 200) {
        valid = [self parsePermissionResponseJSON:response.responseMessage withConfig:config];
    } else {
        valid = NO;
    }
    
    return valid;
}

- (Issue*) getIssueDetails:(Issue*)issue withConfig:(Config*)config {
    Issue* result = issue;
    
    NSString* requestURL = [NSString stringWithFormat:@"%@rest/api/2/issue/%@?fields=key,summary,watches,status,priority,assignee,comment,issuetype,project,created,description", config.jiraURL, issue.issueID];
    NSDictionary* requestHeader = [self getAuthorizationHeader:config];
    
    Response* response = [self.service httpCallWithURL:requestURL andHeader:requestHeader andHttpMethod:@"GET"];
    
    if (response.responseCode == 200) {
        result = [self parseIssueDetailsResponseJSON:response.responseMessage withConfig:config];
    } else {
        result = nil;
    }
    
    return result;
}

- (void) getIssueListOfType:(NSInteger)type startingFrom:(NSInteger)startFrom withConfig:(Config*)config andDelegateIn:(id<NSURLConnectionDelegate,NSURLConnectionDataDelegate>)delegate {
    
    NSMutableString* jql = nil;
    
    if (type == ASSIGNED_TASK) {
        jql = [NSMutableString stringWithFormat:@"assignee=%@+ORDER+BY+createdDate+DESC", config.jiraUsername];
    } else if (type == OPEN_TASK) {
        jql = [NSMutableString stringWithString:@"status=Open+OR+status=\'In+Progress\'+OR+status=Reopened+ORDER+BY+createdDate+DESC"];        
    } else if (type == CLOSED_TASK) {
        jql = [NSMutableString stringWithString:@"status=Closed+OR+status=Resolved+ORDER+BY+createdDate+DESC"];       
    } else if (type == WHATCHING_TASK) {
        jql = [NSMutableString stringWithFormat:@"watcher=%@+ORDER+BY+createdDate+DESC", config.jiraUsername];        
    }

    [jql appendString:@"&fields=key,summary,watches,status,priority,assignee"];
    
    NSString* requestURL = [NSString stringWithFormat:@"%@rest/api/2/search?jql=%@&startAt=%d&maxResults=%d", config.jiraURL, jql, startFrom, ELEMENT_PER_PAGE];
    NSDictionary* requestHeader = [self getAuthorizationHeader:config];
    
    [self.asynchronousService httpCallWithURL:requestURL andHeader:requestHeader andDelegateIn:delegate];
}

- (NSArray*) searchIssueWithData:(NSString*)data ofType:(NSInteger)dataType inSection:(NSInteger)section andConfig:(Config*)config {
    NSArray* result = [[NSArray alloc] init];
    
    NSMutableString* jql = nil;
    
    if (dataType == ISSUE_KEY_TYPE) {
        jql = [NSMutableString stringWithFormat:@"issuekey=\'%@\'+AND+", [data stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    } else if (dataType == SUMMARY_TYPE) {
        jql = [NSMutableString stringWithFormat:@"summary~\'%@\'+AND+", [data stringByReplacingOccurrencesOfString:@" " withString:@"+"]];        
    }
    
    if (section == ASSIGNED_TASK) {
        [jql appendFormat:@"assignee=%@+ORDER+BY+createdDate+DESC", config.jiraUsername];
    } else if (section == OPEN_TASK) {
        [jql appendFormat:@"(status=Open+OR+status=\'In+Progress\'+OR+status=Reopened)+ORDER+BY+createdDate+DESC"];        
    } else if (section == CLOSED_TASK) {
        [jql appendFormat:@"(status=Closed+OR+status=Resolved)+ORDER+BY+createdDate+DESC"];       
    } else if (section == WHATCHING_TASK) {
        [jql appendFormat:@"watcher=%@+ORDER+BY+createdDate+DESC", config.jiraUsername];        
    }
    
    [jql appendString:@"&fields=key,summary,watches,status,priority,assignee"];
    
    NSString* requestURL = [NSString stringWithFormat:@"%@rest/api/2/search?jql=%@", config.jiraURL, jql];
    NSDictionary* requestHeader = [self getAuthorizationHeader:config];
    
    Response* response = [self.service httpCallWithURL:requestURL andHeader:requestHeader andHttpMethod:@"GET"];
    
    if (response.responseCode == 200) {
        result = [self parseIssueResponseJSON:response.responseMessage withConfig:config];
    }
    
    return result;
}

- (Issue*) watchUnwatchIssue:(Issue*)issue withConfig:(Config*)config {
    Issue* returnedIssue = nil;
    Response* response = nil;
    
    if (issue.isWatching) {
        NSString* requestURL = [NSString stringWithFormat:@"%@rest/api/2/issue/%@/watchers?username=%@", config.jiraURL, issue.issueID, config.jiraUsername];
        NSDictionary* requestHeader = [self getAuthorizationHeader:config];
        
        response = [self.service httpCallWithURL:requestURL andHeader:requestHeader andHttpMethod:@"DELETE"];
    } else {
        NSString* requestURL = [NSString stringWithFormat:@"%@rest/api/2/issue/%@/watchers", config.jiraURL, issue.issueID];
        NSDictionary* requestHeader = [self getAuthorizationHeader:config];
        
        response = [self.service httpCallWithURL:requestURL andHeader:requestHeader andBody:[NSString stringWithFormat:@"\"%@\"", config.jiraUsername] andHttpMethod:@"POST"];
    }
    
    if (response.responseCode == 204) {
        returnedIssue = issue;
        returnedIssue.isWatching = !issue.isWatching;
    }
    
    return returnedIssue;
}

- (Issue*) finishOrAssignIssue:(Issue*)issue withConfig:(Config*)config {
    Issue* returnedIssue = nil;
    Response* response = nil;
    
    if (issue.isAssignedToMe) {
        NSString* requestURL = [NSString stringWithFormat:@"%@rest/api/2/issue/%@/transitions", config.jiraURL, issue.issueID];
        NSDictionary* requestHeader = [self getAuthorizationHeader:config];
        
        NSDictionary* requestBody = [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:@"5", @"id", nil], @"transition", nil];
        NSString* jsonBody = [requestBody JSONRepresentation];
        
        response = [self.service httpCallWithURL:requestURL andHeader:requestHeader andBody:jsonBody andHttpMethod:@"POST"];
    } else {
        NSString* requestURL = [NSString stringWithFormat:@"%@rest/api/2/issue/%@/assignee", config.jiraURL, issue.issueID];
        NSDictionary* requestHeader = [self getAuthorizationHeader:config];
        NSDictionary* requestBody = [NSDictionary dictionaryWithObjectsAndKeys:config.jiraUsername, @"name", nil];
        NSString* jsonBody = [requestBody JSONRepresentation];
        
        response = [self.service httpCallWithURL:requestURL andHeader:requestHeader andBody:jsonBody andHttpMethod:@"PUT"];
    }
    
    if (response.responseCode == 204) {
        returnedIssue = issue;
        
        if (issue.isAssignedToMe) {
            returnedIssue.isClosed = !issue.isClosed;
        } else {
            returnedIssue.isAssignedToMe = !issue.isAssignedToMe;
            returnedIssue.isClosed = NO;
        }
    }
    
    return returnedIssue;
}

- (BOOL) addHouseToIssue:(Issue*)issue withConfig:(Config*)config {
    return NO;
}

- (Issue*) startStopIssueProgress:(Issue*)issue withConfig:(Config*)config {
    Issue* returnedIssue = nil;
    Response* response = nil;
    NSString* transitionID = nil;
    
    if (issue.isStarted) {
        transitionID = @"301";
    } else {
        transitionID = @"4";
    }
    
    NSString* requestURL = [NSString stringWithFormat:@"%@rest/api/2/issue/%@/transitions", config.jiraURL, issue.issueID];
    NSDictionary* requestHeader = [self getAuthorizationHeader:config];
    
    NSDictionary* requestBody = [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:transitionID, @"id", nil], @"transition", nil];
    NSString* jsonBody = [requestBody JSONRepresentation];
    
    response = [self.service httpCallWithURL:requestURL andHeader:requestHeader andBody:jsonBody andHttpMethod:@"POST"];
    
    if (response.responseCode == 204) {
        returnedIssue = issue;
        returnedIssue.isStarted = !issue.isStarted;
    }
    
    return returnedIssue;
}

- (Issue*) addComment:(Comment*)comment toIssue:(Issue*)issue withConfig:(Config*)config {
    Issue* returnedIssue = nil;
    Response* response = nil;
    
    NSString* requestURL = [NSString stringWithFormat:@"%@rest/api/2/issue/%@/comment", config.jiraURL, issue.issueID];
    NSDictionary* requestHeader = [self getAuthorizationHeader:config];
    
    NSDictionary* requestBody = [NSDictionary dictionaryWithObjectsAndKeys:comment.body, @"body", nil];
    NSString* jsonBody = [requestBody JSONRepresentation];
    
    response = [self.service httpCallWithURL:requestURL andHeader:requestHeader andBody:jsonBody andHttpMethod:@"POST"];
    
    if (response.responseCode == 201) {
        returnedIssue = issue;
    }
    
    return returnedIssue;
}

- (NSDictionary*) getAuthorizationHeader:(Config*)config {
    NSString* base64Credentials = [[[NSData alloc] initWithData:[[NSString stringWithFormat:@"%@:%@", config.jiraUsername, config.jiraPassword] dataUsingEncoding:NSUTF8StringEncoding]] base64EncodedString];
    NSString* basicAuthentication = [NSString stringWithFormat:@"Basic %@", base64Credentials];
    
    NSDictionary* requestHeader = [NSDictionary dictionaryWithObjectsAndKeys:basicAuthentication, @"Authorization", nil];
    
    return requestHeader;
}

- (NSArray*) parseIssueResponseJSON:(NSString*)json withConfig:(Config*)config {
    NSMutableArray* issueList = [[NSMutableArray alloc] init];
    
    NSDictionary* data = [json JSONValue];
    NSArray* issues = [data objectForKey:@"issues"];
    
    for (NSDictionary* issue in issues) {
        Issue* newIssue = [Issue new];
        newIssue.issueID = [issue objectForKey:@"key"];
        
        NSDictionary* fields = (NSDictionary*) [issue objectForKey:@"fields"];
        newIssue.summary = [fields objectForKey:@"summary"];
        newIssue.isWatching = [[(NSDictionary*) [fields objectForKey:@"watches"] objectForKey:@"isWatching"] boolValue];
        
        NSString* inProgress = [(NSDictionary*) [fields objectForKey:@"status"] objectForKey:@"name"];
        
        if ([inProgress isEqualToString:@"Open"] || [inProgress isEqualToString:@"Reopened"]) {
            newIssue.isClosed = NO;
            newIssue.isResolved = NO;
            newIssue.isStarted = NO;
        } else if ([inProgress isEqualToString:@"In Progress"]) {
            newIssue.isClosed = NO;
            newIssue.isResolved = NO;
            newIssue.isStarted = YES;
        } else if ([inProgress isEqualToString:@"Resolved"]) {
            newIssue.isClosed = NO;
            newIssue.isResolved = YES;
            newIssue.isStarted = NO;
        } else if ([inProgress isEqualToString:@"Closed"]) {
            newIssue.isClosed = YES;
            newIssue.isResolved = NO;
            newIssue.isStarted = NO;
        }
        
        newIssue.priority = [(NSDictionary*) [fields objectForKey:@"priority"] objectForKey:@"name"];
        
        NSString* assigneeUsername = [(NSDictionary*) [fields objectForKey:@"assignee"] objectForKey:@"name"];
        
        if ([assigneeUsername isEqualToString:config.jiraUsername]) {
            newIssue.isAssignedToMe = YES;
        } else {
            newIssue.isAssignedToMe = NO;
        }
        
        [issueList addObject:newIssue];
    }
    
    return issueList;
}

- (BOOL) parsePermissionResponseJSON:(NSString*)json withConfig:(Config*)config {
    BOOL valid = YES;

    NSDictionary* permissions = [[json JSONValue] objectForKey:@"permissions"];
    
    if (valid) {
        valid = [[(NSDictionary*) [permissions objectForKey:@"ASSIGNABLE_USER"] objectForKey:@"havePermission"] boolValue];
    }

    if (valid) {
        valid = [[(NSDictionary*) [permissions objectForKey:@"BROWSE"] objectForKey:@"havePermission"] boolValue];
    }
    
    if (valid) {
        valid = [[(NSDictionary*) [permissions objectForKey:@"CLOSE_ISSUE"] objectForKey:@"havePermission"] boolValue];
    }
    
    if (valid) {
        valid = [[(NSDictionary*) [permissions objectForKey:@"COMMENT_ISSUE"] objectForKey:@"havePermission"] boolValue];
    }
    
    if (valid) {
        valid = [[(NSDictionary*) [permissions objectForKey:@"EDIT_ISSUE"] objectForKey:@"havePermission"] boolValue];
    }
    
    if (valid) {
        valid = [[(NSDictionary*) [permissions objectForKey:@"RESOLVE_ISSUE"] objectForKey:@"havePermission"] boolValue];
    }
    
    if (valid) {
        valid = [[(NSDictionary*) [permissions objectForKey:@"USE"] objectForKey:@"havePermission"] boolValue];
    }
    
    return valid;
}

- (Issue*) parseIssueDetailsResponseJSON:(NSString*)json withConfig:(Config*)config {
    Issue* newIssue = [Issue new];
    
    NSDictionary* parsedJSON = [json JSONValue];
    NSDictionary* fields = (NSDictionary*) [parsedJSON objectForKey:@"fields"];
    newIssue.summary = [self getString:[fields objectForKey:@"summary"]];
    newIssue.isWatching = [[[fields objectForKey:@"watches"] objectForKey:@"isWatching"] boolValue];
    newIssue.issueID = [self getString:[parsedJSON objectForKey:@"key"]];
    newIssue.status = [self getString:[[fields objectForKey:@"status"] objectForKey:@"name"]];
    
    if ([newIssue.status isEqualToString:@"Open"] || [newIssue.status isEqualToString:@"Reopened"]) {
        newIssue.isClosed = NO;
        newIssue.isResolved = NO;
        newIssue.isStarted = NO;
    } else if ([newIssue.status isEqualToString:@"In Progress"]) {
        newIssue.isClosed = NO;
        newIssue.isResolved = NO;
        newIssue.isStarted = YES;
    } else if ([newIssue.status isEqualToString:@"Resolved"]) {
        newIssue.isClosed = NO;
        newIssue.isResolved = YES;
        newIssue.isStarted = NO;
    } else if ([newIssue.status isEqualToString:@"Closed"]) {
        newIssue.isClosed = YES;
        newIssue.isResolved = NO;
        newIssue.isStarted = NO;
    }
    
    newIssue.priority = [self getString:[(NSDictionary*) [fields objectForKey:@"priority"] objectForKey:@"name"]];
    
    NSString* assigneeUsername = [(NSDictionary*) [fields objectForKey:@"assignee"] objectForKey:@"name"];
    newIssue.assignedUser = [self getString:[(NSDictionary*) [fields objectForKey:@"assignee"] objectForKey:@"displayName"]];
    
    if ([assigneeUsername isEqualToString:config.jiraUsername]) {
        newIssue.isAssignedToMe = YES;
    } else {
        newIssue.isAssignedToMe = NO;
    }                  
    
    NSArray* comments = [[fields objectForKey:@"comment"] objectForKey:@"comments"];
    NSMutableArray* issueComments = [[NSMutableArray alloc] init];
    
    for (NSDictionary* comment in comments) {
        Comment* newComment = [Comment new];
        newComment.author = [self getString:[[comment objectForKey:@"author"] objectForKey:@"displayName"]];
        newComment.body = [self getString:[comment objectForKey:@"body"]];
        newComment.username = [self getString:[[comment objectForKey:@"author"] objectForKey:@"name"]];
        
        [issueComments addObject:newComment];
    }
    
    newIssue.comments = issueComments;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    
    newIssue.created = [dateFormatter dateFromString:[fields objectForKey:@"created"]];
    [dateFormatter release];
    
    newIssue.description = [self getString:[fields objectForKey:@"description"]];
    newIssue.issueType = [self getString:[[fields objectForKey:@"issuetype"] objectForKey:@"name"]];
    newIssue.project = [self getString:[[fields objectForKey:@"project"] objectForKey:@"name"]];
    
    return newIssue;
}

- (NSString*) getString:(id)string {
    NSString* cadena = @"";
    
    if ([string isKindOfClass:[NSString class]]) {
        NSString* temp = [NSString stringWithString:string];
        
        if (temp && temp.length > 0) {
            cadena = temp;
        }
    }
    
    return cadena;
}

- (void)dealloc
{
    [self.service release];
    self.service = nil;
    [self.asynchronousService release];
    self.asynchronousService = nil;
    [super dealloc];
}

@end
