//
//  MKFaceScrollView.m
//  WXWeibo
//
//  Created by Mark Lewis on 16-5-10.
//  Copyright (c) 2016年 MarkLewis All rights reserved.
//

#import "MKFaceScrollView.h"

@implementation MKFaceScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // init code
        [self initViews];
    }
    return self;
}


- (id)initWithSelectBlock:(SelectBlock)block
{
    return nil;
}

-(void)initViews
{
    
    faceView = [[MKFaceView alloc]initWithFrame:CGRectZero];
    
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, faceView.height+10)];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.contentSize = CGSizeMake(faceView.width, faceView.height);
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.clipsToBounds = NO;
    scrollView.delegate = self;
    [scrollView addSubview:faceView];
    [faceView release];
    [self addSubview:scrollView];
    
    pageControl  = [[UIPageControl alloc]initWithFrame:CGRectMake(0, scrollView.bottom, 40, 20)];
    pageControl.backgroundColor = [UIColor clearColor];
    pageControl.pageIndicatorTintColor = [UIColor redColor];
    pageControl.numberOfPages = faceView.pageNumber;
    pageControl.currentPage = 0;
    
    [self addSubview:pageControl];
    [pageControl release];
    [scrollView release];
    
    
    self.height = scrollView.height + pageControl.height;
    self.width = scrollView.width;
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"emoticon_keyboard_background.png" ]];
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
    
    int pageNumber = _scrollView.contentOffset.x / 320;
    pageControl.currentPage = pageNumber;
    
    
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 */
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    [[UIImage imageNamed:@"emoticon_keyboard_background.png"] drawInRect:rect];
}

@end