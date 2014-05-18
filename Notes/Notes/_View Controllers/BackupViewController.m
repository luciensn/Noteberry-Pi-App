//
//  BackupViewController.m
//
//  Created by Scott Lucien on 2/26/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

#import "BackupViewController.h"
#import "BackupManager.h"
#import "TextInputCell.h"
#import "SettingsViewController.h"

@interface BackupViewController () <UITableViewDataSource, UITableViewDelegate>

// IBOutlets
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

#pragma mark -

@implementation BackupViewController

- (id)init
{
    NSString *nibName = @"GroupedTableViewController";
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:NSLocalizedString(@"Back Up Data", nil)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem doneButtonWithTarget:self action:@selector(donePressed:)];
    
    // set up the tableView
    UIEdgeInsets insets = UIEdgeInsetsMake(64, 0, 10, 0);
    [_tableView setContentInset:insets];
    [_tableView setScrollIndicatorInsets:insets];
    [_tableView registerClass:[TextInputCell class] forCellReuseIdentifier:INPUT_CELL_IDENTIFIER];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CELL_IDENTIFIER];
    [_tableView setKeyboardDismissMode:UIScrollViewKeyboardDismissModeOnDrag];
    
    // add the tap gesture to close the keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    [tap setCancelsTouchesInView:NO];
    [_tableView addGestureRecognizer:tap];
}

#pragma mark - UITableView DataSource

static NSString *const INPUT_CELL_IDENTIFIER = @"BackupInputCell";
static NSString *const CELL_IDENTIFIER = @"BackupCell";

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"Destination", nil);
    } else {
        return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"This operation will send a POST request to the specified URL. The body of the request will contain your notes in JSON format.", nil);
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // input fields
    if (indexPath.section == 0) {
        TextInputCell *cell = [tableView dequeueReusableCellWithIdentifier:INPUT_CELL_IDENTIFIER];
        [cell.textField setPlaceholder:NSLocalizedString(@"http://url.com/path", nil)];
        [cell.textField setText:[BackupManager getDestination]];
        return cell;
    }
    
    // action button
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        [cell.textLabel setTextColor:[UIColor themeColor]];
        [cell.textLabel setText:NSLocalizedString(@"Back Up Now", nil)];
        return cell;
    }
}

#pragma mark - UITableView Delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 1);
}

- (BOOL)tableView:(UITableView *)tableView shouldSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 1);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
    if (indexPath.section == 1) {
        [self backUpNow];
    }
}

#pragma mark - View Actions

- (void)backgroundTapped:(id)sender
{
    // close the keyboard
    for (UITableView *cell in _tableView.visibleCells) {
        if ([cell isKindOfClass:[TextInputCell class]]) {
            TextInputCell *inputCell = (TextInputCell *)cell;
            [inputCell.textField resignFirstResponder];
        }
    }
}

- (void)donePressed:(id)sender
{
    SettingsViewController *settings = (SettingsViewController *)[self.navigationController.viewControllers objectAtIndex:0];
    [settings.settingsDelegate settingsViewControllerDidDismiss:settings];
}

#pragma mark - Backup Methods

- (void)backUpNow
{
    // TODO: check for empty text fields
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    TextInputCell *cell = (TextInputCell *)[_tableView cellForRowAtIndexPath:indexPath];
    NSString *destination = cell.textField.text;
    if (destination.length > 0) {
        [BackupManager saveDestination:destination];
    }
    
    // trigger the backup
    [[BackupManager sharedManager] sendBackupToDestination:destination completion:nil];
}


@end
