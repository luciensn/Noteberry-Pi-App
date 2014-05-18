//
//  AboutViewController.m
//
//  Created by Scott Lucien on 11/23/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

@import MessageUI;

#import "AboutViewController.h"
#import "SettingsViewController.h"

@interface AboutViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

// IBOutlets
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// Properties
@property (strong, nonatomic) NSDictionary *infoDictionary;

@end

#pragma mark -

@implementation AboutViewController

- (id)initWithInfo:(NSDictionary *)dictionary
{
    NSString *nibName = @"GroupedTableViewController";
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        [self setInfoDictionary:dictionary];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:NSLocalizedString(@"About", nil)];
    
    // navigation items
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem doneButtonWithTarget:self action:@selector(donePressed:)];
    
    // set up the tableView
    UIEdgeInsets insets = UIEdgeInsetsMake(64, 0, 10, 0);
    [_tableView setContentInset:insets];
    [_tableView setScrollIndicatorInsets:insets];
    [_tableView setShowsVerticalScrollIndicator:NO];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
}

#pragma mark - UITableView Data Source

static NSString *CellIdentifier = @"AboutCell";

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //return 3;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 2;
    } else {
        return 3;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 24;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 88;
    } else {
        return 44;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // app name cell
    if (indexPath.section == 0) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        // app icon
        CGRect frame = CGRectMake(15, 14, 60, 60);
        UIButton *icon = [UIButton buttonWithType:UIButtonTypeSystem];
        [icon setBackgroundColor:[UIColor clearColor]];
        [icon setBackgroundImage:[UIImage imageNamed:@"app-icon-about"] forState:UIControlStateNormal];
        [icon setFrame:frame];
        [icon setUserInteractionEnabled:NO];
        [cell addSubview:icon];
        
        // app name label
        CGRect nameLabelFrame = CGRectMake(90, 24, 215, 22);
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameLabelFrame];
        [nameLabel setFont:[UIFont systemFontOfSize:17.f]];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setText:[_infoDictionary objectForKey:@"APPSTORE_NAME"]];
        [cell addSubview:nameLabel];
        
        // version label
        CGRect versionLabelFrame = CGRectMake(91, 46, 215, 22);
        UILabel *versionLabel = [[UILabel alloc] initWithFrame:versionLabelFrame];
        [versionLabel setFont:[UIFont systemFontOfSize:13.f]];
        [versionLabel setTextColor:[UIColor lightGrayColor]];
        [versionLabel setBackgroundColor:[UIColor clearColor]];
        NSString *versionNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString *versionString = [NSString stringWithFormat:@"Version %@", versionNumber];
        [versionLabel setText:versionString];
        [cell addSubview:versionLabel];
    }
    
    // company information
    else if (indexPath.section == 1) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
        [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
        [cell.textLabel setTextColor:[UIColor lightGrayColor]];
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Copyright", nil);
            cell.detailTextLabel.text = [_infoDictionary objectForKey:@"COPYRIGHT"];
        } else {
            cell.textLabel.text = NSLocalizedString(@"Twitter", nil);
            cell.detailTextLabel.text = [_infoDictionary objectForKey:@"TWITTER"];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
    }
    
    // help/support actions
    else if (indexPath.section == 2) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell.textLabel setFont:[UIFont systemFontOfSize:15.f]];
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Send Feedback", nil);
        } else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"Share This App", nil);
        } else {
            cell.textLabel.text = NSLocalizedString(@"Write a Review", nil);
        }
    }
    
    return cell;
}

#pragma mark - UITableView Delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self shouldHighlightAndSelect:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView shouldSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self shouldHighlightAndSelect:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            [self goToTwitter];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [self sendFeedback];
        } else if (indexPath.row == 1) {
            [self shareThisApp];
        } else if (indexPath.row == 2) {
            [self writeAReview];
        }
    }
}

#pragma mark - Actions

- (void)goToWebsite
{
    NSString *url = [_infoDictionary objectForKey:@"WEBSITE_URL"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    [self deselectTableViewRow:YES];
}

- (void)goToTwitter
{
    NSString *url = [_infoDictionary objectForKey:@"TWITTER_URL"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    [self deselectTableViewRow:YES];
}

- (void)sendFeedback
{
    NSString *email = [_infoDictionary objectForKey:@"EMAIL"];
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *newMail = [[MFMailComposeViewController alloc] init];
        [newMail setToRecipients:@[email]];
        NSString *appName = [_infoDictionary objectForKey:@"APPSTORE_NAME"];
        NSString *subject = [NSString stringWithFormat:@"Feedback : %@", appName];
        [newMail setSubject:subject];
        [newMail setMailComposeDelegate:self];
        [self presentViewController:newMail animated:YES completion:nil];
    }
    else {
        UIAlertView *message = [UIAlertView sendFeedbackToAddress:email delegate:self];
        [message show];
    }
}

- (void)shareThisApp
{
    NSString *message = [self getShareMessage];
    NSArray *items = @[message];
    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    [activity setExcludedActivityTypes:@[UIActivityTypeAddToReadingList,
                                         UIActivityTypeAssignToContact,
                                         UIActivityTypePrint,
                                         UIActivityTypeSaveToCameraRoll]];
    NSString *mailSubject = NSLocalizedString(@"Check out this app!", nil);
    [activity setValue:mailSubject forKey:@"subject"];
    [self presentViewController:activity animated:YES completion:nil];
    [self deselectTableViewRow:YES];
}

- (void)writeAReview
{
    NSString *url = [_infoDictionary objectForKey:@"APPSTORE_URL"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    [self deselectTableViewRow:YES];
}

- (void)donePressed:(id)sender
{
    SettingsViewController *settings = (SettingsViewController *)[self.navigationController.viewControllers objectAtIndex:0];
    [settings.settingsDelegate settingsViewControllerDidDismiss:settings];
}

#pragma mark - MailComposeViewController Delegate

- (NSString *)getShareMessage
{
    NSString *appName = [_infoDictionary objectForKey:@"APPSTORE_NAME"];
    NSString *url = [_infoDictionary objectForKey:@"SHORT_URL"];
    return [NSString stringWithFormat:@"%@ : %@", appName, url];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self deselectTableViewRow:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Methods

- (void)deselectTableViewRow:(BOOL)animated
{
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:animated];
}

- (BOOL)shouldHighlightAndSelect:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            return YES;
        }
    } else if (indexPath.section == 2) {
        return YES;
    }
    return NO;
}

@end
