//
//  AsynchronousRESTservice.m
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 27/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AsynchronousRESTservice.h"

@implementation AsynchronousRESTservice

- (void)httpCallWithURL:(NSString*)url andDelegateIn:(id<NSURLConnectionDelegate,NSURLConnectionDataDelegate>)delegate {
    [self httpCallWithURL:url andHeader:nil andBody:nil andDelegateIn:delegate];
}

- (void)httpCallWithURL:(NSString*)url andHeader:(NSDictionary*)header andDelegateIn:(id<NSURLConnectionDelegate,NSURLConnectionDataDelegate>)delegate {
    [self httpCallWithURL:url andHeader:header andBody:nil andDelegateIn:delegate];
}

- (void)httpCallWithURL:(NSString*)url andBody:(NSString*)body andDelegateIn:(id<NSURLConnectionDelegate,NSURLConnectionDataDelegate>)delegate {
    [self httpCallWithURL:url andHeader:nil andBody:body andDelegateIn:delegate];
}

- (void)httpCallWithURL:(NSString*)url andHeader:(NSDictionary*)header andBody:(NSString*)body andDelegateIn:(id<NSURLConnectionDelegate,NSURLConnectionDataDelegate>)delegate {
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    
    if (body) {
        request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    if (header) {
        for (NSString* headerKey in header) {
            [request addValue:[header objectForKey:headerKey] forHTTPHeaderField:headerKey];
        }
    }
    
    [NSURLConnection connectionWithRequest:request delegate:delegate];
}

@end
