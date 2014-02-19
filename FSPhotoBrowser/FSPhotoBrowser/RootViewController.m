//
//  RootViewController.m
//  FSPhotoBrowser
//
//  Created by Fengshan.yang on 14-2-17.
//  Copyright (c) 2014年 Fanyi Network techonology Co.,Ltd. All rights reserved.
//

#import "RootViewController.h"
#import "FSPhotoBrowser.h"

@interface RootViewController ()<PhotoBrowerScrollImageViewDataSource, PhotoBrowerScrollImageViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;

@end


@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake(100, 200, 120.0f, 50.0f)];
    [[button layer] setBorderColor:[UIColor redColor].CGColor];
    [[button layer] setBorderWidth:1.0f];
    [button setTitle:@"show image" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:button];

    self.dataArray = [NSMutableArray arrayWithObjects:
                  @"http://img3.cache.netease.com/photo/0001/2014-02-14/9L2LRI9K19BR0001.jpg",
                  @"http://img1.cache.netease.com/sports/2014/2/19/201402190918061d9f4.jpg",
                  @"http://img1.cache.netease.com/sports/2014/2/18/201402180902059c165.jpg",
                  @"http://img3.cache.netease.com/sports/2014/2/17/20140217075444348e5.jpg",
                  @"http://img3.cache.netease.com/sports/2014/2/16/20140216081941b2406.jpg",
                  @"http://img1.cache.netease.com/sports/2014/2/15/20140215091002fa47f.jpg", nil];
}

- (void)buttonClick
{
    NSLog(@"buttonClick");

    BOOL isIos7 = [[UIDevice currentDevice].systemVersion floatValue] >= 7.0;
    CGRect rect = CGRectMake(0,
                             0,
                             CGRectGetWidth([[self view] bounds]),
                             CGRectGetHeight([[self view] bounds]));

    if (isIos7) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }

    FSPhotoBrowser *view = [[FSPhotoBrowser alloc] initWithFrame:rect];
    [view setDataSource:self];
    [view setDelegate:self];
    [view setNumberOfImages:[_dataArray count] andCurrentImageIndex:0];
    __block typeof(FSPhotoBrowser *) __weak browser = view;
    [view setDidTapBlock:^() {
        [browser willRemoveInfiniteView];
    }];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:view];
}

#pragma mark -
#pragma mark - Delegate and datasource

- (NSString *)photoBrowser:(FSPhotoBrowser *)browser requestDataWithType:(PhotoBrowerScrollRequestDataType)type atIndex:(NSInteger)index
{
    if (index < [_dataArray count]) {
        return [_dataArray objectAtIndex:index];
    } else {
        return nil;
    }
}

@end
