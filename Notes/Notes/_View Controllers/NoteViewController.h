//
//  NoteViewController.h
//
//  Created by Scott Lucien on 11/2/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

#import "BaseViewController.h"
#import "Group.h"
#import "Note.h"

@protocol NoteViewControllerDelegate <NSObject>
- (void)didSaveNote:(Note *)note;
- (void)didDeleteNote:(Note *)note;
@end

@interface NoteViewController : BaseViewController

- (id)initWithNote:(Note *)note group:(Group *)group noteDelegate:(id<NoteViewControllerDelegate>)noteDelegate;

@end
