//
//  PINViewController.m
//
//  Created by Scott Lucien on 11/2/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

#import "PINViewController.h"
#import "PinManager.h"
#import "UIView+EasingAnimation.h"

typedef NS_ENUM(NSInteger, PinMode) {
    PinLockedMode,
    EnterPinMode,
    CreateNewPinMode,
    CreateNewPinModeConfirm,
    ChangePinMode,
    ChangePinModeNewPin,
    ChangePinModeConfim
};

@interface PINViewController ()

// IBOutlets
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *keypadContainer;
@property (weak, nonatomic) IBOutlet UIImageView *dotsImageView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keypadBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dotsImageViewLeftConstraint;

// Properties
@property (nonatomic, copy) PinCompletionBlock completion;
@property (strong, nonatomic) PINKeypadView *keypadView;
@property (strong, nonatomic) NSString *pin;
@property (strong, nonatomic) NSString *sequence;
@property (nonatomic) PinMode pinMode;

@end

#pragma mark -

@implementation PINViewController

- (id)initWithPinLockedModeWithCompletion:(PinCompletionBlock)completion
{
    self = [self init];
    if (self) {
        [self setPinMode:PinLockedMode];
        [self setCompletion:completion];
    }
    return self;
}

- (id)initWithEnterPinModeWithCompletion:(PinCompletionBlock)completion
{
    self = [self init];
    if (self) {
        [self setPinMode:EnterPinMode];
        [self setCompletion:completion];
    }
    return self;
}

- (id)initWithCreateNewPinModeWithCompletion:(PinCompletionBlock)completion
{
    self = [self init];
    if (self) {
        [self setPinMode:CreateNewPinMode];
        [self setCompletion:completion];
    }
    return self;
}

- (id)initWithChangePinModeWithCompletion:(PinCompletionBlock)completion
{
    self = [self init];
    if (self) {
        [self setPinMode:ChangePinMode];
        [self setCompletion:completion];
    }
    return self;
}

- (id)init
{
    NSString *nibName = @"PINViewController";
    self = [super initWithNibName:nibName bundle:nil];
    return self;
}

#pragma mark - View Life Cycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // add the keypad view
    CGRect keypadFrame = CGRectMake(0, 0, 320, 344);
    _keypadView = [[PINKeypadView alloc] initWithFrame:keypadFrame];
    [_keypadView setKeypadDelegate:self];
    [_keypadContainer addSubview:_keypadView];
    [_keypadContainer setBackgroundColor:[UIColor clearColor]];
    if ([[UIScreen mainScreen] bounds].size.height < 568) {
        [_keypadBottomConstraint setConstant:20];
    }
    
    // set up the error label
    [_errorLabel setBackgroundColor:self.view.backgroundColor];
    [_errorLabel setTextColor:[UIColor themeColor]];
    [_errorLabel setHidden:YES];
    
    // set up the pin sequence image view
    [_dotsImageView setTintColor:[UIColor themeColor]];
    [self resetSequence];
    
    // navigation items
    if (_pinMode != PinLockedMode) {
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem cancelButtonWithTarget:self action:@selector(cancelPressed:)];
    }
    
    /* PIN LOCKED MODE */
    if (_pinMode == PinLockedMode) {
        [self setPin:[PinManager getPin]];
    }
    
    /* ENTER PIN MODE */
    else if (_pinMode == EnterPinMode) {
        [self setPin:[PinManager getPin]];
    }
    
    /* CHANGE PIN MODE */
    else if (_pinMode == ChangePinMode) {
        [self setPin:[PinManager getPin]];
    }
}

#pragma mark - PINKeypadDelegate

- (void)deleteButtonPressed
{
    [self deleteDigit];
}

- (void)numericButtonPressedWithIndex:(NSInteger)buttonIndex
{
    NSString *digit = [NSString stringWithFormat:@"%ld", (long)buttonIndex];
    [self addDigit:digit];
}

#pragma mark - Private Methods

- (void)setPinMode:(PinMode)pinMode
{
    _pinMode = pinMode;
    
    /* PIN LOCKED MODE */
    if (pinMode == PinLockedMode) {
        [self setTitle:NSLocalizedString(@"Enter Passcode", nil)];
    }
    
    /* ENTER PIN MODE */
    else if (pinMode == EnterPinMode) {
        [self setTitle:NSLocalizedString(@"Enter Passcode", nil)];
    }
    
    /* CREATE NEW PIN MODE */
    else if (pinMode == CreateNewPinMode) {
        [self setTitle:NSLocalizedString(@"Enter New Passcode", nil)];
    } else if (pinMode == CreateNewPinModeConfirm) {
        [self setTitle:NSLocalizedString(@"Re-Enter New Passcode", nil)];
    }
    
    /* CHANGE PIN MODE */
    else if (pinMode == ChangePinMode) {
        [self setTitle:NSLocalizedString(@"Enter Old Passcode", nil)];
    } else if (pinMode == ChangePinModeNewPin) {
        [self setTitle:NSLocalizedString(@"Enter New Passcode", nil)];
    } else if (pinMode == ChangePinModeConfim) {
        [self setTitle:NSLocalizedString(@"Re-Enter New Passcode", nil)];
    }
}

- (void)addDigit:(NSString *)digit
{
    if ([_sequence length] < 4) {
        if (_sequence.length == 3) {
            [_keypadView setUserInteractionEnabled:NO];
        }
        NSString *newSequence = [NSString stringWithFormat:@"%@%@", _sequence, digit];
        [self setSequence:newSequence];
        [self updateDisplay];
        if (newSequence.length == 4) {
            double delayInSeconds = 0.2;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self evaluateSequence];
            });
        }
    }
}

- (void)deleteDigit
{
    if (_sequence.length > 0) {
        NSString *newSequence = [_sequence substringToIndex:(_sequence.length - 1)];
        [self setSequence:newSequence];
    }
    [self updateDisplay];
}

- (void)updateDisplay
{
    NSInteger num = _sequence.length;
    if (num == 0) {
        UIImage *image = [[UIImage imageNamed:@"sequence-0"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_dotsImageView setImage:image];
    } else if (num == 1) {
        UIImage *image = [[UIImage imageNamed:@"sequence-1"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_dotsImageView setImage:image];
    } else if (num == 2) {
        UIImage *image = [[UIImage imageNamed:@"sequence-2"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_dotsImageView setImage:image];
    } else if (num == 3) {
        UIImage *image = [[UIImage imageNamed:@"sequence-3"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_dotsImageView setImage:image];
    } else {
        UIImage *image = [[UIImage imageNamed:@"sequence-4"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_dotsImageView setImage:image];
    }
    
    // hide the error label
    //[_errorLabel setHidden:YES];
}

- (void)evaluateSequence
{
    /* PIN LOCKED MODE */
    if (_pinMode == PinLockedMode) {
        if ([_sequence isEqualToString:_pin]) {
            [self finishWithSuccess:YES];
        } else {
            [self resetSequenceWithError];
        }
    }
    
    /* ENTER PIN MODE */
    else if (_pinMode == EnterPinMode) {
        if ([_sequence isEqualToString:_pin]) {
            [self finishWithSuccess:YES];
        } else {
            [self resetSequenceWithError];
        }
    }
    
    /* CREATE NEW PIN MODE */
    else if (_pinMode == CreateNewPinMode) {
        [self setPin:_sequence];
        [self createNewPinGoToConfirmationMode];
    } else if (_pinMode == CreateNewPinModeConfirm) {
        if ([_sequence isEqualToString:_pin]) {
            [self createNewPinConfirmedSuccessfully];
        } else {
            [self createNewPinStartOver];
        }
    }
    
    /* CHANGE PIN MODE */
    else if (_pinMode == ChangePinMode) {
        if ([_sequence isEqualToString:_pin]) {
            [self changePinGoToNewPinMode];
        } else {
            [self resetSequenceWithError];
        }
    } else if (_pinMode == ChangePinModeNewPin) {
        [self setPin:_sequence];
        [self changePinGoToConfirmationMode];
    } else if (_pinMode == ChangePinModeConfim) {
        if ([_sequence isEqualToString:_pin]) {
            [self changePinConfirmedSuccessfully];
        } else {
            [self changePinStartOver];
        }
    }
}

- (void)resetSequence
{
    [self setSequence:@""];
    [self updateDisplay];
}

- (void)resetSequenceWithError
{
    [self resetSequence];
    
    // show pins didn't match error alert
    if (_pinMode == CreateNewPinModeConfirm || _pinMode == ChangePinModeConfim) {
        UIAlertView *alert = [UIAlertView pinsDidntMatchErrorWithDelegate:nil];
        [alert show];
    } else {
        [self shakePinSequenceImage];
    }
    
    // enable user input
    [_keypadView setUserInteractionEnabled:YES];
}

- (void)shakePinSequenceImage
{
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    anim.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-6.0f, 0.0f, 0.0f)],
                    [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(6.0f, 0.0f, 0.0f)]];
    anim.autoreverses = YES;
    anim.repeatCount = 2.0f;
    anim.duration = 0.08f;
    [_dotsImageView.layer addAnimation:anim forKey:nil];
}

- (void)slideDotsToTheLeft
{
    CGFloat width = CGRectGetWidth(_dotsImageView.frame);
    CGFloat left = -width;
    CGFloat right = CGRectGetWidth(self.view.frame);
    CGFloat middle = ((right - width) / 2);
    
    [UIView animateWithDuration:0.1 animations:^{
        [_dotsImageViewLeftConstraint setConstant:left];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [_dotsImageViewLeftConstraint setConstant:right];
        [self.view layoutIfNeeded];
        [UIView animateWithEasing:^{
            [_dotsImageViewLeftConstraint setConstant:middle];
            [self.view layoutIfNeeded];
        }];
    }];
}

- (void)finishWithSuccess:(BOOL)success
{
    if (_completion) {
        _completion(success);
    }
}

#pragma mark - Create New Pin Mode

- (void)createNewPinGoToConfirmationMode
{
    [self resetSequence];
    [self slideDotsToTheLeft];
    [self setPinMode:CreateNewPinModeConfirm];
    [_keypadView setUserInteractionEnabled:YES];
}

- (void)createNewPinStartOver
{
    [self setPin:nil];
    [self resetSequenceWithError];
    [self setPinMode:CreateNewPinMode];
}

- (void)createNewPinConfirmedSuccessfully
{
    [PinManager setPin:_pin];
    [PinManager setPinDelay:PinDelayNone];
    [self finishWithSuccess:YES];
}

#pragma mark - Change Pin Mode

- (void)changePinGoToNewPinMode
{
    [self setPin:nil];
    [self resetSequence];
    [self slideDotsToTheLeft];
    [self setPinMode:ChangePinModeNewPin];
    [_keypadView setUserInteractionEnabled:YES];
}

- (void)changePinGoToConfirmationMode
{
    [self resetSequence];
    [self slideDotsToTheLeft];
    [self setPinMode:ChangePinModeConfim];
    [_keypadView setUserInteractionEnabled:YES];
}

- (void)changePinStartOver
{
    [self setPin:nil];
    [self resetSequenceWithError];
    [self setPinMode:ChangePinModeNewPin];
}

- (void)changePinConfirmedSuccessfully
{
    [PinManager setPin:_pin];
    [self finishWithSuccess:YES];
}

#pragma mark - View Controller Actions

- (void)cancelPressed:(id)sender
{
    [self finishWithSuccess:NO];
}

@end
