//
//  TextInputCell.m
//
//  Created by Scott Lucien on 2/26/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

#import "TextInputCell.h"
#import "UIColor+ThemeColor.h"

#define L_PADDING 15
#define R_PADDING 15

@implementation TextInputCell

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
    _textField = [[UITextField alloc] initWithFrame:CGRectZero];
    [_textField setBorderStyle:UITextBorderStyleNone];
    [_textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_textField setSpellCheckingType:UITextSpellCheckingTypeNo];
    [_textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.contentView addSubview:_textField];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.textLabel setHighlighted:YES];
    [self.detailTextLabel setHidden:YES];
    
    // colors & fonts
    [_textField setTextColor:[UIColor blackColor]];
    [_textField setFont:[self.textLabel font]];
    
    // layout calculations
    CGFloat cellWidth = self.contentView.frame.size.width;
    CGFloat cellHeight = self.contentView.frame.size.height;
    CGFloat y = 0;
    CGFloat h = cellHeight;
    CGFloat w = cellWidth - R_PADDING - L_PADDING;
    CGRect textFieldFrame = CGRectMake(L_PADDING, y, w, h);
    [_textField setFrame:textFieldFrame];
}

@end
