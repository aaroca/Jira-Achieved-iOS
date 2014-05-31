//
//  RESTservice.h
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 23/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Response.h"

/*
 * Clase encargada de la comunicación con servicios REST.
 */
@interface RESTservice : NSObject

- (Response*)httpCallWithURL:(NSString*)url andHttpMethod:(NSString*)method;
- (Response*)httpCallWithURL:(NSString*)url andHeader:(NSDictionary*)header andHttpMethod:(NSString*)method;
- (Response*)httpCallWithURL:(NSString*)url andBody:(NSString*)body andHttpMethod:(NSString*)method;
- (Response*)httpCallWithURL:(NSString*)url andHeader:(NSDictionary*)header andBody:(NSString*)body andHttpMethod:(NSString*)method;

@end
