//
//  PINSetupDelayViewController.m
//
//  Created by Scott Lucien on 11/23/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

#import "PINSetupDelayViewController.h"

@interface PINSetupDelayViewController () <UITableViewDataSource, UITableViewDelegate>

// IBOutlets
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

#pragma mark -

@implementation PINSetupDelayViewController

- (id)initWithDelegate:(id<PinSetupDelayViewControllerDelegate>)setupDelayDelegate
{
    NSString *nibName = @"GroupedTableViewController";
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        [self setTitle:NSLocalizedString(@"Require Passcode", nil)];
        if (setupDelayDelegate) {
            [self setSetupDelayDelegate:setupDelayDelegate];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set up the tableView
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    [_tableView setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
}

#pragma mark - UITableView Data Source

static NSString *CellIdentifier = @"DelayCell";

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
//{
//    return NSLocalizedString(@"If you remove this app from the multitasking menu, your passcode will be required immediately.", nil);
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return UITableViewAutomaticDimension;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // update the cell based on the current pin settings
    [cell.textLabel setText:[PinManager stringForPinDelaySetting:indexPath.row]];
    if (indexPath.row == [PinManager getPinDelay]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // save the new selection
    [PinManager setPinDelay:indexPath.row];
    
    // update the tableView
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
    for (UITableViewCell *cell in [tableView visibleCells]) {
        NSIndexPath *cellIndexPath = [tableView indexPathForCell:cell];
        if (cellIndexPath.row == indexPath.row) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    
    // notify the delegate that a selection was made
    if (_setupDelayDelegate && [_setupDelayDelegate respondsToSelector:@selector(pinSetupDelayViewControllerDidSelectDelay:)]) {
        [_setupDelayDelegate pinSetupDelayViewControllerDidSelectDelay:indexPath.row];
    }
}

@end
