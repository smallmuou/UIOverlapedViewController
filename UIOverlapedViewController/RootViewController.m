//
//  RootViewController.m
//  UIOverlapedViewController
//
//  Created by xuwf on 13-7-2.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import "RootViewController.h"
#import "MiddleViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPushButtonPressed:(id)sender {
    MiddleViewController* vc = [[MiddleViewController alloc] initWithNibName:@"MiddleViewController" bundle:nil];
    [self.overlapedViewController pushViewController:vc fromViewController:nil animated:YES];
}

- (IBAction)onPopButtonPressed:(id)sender {
    [self.overlapedViewController popViewControllerAnimated:YES];
}

@end
