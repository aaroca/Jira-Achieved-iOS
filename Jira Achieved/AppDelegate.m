//
//  AppDelegate.m
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 18/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "MalcomLib.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize taskListViewController = _taskListViewController;

- (void)dealloc
{
    [_taskListViewController release];
    self.taskListViewController = nil;
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    // Inicializamos el SDK de Gree
    NSDictionary* settings =
    [NSDictionary dictionaryWithObjectsAndKeys:
     GreeDevelopmentModeProduction, GreeSettingDevelopmentMode, [NSNumber numberWithBool:YES], GreeSettingEnableGrade0, [NSNumber                                                                                                    numberWithInt:GreeNotificationDisplayTopPosition], GreeSettingNotificationPosition, nil];

    // [GreePlatform setConsumerProtectionWithScramble:@"codegeist@2012"];
    [GreePlatform initializeWithApplicationId:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"GreeApplicationID"]
                                  consumerKey:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"GreeConsumerKey"]
                               consumerSecret:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"GreeConsumerSecret"]
                                     settings:settings
                                     delegate:self];
    
    [GreePlatform handleLaunchOptions:launchOptions application:application];
    
    // Inicializamos el SDK de Malcom
    [MalcomLib initWithUUID:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"MalcomUUID"] andSecretKey:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"MalcomSecret"] withAdId:nil];
    
#if DISTRIBUTION
    [MalcomLib startNotifications:application withOptions:launchOptions isDevelopmentMode:NO];
#else
    [MalcomLib startNotifications:application withOptions:launchOptions isDevelopmentMode:YES];
#endif
    
    // Construímos la vista delantera y trasera de la lista de tareas.
    self.taskListViewController = [[TaskListViewController alloc] initWithNibName:@"TaskListView" bundle:nil];
    UINavigationController* taskListNavigationController = [[UINavigationController alloc] initWithRootViewController:self.taskListViewController];
    
    ECSlidingViewController* slideViewController = [ECSlidingViewController new];
    slideViewController.topViewController = taskListNavigationController;
    
    // Override point for customization after application launch.
    self.window.rootViewController = slideViewController;
    
    [MalcomLib loadConfiguration:slideViewController withDelegate:self withLabel:NO];
    [MalcomLib initAndStartBeacon:YES useOnlyWiFi:YES];
    
    // Personalizamos la interfaz.
    [CustomAppearance customAppearance];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inacive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [MalcomLib setAppActive:NO];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [MalcomLib endBeacon];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [MalcomLib initAndStartBeacon:YES useOnlyWiFi:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [MalcomLib initAndStartBeacon:YES useOnlyWiFi:YES];
    [MalcomLib setAppActive:YES];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [MalcomLib endBeacon];
    [GreePlatform shutdown];
}

//#indoc "GreePlatformDelegate#greePlatformWillShowModalView"
- (void)greePlatformWillShowModalView:(GreePlatform*)platform {
    
}

//#indoc "GreePlatformDelegate#greePlatformDidDismissModalView"
- (void)greePlatformDidDismissModalView:(GreePlatform*)platform {
    
}

//#indoc "GreePlatformDelegate#greePlatform:didLoginUser:"
- (void)greePlatform:(GreePlatform*)platform didLoginUser:(GreeUser*)localUser {
    // Creamos un fichero para indicar que el login está configurado y debe autenticarse
    // cada vez que iniciemos la aplicación.
    GreeFacade* facade = [GreeFacade new];
    BOOL previouslyLogin = [facade isLoginConfg];
    [facade saveLoginConfigState:YES];
    [facade increaseStatisticByOne:3];
    [facade showUnlockedAchievements];
    
    if (!previouslyLogin) {
        [facade synchronizeDataWithGreeFromView:nil];
    }
}

//#indoc "GreePlatformDelegate#greePlatform:didLogoutUser:"
- (void)greePlatform:(GreePlatform*)platform didLogoutUser:(GreeUser*)localUser {
    // Eliminamos el fichero que indica que el login está configurado ya que hemos
    // hecho log out.
    GreeFacade* facade = [GreeFacade new];
    [facade saveLoginConfigState:NO];
}

//#indoc "GreePlatformDelegate#greePlatformParamsReceived"
- (void)greePlatformParamsReceived:(NSDictionary*)params {
    
}

-(BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)url {
    return [GreePlatform handleOpenURL:url application:application];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [MalcomLib didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    [GreePlatform postDeviceToken:deviceToken block:^(NSError * error) {
        if (error) {
            NSLog(@"Error uploading User Token:%@", error);
        }
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Error registering for remote notifications:%@", error);
    [MalcomLib didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [MalcomLib didReceiveRemoteNotification:userInfo active:[MalcomLib getAppActive]];
    [GreePlatform handleRemoteNotification:userInfo application:application];
}

@end
