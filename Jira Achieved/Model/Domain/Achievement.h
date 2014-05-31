//
//  Achievement.h
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 01/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Achievement : NSObject

@property (assign, nonatomic) NSInteger ID;
@property (retain, nonatomic) NSString* name;
@property (retain, nonatomic) NSString* description;
@property (assign, nonatomic) BOOL done;
@property (assign, nonatomic) NSInteger condition;
@property (assign, nonatomic) NSInteger statistic;

@end
