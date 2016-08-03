//
//  ViewController.m
//  EZQRCodeScanner
//
//  Created by ezfen on 16/5/16.
//  Copyright © 2016年 Ezfen Cheung. All rights reserved.
//

#import "ViewController.h"
#import "UINavigationBar+Transparent.h"
#import "EZQRCodeScanner.h"

@interface ViewController () <EZQRCodeScannerDelegate>
@property (strong, nonatomic) EZQRCodeScanner *test;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar reset];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundColorByMyself:[UIColor clearColor]];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)scanQRCode:(id)sender {
    EZQRCodeScanner *scanner = [[EZQRCodeScanner alloc] init];
    scanner.delegate = self;
    [self.navigationController pushViewController:scanner animated:YES];
}

- (void)scannerView:(EZQRCodeScanner *)scanner errorMessage:(NSString *)errorMessage {
    
}
- (void)scannerView:(EZQRCodeScanner *)scanner outputString:(NSString *)output {
    NSLog(@"%@",output);
}

@end
