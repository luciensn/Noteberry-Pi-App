//
//  SettingsViewController.m
//
//  Created by Scott Lucien on 11/2/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

#import "SettingsViewController.h"
#import "AboutViewController.h"
#import "PinManager.h"
#import "PINViewController.h"
#import "BackupViewController.h"
#import "BackupManager.h"

@interface SettingsViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

// IBOutlets
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// Properties
@property (strong, nonatomic) NSDictionary *infoDictionary;

@end

#pragma mark -

@implementation SettingsViewController

- (id)initWithSettingsDelegate:(id<SettingsViewControllerDelegate>)delegate
{
    NSString *nibName = @"GroupedTableViewController";
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        [self setTitle:NSLocalizedString(@"Options", nil)];
        [self setSettingsDelegate:delegate];
    }
    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set up navigation items
    [self.navigationItem setRightBarButtonItem:[UIBarButtonItem doneButtonWithTarget:self action:@selector(dismiss:)]];
    [self.navigationItem setBackBarButtonItem:[UIBarButtonItem backButton]];
    
    // set up the tableView
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    UIEdgeInsets insets = UIEdgeInsetsMake(64, 0, 10, 0);
    [_tableView setContentInset:insets];
    [_tableView setScrollIndicatorInsets:insets];
    
    // get the info plist from application bundle
    NSString *infoFilePath = [[NSBundle mainBundle] pathForResource:@"About" ofType:@"plist"];
    _infoDictionary = [NSDictionary dictionaryWithContentsOfFile:infoFilePath];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self deselectTableViewRow:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backupComplete:) name:BackupDidCompleteNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableView Data Source

static NSString *CellIdentifier = @"Cell";

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2) {
        return 2;
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 3) {
        return [self getLastBackupTimeString];
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 3) {
        return UITableViewAutomaticDimension;
    } else {
        return 24;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // about screen
    if (indexPath.section == 0) {
        [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
        [cell.textLabel setTextColor:[UIColor blackColor]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = NSLocalizedString(@"About", nil);
    }
    
    // passcode on/off switch
    else if (indexPath.section == 1) {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [cell.textLabel setText:NSLocalizedString(@"Passcode Lock", nil)];
        UISwitch *onOffSwitch = [[UISwitch alloc] init];
        [onOffSwitch setOn:[PinManager pinIsEnabled]];
        [onOffSwitch addTarget:self action:@selector(toggleOnOffSwitch:) forControlEvents:UIControlEventValueChanged];
        [cell setAccessoryView:onOffSwitch];
    }
    
    // passcode details
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [cell.textLabel setText:NSLocalizedString(@"Change Passcode", nil)];
            if ([PinManager pinIsEnabled]) {
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                [cell.textLabel setTextColor:[UIColor blackColor]];
            } else {
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [cell.textLabel setTextColor:[UIColor lightGrayColor]];
            }
        } else if (indexPath.row == 1) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            [cell.textLabel setText:NSLocalizedString(@"Require Passcode", nil)];
            [cell.detailTextLabel setTextColor:[UIColor lightGrayColor]];
            
            // update the label based on the current pin settings
            [cell.detailTextLabel setText:[PinManager stringForPinDelaySetting:[PinManager getPinDelay]]];
            
            if ([PinManager pinIsEnabled]) {
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                [cell.textLabel setTextColor:[UIColor blackColor]];
            } else {
                [cell.textLabel setTextColor:[UIColor lightGrayColor]];
                [cell.detailTextLabel setHidden:YES];
            }
        }
    }
    
    // back up data
    else if (indexPath.section == 3) {
        [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
        [cell.textLabel setTextColor:[UIColor blackColor]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = NSLocalizedString(@"Back Up Data", nil);
    }
    
    return cell;
}

#pragma mark - UITableView Delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self canSelectRowAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView shouldSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self canSelectRowAtIndexPath:indexPath];
}

- (BOOL)canSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return NO;
    } else if (indexPath.section == 2) {
        return [PinManager pinIsEnabled];
    } else {
        return YES;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // about screen
    if (indexPath.section == 0) {
        [self viewAboutScreen];
    }
    
    // passcode details
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [self changePasscode];
        } else if (indexPath.row == 1) {
            [self choosePinDelay];
        }
    }
    
    // backup data
    else if (indexPath.section == 3) {
        [self backupData];
    }
}

#pragma mark - View Controller Actions

- (void)dismiss:(id)sender
{
    [self.settingsDelegate settingsViewControllerDidDismiss:self];
}

- (void)viewAboutScreen
{
    AboutViewController *about = [[AboutViewController alloc] initWithInfo:_infoDictionary];
    [self.navigationController pushViewController:about animated:YES];
}

- (void)backupData
{
    BackupViewController *backup = [[BackupViewController alloc] init];
    [self.navigationController pushViewController:backup animated:YES];
}

#pragma mark - Pin Actions

- (void)toggleOnOffSwitch:(UISwitch *)onOffSwitch
{
    if (onOffSwitch.isOn) {
        
        // create new pin
        __weak typeof(self) weakSelf = self;
        PINViewController *pinvc = [[PINViewController alloc] initWithCreateNewPinModeWithCompletion:^(BOOL success){
            if (success) {
                [PinManager setPinEnabled:YES];
            }
            [weakSelf dismissPinViewController];
        }];
        
        BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:pinvc];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
        
    } else {
    
        // prompt to enter passcode before turning off
        __weak typeof(self) weakSelf = self;
        PINViewController *pinvc = [[PINViewController alloc] initWithEnterPinModeWithCompletion:^(BOOL success){
            if (success) {
                [PinManager setPinEnabled:NO];
            }
            [weakSelf dismissPinViewController];
        }];
        
        BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:pinvc];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
}

- (void)choosePinDelay
{
    // enter passcode before making changes
    __weak typeof(self) weakSelf = self;
    PINViewController *pinvc = [[PINViewController alloc] initWithEnterPinModeWithCompletion:^(BOOL success){
        if (!success) {
            [weakSelf.navigationController popViewControllerAnimated:NO];
        }
        [weakSelf dismissPinViewController];
    }];
    
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:pinvc];
    PINSetupDelayViewController *pinDelay = [[PINSetupDelayViewController alloc] initWithDelegate:self];
    [self.navigationController presentViewController:nav animated:YES completion:^{
        [weakSelf.navigationController pushViewController:pinDelay animated:YES];
    }];
}

- (void)changePasscode
{
    // change passcode
    __weak typeof(self) weakSelf = self;
    PINViewController *pinvc = [[PINViewController alloc] initWithChangePinModeWithCompletion:^(BOOL success){
        [weakSelf dismissPinViewController];
    }];
    
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:pinvc];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)dismissPinViewController
{
    [_tableView reloadData];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PinSetupDelayViewControllerDelegate

- (void)pinSetupDelayViewControllerDidSelectDelay:(PinDelay)delay
{
    // update the cell's text label
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:2];
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    [cell.detailTextLabel setText:[PinManager stringForPinDelaySetting:delay]];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self deselectTableViewRow:YES];
}

#pragma mark - Private Methods

- (void)deselectTableViewRow:(BOOL)animated
{
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:animated];
}

- (NSString *)getLastBackupTimeString
{
    AppDelegate *delegate = [AppDelegate appDelegate];
    [delegate.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [delegate.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *backup = [delegate.dateFormatter stringFromDate:[BackupManager getLastBackupDate]];
    if (backup.length < 1) {
        backup = NSLocalizedString(@"Never", nil);
    }
    NSString *text = NSLocalizedString(@"Last Backup:", nil);
    NSString *combined = [NSString stringWithFormat:@"%@ %@", text, backup];
    return combined;
}

- (void)backupComplete:(NSNotification *)notification
{
    [_tableView reloadData];
}

@end
