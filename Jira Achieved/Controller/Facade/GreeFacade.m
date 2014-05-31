//
//  GreeFacade.m
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 23/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GreeFacade.h"
#import "ProfileViewController.h"

@implementation GreeFacade

static bool updatingScore;
static bool updatingAchievements;
static bool updatingError;
static GreeNotificationQueue* queue;

- (id)init
{
    self = [super init];
    if (self) {
        if (!queue) {
            queue = [[GreeNotificationQueue alloc] initWithSettings:nil];
            queue.displayPosition = GreeNotificationDisplayBottomPosition;
        }
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        loginStateConfigFile = [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0], @"greeLoginConfig.tmp"];
    }
    return self;
}

- (void)saveLoginConfigState:(BOOL)login {
    NSFileManager* fm = [NSFileManager defaultManager];
    
    if (login && ![fm fileExistsAtPath:loginStateConfigFile]) {
        [fm createFileAtPath:loginStateConfigFile contents:nil attributes:nil];
    } else if (!login && [fm fileExistsAtPath:loginStateConfigFile]) {
        NSError* error = nil;
        [fm removeItemAtPath:loginStateConfigFile error:&error];
    }
}

- (BOOL)isLoginConfg {
    NSFileManager* fm = [NSFileManager defaultManager];
    
    return [fm fileExistsAtPath:loginStateConfigFile];
}

- (void) increaseStatisticByOne:(NSInteger)statID {
    [[AchievementsDAO new] increaseStatisticByOne:statID];
}

- (void) increaseStatistic:(NSInteger)statID byValue:(NSInteger)value {
    [[AchievementsDAO new] increaseStatistic:statID byValue:value];
}

- (void) setStatistic:(NSInteger)statID byValue:(NSInteger)value {
    [[AchievementsDAO new] setStatistic:statID byValue:value];
}

- (NSArray*) getUnlockedAchievements {
    return [[AchievementsDAO new] getUnlockedAchievements];
}

- (void) uploadToGreeUnlockedAchievements:(NSArray*)achievements {
    for (Achievement* achievement in achievements) {
        GreeAchievement* greeAchievement = [[GreeAchievement alloc] initWithIdentifier:[NSString stringWithFormat:@"%d", achievement.ID]];
        [greeAchievement unlockWithBlock:^(void) {
            
        }];
    }
}

- (void) uploadToGreeScore:(NSInteger)newScore {
    GreeScore* score = [[GreeScore alloc] initWithLeaderboard:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"GreeLeaderboardID"] score:newScore];
    [score submitWithBlock:^(void) {
        
    }];
    [score release];
}

- (void) showUnlockedAchievements {
    NSArray* unlockedAchievements = [self getUnlockedAchievements];

    if (unlockedAchievements.count > 0) {
        for (Achievement* achievement in unlockedAchievements) {
            GreeNotification* notificacion = [[GreeNotification alloc] initWithMessage:[NSString stringWithFormat:@"Unlocked: %@",achievement.name] displayType:GreeNotificationViewDisplayCloseType duration:2.0f];
            [queue addNotification:notificacion];
        }
        
        // Subimos los nuevos logros a Gree si está configurado.
        if ([self isLoginConfg]) {
            [self uploadToGreeUnlockedAchievements:unlockedAchievements];
        }
    }
}

- (void) increaseScoreByValue:(NSInteger)value {
    NSInteger storeValue = [[AchievementsDAO new] increaseScoreByValue:value];
    
    // Subimos a gree la nueva puntuación si está configurado.
    if ([self isLoginConfg]) {
        [self uploadToGreeScore:storeValue];
    }
}

- (void) synchronizeDataWithGreeFromView:(ProfileViewController*)viewController {
    AchievementsDAO* dao = [AchievementsDAO new];
    
    // Sincronizamos primero las puntuaciones.
    // Mantendremos el valor más algo, si es el de Gree actualizaremos el local.
    // Si es el local, actualizaremos el de Gre.
    [GreeScore loadMyScoreForLeaderboard:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"GreeLeaderboardID"] timePeriod:GreeScoreTimePeriodAlltime block:^(GreeScore *score, NSError *error) {
        updatingScore = YES;
        updatingError = NO;
        
        if (!error) {
            NSInteger greeScore = score.score;
            NSInteger storeValue = [[AchievementsDAO new] increaseScoreByValue:0];
            
            if (greeScore > storeValue) {
                [dao setScoreByValue:greeScore];
            } else if (greeScore < storeValue) {
                [self uploadToGreeScore:storeValue];
            }
        } else {
            updatingError = YES;
        }
        
        updatingScore = NO;
        
        if (![GreeFacade isUpdating] && viewController) {
            [viewController doneLoadingTableViewData];
        }
    }];
    
    // Actualizamos los logros.
    // Si un logro está desbloqueado en uno de los dos lados, local o Gree,
    // pero no en el otro, se desbloqueará en los dos.
    [GreeAchievement loadAchievementsWithBlock:^(NSArray *achievements, NSError *error) {
        updatingAchievements = YES;
        updatingError = NO;
        
        if (!error) {
            NSArray* greeAchievements = achievements;
            
            for (GreeAchievement* greeAchievement in greeAchievements) {
                Achievement* localAchievement = [dao getAchievementWithID:greeAchievement.identifier.integerValue];
                
                if (localAchievement.done && !greeAchievement.isUnlocked) {
                    [greeAchievement unlockWithBlock:^(void) { }];
                } else if (!localAchievement.done && greeAchievement.isUnlocked) {
                    // En este caso se reiniciará el valor del campo de la estadística
                    // asociada al logro por el valor requerido por dicho logro si no
                    // existía ya uno registrado o es menor el que ya existía.
                    [dao unlockAchievement:localAchievement];
                }
            }
        } else {
            updatingError = YES;
        }
        
        updatingAchievements = NO;
        
        if (![GreeFacade isUpdating] && viewController) {
            [viewController doneLoadingTableViewData];
        }
    }];
}

+ (BOOL) isUpdating {
    BOOL updating = NO;
    
    if (!updating) {
        updating = updatingScore;
    }
    
    if (!updating) {
        updating = updatingAchievements;
    }
    
    return updating;
}

+ (BOOL) isUpdatingError {
    return updatingError;
}

@end
