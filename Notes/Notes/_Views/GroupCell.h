//
//  GroupCell.h
//
//  Created by Scott Lucien on 1/25/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

@import UIKit;

#import "GroupCellEditButtonsView.h"

@class GroupCell;

@protocol GroupCellDelegate <NSObject>
- (void)groupCellDidDelete:(GroupCell *)cell;
- (void)groupCellDidEdit:(GroupCell *)cell;
- (void)groupCellDidOpen:(GroupCell *)cell;
- (void)groupCellDidClose:(GroupCell *)cell;
@end

@interface GroupCell : UITableViewCell <UIScrollViewDelegate>

// Properties
@property (weak, nonatomic) id<GroupCellDelegate> groupCellDelegate;
@property (strong, nonatomic) GroupCellEditButtonsView *editButtonsView;
@property (strong, nonatomic) UILongPressGestureRecognizer *dragToReorderGesture;
@property (nonatomic) BOOL open;

// Methods
- (void)addLongPressGestureWithTarget:(id)target action:(SEL)action delegate:(id<UIGestureRecognizerDelegate>)delegate;

@end
