//
//  RESTservice.m
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 23/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RESTservice.h"

@implementation RESTservice

- (Response*)httpCallWithURL:(NSString*)url andHttpMethod:(NSString*)method {
    return [self httpCallWithURL:url andHeader:nil andBody:nil andHttpMethod:method];
}

- (Response*)httpCallWithURL:(NSString*)url andHeader:(NSDictionary*)header andHttpMethod:(NSString*)method {
    return [self httpCallWithURL:url andHeader:header andBody:nil andHttpMethod:method];
}

- (Response*)httpCallWithURL:(NSString*)url andBody:(NSString*)body andHttpMethod:(NSString*)method{
    return [self httpCallWithURL:url andHeader:nil andBody:body andHttpMethod:method];
}

- (Response*)httpCallWithURL:(NSString*)url andHeader:(NSDictionary*)header andBody:(NSString*)body andHttpMethod:(NSString*)method {
    Response* response = [Response new];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    request.HTTPMethod = method;
    
    if (body) {
        [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
        request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    if (header) {
        for (NSString* headerKey in header) {
            [request addValue:[header objectForKey:headerKey] forHTTPHeaderField:headerKey];
        }
    }
    
    NSURLResponse* urlResponse = nil;
    NSError* error = nil;
    NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    
    if (!error) {
        response.responseCode = ((NSHTTPURLResponse*) urlResponse).statusCode;
        response.responseMessage = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    } else {
        response.responseCode = -1;
        response.responseMessage = [error localizedDescription];
    }
    
    return response;
}

@end
