//
//  DetailViewController.m
//  wifidisk
//
//  Created by xuwf on 13-7-4.
//  Copyright (c) 2013年 xuwf. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

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
    random();
    CGFloat r = rand()%256/256.0f;
    CGFloat g = rand()%256/256.0f;
    CGFloat b = rand()%256/256.0f;
    
    self.view.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0f];
    
    self.title = [NSString stringWithFormat:@"Tittle:%f", rand()%256/256.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPushButtonPressed:(id)sender {
    static BOOL hidden = YES;
    DetailViewController* vc = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    [self.overlapedViewController pushViewController:vc fromViewController:self animated:YES];
//    self.overlapedViewController.hidesNavigationBar = hidden;
    hidden = !hidden;
}


@end
