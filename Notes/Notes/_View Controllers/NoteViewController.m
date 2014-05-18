//
//  NoteViewController.m
//
//  Created by Scott Lucien on 11/2/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

#import "NoteViewController.h"
#import "PinManager.h"

@interface NoteViewController () <UITextViewDelegate, UIActionSheetDelegate>

// IBOutlets
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *tableHeaderBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *shadowImageView;

// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableHeaderBackgroundTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shadowTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

// Properties
@property (weak, nonatomic) id<NoteViewControllerDelegate> noteDelegate;
@property (strong, nonatomic) UIBarButtonItem *composeButton;
@property (strong, nonatomic) UIBarButtonItem *doneButton;
@property (strong, nonatomic) Group *group;
@property (strong, nonatomic) Note *note;
@property (nonatomic) BOOL textHasChanged;
@property (nonatomic) BOOL keyboardIsShowing;

// IBActions
- (IBAction)sharePressed:(id)sender;
- (IBAction)trashPressed:(id)sender;

@end

#pragma mark -

@implementation NoteViewController

- (id)initWithNote:(Note *)note group:(Group *)group noteDelegate:(id<NoteViewControllerDelegate>)noteDelegate
{
    NSString *nibName = @"NoteViewController";
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        if (group) {
            [self setGroup:group];
        }
        if (note) {
            [self setNote:note];
        }
        if (noteDelegate) {
            [self setNoteDelegate:noteDelegate];
        }
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
    
    // set up the text view
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [_textView setTextContainerInset:UIEdgeInsetsMake(80, 10, 80, 10)];
    [_textView setDelegate:self];
    
    // set up the shadow image
    UIImage *shadowImage = [[UIImage imageNamed:@"shadow-top"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
    [_shadowImageView setImage:shadowImage];
    
    
    //[_textView setDataDetectorTypes:UIDataDetectorTypeAll];
    
    
    // set up the bar button items
    [self setComposeButton:[UIBarButtonItem composeButtonWithTarget:self action:@selector(composePressed:)]];
    [self setDoneButton:[UIBarButtonItem doneButtonWithTarget:self action:@selector(donePressed:)]];
    [self.navigationItem setRightBarButtonItem:[UIBarButtonItem composeButtonWithTarget:self action:@selector(composePressed:)]];
    
    // display the note if there is one
    if (_note) {
        [_textView setText:_note.text];
        [self updateDateLabelWithDate:_note.date];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerForNotifications];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([[_textView text] length] < 1) {
        [_textView becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_textView resignFirstResponder];
    [self saveOrDelete];
    [self unregisterForNotifications];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - NSNotificationCenter

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)unregisterForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

#pragma mark - Keyboard Animations

- (void)keyboardDidChangeFrame:(NSNotification *)notification
{
    if (_keyboardIsShowing) {
        NSDictionary *info = [notification userInfo];
        NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardFrame = [kbFrame CGRectValue];
        CGFloat height = keyboardFrame.size.height;
        [_bottomConstraint setConstant:height];
        [self.view layoutIfNeeded];
        [_textView scrollRangeToVisible:_textView.selectedRange];
    }
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    [self setKeyboardIsShowing:YES];
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    CGFloat height = keyboardFrame.size.height;
    [_bottomConstraint setConstant:height];
    [self.view layoutIfNeeded];
    [_textView scrollRangeToVisible:_textView.selectedRange];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    // TODO: fix the scroll-to-bottom problem when keyboard dismisses
    
    //CGPoint offset = _textView.contentOffset;
    //NSLog(@"%f", offset.y);
    
    [self setKeyboardIsShowing:NO];
    [_bottomConstraint setConstant:0];
    [self.view layoutIfNeeded];
    
//    NSLog(@"%f", _textView.contentSize.height );
//    
//    if (offset.y > (_textView.contentSize.height - _textView.frame.size.height - 80)) {
//        offset.y = (_textView.contentSize.height - _textView.frame.size.height);
//    }
//    
//    [_textView setContentOffset:offset animated:NO];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _textView) {
        
        // move the header view and shadow
        CGFloat normalized = -(scrollView.contentOffset.y);
        [_shadowTopConstraint setConstant:(58 + normalized)];
        [_tableHeaderBackgroundTopConstraint setConstant:(-256 + normalized)];
    }
}

#pragma mark - Actions

- (void)donePressed:(id)sender
{
    if (![self textViewIsEmpty]) {
        [self saveThisNote];
        [self updateDateLabelWithDate:_note.date];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    [_textView resignFirstResponder];
}

- (void)composePressed:(id)sender
{
    // save this note and create a new note
    [self saveOrDelete];
    [self setNote:nil];
    [_dateLabel setText:@""];
    [_textView setText:@""];
    [_textView becomeFirstResponder];
}

- (IBAction)sharePressed:(id)sender
{
    // present share actions
    NSString *message = _textView.text;
    NSArray *items = @[message];
    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
//    [activity setExcludedActivityTypes:@[UIActivityTypeAddToReadingList,
//                                         UIActivityTypeAssignToContact,
//                                         UIActivityTypePrint,
//                                         UIActivityTypeSaveToCameraRoll]];
//    NSString *mailSubject = NSLocalizedString(@"Check out this app!", nil);
//    [activity setValue:mailSubject forKey:@"subject"];
    [self presentViewController:activity animated:YES completion:nil];
}

- (IBAction)trashPressed:(id)sender
{
    UIActionSheet *actions = [UIActionSheet deleteNoteActionSheetWithDelegate:self];
    [actions showInView:self.view];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.navigationItem setRightBarButtonItem:_doneButton animated:YES];
    
    // TODO: disable link detection
    //[_textView setDataDetectorTypes:UIDataDetectorTypeNone];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self.navigationItem setRightBarButtonItem:_composeButton animated:YES];
    
    // TODO: enable link detection
    //[_textView setDataDetectorTypes:UIDataDetectorTypeAll];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self setTextHasChanged:YES];
    [_textView scrollRangeToVisible:_textView.selectedRange];
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self deleteThisNote];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Private Methods

- (BOOL)textViewIsEmpty
{
    NSString *rawString = [_textView text];
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
    if ([trimmed length] == 0) {
        return YES;
    } else {
        return NO;
    }
}

- (void)updateDateLabelWithDate:(NSDate *)date
{
    AppDelegate *delegate = [AppDelegate appDelegate];
    [delegate.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [delegate.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [_dateLabel setText:[delegate.dateFormatter stringFromDate:date]];
}

- (void)saveOrDelete
{
    if ([self textViewIsEmpty]) {
        [self deleteThisNote];
    } else {
        [self saveThisNote];
    }
}

- (void)saveThisNote
{
    if (_textHasChanged) {
        if (_note) {
            
            // update the note text & date
            [_note setText:[_textView text]];
            [_note setDate:[NSDate date]];
            
        } else {
            
            // create a new note in this group
            Note *newNote = [[CoreDataManager sharedManager] newNoteInGroup:_group];
            [newNote setText:[_textView text]];
            [newNote setDate:[NSDate date]];
            [self setNote:newNote];
        }
        
        [self setTextHasChanged:NO];
        
        // notify the delegate to save this note
        if (_noteDelegate) {
            [_noteDelegate didSaveNote:_note];
        }
    }
}

- (void)deleteThisNote
{
    if (_note) {
        
        // notify the delegate to delete this note
        if (_noteDelegate) {
            [_noteDelegate didDeleteNote:_note];
        }
    }
}

#pragma mark - Application Events

- (void)didEnterBackground:(NSNotification *)notification
{
    // the equivalent of "donePressed:" method without animation
    if (![self textViewIsEmpty]) {
        [self saveThisNote];
        [self updateDateLabelWithDate:_note.date];
    } else {
        [self.navigationController popViewControllerAnimated:NO];
    }
    
    // dismiss the keyboard if pin is enabled (because of the splash screen)
    if ([PinManager pinIsEnabled]) {
        [_textView resignFirstResponder];
    }
    
    // save the context for good measure
    [[CoreDataManager sharedManager] saveContext];
}


@end
