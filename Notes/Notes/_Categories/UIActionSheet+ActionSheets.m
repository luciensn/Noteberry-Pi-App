//
//  UIActionSheet+ActionSheets.m
//
//  Created by Scott Lucien on 1/22/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

#import "UIActionSheet+ActionSheets.h"

@implementation UIActionSheet (ActionSheets)

+ (UIActionSheet *)deleteNoteActionSheetWithDelegate:(id<UIActionSheetDelegate>)delegate
{
    NSString *cancel = NSLocalizedString(@"Cancel", nil);
    NSString *delete = NSLocalizedString(@"Delete Note", nil);
    return [[UIActionSheet alloc] initWithTitle:nil
                                       delegate:delegate
                              cancelButtonTitle:cancel
                         destructiveButtonTitle:delete otherButtonTitles:nil];
}

+ (UIActionSheet *)deleteGroupPromptWithName:(NSString *)name delegate:(id<UIActionSheetDelegate>)delegate
{
    NSString *cancel = NSLocalizedString(@"Cancel", nil);
    NSString *delete = NSLocalizedString(@"Delete", nil);
    NSString *combined = [NSString stringWithFormat:@"%@ %@", delete, name];
    UIActionSheet *confirm = [[UIActionSheet alloc] initWithTitle:nil
                                                         delegate:delegate
                                                cancelButtonTitle:cancel
                                           destructiveButtonTitle:combined
                                                otherButtonTitles:nil];
    return confirm;
}

@end
