//
//  FSPhotoBrowser.m
//  FSPhotoBrowser
//
//  Created by Fengshan.yang on 14-2-15.
//  Copyright (c) 2014年 Fanyi Network techonology Co.,Ltd. All rights reserved.
//

//@class InfiniteScrollBottomView;

#define FS_PHOTO_BROWSER_SCROLL_IMAGE_VIEW_MAX_ZOOM_IMAGES 4
#define FS_PHOTO_BROWSER_SCROLL_BACKGROUND_COLOR_WITH_ALPHA(a) [UIColor colorWithRed:36/255.0f green:36/255.0f blue:36/255.0f alpha:a]

#import "FSPhotoBrowser.h"
#import "FSZoomImageView.h"

@interface FSPhotoBrowser()<UIScrollViewDelegate>
{
    CGFloat _selfViewWidth;
    NSInteger _lastLocation;
}

@property (nonatomic, strong) NSMutableArray *zoomImageViews;
@property (nonatomic, strong) UIScrollView *infiniteScroll;

@end

@implementation FSPhotoBrowser

@synthesize infiniteScroll = _infiniteScroll;
@synthesize zoomImageViews = _zoomImageViews;

- (void)dealloc
{
    self.infiniteScroll = nil;
    self.zoomImageViews = nil;

    NSLog(@"FSPhotoBrowser dealloc");
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupSelfView];
    }
    return self;
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    if (newWindow && !_photoFlags.didMoveToWindow) {
        NSInteger index = _currentImageIndex % FS_PHOTO_BROWSER_SCROLL_IMAGE_VIEW_MAX_ZOOM_IMAGES;
        FSZoomImageView *zoomView = [_zoomImageViews objectAtIndex:index];
        CGRect rect = [zoomView.imageView frame];
        [zoomView.imageView setFrame:CGRectMake(CGRectGetWidth([self bounds]) / 2 - 10, CGRectGetHeight([self bounds]) / 2 - 10, 20.0f, 20.0f)];
        [zoomView.imageView setBackgroundColor:FS_PHOTO_BROWSER_SCROLL_BACKGROUND_COLOR_WITH_ALPHA(1)];
        [zoomView.imageView setAlpha:0.0f];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:0.35f];
        [zoomView.imageView setFrame:rect];
        [zoomView.imageView setAlpha:1.0f];
        [UIView commitAnimations];

        [self setBackgroundColor:[UIColor clearColor]];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:0.15f];
        [self setBackgroundColor:FS_PHOTO_BROWSER_SCROLL_BACKGROUND_COLOR_WITH_ALPHA(1)];
        [UIView commitAnimations];

        _photoFlags.didMoveToWindow = YES;
    }
}

#pragma mark -
#pragma mark - Private Method

- (void)setupSelfView
{
    CGRect rect = [self bounds];
    rect.size.width += FS_ZOOM_IMAGE_SCROLL_VIEW_GAP_WIDTH;
    _infiniteScroll = [[UIScrollView alloc] initWithFrame:rect];
    [_infiniteScroll setPagingEnabled:YES];
    [_infiniteScroll setDelegate:self];
    [_infiniteScroll setShowsHorizontalScrollIndicator:NO];
    [_infiniteScroll setShowsVerticalScrollIndicator:NO];
    [self addSubview:_infiniteScroll];

    [self setupZoomImageView];
}

- (void)setupZoomImageView
{
    _selfViewWidth = CGRectGetWidth([self bounds]) + FS_ZOOM_IMAGE_SCROLL_VIEW_GAP_WIDTH;
    _zoomImageViews = [[NSMutableArray alloc] initWithCapacity:4];
    for (int i = 0; i < FS_PHOTO_BROWSER_SCROLL_IMAGE_VIEW_MAX_ZOOM_IMAGES; i++) {
        CGRect rect = CGRectMake(i * _selfViewWidth, 0, _selfViewWidth, CGRectGetHeight([self bounds]));
        FSZoomImageView *zoomImage = [[FSZoomImageView alloc] initWithFrame:rect];
        [_infiniteScroll addSubview:zoomImage];
        [_zoomImageViews addObject:zoomImage];
        __block typeof(self) __weak myself = self;
        [zoomImage setZoomStateBlock:^(BOOL normalState) {
            [myself zoomImageViewNormal:normalState];
        }];
    }
}

- (void)resetZoomImageViewsFrameAtIndex:(NSInteger)index
{
    for (int i = index; i < FS_PHOTO_BROWSER_SCROLL_IMAGE_VIEW_MAX_ZOOM_IMAGES + index; i++) {
        NSInteger modulo = i % FS_PHOTO_BROWSER_SCROLL_IMAGE_VIEW_MAX_ZOOM_IMAGES;

        if (i > _numberOfImages - 1) {
            return;
        }

        FSZoomImageView *zoomImage = [_zoomImageViews objectAtIndex:modulo];
        CGRect rect = CGRectMake(i * _selfViewWidth, 0, _selfViewWidth, CGRectGetHeight([self bounds]));
        [zoomImage setFrame:rect];

        [_infiniteScroll addSubview:zoomImage];

        if (_dataSource && [_dataSource respondsToSelector:@selector(photoBrowser:requestDataWithType:atIndex:)]) {
            NSString *url = [_dataSource photoBrowser:self
                                  requestDataWithType:PhotoBrowerScrollRequestDataTypeForImageURL
                                              atIndex:i];
            if (url) {
                [zoomImage setImageWithUrl:url];
            }
        }
    }
}


- (void)resetZoomImageViewsWithLocation:(NSInteger)location
{
    if (location > _lastLocation) {
        if (_photoFlags.orientation == PhotoBrowerScrollOrientationLeft) {
            if ((_lastLocation + 2) * _selfViewWidth > (_infiniteScroll.contentSize.width - _selfViewWidth)) {
                return;
            }
            [self resetZoomImageViewWithLocation:_lastLocation
                                     orientation:PhotoBrowerScrollOrientationRight];
            _photoFlags.orientation = PhotoBrowerScrollOrientationRight;
        }
        if ((location + 2) * _selfViewWidth > (_infiniteScroll.contentSize.width - _selfViewWidth)) {
            return;
        }
        [self resetZoomImageViewWithLocation:location
                                 orientation:PhotoBrowerScrollOrientationRight];
    } else {
        if (_photoFlags.orientation == PhotoBrowerScrollOrientationRight) {
            if ((_lastLocation - 2) * _selfViewWidth < 0) {
                return;
            }
            [self resetZoomImageViewWithLocation:_lastLocation
                                     orientation:PhotoBrowerScrollOrientationLeft];
            _photoFlags.orientation = PhotoBrowerScrollOrientationLeft;
        }
        if ((location - 2) * _selfViewWidth < 0) {
            return;
        }
        [self resetZoomImageViewWithLocation:location
                                 orientation:PhotoBrowerScrollOrientationLeft];
    }
}

- (void)resetZoomImageViewWithLocation:(NSInteger)location orientation:(PhotoBrowerScrollOrientation)orientation
{
    FSZoomImageView *zoomImageView = nil;
    NSInteger modulo = location % FS_PHOTO_BROWSER_SCROLL_IMAGE_VIEW_MAX_ZOOM_IMAGES;
    NSInteger index = (modulo + 2) % FS_PHOTO_BROWSER_SCROLL_IMAGE_VIEW_MAX_ZOOM_IMAGES;

    if (index >= [_zoomImageViews count]) {
        NSString *reason = [NSString stringWithFormat:@"NSAssert: PhotoBrower_scroll_image_view: [__NSArrayM objectAtIndex:]: index %d beyond bounds [0 .. %d]", (int)index, (int)[_zoomImageViews count]];
        NSAssert(0, reason);
    }
    zoomImageView = (FSZoomImageView *)[_zoomImageViews objectAtIndex:index];
    CGRect rect = [zoomImageView frame];
    rect.origin.x = (location + (orientation == PhotoBrowerScrollOrientationRight ? 2 : -2)) * _selfViewWidth;
    [zoomImageView setFrame:rect];

    index = rect.origin.x / _selfViewWidth;
    if (_dataSource && [_dataSource respondsToSelector:@selector(photoBrowser:requestDataWithType:atIndex:)]) {
        NSString *url = [_dataSource photoBrowser:self
                              requestDataWithType:PhotoBrowerScrollRequestDataTypeForImageURL
                                          atIndex:index];
        if (url) {
            [zoomImageView setImageWithUrl:url];
        }
    }
}

- (void)recoveryZoomScaleWithLocation:(NSInteger)location
{
    NSInteger index = location % FS_PHOTO_BROWSER_SCROLL_IMAGE_VIEW_MAX_ZOOM_IMAGES;
    if (index >= [_zoomImageViews count]) {
        return;
    }
    FSZoomImageView *zoomView = [_zoomImageViews objectAtIndex:index];
    [zoomView recoveryZoomScale];
}

#pragma mark -
#pragma mark - Public Method

- (NSInteger)numberOfImages
{
    return _numberOfImages;
}

- (NSInteger)currentImageIndex
{
    return _currentImageIndex;
}

- (void)setNumberOfImages:(NSInteger)numberOfImages andCurrentImageIndex:(NSInteger)currentIndex
{
    if (_numberOfImages == numberOfImages) {
        return;
    }
    [_infiniteScroll setContentSize:CGSizeMake(numberOfImages * _selfViewWidth, CGRectGetHeight([self bounds]))];
    _numberOfImages = numberOfImages;

    NSInteger current = currentIndex;
    if (current < 0) {
        current = 0;
    } else if (currentIndex > _numberOfImages) {
        current = _numberOfImages - 1;
    }
    [_infiniteScroll setContentOffset:CGPointMake(current * _selfViewWidth, 0.0f)];
    _currentImageIndex = current;
    _lastLocation = current;
    if (_numberOfImages <= FS_PHOTO_BROWSER_SCROLL_IMAGE_VIEW_MAX_ZOOM_IMAGES) {
        [self resetZoomImageViewsFrameAtIndex:0];
    } else {
        [self resetZoomImageViewsFrameAtIndex:current ? current - 1 : 0];
    }

    if (_delegate && [_delegate respondsToSelector:@selector(photoBrowser:currentPhotoIndex:)]) {
        [_delegate photoBrowser:self currentPhotoIndex:current];
    }
}

- (void)setTapBlock:(dispatch_block_t)tapBlock
{
    if (_tapBlock == tapBlock) {
        return;
    }
    _tapBlock = tapBlock;

    if ([_zoomImageViews count]) {
        for (FSZoomImageView *view in _zoomImageViews) {
            [view setDidTapBlock:_tapBlock];
        }
    }
}

- (void)willRemovePhotoBrowser
{
    [UIView animateWithDuration:0.35f animations:^{
        [self setAlpha:0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark -
#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = [scrollView contentOffset];
    NSInteger location = offset.x / _selfViewWidth;

    if (_photoFlags.scrollviewExpand && location < _lastLocation) {
        //  scroll view is expand state
        CGFloat origin = location * _selfViewWidth;
        if (offset.x - origin > 10.0f) {
            return;
        }
    }

    if (location != _lastLocation) {
        [self recoveryZoomScaleWithLocation:_lastLocation];
        [self resetZoomImageViewsWithLocation:location];
        _lastLocation = location;
        _currentImageIndex = location;
        if (_delegate && [_delegate respondsToSelector:@selector(photoBrowser:currentPhotoIndex:)]) {
            [_delegate photoBrowser:self currentPhotoIndex:location];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset = [scrollView contentOffset];
    NSInteger location = offset.x / _selfViewWidth;

    if (_photoFlags.scrollviewExpand && location != _lastLocation) {
        [self recoveryZoomScaleWithLocation:_lastLocation];
    }

    _currentImageIndex = location;
}

#pragma mark -
#pragma mark - @ - selector

- (void)zoomImageViewNormal:(BOOL)normal
{
    if (normal == !_photoFlags.scrollviewExpand) {
        return;
    }

    if (normal && _photoFlags.scrollviewExpand) {
        _photoFlags.scrollviewExpand = NO;
    } else if (!normal && !_photoFlags.scrollviewExpand) {
        _photoFlags.scrollviewExpand = YES;
    }
}

@end






















