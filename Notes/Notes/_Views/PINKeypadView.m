//
//  PINKeypadView.m
//
//  Created by Scott Lucien on 1/31/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

#import "PINKeypadView.h"
#import "PINKeypadButton.h"
#import "UIColor+ThemeColor.h"

@implementation PINKeypadView

- (id)initWithFrame:(CGRect)frame // suggested frame: CGRectMake(0, 116, 320, 344)
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setMultipleTouchEnabled:NO];
        [self setBackgroundColor:[UIColor clearColor]];
        [self addKeypadButtons];
    }
    return self;
}

- (void)addKeypadButtons
{
    // lay out the keypad buttons (0-9)
    for (NSInteger i = 0; i < 10; i++) {
        
        PINKeypadButton *button = [PINKeypadButton loadFromNib];
        [self addSubview:button];
        [button setTag:i];
        
        switch (i) {
            case 0:
                [button setFrame:CGRectMake(120, 264, 80, 80)];
                [button setNumber:0 letters:nil];
                break;
                
            case 1:
                [button setFrame:CGRectMake(26, 0, 80, 80)];
                [button setNumber:1 letters:nil];
                break;
                
            case 2:
                [button setFrame:CGRectMake(120, 0, 80, 80)];
                [button setNumber:2 letters:@"ABC"];
                break;
                
            case 3:
                [button setFrame:CGRectMake(214, 0, 80, 80)];
                [button setNumber:3 letters:@"DEF"];
                break;
                
            case 4:
                [button setFrame:CGRectMake(26, 88, 80, 80)];
                [button setNumber:4 letters:@"GHI"];
                break;
                
            case 5:
                [button setFrame:CGRectMake(120, 88, 80, 80)];
                [button setNumber:5 letters:@"JKL"];
                break;
                
            case 6:
                [button setFrame:CGRectMake(214, 88, 80, 80)];
                [button setNumber:6 letters:@"MNO"];
                break;
                
            case 7:
                [button setFrame:CGRectMake(26, 176, 80, 80)];
                [button setNumber:7 letters:@"PQRS"];
                break;
                
            case 8:
                [button setFrame:CGRectMake(120, 176, 80, 80)];
                [button setNumber:8 letters:@"TUV"];
                break;
                
            case 9:
                [button setFrame:CGRectMake(214, 176, 80, 80)];
                [button setNumber:9 letters:@"WXYZ"];
                break;
                
            default:
                break;
        }
        
        // add the pan gesture
        UILongPressGestureRecognizer *longfellowDeeds = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [longfellowDeeds setNumberOfTouchesRequired:1];
        [longfellowDeeds setNumberOfTapsRequired:0];
        [longfellowDeeds setMinimumPressDuration:0];
        [longfellowDeeds setDelaysTouchesBegan:NO];
        [longfellowDeeds setDelegate:self];
        [button addGestureRecognizer:longfellowDeeds];
    }
    
    // add the delete button
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [deleteButton setFrame:CGRectMake(214, 264, 80, 80)];
    [deleteButton addTarget:self action:@selector(deleteTapped:) forControlEvents:UIControlEventTouchUpInside];
    [deleteButton setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];
    [deleteButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]];
    [deleteButton setTintColor:[UIColor themeColor]];
    [self addSubview:deleteButton];
}

#pragma mark - UIPanGestureRecognizer

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // restrict to one button touch at a time
    if (_touchInProgress) {
        return NO;
    }
    
    [self setTouchInProgress:YES];
    return YES;
}

- (void)handlePanGesture:(UILongPressGestureRecognizer *)recognizer
{
    /* TOUCH START */
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        PINKeypadButton *button = (PINKeypadButton *)recognizer.view;
        [button showBackground];
        
        // trigger the 'touch down' event
        if (self.keypadDelegate && [self.keypadDelegate respondsToSelector:@selector(numericButtonPressedWithIndex:)]) {
            [self.keypadDelegate numericButtonPressedWithIndex:button.tag];
        }
    }
    
    /* TOUCH MOVE */
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        // set highlighted based on how far the touch has moved from the button
        PINKeypadButton *button = (PINKeypadButton *)recognizer.view;
        CGPoint center = button.center;
        CGPoint touch = [recognizer locationInView:self];
        CGFloat xDist = (touch.x - center.x);
        CGFloat yDist = (touch.y - center.y);
        CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
        if (distance < 42) {
            [button showBackground];
        } else {
            [button hideBackground];
        }
    }
    
    /* TOUCH END */
    else if (recognizer.state == UIGestureRecognizerStateCancelled ||
             recognizer.state == UIGestureRecognizerStateEnded ||
             recognizer.state == UIGestureRecognizerStateFailed)
    {
        PINKeypadButton *button = (PINKeypadButton *)recognizer.view;
        [button hideBackground];
        
        [self setTouchInProgress:NO];
    }
}

#pragma mark - Actions

- (void)deleteTapped:(id)sender
{
    if (self.keypadDelegate && [self.keypadDelegate respondsToSelector:@selector(deleteButtonPressed)]) {
        [self.keypadDelegate deleteButtonPressed];
    }
}

@end
