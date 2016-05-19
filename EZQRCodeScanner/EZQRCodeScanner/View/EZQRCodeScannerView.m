//
//  EZQRCodeScannerView.m
//  EZQRCodeScanner
//
//  Created by ezfen on 16/5/16.
//  Copyright © 2016年 Ezfen Cheung. All rights reserved.
//

#import "EZQRCodeScannerView.h"

@interface EZQRCodeScannerView()
// Animation Show View
@property (strong, nonatomic) UIView *showView;
@property (nonatomic) CGRect scanRegionFrame;
// ScanLine
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) UIView *scannerLine;
@property (nonatomic) CGFloat minBorder;
@property (nonatomic) CGFloat maxBorder;
@property (nonatomic) BOOL direction;

// ScanNetGrid
@property (strong, nonatomic) UIImageView *netGrid;
@property (nonatomic) CGRect initFrame;

@end

@implementation EZQRCodeScannerView

# pragma mark - Initial
- (instancetype)init {
    return [self initWithFrame:[UIScreen mainScreen].bounds];
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.scanRegionFrame = CGRectMake(self.frame.size.width * kPaddingAspect,
                                    self.frame.size.height * kPaddingAspect,
                                    self.frame.size.width * kClearRectAspect,
                                    self.frame.size.width * kClearRectAspect);
//        self.scanStyle = EZScanStyleNetGrid;
        self.scanStyle = EZScanStyleLine;
    }
    return self;
}

# pragma mark - Getter and Setter
- (UIView *)showView {
    if (!_showView) {
        _showView = [[UIView alloc] initWithFrame:self.scanRegionFrame];
        _showView.clipsToBounds = YES;
        [self addSubview:_showView];
    }
    return _showView;
}

- (void)setScanStyle:(EZScanStyle)scanStyle {
    _scanStyle = scanStyle;
    switch (scanStyle) {
        case EZScanStyleNetGrid:
        {
            self.netGrid = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scan_net"]];
            CGRect frame = self.scanRegionFrame;
            frame.origin.x = 0;
            frame.origin.y = -frame.size.height;
            self.initFrame = frame;
            self.netGrid.frame = self.initFrame;
            self.netGrid.contentMode = UIViewContentModeScaleAspectFill;
            [self.showView addSubview:self.netGrid];
        }
            break;
        case EZScanStyleLine:
        {
            self.scannerLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.showView.frame.size.width, 1)];
            self.scannerLine.backgroundColor = [UIColor colorWithRed:0.400 green:1.000 blue:1.000 alpha:0.600];
            [self.showView addSubview:self.scannerLine];
            self.minBorder = CGRectGetMinY(self.showView.bounds);
            self.maxBorder = CGRectGetMaxY(self.showView.bounds);
            self.direction = YES;
        }
            break;
        case EZScanStyleCycle:
        {
        
        }
            break;
        default:
            break;
    }
}

# pragma mark - Running Control
- (void)startAnimation {
    switch (self.scanStyle) {
        case EZScanStyleLine:
        {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:.01
                                                          target:self
                                                        selector:@selector(startAnimate)
                                                        userInfo:nil
                                                         repeats:YES];
        }
            break;
        case EZScanStyleCycle:
        {
            
        }
            break;
        case EZScanStyleNetGrid:
        {
            [UIView animateWithDuration:3.5 animations:^{
                CGRect frame = self.initFrame;
                frame.origin.y += 2 * self.initFrame.size.height;
                self.netGrid.frame = frame;
            } completion:^(BOOL finished) {
                self.netGrid.frame = self.initFrame;
                [self startAnimation];
            }];
        }
            break;
        default:
        break;
    }
}
- (void)startAnimate {
    
    CGRect rect = self.scannerLine.frame;
    UIView *shadowLine = [[UIView alloc] initWithFrame:rect];
    shadowLine.backgroundColor = self.scannerLine.backgroundColor;
    [self.showView addSubview:shadowLine];
    [UIView animateWithDuration:.5 animations:^{
        shadowLine.alpha = 0;
    } completion:^(BOOL finished) {
        [shadowLine removeFromSuperview];
    }];
    if (self.direction) {
        rect.origin.y += 1;
        self.scannerLine.frame = rect;
        if (self.scannerLine.frame.origin.y >= self.maxBorder) {
            self.direction = NO;
        }
    } else {
        rect.origin.y -= 1;
        self.scannerLine.frame = rect;
        if (self.scannerLine.frame.origin.y <= self.minBorder) {
            self.direction = YES;
        }
    }
    
}
- (void)stopAnimation {
    [self.timer invalidate];
    self.timer = nil;
}

# pragma mark - 描绘中间透明四周半透明的View
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGSize viewSize = rect.size;
    CGRect screenDrawRect = CGRectMake(0, 0, viewSize.width, viewSize.height);
    CGRect clearDrawRect = self.scanRegionFrame;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [self drawFullScreen:ctx rect:screenDrawRect];
    [self addCenterClearRect:ctx rect:clearDrawRect];
    [self addWhiteRect:ctx rect:clearDrawRect];
}
- (void)drawFullScreen:(CGContextRef)ctx rect:(CGRect)rect {
    CGContextSetRGBFillColor(ctx, 0, 0, 0, .5);
    CGContextFillRect(ctx, rect);
}
- (void)addCenterClearRect:(CGContextRef)ctx rect:(CGRect)rect {
    CGContextClearRect(ctx, rect);
}
- (void)addWhiteRect:(CGContextRef)ctx rect:(CGRect)rect {
    CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1);
    CGContextSetLineWidth(ctx, 0.7);
    CGContextAddRect(ctx, rect);
    CGContextStrokeRect(ctx, rect);
}
- (void)addCorner:(CGContextRef)ctx rect:(CGRect)rect {
    
}


@end
