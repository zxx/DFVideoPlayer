//
//  DFVideoControlView.h
//  DFVideoPlayer
//
//  Created by zhudf on 15/5/29.
//  Copyright (c) 2015年 朱东方. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DFVideoControlView;

@protocol DFVideoControlViewDelegate <NSObject>

@required
- (void)videoControlView:(DFVideoControlView *)controlView didPlayButtonClicked:(UIButton *)sender;
- (void)videoControlView:(DFVideoControlView *)controlView didPauseButtonClicked:(UIButton *)sender;
- (void)videoControlView:(DFVideoControlView *)controlView didCloseButtonClicked:(UIButton *)sender;
- (void)videoControlView:(DFVideoControlView *)controlView didFullScreenButtonClicked:(UIButton *)sender;
- (void)videoControlView:(DFVideoControlView *)controlView didShrinkScreenButtonClicked:(UIButton *)sender;
- (void)videoControlView:(DFVideoControlView *)controlView didProgressSliderDragBegan:(UISlider *)slider;
- (void)videoControlView:(DFVideoControlView *)controlView didProgressSliderDragEnded:(UISlider *)slider;

// 可以定义一个getProgress协议。就可以在这里定义一个Timer了。

@end
@interface DFVideoControlView : UIView

@property (nonatomic, strong, readonly) UIView *topBar;
@property (nonatomic, strong, readonly) UIView *bottomBar;
@property (nonatomic, strong, readonly) UIButton *playButton;
@property (nonatomic, strong, readonly) UIButton *pauseButton;
@property (nonatomic, strong, readonly) UIButton *fullScreenButton;
@property (nonatomic, strong, readonly) UIButton *shrinkScreenButton;
@property (nonatomic, strong, readonly) UISlider *progressSlider;
@property (nonatomic, strong, readonly) UIButton *closeButton;
@property (nonatomic, strong, readonly) UILabel *timeLabel;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *indicatorView;


@property (nonatomic, weak) id<DFVideoControlViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)setPlaying:(BOOL)playing;
- (void)setBuffering:(BOOL)buffering;

- (void)updateProgress:(long)currentTime totalTime:(long)totalTime;

- (void)reset;
@end
