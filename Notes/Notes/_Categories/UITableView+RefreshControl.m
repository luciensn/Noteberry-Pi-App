//
//  UITableView+RefreshControl.m
//
//  Created by Scott Lucien on 2/16/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

#import "UITableView+RefreshControl.h"

@implementation UITableView (RefreshControl)

- (UIRefreshControl *)refreshControlWithTarget:(id)target action:(SEL)action
{
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:target action:action forControlEvents:UIControlEventValueChanged];
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    [tableViewController setTableView:self];
    [tableViewController setRefreshControl:refreshControl];
    return refreshControl;
}

@end
