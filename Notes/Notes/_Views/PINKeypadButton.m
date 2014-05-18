//
//  PINKeypadButton.m
//
//  Created by Scott Lucien on 1/31/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

#import "PINKeypadButton.h"
#import "UIColor+ThemeColor.h"

@implementation PINKeypadButton 

+ (PINKeypadButton *)loadFromNib
{
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"PINKeypadButton" owner:self options:nil];
    return (PINKeypadButton *)[nibViews objectAtIndex:0];
}

#pragma mark -

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // set the styles
    [_backgroundView setBackgroundColor:[UIColor themeColor]];
    [_backgroundView setAlpha:0];
    
    UIImage *bgImage = [_backgroundImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_backgroundImageView setImage:bgImage];
    [_backgroundImageView setTintColor:[UIColor whiteColor]];
    
    UIImage *fgImage = [_foregroungImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_foregroungImageView setImage:fgImage];
    [_foregroungImageView setTintColor:[UIColor themeColor]];
}

- (void)configureNormalAttributedString
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:_textLabel.attributedText];
    
    // number text
    NSDictionary *numberAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Thin" size:31],
                                       NSForegroundColorAttributeName:[UIColor themeColor]};
    [attributedString setAttributes:numberAttributes range:NSMakeRange(0, 1)];
    
    // letter text
    if (attributedString.length > 1) {
        NSDictionary *letterAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:11],
                                           NSForegroundColorAttributeName:[UIColor themeColor]};
        [attributedString setAttributes:letterAttributes range:NSMakeRange(2, (attributedString.length - 2))];
    }
    
    [_textLabel setAttributedText:attributedString];
}

- (void)configureHighlightedAttributedString
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:_textLabel.attributedText];
    
    // number text
    NSDictionary *numberAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Thin" size:31],
                                       NSForegroundColorAttributeName:[UIColor whiteColor]};
    [attributedString setAttributes:numberAttributes range:NSMakeRange(0, 1)];
    
    // letter text
    if (attributedString.length > 1) {
        NSDictionary *letterAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:11],
                                           NSForegroundColorAttributeName:[UIColor whiteColor]};
        [attributedString setAttributes:letterAttributes range:NSMakeRange(2, (attributedString.length - 2))];
    }
    
    [_textLabel setAttributedText:attributedString];
}

#pragma mark - Public Methods

- (void)setNumber:(NSInteger)number letters:(NSString *)letters
{
    NSString *completeString;
    if (letters) {
        completeString = [NSString stringWithFormat:@"%ld %@", (long)number, letters];
    } else {
        completeString = [NSString stringWithFormat:@"%ld", (long)number];
    }
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:completeString];
    [_textLabel setAttributedText:attributedString];
    [self configureNormalAttributedString];
    
    // change the frame of the '1' label
    if (number == 1) {
        CGRect labelFrame = _textLabel.frame;
        labelFrame.size.height = 62;
        [_textLabel setFrame:labelFrame];
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
}

- (void)showBackground
{
    [self configureHighlightedAttributedString];
    [_backgroundView setAlpha:1];
}

- (void)hideBackground
{
    [self configureNormalAttributedString];
    if (_backgroundView.alpha > 0) {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction animations:^{
            [_backgroundView setAlpha:0];
        } completion:nil];
    }
}


@end
