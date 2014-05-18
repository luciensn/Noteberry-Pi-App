//
//  PINKeypadButton.h
//
//  Created by Scott Lucien on 1/31/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

@import UIKit;

@interface PINKeypadButton : UIView <UIGestureRecognizerDelegate>

+ (PINKeypadButton *)loadFromNib;

// IBOutlets
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *foregroungImageView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

// Methods
- (void)setNumber:(NSInteger)number letters:(NSString *)letters;
- (void)showBackground;
- (void)hideBackground;

@end

