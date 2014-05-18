//
//  ListViewCell.m
//
//  Created by Scott Lucien on 1/22/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

#import "ListViewCell.h"

@implementation ListViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // hide the default labels
    [self.textLabel setHidden:YES];
    [self.detailTextLabel setHidden:YES];
}

- (void)addLongPressGestureWithTarget:(id)target action:(SEL)action delegate:(id<UIGestureRecognizerDelegate>)delegate
{
    if (!_longPressGesture) {
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:target action:action];
        [_longPressGesture setDelegate:delegate];
        [_longPressGesture setMinimumPressDuration:1];
        [_longPressGesture setNumberOfTouchesRequired:1];
        [_longPressGesture setDelaysTouchesBegan:NO];
        [self.contentView addGestureRecognizer:_longPressGesture];
    }
}

@end
