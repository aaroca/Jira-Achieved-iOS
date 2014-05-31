//
//  ConfigDAO.h
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 18/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GenericDAO.h"
#import "Config.h"

@interface ConfigDAO : GenericDAO

-(Config*) getConfig;
-(void) createConfig:(Config*)config;
-(void) updateConfig:(Config*)config;

@end
