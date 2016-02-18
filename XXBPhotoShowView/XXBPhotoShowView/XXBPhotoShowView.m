//
//  XXBPhotoShowView.m
//  XXBPhotoShowView
//
//  Created by 杨小兵 on 15/4/27.
//  Copyright (c) 2015年 xiaoxiaobing. All rights reserved.
//

#import "XXBPhotoShowView.h"

@interface UIImage (VIUtil)

- (CGSize)sizeThatFits:(CGSize)size;

@end

@implementation UIImage (VIUtil)

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize imageSize = CGSizeMake(self.size.width / self.scale,
                                  self.size.height / self.scale);
    
    CGFloat widthRatio = imageSize.width / size.width;
    CGFloat heightRatio = imageSize.height / size.height;
    
    if (widthRatio > heightRatio) {
        imageSize = CGSizeMake(imageSize.width / widthRatio, imageSize.height / widthRatio);
    } else {
        imageSize = CGSizeMake(imageSize.width / heightRatio, imageSize.height / heightRatio);
    }
    
    return imageSize;
}

@end

@interface UIImageView (VIUtil)

- (CGSize)contentSize;

@end

@implementation UIImageView (VIUtil)

- (CGSize)contentSize
{
    return [self.image sizeThatFits:self.bounds.size];
}

@end


@interface XXBPhotoShowView ()<UIScrollViewDelegate>

@property (nonatomic, weak)     UIImageView *imageView;
@property (nonatomic , assign)  BOOL    rotating;
@property (nonatomic , assign)  CGSize  minSize;

@end

@implementation XXBPhotoShowView
- (void)setImage:(UIImage *)image
{
    _image = image;
    self.imageView.image = image;
    self.imageView.frame = self.bounds;
    CGSize imageSize = self.imageView.contentSize;
    self.imageView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
    self.imageView.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
    self.imageView.center = CGPointMake(imageSize.width / 2, imageSize.height / 2);
    self.contentSize = imageSize;
    self.minSize = imageSize;
    [self setMaxMinZoomScale];
    [self centerContent];
    [self setupGestureRecognizer];
    [self setupRotationNotification];
    
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.bouncesZoom = YES;
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.rotating)
    {
        self.rotating = NO;
        CGSize containerSize = self.imageView.frame.size;
        BOOL containerSmallerThanSelf = (containerSize.width < CGRectGetWidth(self.bounds)) && (containerSize.height < CGRectGetHeight(self.bounds));
        
        CGSize imageSize = [self.imageView.image sizeThatFits:self.bounds.size];
        CGFloat minZoomScale = imageSize.width / self.minSize.width;
        self.minimumZoomScale = minZoomScale;
        if (containerSmallerThanSelf || self.zoomScale == self.minimumZoomScale)
        { // 宽度或高度 都小于 self 的宽度和高度
            self.zoomScale = minZoomScale;
        }
        // Center container view
        [self centerContent];
    }
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (UIImageView *)imageView
{
    if (_imageView == nil) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView =  imageView;
        [self addSubview: imageView];
    }
    return _imageView;
}
#pragma mark - Setup

- (void)setupRotationNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}
- (void)setupGestureRecognizer
{
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapHandler:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [_imageView addGestureRecognizer:doubleTapGestureRecognizer];
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapHandler:)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    [_imageView addGestureRecognizer:singleTapGestureRecognizer];
}
#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self centerContent];
}
#pragma mark - 手势处理
- (void)singleTapHandler:(UITapGestureRecognizer *)recognizer
{
    recognizer.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        recognizer.enabled = YES;
    });
    [self performSelector:@selector(singleTapAction) withObject:nil afterDelay:0.5];
}
- (void)singleTapAction
{
    NSLog(@"单击了");
}
//手势
- (void)doubleTapHandler:(UITapGestureRecognizer *)recognizer
{

    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    NSLog(@"双击了");
    if (self.zoomScale > self.minimumZoomScale)
    {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    }
    else
    {
        if (self.zoomScale < self.maximumZoomScale)
        {
            CGPoint location = [recognizer locationInView:recognizer.view];
            CGRect zoomToRect = CGRectMake(0, 0, 50, 50);
            zoomToRect.origin = CGPointMake(location.x - CGRectGetWidth(zoomToRect)/2, location.y - CGRectGetHeight(zoomToRect)/2);
            [self zoomToRect:zoomToRect animated:YES];
        }
    }
    
}
#pragma mark - Notification

- (void)orientationChanged:(NSNotification *)notification
{
    self.rotating = YES;
}
#pragma mark - Helper

- (void)setMaxMinZoomScale
{
    CGSize imageSize = self.imageView.image.size;
    CGSize imagePresentationSize = self.imageView.contentSize;
    CGFloat maxScale = MAX(imageSize.height / imagePresentationSize.height, imageSize.width / imagePresentationSize.width);
    self.maximumZoomScale = MAX(1, maxScale);
    self.minimumZoomScale = 1.0;
}
- (void)centerContent
{
    CGRect frame = self.imageView.frame;
    CGFloat top = 0, left = 0;
    if (self.contentSize.width < self.bounds.size.width) {
        left = (self.bounds.size.width - self.contentSize.width) * 0.5f;
    }
    if (self.contentSize.height < self.bounds.size.height) {
        top = (self.bounds.size.height - self.contentSize.height) * 0.5f;
    }
    top -= frame.origin.y;
    left -= frame.origin.x;
    self.contentInset = UIEdgeInsetsMake(top, left, top, left);
}

@end
