//
//  GenericDAO.h
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 18/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface GenericDAO : NSObject

@property (retain, nonatomic) FMDatabase* databaseController;
@property (retain, nonatomic) NSString* dbPath;

@end
