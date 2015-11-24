//
//  ViewControllerWrite.m
//  tabbar color
//
//  Created by Victor Pierre on 02/10/2015.
//  Copyright © 2015 Bernard Pierre. All rights reserved.
//

#import "ViewControllerWrite.h"
#import "UIColor+HexString.h"

@interface ViewControllerWrite ()

@end

@implementation ViewControllerWrite

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    self.topView.backgroundColor = [UIColor colorWithHexString:@"#ff3366"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
