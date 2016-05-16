//
//  EZQRCodeScannerView.h
//  EZQRCodeScanner
//
//  Created by ezfen on 16/5/16.
//  Copyright © 2016年 Ezfen Cheung. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPaddingAspect .15          //中间透明部分与两端间隔占整个View的比例
#define kClearRectAspect .70        //中间透明部分的宽高占整个View的比例

@class EZQRCodeScannerView;
@protocol EZQRCodeScannerDelegate <NSObject>

@required
- (void)scannerView:(EZQRCodeScannerView *)scannerView outputString:(NSString *)output;
@optional
- (void)scannerView:(EZQRCodeScannerView *)scannerView errorMessage:(NSString *)errorMessage;

@end

@interface EZQRCodeScannerView : UIView

@property (weak, nonatomic) id<EZQRCodeScannerDelegate> delegate;

- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)frame;
- (void)startRunning;   // 控制QRCodeScanner开始扫描，同时启动定时器NSTimer实现动画效果
- (void)stopRunning;    // 为了不让NSTimer处于工作状态，可手动停止二维码扫描

@end
