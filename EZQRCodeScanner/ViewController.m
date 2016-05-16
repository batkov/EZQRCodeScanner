//
//  ViewController.m
//  EZQRCodeScanner
//
//  Created by ezfen on 16/5/16.
//  Copyright © 2016年 Ezfen Cheung. All rights reserved.
//

#import "ViewController.h"
#import "EZQRCodeScannerView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    EZQRCodeScannerView *testView = [[EZQRCodeScannerView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:testView];
//    [testView startRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
