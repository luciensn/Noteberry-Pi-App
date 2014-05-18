//
//  ListViewController.m
//
//  Created by Scott Lucien on 1/22/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

#import "ListViewController.h"
#import "NoteViewController.h"
#import "ListViewCell.h"

@interface ListViewController () <UITableViewDataSource, UITableViewDelegate, NoteViewControllerDelegate, UIGestureRecognizerDelegate>

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
@property (strong, nonatomic) Group *group;
@property (strong, nonatomic) NSMutableArray *notes;
@property (strong, nonatomic) UIView *snapshotView;

@end

#pragma mark -

@implementation ListViewController

- (id)initWithGroup:(Group *)group
{
    NSString *nib = @"ListViewController";
    self = [super initWithNibName:nib bundle:nil];
    if (self) {
        [self setGroup:group];
        [self setTitle:group.displayName];
    }
    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // navigation items
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem composeButtonWithTarget:self action:@selector(composeButtonPressed:)];
    
    // set up the tableView
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(64, 0, 0, 0);
    [_tableView setContentInset:edgeInsets];
    [_tableView setScrollIndicatorInsets:edgeInsets];
    [_tableView registerNib:[UINib nibWithNibName:@"ListViewCell" bundle:nil] forCellReuseIdentifier:CELL_IDENTIFIER];
    
    // set up the pull gesture hint    
    UIImage *shadowImage = [[UIImage imageNamed:@"shadow-top"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
    [_shadowImageView setImage:shadowImage];
    _pullPlus = [UIImage imageNamed:@"pull-arrow-inverted"];
    _pullArrow = [UIImage imageNamed:@"pull-arrow"];
    [_pullIconImageView setImage:_pullArrow];
    
    // sort the notes by date
    NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray *sortedArray = [_group.notes sortedArrayUsingDescriptors:@[sortByDate]];
    _notes = [NSMutableArray arrayWithArray:sortedArray];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self hideSnapshot];
    if ([_tableView isEditing]) {
        [_tableView setEditing:NO animated:NO];
    }
}

#pragma mark - UITableView DataSource

static NSString *const CELL_IDENTIFIER = @"NoteCell";

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _notes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListViewCell *cell = (ListViewCell *)[tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    Note *note = (Note *)_notes[indexPath.row];
    
    // format and display the note title and date strings
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell.stringLabel setText:[self getTitleFromText:note.text]];
    AppDelegate *delegate = [AppDelegate appDelegate];
    [cell.dateLabel setText:[delegate.dateFormatter stringFromDate:note.date withFormat:@"MMM d"]];
    [cell.stringLabel setHidden:NO];
    [cell.dateLabel setHidden:NO];
    
    [cell addLongPressGestureWithTarget:self action:@selector(handleCellLongPress:) delegate:self];
    [cell setNote:note];
    
    return cell;
}

#pragma mark - UITableView Delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"Delete", nil);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // delete the note and the cell
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // remove the note from the list
        Note *note = (Note *)_notes[indexPath.row];
        [_notes removeObject:note];
        
        // delete the note from core data
        [[CoreDataManager sharedManager] deleteNote:note];
        
        // remove the cell from the tableView
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // push in the note editor view controller
    Note *selectedNote = (Note *)_notes[indexPath.row];
    NoteViewController *noteViewController = [[NoteViewController alloc] initWithNote:selectedNote group:_group noteDelegate:self];
    [self.navigationController pushViewController:noteViewController animated:YES];
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
            [self showSnapshot];
            [self createNewNote];
        }
    }
}

#pragma mark - Cell Long Press Gesture

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

- (void)handleCellLongPress:(UILongPressGestureRecognizer *)recognizer
{
    // present share actions
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        ListViewCell *cell = (ListViewCell *)recognizer.view.superview.superview;
        NSArray *items = @[cell.note.text];
        UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
        [self presentViewController:activity animated:YES completion:nil];
    }
}

#pragma mark - View Controller Actions

- (void)composeButtonPressed:(id)sender
{
    [self createNewNote];
}

#pragma mark - NoteViewController Delegate

- (void)didSaveNote:(Note *)note
{
    // remove the note from its current spot in the list
    if ([_notes containsObject:note]) {
        [_notes removeObject:note];
    }
    
    // add the note to the top of the list
    if ([_notes count] < 1) {
        [_notes addObject:note];
    } else {
        [_notes insertObject:note atIndex:0];
    }
    
    // reload the tableView
    [self reloadTableView];
}

- (void)didDeleteNote:(Note *)note
{
    // remove the note from the list
    [_notes removeObject:note];
    
    // delete the note from core data
    [[CoreDataManager sharedManager] deleteNote:note];
    
    // reload the tableView
    [self reloadTableView];
}

#pragma mark - Private Methods

- (void)reloadTableView
{
    [_tableView reloadData];
}

- (NSString *)getTitleFromText:(NSString *)text
{
    // TODO: optimize this???
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [text stringByTrimmingCharactersInSet:whitespace];
}

- (void)showSnapshot
{
    _snapshotView = [self.view snapshotViewAfterScreenUpdates:NO];
    [self.view addSubview:_snapshotView];
}

- (void)hideSnapshot
{
    [_snapshotView removeFromSuperview];
    [self setSnapshotView:nil];
}

- (void)createNewNote
{
    NoteViewController *noteViewController = [[NoteViewController alloc] initWithNote:nil group:_group noteDelegate:self];
    [self.navigationController pushViewController:noteViewController animated:YES];
}

@end
