//
//  Response.h
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 23/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * Modelado de una respuesta del servicio REST o HTTP invocado.
 */
@interface Response : NSObject
    
@property (assign, nonatomic) NSInteger responseCode;
@property (retain, nonatomic) NSString* responseMessage;

@end
