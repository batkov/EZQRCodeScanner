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

@property (strong, nonatomic) EZQRCodeScannerView *scannerView;
@end

@implementation EZQRCodeScanner

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupAVCaptureComponent:self.view.layer.bounds];
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
    // TODO
    [self.view.layer insertSublayer:self.capturePreviewLayer atIndex:0];
    //    [self.superview.layer addSublayer:self.capturePreviewLayer];
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
