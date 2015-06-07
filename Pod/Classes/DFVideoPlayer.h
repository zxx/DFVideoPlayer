//
//  ViewController.h
//  DFVitamioVideoPlayer
//
//  Created by zhudf on 15/5/29.
//  Copyright (c) 2015年 朱东方. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DFVideoPlayer;
@class DFVideoControlView;

@protocol DFVideoPlayerDelegate <NSObject>

@optional
- (void)videoPlayer:(DFVideoPlayer *)player didCompleted:(BOOL)complete;
- (void)videoPlayer:(DFVideoPlayer *)player didError:(NSError *)error;

- (NSMutableArray *)videoPlayerLayout:(DFVideoPlayer *)player constraintsForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end

@interface DFVideoPlayer :NSObject

@property (nonatomic, readonly) UIView *view;
@property (nonatomic) UIInterfaceOrientation orientation;
@property (nonatomic, weak) id<DFVideoPlayerDelegate>       delegate;

- (instancetype)initWithURL:(NSURL *)url;

/* viewWillAppear 中调用 */
- (void)showInWindow;
/* viewWillAppear 中调用 */
- (void)showInParentView:(UIView *)parentView;
- (void)dismiss;

/* willRotateToInterfaceOrientation 中调用 */
- (void)setOrientation:(UIInterfaceOrientation)orientation;
- (void)updateViewWithInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end