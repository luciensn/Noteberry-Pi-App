//
//  UITableView+RefreshControl.h
//
//  Created by Scott Lucien on 2/16/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

@import UIKit;

@interface UITableView (RefreshControl)

- (UIRefreshControl *)refreshControlWithTarget:(id)target action:(SEL)action;

@end
