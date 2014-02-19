//
//  FSPhotoBrowser.h
//  FSPhotoBrowser
//
//  Created by Fengshan.yang on 14-2-15.
//  Copyright (c) 2014年 Fanyi Network techonology Co.,Ltd. All rights reserved.
//

@class FSPhotoBrowser;

typedef NS_ENUM(NSInteger, PhotoBrowerScrollButtonType) {
    PhotoBrowerScrollButtonTypeGoBack  = 0,    //  goback buton type
    PhotoBrowerScrollButtonTypeLike       ,    //  like button type
};

typedef NS_ENUM(NSInteger, PhotoBrowerScrollRequestDataType) {
    PhotoBrowerScrollRequestDataTypeForNull        = 0,
    PhotoBrowerScrollRequestDataTypeForImageURL       ,    //  request image url
    PhotoBrowerScrollRequestDataTypeForTitle          ,    //  request title
    PhotoBrowerScrollRequestDataTypeForDescription    ,    //  request description
};

@protocol PhotoBrowerScrollImageViewDataSource <NSObject>

@required
/**
 *  @description
 *      Tells the data source to return the data with a PhotoBrowerScrollRequestDataType type.
 *  @params
 *      view    The InfiniteScrollImageView object requesting this information.
 *  @params
 *      type    InfiniteScrollRequestDataType.
 *  @params
 *      index   Picture index.
 *  @return
 *      return  Rquest data.
 */
- (NSString *)photoBrowser:(FSPhotoBrowser *)browser
                  requestDataWithType:(PhotoBrowerScrollRequestDataType)type
                              atIndex:(NSInteger)index;

@end


@protocol PhotoBrowerScrollImageViewDelegate <NSObject>

/**
 *  @description
 *      Tells the delegate that the InfiniteScrollImageView did scroll index.
 *  @params
 *      view    The InfiniteScrollImageView object requesting this information.
 *  @params
 *      index   did scroll index.
 */
- (void)photoBrowser:(FSPhotoBrowser *)view currentPhotoIndex:(NSInteger)index;

/**
 *  @description
 *      Tells the delegate that the InfiniteScrollImageView's buton did click with InfiniteScrollButtonType.
 *  @params
 *      view    The InfiniteScrollImageView object requesting this information.
 *  @params
 *      type    InfiniteScrollButtonType.
 */
- (void)photoBrowser:(FSPhotoBrowser *)view didClickButtonWithType:(PhotoBrowerScrollButtonType)type atIndex:(NSInteger)index;

@end

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PhotoBrowerScrollOrientation) {
    PhotoBrowerScrollOrientationLeft   = 0,        //  Sliding to the left.
    PhotoBrowerScrollOrientationRight     ,        //  Sliding to the right.
};

@interface FSPhotoBrowser : UIView
{
@private
    UIScrollView *_infiniteScroll;  //  the background scroll view.
    NSMutableArray *_zoomImageViews;    //  an array which contains four GSZoomImageView instances.
    NSInteger _numberOfImages;
    NSInteger _currentImageIndex;
    struct {
        unsigned int bottomViewHidden:1;
        unsigned int orientation:2;
        unsigned int firstLoad:1;
        unsigned int didBreathe:1;  //  点击图片喜欢按钮，是否开始呼吸效果判断
        unsigned int localImageData:1;  //  本地图片，不需要在显示的时候设置 alpha 为 0，网络图片需要
        unsigned int didMoveToWindow:1; //  防止重复 绘制
        unsigned int animationStop:1;
    } _photoFlags;
}

@property (nonatomic, weak) id<PhotoBrowerScrollImageViewDataSource> dataSource;
@property (nonatomic, weak) id<PhotoBrowerScrollImageViewDelegate> delegate;
@property (nonatomic, readonly) NSInteger numberOfImages; //  total images
@property (nonatomic, readonly) NSInteger currentImageIndex;  //  current image
@property (nonatomic, copy) dispatch_block_t didTapBlock;   //  did tap

//  TODO:....
- (void)setNumberOfImages:(NSInteger)numberOfImages andCurrentImageIndex:(NSInteger)currentIndex;

//  TODO:....
- (void)willRemoveInfiniteView;

//- (void)startBreathe;   //  当点击喜欢按钮，开始呼吸效果

//- (void)stopBreathe:(BOOL)fade;    //  交互完成后，停止呼吸效果，并且变成红色

@property (nonatomic) BOOL abandonLikeButton;   //  不需要喜欢按钮

@end
