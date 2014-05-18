//
//  ListViewCell.h
//
//  Created by Scott Lucien on 1/22/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

#import "CustomDeleteColorCell.h"
#import "Note.h"

@interface ListViewCell : CustomDeleteColorCell

// IBOutlets
@property (weak, nonatomic) IBOutlet UILabel *stringLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

// Properties
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGesture;
@property (weak, nonatomic) Note *note;

// Methods
- (void)addLongPressGestureWithTarget:(id)target action:(SEL)action delegate:(id<UIGestureRecognizerDelegate>)delegate;

@end
