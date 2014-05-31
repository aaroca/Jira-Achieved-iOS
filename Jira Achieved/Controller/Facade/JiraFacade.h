//
//  JiraFacade.h
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 23/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Config.h"
#import "NSData+Base64.h"
#import "RESTservice.h"
#import "AsynchronousRESTservice.h"
#import "Response.h"
#import "NSObject+SBJson.h"
#import "Issue.h"
#import "Comment.h"

@interface JiraFacade : NSObject

@property (retain, nonatomic) RESTservice* service;
@property (retain, nonatomic) AsynchronousRESTservice* asynchronousService;

/**
 * Valida el usuario contra el servidor JIRA y comprueba
 * si está activo.
 * Devuelve un mensaje de error o nil en caso de que
 * todo esté correcto.
 */
- (NSString*) validateUser:(Config*) config;
- (BOOL) validatePermission:(Config*) config;

- (Issue*) getIssueDetails:(Issue*)issue withConfig:(Config*)config;
- (void) getIssueListOfType:(NSInteger)type startingFrom:(NSInteger)startFrom withConfig:(Config*)config andDelegateIn:(id<NSURLConnectionDelegate,NSURLConnectionDataDelegate>)delegate;
- (NSArray*) searchIssueWithData:(NSString*)data ofType:(NSInteger)dataType inSection:(NSInteger)section andConfig:(Config*)config;

- (NSArray*) parseIssueResponseJSON:(NSString*)json withConfig:(Config*)config;
- (BOOL) parsePermissionResponseJSON:(NSString*)json withConfig:(Config*)config;
- (Issue*) parseIssueDetailsResponseJSON:(NSString*)json withConfig:(Config*)config;

- (Issue*) watchUnwatchIssue:(Issue*)issue withConfig:(Config*)config;
- (Issue*) finishOrAssignIssue:(Issue*)issue withConfig:(Config*)config;
- (BOOL) addHouseToIssue:(Issue*)issue withConfig:(Config*)config;
- (Issue*) startStopIssueProgress:(Issue*)issue withConfig:(Config*)config;
- (Issue*) addComment:(Comment*)comment toIssue:(Issue*)issue withConfig:(Config*)config;

@end
