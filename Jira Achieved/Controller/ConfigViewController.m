//
//  WizardJiraViewController.m
//  Jira Achieved
//
//  Created by Álvaro Aroca Muñoz on 22/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConfigViewController.h"
#import "MalcomLib.h"

@interface ConfigViewController ()

@end

@implementation ConfigViewController

@synthesize appConfig = _appConfig;
@synthesize configDAO = _configDAO;
@synthesize jiraCredentialsFields = _jiraCredentialsFields;
@synthesize jiraCredentialsFieldsPlaceholder = _jiraCredentialsFieldsPlaceholder;
@synthesize jiraUrlFields = _jiraUrlFields;
@synthesize jiraUrlFieldsPlaceholder = _jiraUrlFieldsPlaceholder;
@synthesize jiraUsernameField = _jiraUsernameField;
@synthesize jiraPasswrodField = _jiraPasswrodField;
@synthesize jiraUrlField = _jiraUrlField;
@synthesize formTable = _formTable;
@synthesize greeButton = _greeButton;
@synthesize acknowledgmentsButton = _acknowledgmentsButton;
@synthesize formOriginalFrame = _formOriginalFrame;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [MalcomLib startBeaconWithName:@"Config View"];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = @"Config";
    
    UIBarButtonItem* finishBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(validateData)];
    self.navigationItem.rightBarButtonItem = finishBarButton;
    
    self.jiraCredentialsFields = [NSArray arrayWithObjects:@"Username", @"Password", nil];
    self.jiraCredentialsFieldsPlaceholder = [NSArray arrayWithObjects:@"Your account username", @"Your account password", nil];
    
    self.jiraUrlFields = [NSArray arrayWithObjects:@"URL", nil];
    self.jiraUrlFieldsPlaceholder = [NSArray arrayWithObjects:@"Where Jira is hosted", nil];
    
    self.configDAO = [ConfigDAO new];
    self.formOriginalFrame = self.formTable.frame;
    
    UITapGestureRecognizer* touchTable = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    touchTable.cancelsTouchesInView = NO;
    [self.formTable addGestureRecognizer:touchTable];
    
    [self.acknowledgmentsButton setTitle:@"Acknowledgments" forState:UIControlStateNormal];
    
    // Setup gree button.
//    if([GreePlatform sharedInstance].localUser) {
//        [self setSignOutButton];
//    } else {
//        [self setSignInButton];
//    }
    [self setSignInButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.appConfig) {
        UIBarButtonItem* cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
        self.navigationItem.leftBarButtonItem = cancelBarButton;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
      
    if (self.appConfig.ID == 0 && created) {    
        GreeFacade* facade = [GreeFacade new];
        [facade increaseStatisticByOne:2];
        [facade increaseStatisticByOne:1];
        [facade showUnlockedAchievements];
        [facade release];
    }
}

- (void) cancel {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void) finishWizard {
    if (self.appConfig.ID == 0) {
        [self.configDAO createConfig:self.appConfig];
        created = YES;
    } else {
        [self.configDAO updateConfig:self.appConfig];
    }
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void) validateData {
    [self hideKeyboard];
    BOOL changed = [self getData];
    
    if (changed) {
        BOOL success = YES;
        
        UIView* target = nil;
        NSString* message = nil;
        
        if (success && self.appConfig.jiraUsername.length == 0) {
            target = self.jiraUsernameField;
            message = @"Username cannot be empty";
            success = NO;
        }
        
        if (success && self.appConfig.jiraPassword.length == 0) {
            target = self.jiraPasswrodField;
            message = @"Password cannot be empty";
            success = NO;
        }
        
        if (success) {
            if (self.appConfig.jiraURL.length == 0) {
                message = @"URL cannot be empty";
                target = self.jiraUrlField;
                success = NO;
            } else if (![self.appConfig.jiraURL hasPrefix:@"http://"] && ![self.appConfig.jiraURL hasPrefix:@"https://"]) {
                message = @"Invalid URL";
                target = self.jiraUrlField;
                success = NO;
            }
        }
        
        if (!success) {
            CMPopTipView *errorPopup = [[[CMPopTipView alloc] initWithMessage:message] autorelease];
            errorPopup.backgroundColor = [UIColor redColor];
            errorPopup.animation = CMPopTipAnimationPop;
            [errorPopup presentPointingAtView:target inView:self.view animated:YES];
            [errorPopup autoDismissAnimated:YES atTimeInterval:1];
        } else {
            HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:HUD];
            HUD.dimBackground = YES;
            HUD.delegate = self;
            HUD.labelText = @"Verifing Jira config...";
            
            [HUD showWhileExecuting:@selector(validateUser) onTarget:self withObject:nil animated:YES];
        }
    } else {
        [self finishWizard];
    }
}

- (BOOL) getData {
    BOOL chanded = NO;
    
    if (!self.appConfig) {
        self.appConfig = [Config new];
    }
    
    if (![self.appConfig.jiraUsername isEqualToString:self.jiraUsernameField.text]) {
        chanded = YES;
        self.appConfig.jiraUsername = self.jiraUsernameField.text;
    }
    
    if (![self.appConfig.jiraPassword isEqualToString:self.jiraPasswrodField.text]) {
        chanded = YES;
        self.appConfig.jiraPassword = self.jiraPasswrodField.text;
    }
    
    if (![self.appConfig.jiraURL isEqualToString:self.jiraUrlField.text]) {
        chanded = YES;
        self.appConfig.jiraURL = [self.jiraUrlField.text lowercaseString];
        
        if (self.appConfig.jiraURL.length > 0 && [self.appConfig.jiraURL characterAtIndex:self.appConfig.jiraURL.length - 1] != '/') {
            NSMutableString* url = [NSMutableString stringWithString:self.appConfig.jiraURL];
            [url appendString:@"/"];
            
            self.appConfig.jiraURL = url;
        }
    }
    
    return chanded;
}

- (void) validateUser {
    NSString* valid = [[JiraFacade new] validateUser:self.appConfig];
    
    // Si no es nulo, es que hemos obtenido un mensaje de error a mostrar.
    if (valid != nil) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:valid delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    } else {
        HUD.labelText = @"Verifing user permissions...";
        
        [self validatePermissions]; 
    }
}

- (void) validatePermissions {
    BOOL valid = [[JiraFacade new] validatePermission:self.appConfig];
    
    if (!valid) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You haven't got enough permissions" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    } else {
        HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"done.png"]] autorelease];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.dimBackground = NO;
        HUD.labelText = @"Done";
        sleep(1);
        
        [self finishWizard]; 
    }
}

- (void)viewDidUnload
{
    [MalcomLib endBeaconWithName:@"Config View"];

    self.appConfig = nil;
    self.configDAO = nil;
    self.jiraCredentialsFields = nil;
    self.jiraCredentialsFieldsPlaceholder = nil;
    self.jiraUrlFields = nil;
    self.jiraUrlFieldsPlaceholder = nil;
    self.jiraUsernameField = nil;
    self.jiraPasswrodField = nil;
    self.jiraUrlField = nil;
    [self setFormTable:nil];
    [self setGreeButton:nil];
    [self setAcknowledgmentsButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString* headerTitle ;
    
    switch (section) {
        case 0:
            headerTitle = @"Jira Credentials";
            break;
            
        case 1:
            headerTitle = @"Jira Connection";
            break;
    }
    
    return headerTitle;
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString* footerTitle;
    
    switch (section) {
        case 0:
            footerTitle = @"";
            break;
            
        case 1:
            footerTitle = @"Gree is a gamer social network where share your score and achievements with your friends. Log in or create an account. Optional";
            break;
    }
    
    return footerTitle;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRowsInSection = 0;
    
    switch (section) {
        case 0:
            numberOfRowsInSection = self.jiraCredentialsFields.count;
            break;
            
        case 1:
            numberOfRowsInSection = self.jiraUrlFields.count;
            break;
    }
    
    return numberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FieldCell";
    ELCTextfieldCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[ELCTextfieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FieldCell"];
        cell.rightTextField.textColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1] /*#666666*/;
    }
    
    switch (indexPath.section) {
        case 0:
            cell.leftLabel.text = [self.jiraCredentialsFields objectAtIndex:indexPath.row];
            cell.rightTextField.placeholder = [self.jiraCredentialsFieldsPlaceholder objectAtIndex:indexPath.row];
            cell.indexPath = indexPath;
            cell.delegate = self;
            //Disables UITableViewCell from accidentally becoming selected.
            cell.selectionStyle = UITableViewCellEditingStyleNone;

            switch (indexPath.row) {
                case 0:
                    cell.rightTextField.returnKeyType = UIReturnKeyNext;
                    
                    if (self.appConfig) {
                        cell.rightTextField.text = self.appConfig.jiraUsername;
                    }
                    
                    self.jiraUsernameField = cell.rightTextField;
                    break;
                    
                case 1:
                    cell.rightTextField.secureTextEntry = YES;
                    cell.rightTextField.returnKeyType = UIReturnKeyDone;     
                    
                    if (self.appConfig) {
                        cell.rightTextField.text = self.appConfig.jiraPassword;
                    }
                    
                    self.jiraPasswrodField = cell.rightTextField;
                    break;
            }
            
            break;
            
        case 1:
            cell.leftLabel.text = [self.jiraUrlFields objectAtIndex:indexPath.row];
            cell.rightTextField.placeholder = [self.jiraUrlFieldsPlaceholder objectAtIndex:indexPath.row];
            cell.indexPath = indexPath;
            cell.delegate = self;
            //Disables UITableViewCell from accidentally becoming selected.
            cell.selectionStyle = UITableViewCellEditingStyleNone;
            cell.rightTextField.returnKeyType = UIReturnKeyDone;
            
            if (self.appConfig) {
                cell.rightTextField.text = self.appConfig.jiraURL;
            }
            
            cell.rightTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.jiraUrlField = cell.rightTextField;
            
            break;
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Fila seleccionada: %d", indexPath.row);
}

-(void)textFieldDidReturnWithIndexPath:(NSIndexPath*)_indexPath {
    switch (_indexPath.section) {
        case 0:
            
            switch (_indexPath.row) {
                case 0:
                    [self.jiraPasswrodField becomeFirstResponder];
                    break;
                case 1:
                    [self.jiraPasswrodField resignFirstResponder];
                    break;
            }
            
            break;
        case 1:
            [self.jiraUrlField resignFirstResponder];
            [self downFormTable];
            break;
    }
    
}

-(void)updateTextLabelAtIndexPath:(NSIndexPath*)_indexPath string:(NSString*)_string {

}

- (void)upFormTable {
    if (self.formOriginalFrame.origin.y == self.formTable.frame.origin.y) {
        [UIView beginAnimations:@"mostrarURL" context:nil];
        [UIView setAnimationDuration:0.3f];
        
        CGRect upperFrame = self.formOriginalFrame;
        upperFrame.origin.y -= 70;
        [self.formTable setFrame:upperFrame];
        
        [UIView commitAnimations];
    }
}

- (void)downFormTable {
    if (self.formOriginalFrame.origin.y != self.formTable.frame.origin.y) {
        [UIView beginAnimations:@"ocultarURL" context:nil];
        [UIView setAnimationDuration:0.3f];
        
        [self.formTable setFrame:self.formOriginalFrame];
        
        [UIView commitAnimations];
    }
}

- (void)hideKeyboard {
    [self.jiraUsernameField resignFirstResponder];
    [self.jiraPasswrodField resignFirstResponder];
    [self.jiraUrlField resignFirstResponder];
    [self downFormTable];
}

-(void)textFieldDidBeginEditing:(NSIndexPath*)_indexPath {
    /*
     * Si seleccionamos el campo de texto de Jira URL, subiremos
     * la tabla para permitir ver dicho campo. En caso contrario
     * la bajaremos.
     */
    if (_indexPath.section == 1) {
        [self upFormTable];
    } else {
        [self downFormTable];
    }
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	[HUD release];
	HUD = nil;
}

- (void)dealloc {
    [self.appConfig release];
    [self.configDAO  release];
    [self.jiraCredentialsFields release];
    [self.jiraCredentialsFieldsPlaceholder release];
    [self.jiraUrlFields release];
    [self.jiraUrlFieldsPlaceholder release];
    [self.jiraUsernameField release];
    [self.jiraPasswrodField release];
    [self.jiraUrlField release];
    [_formTable release];
    [_greeButton release];
    [_acknowledgmentsButton release];
    [super dealloc];
}

- (IBAction)signInOrSignUp:(id)sender {
    if([GreePlatform sharedInstance].localUser) {
        [GreePlatform revokeAuthorization];
//        [self setSignInButton];
    } else {
        [GreePlatform authorize];
//        [self setSignOutButton];
    }
}

- (IBAction)showAcknowledgments:(id)sender {
    AcknowledgmentsViewController* ackViewController = [[AcknowledgmentsViewController alloc] initWithNibName:@"AcknowledgmentsView" bundle:nil];
    [self.navigationController pushViewController:ackViewController animated:YES];
}

- (void)setSignInButton {
    [self.greeButton setTitle:@"Manage Gree account" forState:UIControlStateNormal];
    [self.greeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UIImage *buttonBG = [[UIImage imageNamed:@"acceptButton.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    UIImage *buttonBGhover = [[UIImage imageNamed:@"acceptButtonHover.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    [self.greeButton setBackgroundImage:buttonBG forState:UIControlStateNormal];
    [self.greeButton setBackgroundImage:buttonBGhover forState:UIControlStateHighlighted];
}

- (void)setSignOutButton {
    [self.greeButton setTitle:@"Sign out Gree account" forState:UIControlStateNormal];
    [self.greeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UIImage *buttonBG = [[UIImage imageNamed:@"cancelButton.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    UIImage *buttonBGhover = [[UIImage imageNamed:@"cancelButtonHover.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    [self.greeButton setBackgroundImage:buttonBG forState:UIControlStateNormal];
    [self.greeButton setBackgroundImage:buttonBGhover forState:UIControlStateHighlighted];
}

@end
