//
//  GenericDAO.m
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 18/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GenericDAO.h"

@implementation GenericDAO

@synthesize databaseController = _databaseController;
@synthesize dbPath = _dbPath;

-(id) init {
    if (self = [super init]) {
        [self createDBifNotExist];
        self.databaseController = [FMDatabase databaseWithPath:self.dbPath];
        
        if (![self.databaseController open]) {
            [self.databaseController release];
            self.databaseController = nil;
        }
    }

    return self;
}

-(void) createDBifNotExist {
    BOOL initialized = NO;
    
    // Obtenemos la ruta de la carpeta de documentos donde almacenaremos
    // la base de datos.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    // Almacenamos la ruta para utilizarla al para abrir/crear la base de datos.
    self.dbPath = [documentsPath stringByAppendingPathComponent:@"jiraachieved.sqlite"];
    
    // Ahora verificamos si el archivo existe o no. De esta forma comprobamos que la base de datos
    // inicial existe.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:self.dbPath]) {
        initialized = YES;
    }
    
    // Si no está inicializada, copiaremos la estructura desde la carpeta recursos
    if (!initialized) {
        // Obtenemos la ruta donde está almacenada la base de datos inicial
        // para su inicialización.
        NSString *initialDatabasePath = [[NSBundle mainBundle] pathForResource:@"jiraachieved" ofType:@"sqlite"];
        
        // Copiamos la base de datos inicial a la ruta donde debería de estar.
        [fileManager copyItemAtPath:initialDatabasePath toPath:self.dbPath error:nil];
    }
}

-(void) dealloc {
    [self.databaseController close];
    
    if (self.databaseController) {
        [self.databaseController release];
        self.databaseController = nil;
    }
    
    [self.dbPath release];
    self.dbPath = nil;
    
    [super dealloc];
}

@end
