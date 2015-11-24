//
//  ViewController.m
//  LTNavigationBar
//
//  Created by ltebean on 15-2-15.
//  Copyright (c) 2015年 ltebean. All rights reserved.
//

#import "BGColorDemoViewController.h"
#import "UINavigationBar+Awesome.h"
#import "UIColor+HexString.h"
#import "UIImageView+LBBlurredImage.h"

#define NAVBAR_CHANGE_POINT -50

@interface BGColorDemoViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation BGColorDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor clearColor]];
    
    self.tweets.backgroundColor = [UIColor colorWithHexString:@"#5695E2"];
    
    self.tweets.layer.cornerRadius = 14; // this value vary as per your desire
    self.tweets.clipsToBounds = YES;
    
    self.profileImage.layer.cornerRadius = 37.5;
    self.profileImage.clipsToBounds = YES;
    self.profileImage.layer.borderWidth = 3;
    self.profileImage.layer.borderColor = [UIColor whiteColor].CGColor;
    
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
    
    [self.imageView setImageToBlur:[UIImage imageNamed:@"New-York-City-Manhattan-Bridge-Night-Light-Bokeh.jpg"]
                        blurRadius:kLBBlurredImageDefaultBlurRadius
                   completionBlock:^(){
                       NSLog(@"The blurred image has been set");
                   }];
    
    [self.imageView setClipsToBounds:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    UIColor * color = [UIColor colorWithHexString:@"#17293a"];
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY > NAVBAR_CHANGE_POINT) {
        CGFloat alpha = MIN(1, 1 - ((NAVBAR_CHANGE_POINT + 64 - offsetY) / 64));
        [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:alpha]];
    } else {
        [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:0]];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.tableView.delegate = self;
    [self scrollViewDidScroll:self.tableView];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tableView.delegate = nil;
    [self.navigationController.navigationBar lt_reset];
}

#pragma mark UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 25;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = @"text";
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
