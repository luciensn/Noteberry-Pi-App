//
//  GroupCell.m
//
//  Created by Scott Lucien on 1/25/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

#import "GroupCell.h"
#import "UIColor+ThemeColor.h"

@implementation GroupCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    if (!_editButtonsView) {
        _editButtonsView = [GroupCellEditButtonsView loadFromNib];
        
        // set styles
        [self.textLabel setFont:[UIFont systemFontOfSize:23]];
        
        // add the target/actions
        [_editButtonsView.deleteButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_editButtonsView.editButton addTarget:self action:@selector(editButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UITableViewCellScrollView")]) {
            for (UIView *sview in subview.subviews) {
                if ([sview isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")]) {
                    if (!_editButtonsView.superview) {
                    
                        // remove the "delete" button
                        for (UIView *view in sview.subviews) {
                            [view removeFromSuperview];
                        }
                        
                        // add the edit buttons
                        [sview addSubview:_editButtonsView];
                    }
                    break;
                }
            }
            break;
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = scrollView.contentOffset.x;
    if (offset > 81) {
        if (!_open) {
            [self setOpen:YES];
        }
    } else {
        if (_open) {
            [self setOpen:NO];
        }
    }
}

- (void)setOpen:(BOOL)open
{
    _open = open;
    
    // notify the delegate
    if (_groupCellDelegate) {
        if (open) {
            [_groupCellDelegate groupCellDidOpen:self];
        } else {
            [_groupCellDelegate groupCellDidClose:self];
        }
    }
}

#pragma mark - Actions

- (void)deleteButtonPressed:(id)sender
{
    if (_groupCellDelegate) {
        [_groupCellDelegate groupCellDidDelete:self];
    }
}

- (void)editButtonPressed:(id)sender
{
    if (_groupCellDelegate) {
        [_groupCellDelegate groupCellDidEdit:self];
    }
}

#pragma mark - Public Methods

- (void)addLongPressGestureWithTarget:(id)target action:(SEL)action delegate:(id<UIGestureRecognizerDelegate>)delegate
{
    _dragToReorderGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:target action:action];
    [_dragToReorderGesture setNumberOfTouchesRequired:1];
    [_dragToReorderGesture setNumberOfTapsRequired:0];
    [_dragToReorderGesture setMinimumPressDuration:0];
    [_dragToReorderGesture setDelaysTouchesBegan:NO];
    [_dragToReorderGesture setDelegate:delegate];
    [_editButtonsView.reorderImageView addGestureRecognizer:_dragToReorderGesture];
    [_editButtonsView.reorderImageView setUserInteractionEnabled:YES];
}


@end
