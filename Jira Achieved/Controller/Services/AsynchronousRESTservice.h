//
//  AsynchronousRESTservice.h
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 27/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AsynchronousRESTservice : NSObject

- (void)httpCallWithURL:(NSString*)url andDelegateIn:(id<NSURLConnectionDelegate,NSURLConnectionDataDelegate>)delegate;
- (void)httpCallWithURL:(NSString*)url andHeader:(NSDictionary*)header andDelegateIn:(id<NSURLConnectionDelegate,NSURLConnectionDataDelegate>)delegate;
- (void)httpCallWithURL:(NSString*)url andBody:(NSString*)body andDelegateIn:(id<NSURLConnectionDelegate,NSURLConnectionDataDelegate>)delegate;
- (void)httpCallWithURL:(NSString*)url andHeader:(NSDictionary*)header andBody:(NSString*)body andDelegateIn:(id<NSURLConnectionDelegate,NSURLConnectionDataDelegate>)delegate;

@end
