//
//  EZQRCodeScanner.h
//  EZQRCodeScanner
//
//  Created by ezfen on 16/5/18.
//  Copyright © 2016年 Ezfen Cheung. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EZQRCodeScanner;
@protocol EZQRCodeScannerDelegate <NSObject>

@required
- (void)scannerView:(EZQRCodeScanner *)scanner outputString:(NSString *)output;
@optional
- (void)scannerView:(EZQRCodeScanner *)scanner errorMessage:(NSString *)errorMessage;

@end

@interface EZQRCodeScanner : UIViewController

@property (weak, nonatomic) id<EZQRCodeScannerDelegate> delegate;

- (void)startRunning;   // 控制QRCodeScanner开始扫描，同时启动定时器NSTimer实现动画效果
- (void)stopRunning;    // 为了不让NSTimer处于工作状态，可手动停止二维码扫描

@end
