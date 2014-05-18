//
//  GroupCellEditButtonsView.h
//
//  Created by Scott Lucien on 2/13/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

@import UIKit;

@interface GroupCellEditButtonsView : UIView

+ (GroupCellEditButtonsView *)loadFromNib;

// IBOutlets
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIImageView *reorderImageView;

@end

