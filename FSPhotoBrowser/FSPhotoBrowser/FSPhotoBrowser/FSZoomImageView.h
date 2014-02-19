//
//  FSZoomImageView.h
//  FSPhotoBrowser
//
//  Created by Fengshan.yang on 14-2-17.
//  Copyright (c) 2014年 Fanyi Network techonology Co.,Ltd. All rights reserved.
//

#define FS_ZOOM_IMAGE_SCROLL_VIEW_GAP_WIDTH 20.0f //  The gap between two photos.

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@class ZoomScrollView;

typedef void (^CTZoomScrollZoomStateBlock) (BOOL normalState);

@interface FSZoomImageView : UIView
{
@private
    ZoomScrollView *_scrollView;
    CGFloat _zoomScale;
    UIImageView *_imageView;
    NSString *_imageUrl;
}

@property (nonatomic, readonly, strong) UIImageView *imageView;
@property (nonatomic, copy) dispatch_block_t didTapBlock;   //  did tap callback block
@property (nonatomic, copy) CTZoomScrollZoomStateBlock zoomStateBlock;

//  recovery scrollview zoom scale
- (void)recoveryZoomScale;

//  本地图片，在 CTInfiniteScrollImageView 获得图片以后，直接设置，但是在本类需要更新 zoomScale 大小
- (void)setZoomImage:(UIImage *)image;

/**
 *
 */
- (void)setImageWithUrl:(NSString *)url;

//  UI 效果需要改为加载图片时菊花转，类外调用此方法，转动菊花，图片加载失败或者完成后菊花消失
- (void)startRotateIndicator;

@end


@interface ZoomScrollView : UIScrollView
{
@private
    UIView *_zoomView;
}

@property (nonatomic, strong) UIView *zoomView;

@end




