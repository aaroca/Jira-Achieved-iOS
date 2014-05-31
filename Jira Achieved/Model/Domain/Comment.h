//
//  Comment.h
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 01/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject

@property (retain, nonatomic) NSString* author;
@property (retain, nonatomic) NSString* body;
@property (retain, nonatomic) NSString* username;

@end
