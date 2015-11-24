//
//  ViewController.m
//  tabbar color
//
//  Created by Victor Pierre on 04/09/2015.
//  Copyright © 2015 Bernard Pierre. All rights reserved.
//

#import "ViewController.h"
#import "UIColor+HexString.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.connexion.backgroundColor = [UIColor colorWithHexString:@"#5695E2"];
    
    self.connexion.layer.cornerRadius = 5; // this value vary as per your desire
    self.connexion.clipsToBounds = YES;
    
    self.inscription.layer.borderWidth = 1;
    self.inscription.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.inscription.layer.cornerRadius = 5; // this value vary as per your desire
    self.inscription.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
