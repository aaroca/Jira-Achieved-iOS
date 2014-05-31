//
//  CustomAppearance.m
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 21/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomAppearance.h"

@implementation CustomAppearance

+ (void)customAppearance {
    // Personalizamos barra de navegación.
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigationBar.png"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0 green:0.341 blue:0.694 alpha:1] /*#0057b1*/];
    
    // Personalizamos barra de búsqueda.
    [[UISearchBar appearance] setTintColor:[UIColor colorWithRed:0 green:0.341 blue:0.694 alpha:1] /*#0057b1*/];
    
    // Personalizamos barra de herramientas.
    [[UIToolbar appearance] setTintColor:[UIColor colorWithRed:0 green:0.341 blue:0.694 alpha:1] /*#0057b1*/];
}

@end
