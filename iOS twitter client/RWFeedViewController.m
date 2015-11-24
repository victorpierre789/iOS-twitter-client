//
//  RWTableViewController.m
//  DeviantArtBrowser
//
//  Created by Victor on 06/10/15.
//  Copyright (c) 2015 Victor. All rights reserved.
//

#import "RWFeedViewController.h"

#import "TWBSocialHelper.h"
#import "UIImageView+WebCache.h"
#import "JTSImageViewController.h"
#import "JTSImageInfo.h"
#import "UIImageView+LBBlurredImage.h"
#import "UIColor+HexString.h"
#import "STTweetLabel.h"

#import "RWBasicCell.h"
#import "RWImageCell.h"

static NSString * const RWBasicCellIdentifier = @"RWBasicCell";
static NSString * const RWImageCellIdentifier = @"RWImageCell";

@interface RWFeedViewController ()

@property (nonatomic) TWBSocialHelper *localInstance;

@property (strong, nonatomic) NSArray *array;

@property (nonatomic,strong) UIRefreshControl *refreshControl;

@end

@implementation RWFeedViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _localInstance = [TWBSocialHelper sharedHelper];
    [self requestAccessToTwitter];
    
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(twitterTimeline)
                                   userInfo:nil
                                    repeats:NO];
    
    self.button2.layer.cornerRadius = 17.5;
    self.button2.layer.masksToBounds = YES;
    
    self.button3.layer.cornerRadius = 30;
    self.button3.layer.masksToBounds = YES;
    self.button3.backgroundColor = [UIColor colorWithHexString:@"#ff3366"];
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    self.refreshControl.tintColor = [UIColor whiteColor];
    
    [self.imageView setImageToBlur:[UIImage imageNamed:@"image-header.png"]
                        blurRadius:kLBBlurredImageDefaultBlurRadius
                   completionBlock:^(){
                       NSLog(@"The blurred image has been set");
                   }];
    
    [self.imageView setClipsToBounds:YES];
    
    self.button.layer.cornerRadius = 17.5;
    self.button.layer.masksToBounds = YES;
    
    /*
    self.tableView.layer.cornerRadius = 10;
    self.tableView.layer.masksToBounds = YES;
     */
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"#17293a"];
    
    self.tweets.backgroundColor = [UIColor colorWithHexString:@"#5695E2"];
    
    self.tweets.layer.cornerRadius = 14; // this value vary as per your desire
    self.tweets.clipsToBounds = YES;
    
    self.photos.layer.borderWidth = 1;
    self.photos.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.photos.layer.cornerRadius = 14; // this value vary as per your desire
    self.photos.clipsToBounds = YES;
    
    self.abonnes.layer.borderWidth = 1;
    self.abonnes.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.abonnes.layer.cornerRadius = 14; // this value vary as per your desire
    self.abonnes.clipsToBounds = YES;
    
    self.abonnements.layer.borderWidth = 1;
    self.abonnements.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.abonnements.layer.cornerRadius = 14; // this value vary as per your desire
    self.abonnements.clipsToBounds = YES;
    
    self.textfield.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    
    self.textfield.layer.cornerRadius = 5;
    self.textfield.clipsToBounds = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    //[self downloadTimeline];
    //[self.tableView reloadData];
    NSLog(@"%@", _localInstance.twitterAccount);
}

#pragma mark - Twitter Access
-(void)requestAccessToTwitter
{
    
    _localInstance = [TWBSocialHelper sharedHelper];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [_localInstance requestAccessToTwitterAccounts];
    });
}

- (void)twitterTimeline {
    
    NSURL *timelineURL         = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
    
    NSDictionary *params       = @{@"count": @"200"};
    
    // Create a request
    SLRequest *getUserTimeline = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                    requestMethod:SLRequestMethodGET
                                                              URL:timelineURL
                                                       parameters:params];
    
    // Set the account for the request
    [getUserTimeline setAccount:_localInstance.twitterAccount];
    
    NSLog(@"%@", _localInstance.twitterAccount);
    
    
    // Perform the request
    [getUserTimeline performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        _array = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
        
        NSLog(@"%@", _array);
        
        if (self.array.count != 0) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView reloadData]; // Here we tell the table view to reload the data it just recieved.
                
            });
        }
    }];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self hasImageAtIndexPath:indexPath]) {
        RWImageCell *cell = [self.tableView dequeueReusableCellWithIdentifier:RWImageCellIdentifier forIndexPath:indexPath];
        // Remove seperator inset
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        
        // Prevent the cell from inheriting the Table View's margin settings
        if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            [cell setPreservesSuperviewLayoutMargins:NO];
        }
        
        // Explictly set your cell's layout margins
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
        
        [self configureImageCell:cell atIndexPath:indexPath];
        
        return cell;
    } else {
        RWBasicCell *cell = [self.tableView dequeueReusableCellWithIdentifier:RWBasicCellIdentifier forIndexPath:indexPath];
        // Remove seperator inset
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        
        // Prevent the cell from inheriting the Table View's margin settings
        if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            [cell setPreservesSuperviewLayoutMargins:NO];
        }
        
        // Explictly set your cell's layout margins
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
        [self configureBasicCell:cell atIndexPath:indexPath];
        
        return cell;
    }
}

- (BOOL)hasImageAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *tweet = _array[indexPath.row];
    
    NSString *imageHD2Array = [tweet valueForKeyPath:@"entities.media.media_url"];
    
    return imageHD2Array != nil;
}

- (void)configureImageCell:(RWImageCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *tweet = _array[indexPath.row];
    
    //NSLog(@"%@", tweet);
    
    cell.titleLabel.text = [NSString stringWithFormat:@"%@ @%@", [[tweet objectForKey:@"user"] valueForKey:@"name"], [[tweet objectForKey:@"user"] valueForKey:@"screen_name"]];
    
    cell.subtitleLabel.text = [tweet valueForKey:@"text"];
    
    cell.subtitleLabel.detectionBlock = ^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
        
        NSArray *hotWords = @[@"Handle", @"Hashtag", @"Link"];
        NSLog(@"%@", [NSString stringWithFormat:@"%@ [%d,%d]: %@%@", hotWords[hotWord], (int)range.location, (int)range.length, string, (protocol != nil) ? [NSString stringWithFormat:@" *%@*", protocol] : @""]);
    };
    
    NSString *dateString = [tweet valueForKey:@"created_at"];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [df setFormatterBehavior:NSDateFormatterBehavior10_4];
    [df setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
    NSDate *convertedDate = [df dateFromString:dateString];
    NSDate *todayDate = [NSDate date];
    double ti = [convertedDate timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    if(ti < 1) {
        dateString = @"jamais";
        NSLog(@"%@", dateString);
    } else 	if (ti < 60) {
        int diff = round(ti < 60);
        dateString = [NSString stringWithFormat:@"%dsec",diff];
        NSLog(@"%@", dateString);
    } else if (ti < 3600) {
        int diff = round(ti / 60);
        dateString = [NSString stringWithFormat:@"%dm",diff];
        NSLog(@"%@", dateString);
    } else if (ti < 86400) {
        int diff = round(ti / 60 / 60);
        dateString = [NSString stringWithFormat:@"%dh",diff];
        NSLog(@"%@", dateString);
    } else if (ti < 2629743) {
        int diff = round(ti / 60 / 60 / 24);
        dateString = [NSString stringWithFormat:@"%dj",diff];
        NSLog(@"%@", dateString);
    } else {
        dateString =  @"never";
        NSLog(@"%@", dateString);
    }
    
    cell.date.text = dateString;
    
    NSString *imageHD = [[tweet objectForKey:@"user"] valueForKey:@"profile_image_url"];
    
    NSString *stringWithoutSpaces = [imageHD
                                     stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
    
    NSLog(@"%@", stringWithoutSpaces);
    
    cell.profileImage.layer.cornerRadius = 25.5;
    cell.profileImage.layer.masksToBounds = YES;
    
    cell.profileImage.layer.borderWidth = 0.5;
    cell.profileImage.clipsToBounds = YES;
    cell.profileImage.layer.borderColor = [UIColor whiteColor].CGColor;
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:stringWithoutSpaces]
                          options:0
                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                             // progression tracking code
                         }
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                            if (image) {
                                // do something with image
                                cell.profileImage.image = image;
                                [cell.profileImage setClipsToBounds:YES];
                            }
                        }];
    
    NSArray *stringImage = [tweet valueForKeyPath:@"entities.media.media_url"];
    
    NSString *lienComplet = [NSString stringWithFormat:@"%@:small", stringImage[0]];
    
    NSLog(@"%@", lienComplet);
    
    if ([stringImage count] == 0) {
        
    } else {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:[NSURL URLWithString:lienComplet]
                              options:0
                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                 // progression tracking code
                             }
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                if (image) {
                                    // do something with image
                                    cell.customImageView.image = image;
                                    [cell.customImageView setClipsToBounds:YES];
                                    
                                    cell.customImageView.userInteractionEnabled = YES;
                                    cell.customImageView.tag = indexPath.row;
                                    
                                    UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myFunction:)];
                                    tapped.numberOfTapsRequired = 1;
                                    [cell.customImageView addGestureRecognizer:tapped];
                                }
                            }];
        
    }
}

- (void)myFunction:(UITapGestureRecognizer *)recognizer
{
    CGPoint swipeLocation = [recognizer locationInView:self.tableView];
    NSIndexPath *swipedIndexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
    RWImageCell *swipedCell = [self.tableView cellForRowAtIndexPath:swipedIndexPath];
    NSDictionary *tweet = _array[swipedIndexPath.row];
    NSArray *imageHD2Array = [tweet valueForKeyPath:@"entities.media.media_url"];
    NSLog(@"%@", imageHD2Array);
    NSURL *url = [NSURL URLWithString:imageHD2Array[0]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    // Create image info
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.image = [UIImage imageWithData:data];
    
    // Setup view controller
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                           initWithImageInfo:imageInfo
                                           mode:JTSImageViewControllerMode_Image
                                           backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];
    
    // Present the view controller.
    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
}

- (void)configureBasicCell:(RWBasicCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *tweet = _array[indexPath.row];
    
    //NSLog(@"%@", tweet);
    
    cell.titleLabel.text = [NSString stringWithFormat:@"%@ @%@", [[tweet objectForKey:@"user"] valueForKey:@"name"], [[tweet objectForKey:@"user"] valueForKey:@"screen_name"]];
    
    cell.subtitleLabel.text = [tweet valueForKey:@"text"];
    
    cell.subtitleLabel.detectionBlock = ^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
        
        NSArray *hotWords = @[@"Handle", @"Hashtag", @"Link"];
        NSLog(@"%@", [NSString stringWithFormat:@"%@ [%d,%d]: %@%@", hotWords[hotWord], (int)range.location, (int)range.length, string, (protocol != nil) ? [NSString stringWithFormat:@" *%@*", protocol] : @""]);
    };
    
    NSString *dateString = [tweet valueForKey:@"created_at"];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [df setFormatterBehavior:NSDateFormatterBehavior10_4];
    [df setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
    NSDate *convertedDate = [df dateFromString:dateString];
    NSDate *todayDate = [NSDate date];
    double ti = [convertedDate timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    if(ti < 1) {
        dateString = @"jamais";
        NSLog(@"%@", dateString);
    } else 	if (ti < 60) {
        int diff = round(ti < 60);
        dateString = [NSString stringWithFormat:@"%dsec", diff];
        NSLog(@"%@", dateString);
    } else if (ti < 3600) {
        int diff = round(ti / 60);
        dateString = [NSString stringWithFormat:@"%dm", diff];
        NSLog(@"%@", dateString);
    } else if (ti < 86400) {
        int diff = round(ti / 60 / 60);
        dateString = [NSString stringWithFormat:@"%dh", diff];
        NSLog(@"%@", dateString);
    } else if (ti < 2629743) {
        int diff = round(ti / 60 / 60 / 24);
        dateString = [NSString stringWithFormat:@"%dj", diff];
        NSLog(@"%@", dateString);
    } else {
        dateString =  @"never";
        NSLog(@"%@", dateString);
    }
    
    cell.date.text = dateString;
    
    NSString *imageHD = [[tweet objectForKey:@"user"] valueForKey:@"profile_image_url"];
    
    NSString *stringWithoutSpaces = [imageHD
                                     stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
    
    NSLog(@"%@", imageHD);
    
    cell.profileImage.layer.cornerRadius = 25.5;
    cell.profileImage.layer.masksToBounds = YES;
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:stringWithoutSpaces]
                          options:0
                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                             // progression tracking code
                         }
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                            if (image) {
                                // do something with image
                                cell.profileImage.image = image;
                                [cell.profileImage setClipsToBounds:YES];
                            }
                        }];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self hasImageAtIndexPath:indexPath]) {
        return [self heightForImageCellAtIndexPath:indexPath];
    } else {
        return [self heightForBasicCellAtIndexPath:indexPath];
    }
}

- (CGFloat)heightForImageCellAtIndexPath:(NSIndexPath *)indexPath {
    static RWImageCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:RWImageCellIdentifier];
    });
    
    [self configureImageCell:sizingCell atIndexPath:indexPath];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static RWBasicCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:RWBasicCellIdentifier];
    });
    
    [self configureBasicCell:sizingCell atIndexPath:indexPath];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(sizingCell.bounds));
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1.0f; // Add 1.0f for the cell separator height
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isLandscapeOrientation]) {
        if ([self hasImageAtIndexPath:indexPath]) {
            return 140.0f;
        } else {
            return 120.0f;
        }
    } else {
        if ([self hasImageAtIndexPath:indexPath]) {
            return 235.0f;
        } else {
            return 155.0f;
        }
    }
}

- (BOOL)isLandscapeOrientation {
    return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
}

-(void) refreshInvoked:(id)sender forState:(UIControlState)state {
    // Refresh table here...
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self twitterTimeline];
    [self.tableView reloadData];
    [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(endRefresh) userInfo:nil repeats:NO];
}

- (void)endRefresh
{
    [self.refreshControl endRefreshing];
    // show in the status bar that network activity is stoping
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - Navigation

@end
