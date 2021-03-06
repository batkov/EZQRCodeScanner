//
//  EZQRCodeScannerView.h
//  EZQRCodeScanner
//
//  Created by ezfen on 16/5/16.
//  Copyright © 2016年 Ezfen Cheung. All rights reserved.
//

#import <UIKit/UIKit.h>

// 需要修改扫描区域的大小请修改kClearRectAspect所占的比例，但以下等式必须满足：kClearRectAspect + kWidthPaddingAspect * 2 = 1
#define kWidthPaddingAspect .15         //中间透明部分与两端间隔占整个View的比例
#define kHeightPaddingAspect .25        //中间透明部分与上方的间隔占整个View的比例
#define kClearRectAspect .70            //中间透明部分的宽高占整个View的比例

typedef struct {
    float widthPadding;
    float heightPadding;
    float clearRect;
} ERInterestRect;

typedef NS_ENUM(NSUInteger, EZScanStyle) {
    EZScanStyleNone,
    EZScanStyleLine,
    EZScanStyleNetGrid
};

@class EZQRCodeScannerView;

@interface EZQRCodeScannerView : UIView

@property (nonatomic) EZScanStyle scanStyle;

- (instancetype)initWithFrame:(CGRect)frame interestRect:(ERInterestRect)interestRect NS_DESIGNATED_INITIALIZER;

- (void)startAnimation;   // 控制QRCodeScanner开始扫描，同时启动定时器NSTimer实现动画效果
- (void)stopAnimation;    // 为了不让NSTimer处于工作状态，可手动停止二维码扫描
- (BOOL)isAnimating;

- (CGFloat)minYUnderScannerRegion;
- (CGFloat)minXNearScannerRegion;

@end
