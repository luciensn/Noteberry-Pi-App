//
//  UIActionSheet+ActionSheets.h
//
//  Created by Scott Lucien on 1/22/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

@import UIKit;

@interface UIActionSheet (ActionSheets)

+ (UIActionSheet *)deleteNoteActionSheetWithDelegate:(id<UIActionSheetDelegate>)delegate;

+ (UIActionSheet *)deleteGroupPromptWithName:(NSString *)name delegate:(id<UIActionSheetDelegate>)delegate;

@end
