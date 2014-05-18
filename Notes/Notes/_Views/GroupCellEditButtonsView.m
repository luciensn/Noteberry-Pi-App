//
//  GroupCellEditButtonsView.m
//
//  Created by Scott Lucien on 2/13/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

#import "GroupCellEditButtonsView.h"
#import "UIColor+ThemeColor.h"

@implementation GroupCellEditButtonsView

+ (GroupCellEditButtonsView *)loadFromNib
{
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"GroupCellEditButtonsView" owner:self options:nil];
    return (GroupCellEditButtonsView *)[nibViews objectAtIndex:0];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // set the styles
    [_deleteButton setBackgroundColor:[UIColor gray1]];
    [_editButton setBackgroundColor:[UIColor gray2]];
    [_reorderImageView setBackgroundColor:[UIColor gray3]];
    
    // reorder button image
    UIImage *reorder = [[UIImage imageNamed:@"reorder-small"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_reorderImageView setImage:reorder];
    [_reorderImageView setTintColor:[UIColor whiteColor]];
}

@end
