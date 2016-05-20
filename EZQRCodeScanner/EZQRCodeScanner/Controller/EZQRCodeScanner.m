//
//  EZQRCodeScanner.m
//  EZQRCodeScanner
//
//  Created by ezfen on 16/5/18.
//  Copyright © 2016年 Ezfen Cheung. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "EZQRCodeScanner.h"
#import "EZQRCodeScannerView.h"

@interface EZQRCodeScanner () <AVCaptureMetadataOutputObjectsDelegate>
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *capturePreviewLayer;
@property (strong, nonatomic) AVCaptureDevice *captureDevice;
@property (strong, nonatomic) AVCaptureDeviceInput *captureDeviceInput;
@property (strong, nonatomic) AVCaptureMetadataOutput *captureMeradataOutput;

@property (strong, nonatomic) EZQRCodeScannerView *scannerView;     // 整个Background，而非扫描区域
@property (strong, nonatomic) UILabel *tipsLabel;
@property (strong, nonatomic) UIButton *flashLight;
@property (strong, nonatomic) UIButton *loadPic;

@end

@implementation EZQRCodeScanner
# pragma mark - Initial
- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    [self setupAVCaptureComponent:self.view.layer.bounds];
    [self addTipsLabel];
    [self addButtons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (EZQRCodeScannerView *)scannerView {
    if (!_scannerView) {
        _scannerView = [[EZQRCodeScannerView alloc] initWithFrame:self.view.frame];
        [self.view addSubview:_scannerView];
    }
    return _scannerView;
}

- (void)addTipsLabel {
    self.tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.scannerView.frame), self.scannerView.minYUnderScannerRegion + 20, self.scannerView.frame.size.width, 20)];
    self.tipsLabel.textAlignment = NSTextAlignmentCenter;
    self.tipsLabel.textColor = [UIColor whiteColor];
    self.tipsLabel.text =  @"请将二维码放置于上框中";
    [self.view addSubview:self.tipsLabel];
}

- (void)addButtons {
    CGFloat minYUnderTipsLabel = CGRectGetMaxY(self.tipsLabel.frame);
    CGFloat maxHeight = self.view.bounds.size.height;
    CGFloat height = maxHeight - minYUnderTipsLabel - maxHeight * kPaddingAspect - 20;
    CGFloat width = (CGRectGetWidth(self.scannerView.frame) * kClearRectAspect - 10) / 2;
    CGFloat buttonWidthAndHeight = MIN(height, width);
    // 添加闪光灯按钮
    self.flashLight = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.flashLight.layer.cornerRadius = 10;
    self.flashLight.clipsToBounds = YES;
    self.flashLight.frame = CGRectMake(CGRectGetWidth(self.scannerView.frame) * kPaddingAspect, minYUnderTipsLabel + 20, buttonWidthAndHeight, buttonWidthAndHeight);
    [self.flashLight setImage:[UIImage imageNamed:@"flash_on"] forState:UIControlStateNormal];
    [self.flashLight setBackgroundColor:[UIColor colorWithWhite:0.902 alpha:0.880]];
    [self.view addSubview:self.flashLight];
    // 添加读取图片库按钮
    self.loadPic = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.loadPic.layer.cornerRadius = 10;
    self.loadPic.clipsToBounds = YES;
    self.loadPic.frame = CGRectMake(CGRectGetMaxX(self.flashLight.frame) + 10, minYUnderTipsLabel + 20, buttonWidthAndHeight, buttonWidthAndHeight);
    [self.loadPic setImage:[UIImage imageNamed:@"album"] forState:UIControlStateNormal];
    [self.loadPic setBackgroundColor:[UIColor colorWithWhite:0.902 alpha:0.880]];
    [self.view addSubview:self.loadPic];
    
}

# pragma mark - Running Control
- (void)startRunning {
    [self.scannerView startAnimation];
    [self.captureSession startRunning];
}
- (void)stopRunning {
    [self.scannerView stopAnimation];
    [self.captureSession stopRunning];
}

# pragma mark - Setup AVCapture Things
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
    [self.view.layer insertSublayer:self.capturePreviewLayer atIndex:0];
    self.captureMeradataOutput.rectOfInterest = CGRectMake(kPaddingAspect, kPaddingAspect, kClearRectAspect * self.capturePreviewLayer.bounds.size.width / self.capturePreviewLayer.bounds.size.height , kClearRectAspect);
}

# pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    [self.captureSession stopRunning];
    __weak EZQRCodeScanner *weakSelf = self;
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
