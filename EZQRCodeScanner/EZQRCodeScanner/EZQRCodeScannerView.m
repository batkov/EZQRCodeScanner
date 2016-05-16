//
//  EZQRCodeScannerView.m
//  EZQRCodeScanner
//
//  Created by ezfen on 16/5/16.
//  Copyright © 2016年 Ezfen Cheung. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "EZQRCodeScannerView.h"

@interface EZQRCodeScannerView() <AVCaptureMetadataOutputObjectsDelegate>
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *capturePreviewLayer;
@property (strong, nonatomic) AVCaptureDevice *captureDevice;
@property (strong, nonatomic) AVCaptureDeviceInput *captureDeviceInput;
@property (strong, nonatomic) AVCaptureMetadataOutput *captureMeradataOutput;

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) UIView *scannerLine;
@property (nonatomic) CGFloat minBorder;
@property (nonatomic) CGFloat maxBorder;
@property (nonatomic) BOOL direction;
@end

@implementation EZQRCodeScannerView

# pragma mark - Initial
- (instancetype)init {
    return [self initWithFrame:[UIScreen mainScreen].bounds];
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 设置AVFoundationComponent
        [self setupAVCaptureComponent:frame];
    }
    return self;
}

#pragma mark - Initiliza ScannerLine
- (UIView *)scannerLine {
    if (!_scannerLine) {
        CGRect viewPreviewRect = self.bounds;
        _scannerLine = [[UIView alloc] initWithFrame:CGRectMake(viewPreviewRect.size.width * kPaddingAspect + 5, viewPreviewRect.size.height * kPaddingAspect, viewPreviewRect.size.width * kClearRectAspect - 10, 1)];
        _scannerLine.backgroundColor = [UIColor blueColor];
        [self addSubview:_scannerLine];
        self.minBorder = self.frame.size.height * kPaddingAspect;
        self.maxBorder = self.minBorder + self.frame.size.width * kClearRectAspect;
        self.direction = YES;
    }
    return _scannerLine;
}

# pragma mark - Running Control
- (void)startRunning {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:.02
                                                  target:self
                                                selector:@selector(startAnimate)
                                                userInfo:nil
                                                 repeats:YES];
    [self.captureSession startRunning];
}
- (void)startAnimate {
    CGRect rect = self.scannerLine.frame;
    if (self.direction) {
        rect.origin.y += 2;
        self.scannerLine.frame = rect;
        if (self.scannerLine.frame.origin.y >= self.maxBorder) {
            self.direction = NO;
        }
    } else {
        rect.origin.y -= 2;
        self.scannerLine.frame = rect;
        if (self.scannerLine.frame.origin.y <= self.minBorder) {
            self.direction = YES;
        }
    }
}
- (void)stopRunning {
    [self.timer invalidate];
    self.timer = nil;
    [self.captureSession stopRunning];
}

# pragma mark - 描绘中间透明四周半透明的View
- (void)drawRect:(CGRect)rect {
    CGSize viewSize = rect.size;
    CGRect screenDrawRect = CGRectMake(0, 0, viewSize.width, viewSize.height);
    CGRect clearDrawRect = CGRectMake(viewSize.width * kPaddingAspect, viewSize.height * kPaddingAspect,
                                      viewSize.width * kClearRectAspect, viewSize.width * kClearRectAspect);
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

#pragma mark - Setup AVCapture Things
- (void)setupAVCaptureComponent:(CGRect)rect {
    NSError *error = nil;
    self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:&error];
    if (error || !self.captureDeviceInput) {
        NSLog(@"error: %@", [error localizedDescription]);
        return ;
    }
    self.captureMeradataOutput = [[AVCaptureMetadataOutput alloc] init];
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession addInput:self.captureDeviceInput];
    [self.captureSession addOutput:self.captureMeradataOutput];
    dispatch_queue_t dispatchQueue = dispatch_queue_create("AVCaptureQueue", DISPATCH_QUEUE_SERIAL);
    [self.captureMeradataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [self.captureMeradataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    self.capturePreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [self.capturePreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    self.capturePreviewLayer.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
    [self.layer insertSublayer:self.capturePreviewLayer atIndex:0];
    self.captureMeradataOutput.rectOfInterest = CGRectMake(kPaddingAspect, kPaddingAspect, kClearRectAspect * self.capturePreviewLayer.bounds.size.width / self.capturePreviewLayer.bounds.size.height , kClearRectAspect);
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    [self.captureSession stopRunning];
    [self.timer invalidate];
    self.timer = nil;
    __weak EZQRCodeScannerView *weakSelf = self;
    if (metadataObjects != nil && metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects firstObject];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            // TODO
            if ([weakSelf.delegate respondsToSelector:@selector(scannerView:outputString:)]) {
                [weakSelf.delegate scannerView:weakSelf outputString:[metadataObj stringValue]];
            };
        } else {
            if ([weakSelf.delegate respondsToSelector:@selector(scannerView:errorMessage:)]) {
                [weakSelf.delegate scannerView:weakSelf errorMessage:@"Can not match the type:AVMetadataObjectTypeQRCode"];
            }
        }
    } else {
        if ([weakSelf.delegate respondsToSelector:@selector(scannerView:errorMessage:)]) {
            [weakSelf.delegate scannerView:weakSelf errorMessage:@"Can not get the message"];
        }
    }
}


@end
