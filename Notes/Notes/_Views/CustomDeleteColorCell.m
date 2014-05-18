//
//  CustomDeleteColorCell.m
//
//  Created by Scott Lucien on 11/2/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

#import "CustomDeleteColorCell.h"
#import "UIColor+ThemeColor.h"

@implementation CustomDeleteColorCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // set the cell scroll view delegate to self
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:[UIScrollView class]]) {
                UIScrollView *scrollView = (UIScrollView *)subview;
                [scrollView setDelegate:self];
            }
        }
    }
    return self;
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // change the delete button color
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UITableViewCellScrollView")]) {
            for (UIView *sview in subview.subviews) {
                if ([sview isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")]) {
                    for (UIView *view in sview.subviews) {
                        if ([view isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationButton")]) {
                            UIButton *button = (UIButton *)view;
                            [button setBackgroundColor:[UIColor themeColor]];
                            break;
                        }
                    }
                    break;
                }
            }
            break;
        }
    }
}

@end
