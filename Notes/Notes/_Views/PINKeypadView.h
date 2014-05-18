//
//  PINKeypadView.h
//
//  Created by Scott Lucien on 1/31/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

@import UIKit;

@class PINKeypadView;

@protocol PINKeypadDelegate <NSObject>
- (void)numericButtonPressedWithIndex:(NSInteger)buttonIndex;
- (void)deleteButtonPressed;
@end

@interface PINKeypadView : UIView <UIGestureRecognizerDelegate>

// Properties
@property (weak, nonatomic) id<PINKeypadDelegate> keypadDelegate;
@property (nonatomic) BOOL touchInProgress;

@end

