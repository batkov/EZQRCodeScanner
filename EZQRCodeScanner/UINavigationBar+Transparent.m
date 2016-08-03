//
//  UINavigationBar+Transparent.m
//  EZQRCodeScanner
//
//  Created by ezfen on 16/8/3.
//  Copyright © 2016年 Ezfen Cheung. All rights reserved.
//

#import "UINavigationBar+Transparent.h"
#import <objc/runtime.h>

@implementation UINavigationBar (Transparent)

// 参考LTNavigationBar的实现方法

static char overlayKey;

- (UIView *)overlay {
    return objc_getAssociatedObject(self, &overlayKey);
}

- (void)setOverlay:(UIView *)overlay {
    objc_setAssociatedObject(self, &overlayKey, overlay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setBackgroundColorByMyself:(UIColor * __nullable)backgroundColor {
    if (!self.overlay) {
        [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [self setShadowImage:[UIImage new]];
        self.overlay = [[UIView alloc] initWithFrame:CGRectMake(0, -20, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) + 20)];
        self.overlay.userInteractionEnabled = NO;
        self.overlay.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self insertSubview:self.overlay atIndex:0];
    }
    self.overlay.backgroundColor = backgroundColor;
}

- (void)setBackgroundColorByMyself2:(UIColor * __nullable)backgroundColor {
    // 同样可以达到让navigationBar透明的目的，但是会导致返回Button失效
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, -20, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) + 20)];
    view.backgroundColor = backgroundColor;
    [self setValue:view forKey:@"backgroundView"];
}

- (void)reset {
    [self setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.overlay removeFromSuperview];
    self.overlay = nil;
}

@end
