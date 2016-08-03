//
//  ViewController.m
//  EZQRCodeScanner
//
//  Created by ezfen on 16/5/16.
//  Copyright © 2016年 Ezfen Cheung. All rights reserved.
//

#import "ViewController.h"
#import "EZQRCodeScanner.h"

@interface ViewController () <EZQRCodeScannerDelegate>
@property (strong, nonatomic) EZQRCodeScanner *test;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    EZQRCodeScanner *scanner = [[EZQRCodeScanner alloc] init];
    scanner.delegate = self;
    [self.navigationController pushViewController:scanner animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scannerView:(EZQRCodeScanner *)scanner errorMessage:(NSString *)errorMessage {
    
}
- (void)scannerView:(EZQRCodeScanner *)scanner outputString:(NSString *)output {
    NSLog(@"%@",output);
}

@end
