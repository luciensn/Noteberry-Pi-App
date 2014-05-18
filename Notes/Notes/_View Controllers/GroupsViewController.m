//
//  SectionsViewController.m
//
//  Created by Scott Lucien on 1/22/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

#import "GroupsViewController.h"
#import "ListViewController.h"
#import "SettingsViewController.h"
#import "GroupCell.h"
#import "UIView+EasingAnimation.h"

@interface GroupsViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate, SettingsViewControllerDelegate, GroupCellDelegate>

// IBOutlets
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *tableHeaderBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *shadowImageView;
@property (weak, nonatomic) IBOutlet UIImageView *pullIconImageView;

// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableHeaderBackgroundTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shadowTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pullIconTopConstraint;

// Properties
@property (strong, nonatomic) UIImage *pullArrow;
@property (strong, nonatomic) UIImage *pullPlus;
@property (strong, nonatomic) UIBarButtonItem *addButton;
@property (strong, nonatomic) UIBarButtonItem *doneButton;
@property (strong, nonatomic) UIBarButtonItem *settingsButton;
@property (strong, nonatomic) UIView *draggableView;
@property (strong, nonatomic) NSIndexPath *draggingIndexPath;
@property (strong, nonatomic) NSTimer *scrollTimer;
@property (nonatomic) CGPoint touchStartingPoint;
@property (nonatomic) CGPoint draggableViewStartingPoint;
@property (nonatomic) BOOL dragging;

@end

#pragma mark -

@implementation GroupsViewController

- (id)init
{
    NSString *nib = @"GroupsViewController";
    self = [super initWithNibName:nib bundle:nil];
    if (self) {
        // initialization
    }
    return self;
}

#pragma mark - View Life Cycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // navigation items
    self.navigationItem.backBarButtonItem = [UIBarButtonItem backButton];
    _settingsButton = [UIBarButtonItem settingsButtonWithTarget:self action:@selector(settingsButtonPressed:)];
    _addButton = [UIBarButtonItem addButtonWithTarget:self action:@selector(addNewButtonPressed:)];
    _doneButton = [UIBarButtonItem doneButtonWithTarget:self action:@selector(doneButtonPressed:)];
    self.navigationItem.leftBarButtonItem = _settingsButton;
    self.navigationItem.rightBarButtonItem = _addButton;
    
    // set up the tableView
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(64, 0, 0, 0);
    [_tableView setContentInset:edgeInsets];
    [_tableView setScrollIndicatorInsets:edgeInsets];
    [_tableView registerClass:[GroupCell class] forCellReuseIdentifier:CELL_IDENTIFIER];
    
    // set up the pull gesture hint
    UIImage *shadowImage = [[UIImage imageNamed:@"shadow-top"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
    [_shadowImageView setImage:shadowImage];
    _pullPlus = [UIImage imageNamed:@"pull-arrow-inverted"];
    _pullArrow = [UIImage imageNamed:@"pull-arrow"];
    [_pullIconImageView setImage:_pullArrow];
    
    // load the groups from core data
    [[CoreDataManager sharedManager] fetchGroupsWithCompletion:^{
        [self reloadTableView];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self clearAndResetTheScreen];
}

#pragma mark - UITableView DataSource

static NSString *const CELL_IDENTIFIER = @"GroupCell";

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[CoreDataManager sharedManager] numberOfGroups];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Group *group = [[CoreDataManager sharedManager] groupForRow:indexPath.row];
    
    GroupCell *cell = (GroupCell *)[tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell.textLabel setText:group.displayName];
    [cell setGroupCellDelegate:self];
    
    // add the drag-to-reorder gesture
    if (!cell.dragToReorderGesture) {
        [cell addLongPressGestureWithTarget:self action:@selector(handlePanGesture:) delegate:nil];
    }
    
    return cell;
}

#pragma mark - UITableView Delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // return a string that approximates the width of the editing buttons (162)
    return @"ooooooooollllllllll";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        return; // do nothing
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // push notes list view controller
    Group *group = [[CoreDataManager sharedManager] groupForRow:indexPath.row];
    ListViewController *list = [[ListViewController alloc] initWithGroup:group];
    [self.navigationController pushViewController:list animated:YES];
}

#pragma mark - GroupCell Delegate

- (void)groupCellDidDelete:(GroupCell *)cell
{
    // prompt to delete the category
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    NSString *groupName = [cell.textLabel text];
    UIActionSheet *confirm = [UIActionSheet deleteGroupPromptWithName:groupName delegate:self];
    [confirm setTag:indexPath.row];
    [confirm showInView:self.view];
}

- (void)groupCellDidEdit:(GroupCell *)cell
{
    // edit the category name
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    Group *group = [[CoreDataManager sharedManager] groupForRow:indexPath.row];
    NSString *name = group.displayName;
    UIAlertView *prompt = [UIAlertView editSectionWithDelegate:self];
    [[prompt textFieldAtIndex:0] setText:name];
    [prompt setTag:indexPath.row];
    [prompt show];
}

- (void)groupCellDidOpen:(GroupCell *)cell
{
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    [self.navigationItem setRightBarButtonItem:_doneButton animated:YES];
}

- (void)groupCellDidClose:(GroupCell *)cell
{
    // this is a hack to prevent the wierd animation bug
    double delayInSeconds = 0.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.navigationItem setLeftBarButtonItem:_settingsButton animated:YES];
        [self.navigationItem setRightBarButtonItem:_addButton animated:YES];
    });
}

#pragma mark - UIPanGestureRecognizer

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
    /* TOUCH START */
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        [self setDragging:YES];
        [self.view setUserInteractionEnabled:NO];
        [self.navigationController.navigationBar setUserInteractionEnabled:NO];

        // find the cell that the touch came from
        GroupCell *cell = (GroupCell *)recognizer.view.superview.superview.superview.superview;
        [self setDraggingIndexPath:[_tableView indexPathForCell:cell]];
        
        // set up the draggable view
        CGRect cellFrame = [self.view convertRect:cell.bounds fromView:cell];
        CGRect draggableFrame = CGRectMake(cellFrame.origin.x, cellFrame.origin.y - 6, cellFrame.size.width, cellFrame.size.height + 12);
        _draggableView = [[UIView alloc] initWithFrame:draggableFrame];
        
        // add the snapshot of the cell to the draggable view
        UIView *snapshotView = [cell snapshotViewAfterScreenUpdates:NO];
        CGRect snapshotRect = CGRectMake(0, 6, snapshotView.frame.size.width, snapshotView.frame.size.height);
        [snapshotView setFrame:snapshotRect];
        [_draggableView addSubview:snapshotView];
        
        // add the shadows to the draggable view
        CGRect topFrame = CGRectMake(0, 0, draggableFrame.size.width, 6);
        CGRect bottomFrame = CGRectMake(0, draggableFrame.size.height - 6, draggableFrame.size.width, 6);
        UIImageView *topShadow = [[UIImageView alloc] initWithFrame:topFrame];
        UIImageView *bottomShadow = [[UIImageView alloc] initWithFrame:bottomFrame];
        UIImage *topShadowImage = [UIImage imageNamed:@"shadow-top"];
        UIImage *bottomShadowImage = [UIImage imageNamed:@"shadow-bottom"];
        [topShadow setImage:topShadowImage];
        [bottomShadow setImage:bottomShadowImage];
        [_draggableView addSubview:topShadow];
        [_draggableView addSubview:bottomShadow];
        
        // add the draggable view to the main view
        [self.view addSubview:_draggableView];
        [cell setHidden:YES];
        
        // set the properties
        [self setTouchStartingPoint:[recognizer locationInView:self.view]];
        [self setDraggableViewStartingPoint:_draggableView.center];
    }
    
    /* TOUCH MOVE */
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        // move the view and handle the changes
        [self moveViewsRelativeToPoint:[recognizer locationInView:self.view]];
    }
    
    /* TOUCH END */
    else if (recognizer.state == UIGestureRecognizerStateCancelled ||
             recognizer.state == UIGestureRecognizerStateEnded ||
             recognizer.state == UIGestureRecognizerStateFailed)
    {
        GroupCell *cell = (GroupCell *)[_tableView cellForRowAtIndexPath:_draggingIndexPath];
        CGRect cellFrame = [self.view convertRect:cell.bounds fromView:cell];
        CGRect draggableFrame = CGRectMake(cellFrame.origin.x, cellFrame.origin.y - 6, cellFrame.size.width, cellFrame.size.height + 12);
        
        void (^animationBlock)() = ^{
            [_draggableView setFrame:draggableFrame];
        };

        void (^completionBlock)(BOOL finished) = ^(BOOL finished) {
            [cell setHidden:NO];
            [_draggableView removeFromSuperview];
            [self setDraggableView:nil];
            [self.view setUserInteractionEnabled:YES];
            [self.navigationController.navigationBar setUserInteractionEnabled:YES];
        };
        
        // perform the animations
        [UIView animateFromCurrentStateWithEasing:animationBlock completion:completionBlock];
        
        // reset the properties
        [self setDraggingIndexPath:nil];
        [self setDragging:NO];
    }
}

- (void)moveViewsRelativeToPoint:(CGPoint)newPoint
{
    // move the draggable view
    CGPoint center = _draggableViewStartingPoint;
    center.y += newPoint.y - _touchStartingPoint.y;
    [_draggableView setCenter:center];
    
    // check if we should switch places with another cell
    NSIndexPath *newIndexPath = [self checkForOverlappingCells];
    if (newIndexPath) {
        [[CoreDataManager sharedManager] moveGroupAtRow:_draggingIndexPath.row toRow:newIndexPath.row];
        [_tableView moveRowAtIndexPath:_draggingIndexPath toIndexPath:newIndexPath];
        [self setDraggingIndexPath:newIndexPath];
    }
}

- (NSIndexPath *)checkForOverlappingCells
{
    NSIndexPath *newIndexPath = nil;
    CGPoint center = [_tableView convertPoint:_draggableView.center fromView:self.view];
    BOOL timerIsRunning = _scrollTimer.isValid;
    if (!timerIsRunning) {
        for (GroupCell *cell in _tableView.visibleCells) {
            if (CGRectContainsPoint(cell.frame, center)) {
                NSIndexPath *cellIndexPath = [_tableView indexPathForCell:cell];
                BOOL isTheFromAccount = [cellIndexPath isEqual:_draggingIndexPath];
                if (!isTheFromAccount) {
                    newIndexPath = cellIndexPath;
                    break;
                }
            }
        }
    }
    return newIndexPath;
}

- (void)clearAndResetTheScreen
{
    [self closeTableViewCellsAnimated:NO];
    [self.view setUserInteractionEnabled:YES];
    [self.navigationController.navigationBar setUserInteractionEnabled:YES];
    //[self stopScrollTimer];
    [_draggableView removeFromSuperview];
    [self setDraggableView:nil];
    [self setDraggingIndexPath:nil];
    [self setDragging:NO];
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // pull-to-create-new
    if (scrollView == _tableView) {
        
        CGFloat offset = scrollView.contentOffset.y;
        CGFloat normalized = -(offset + 64);
        
        // icon parallax
        CGFloat parallax= (34 + normalized/2.5);
        [_shadowTopConstraint setConstant:(58 + normalized)];
        [_pullIconTopConstraint setConstant:parallax];
        if (normalized >= 90) {
            [_pullIconImageView setImage:_pullPlus];
        } else {
            [_pullIconImageView setImage:_pullArrow];
        }
        
        // table header background view
        CGFloat headerConstant = (-256 + normalized);
        [_tableHeaderBackgroundTopConstraint setConstant:headerConstant];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == _tableView) {
        CGFloat offset = scrollView.contentOffset.y;
        CGFloat normalized = -(offset + 64);
        if (normalized >= 90) {
            [self addNewButtonPressed:nil];
        }
    }
}

#pragma mark - View Controller Actions

- (void)addNewButtonPressed:(id)sender
{
    // add new category
    UIAlertView *prompt = [UIAlertView addNewSectionWithDelegate:self];
    [prompt setTag:-1];
    [prompt show];
}

- (void)settingsButtonPressed:(id)sender
{
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithSettingsDelegate:self];
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:settingsViewController];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)doneButtonPressed:(id)sender
{
    [self closeTableViewCellsAnimated:YES];
    [self.navigationItem setLeftBarButtonItem:_settingsButton animated:YES];
    [self.navigationItem setRightBarButtonItem:_addButton animated:YES];
}

#pragma mark - SettingsViewController Delegate

- (void)settingsViewControllerDidDismiss:(SettingsViewController *)controller
{
    [[NSNotificationCenter defaultCenter] removeObserver:controller];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == -1) {
        
        // add new category
        if (buttonIndex == 1) {
            NSString *text = [[alertView textFieldAtIndex:0] text];
            if (text.length < 1) {
                text = NSLocalizedString(@"New Category", nil);
            }
            [[CoreDataManager sharedManager] addNewGroupWithName:text completion:^{
                [self finishAddingNewGroup];
            }];
        }
        
    } else {
        
        // edit category
        if (buttonIndex == 1) {
            Group *group = [[CoreDataManager sharedManager] groupForRow:alertView.tag];
            NSString *newName = [[alertView textFieldAtIndex:0] text];
            if (![group.displayName isEqualToString:newName]) {
                [group setDisplayName:newName];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:alertView.tag inSection:0];
                GroupCell *cell = (GroupCell *)[_tableView cellForRowAtIndexPath:indexPath];
                [cell.textLabel setText:newName];
                return;
            }
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:alertView.tag inSection:0];
        [_tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // delete the category and all notes associated with it
    if (buttonIndex == 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:actionSheet.tag inSection:0];
        [[CoreDataManager sharedManager] deleteGroupAtRow:actionSheet.tag completion:^{
            [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        }];
        [self groupCellDidClose:nil];
    }
}

#pragma mark - Methods

- (void)reloadTableView
{
    [_tableView reloadData];
}

- (void)closeTableViewCellsAnimated:(BOOL)animated
{
    [self groupCellDidClose:nil];
    if (!animated) {
        [UIView performWithoutAnimation:^{
            [_tableView setEditing:NO];
        }];
    } else {
        [_tableView setEditing:NO animated:YES];
    }
}

- (void)finishAddingNewGroup
{
    [self reloadTableView];
    
    // scroll to the bottom after short delay
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSInteger rows = [_tableView numberOfRowsInSection:0];
        NSIndexPath *last = [NSIndexPath indexPathForRow:(rows - 1) inSection:0];
        [_tableView scrollToRowAtIndexPath:last atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    });
}

@end
