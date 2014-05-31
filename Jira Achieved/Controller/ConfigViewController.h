//
//  WizardJiraViewController.h
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 22/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Config.h"
#import "ConfigDAO.h"
#import "ELCTextfieldCell.h"
#import "CMPopTipView.h"
#import "JiraFacade.h"
#import "MBProgressHUD.h"
#import "UIViewController+GreePlatform.h"
#import "GreePlatform.h"
#import "AcknowledgmentsViewController.h"
#import "GreeFacade.h"

@interface ConfigViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, ELCTextFieldDelegate, MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
    BOOL created;
}

@property(retain,nonatomic) Config* appConfig;
@property(retain,nonatomic) ConfigDAO* configDAO;

@property(retain,nonatomic) NSArray* jiraCredentialsFields;
@property(retain,nonatomic) NSArray* jiraCredentialsFieldsPlaceholder;

@property(retain,nonatomic) NSArray* jiraUrlFields;
@property(retain,nonatomic) NSArray* jiraUrlFieldsPlaceholder;

@property(retain,nonatomic) UITextField* jiraUsernameField;
@property(retain,nonatomic) UITextField* jiraPasswrodField;
@property(retain,nonatomic) UITextField* jiraUrlField;

@property (retain, nonatomic) IBOutlet UITableView *formTable;
@property (retain, nonatomic) IBOutlet UIButton *greeButton;
@property (retain, nonatomic) IBOutlet UIButton *acknowledgmentsButton;
@property(nonatomic) CGRect formOriginalFrame;

- (IBAction)signInOrSignUp:(id)sender;
- (IBAction)showAcknowledgments:(id)sender;

@end
