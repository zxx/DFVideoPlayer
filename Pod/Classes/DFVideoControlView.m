//
//  KRVideoPlayerControlView.m
//  KRKit
//
//  Created by aidenluo on 5/23/15.
//  Copyright (c) 2015 36kr. All rights reserved.
//

#import "DFVideoControlView.h"
#import "Utilities.h"

static const CGFloat kVideoControlBarHeight = 40.0;
static const CGFloat kVideoControlAnimationTimeinterval = 0.3;
static const CGFloat kVideoControlTimeLabelFontSize = 10.0;
static const CGFloat kVideoControlBarAutoFadeOutTimeinterval = 5.0;

@interface DFVideoControlView ()
{
    long duration;
}

@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *fullScreenButton;
@property (nonatomic, strong) UIButton *shrinkScreenButton;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, assign) BOOL isBarShowing;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation DFVideoControlView

#pragma mark -

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.topBar];
        [self.topBar addSubview:self.closeButton];
        [self addSubview:self.bottomBar];
        [self.bottomBar addSubview:self.playButton];
        [self.bottomBar addSubview:self.pauseButton];
        self.pauseButton.hidden = YES;
        [self.bottomBar addSubview:self.fullScreenButton];
        [self.bottomBar addSubview:self.shrinkScreenButton];
        self.shrinkScreenButton.hidden = YES;
        [self.bottomBar addSubview:self.progressSlider];
        [self.bottomBar addSubview:self.timeLabel];
        [self addSubview:self.indicatorView];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.topBar.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds), CGRectGetWidth(self.bounds), kVideoControlBarHeight);
    self.closeButton.frame = CGRectMake(CGRectGetWidth(self.topBar.bounds) - CGRectGetWidth(self.closeButton.bounds), CGRectGetMinX(self.topBar.bounds), CGRectGetWidth(self.closeButton.bounds), CGRectGetHeight(self.closeButton.bounds));
    self.bottomBar.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetHeight(self.bounds) - kVideoControlBarHeight, CGRectGetWidth(self.bounds), kVideoControlBarHeight);
    self.playButton.frame = CGRectMake(CGRectGetMinX(self.bottomBar.bounds), CGRectGetHeight(self.bottomBar.bounds)/2 - CGRectGetHeight(self.playButton.bounds)/2, CGRectGetWidth(self.playButton.bounds), CGRectGetHeight(self.playButton.bounds));
    self.pauseButton.frame = self.playButton.frame;
    self.fullScreenButton.frame = CGRectMake(CGRectGetWidth(self.bottomBar.bounds) - CGRectGetWidth(self.fullScreenButton.bounds), CGRectGetHeight(self.bottomBar.bounds)/2 - CGRectGetHeight(self.fullScreenButton.bounds)/2, CGRectGetWidth(self.fullScreenButton.bounds), CGRectGetHeight(self.fullScreenButton.bounds));
    self.shrinkScreenButton.frame = self.fullScreenButton.frame;
    self.progressSlider.frame = CGRectMake(CGRectGetMaxX(self.playButton.frame), CGRectGetHeight(self.bottomBar.bounds)/2 - CGRectGetHeight(self.progressSlider.bounds)/2, CGRectGetMinX(self.fullScreenButton.frame) - CGRectGetMaxX(self.playButton.frame), CGRectGetHeight(self.progressSlider.bounds));
    self.timeLabel.frame = CGRectMake(CGRectGetMidX(self.progressSlider.frame), CGRectGetHeight(self.bottomBar.bounds) - CGRectGetHeight(self.timeLabel.bounds) - 2.0, CGRectGetWidth(self.progressSlider.bounds)/2, CGRectGetHeight(self.timeLabel.bounds));
    self.indicatorView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (void)updateConstraints {
    [super updateConstraints];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    self.isBarShowing = YES;
}

- (void)setPlaying:(BOOL)playing {
    if (playing) {
        [self setPlayButtonHidden:YES pauseButtonHidden:NO];
        [self autoFadeOutControlBar];
    } else {
        [self setPlayButtonHidden:NO pauseButtonHidden:YES];
    }
}

- (void)setBuffering:(BOOL)buffering {
    if (buffering) {
        self.indicatorView.hidden = NO;
        [self setPlaying:NO];
    } else {
        self.indicatorView.hidden = YES;
        [self setPlaying:YES];
    }
}

- (void)reset
{
}

- (void)updateProgress:(long)currentTime totalTime:(long)totalTime {
    // slider 默认0-1
    duration = totalTime;
	[self.progressSlider setValue:(float)currentTime / totalTime];
    [self setTimeLabelValues:currentTime totalTime:totalTime];
}

#pragma mark - Event reponse and GetureRecognizer

- (void)playButtonClick:(UIButton *)sender {
    [self.delegate videoControlView:self didPlayButtonClicked:sender];
    [self setPlaying:YES];
    
    [self autoFadeOutControlBar];
}

- (void)pauseButtonClick:(UIButton *)sender {
    [self.delegate videoControlView:self didPauseButtonClicked:sender];
    [self setPlaying:NO];
    
    [self cancelAutoFadeOutControlBar];
}

- (void)fullScreenButtonClick:(UIButton *)sender {
    [self.delegate videoControlView:self didFullScreenButtonClicked:sender];
    [self setFullScreenButtonHidden:YES shrinkScreenButtonHidden:NO];
    
    [self autoFadeOutControlBar];
}

- (void)shrinkScreenButtonClick:(UIButton *)sender {
    [self.delegate videoControlView:self didShrinkScreenButtonClicked:sender];
    [self setFullScreenButtonHidden:NO shrinkScreenButtonHidden:YES];
    
    [self autoFadeOutControlBar];
}

- (void)closeButtonClick:(UIButton *)sender {
    [self.delegate videoControlView:self didCloseButtonClicked:sender];
}

- (void)progressSliderValueDidChanged:(UISlider *)sender {
    long currentTime = sender.value * duration;
    [self setTimeLabelValues:currentTime totalTime:duration];
}

- (void)progressSliderActionDown:(UISlider *)sender {
    [self.delegate videoControlView:self didProgressSliderDragBegan:sender];
    
    [self cancelAutoFadeOutControlBar];
}

- (void)progressSliderActionUp:(UISlider *)sender {
    [self.delegate videoControlView:self didProgressSliderDragEnded:sender];
    
    [self autoFadeOutControlBar];
}

- (void)onTap:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        if (self.isBarShowing) {
            [self animateHide];
        } else {
            [self animateShow];
        }
    }
}

#pragma mark - Private methods

- (void)animateHide {
    if (!self.isBarShowing) {
        return;
    }
    [UIView animateWithDuration:kVideoControlAnimationTimeinterval animations:^{
        self.topBar.alpha = 0.0;
        self.bottomBar.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.isBarShowing = NO;
    }];
}

- (void)animateShow {
    if (self.isBarShowing) {
        return;
    }
    [UIView animateWithDuration:kVideoControlAnimationTimeinterval animations:^{
        self.topBar.alpha = 1.0;
        self.bottomBar.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.isBarShowing = YES;
        [self autoFadeOutControlBar];
    }];
}

- (void)autoFadeOutControlBar {
    if (!self.isBarShowing || !self.playButton.hidden) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHide) object:nil];
    [self performSelector:@selector(animateHide) withObject:nil afterDelay:kVideoControlBarAutoFadeOutTimeinterval];
}

- (void)cancelAutoFadeOutControlBar {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHide) object:nil];
}

- (NSString *)videoImageName:(NSString *)name {
    if (name) {
        NSString *path = [NSString stringWithFormat:@"%@",name];
        return path;
    }
    return nil;
}

- (void)setTimeLabelValues:(long)currentTime totalTime:(long)totalTime {
    [self.timeLabel setText:[NSString stringWithFormat:@"%@/%@", [Utilities timeToHumanString:currentTime], [Utilities timeToHumanString:totalTime]]];
}

- (void)setPlayButtonHidden:(BOOL)playButtonHidden pauseButtonHidden:(BOOL)pauseButtonHidden {
    self.playButton.hidden = playButtonHidden;
    self.pauseButton.hidden = pauseButtonHidden;
}

- (void)setFullScreenButtonHidden:(BOOL)fullScreenButtonHidden shrinkScreenButtonHidden:(BOOL)shrinkScreenButtonHidden {
    self.fullScreenButton.hidden = fullScreenButtonHidden;
    self.shrinkScreenButton.hidden = shrinkScreenButtonHidden;
}

#pragma mark - Getters and Setters

- (UIView *)topBar {
    if (!_topBar) {
        _topBar = [UIView new];
        _topBar.backgroundColor = [UIColor clearColor];
    }
    return _topBar;
}

- (UIView *)bottomBar {
    if (!_bottomBar) {
        _bottomBar = [UIView new];
        _bottomBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }
    return _bottomBar;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:[self videoImageName:@"kr-video-player-play"]] forState:UIControlStateNormal];
        _playButton.bounds = CGRectMake(0, 0, kVideoControlBarHeight, kVideoControlBarHeight);
        [_playButton addTarget:self action:@selector(playButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (UIButton *)pauseButton {
    if (!_pauseButton) {
        _pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pauseButton setImage:[UIImage imageNamed:[self videoImageName:@"kr-video-player-pause"]] forState:UIControlStateNormal];
        _pauseButton.bounds = CGRectMake(0, 0, kVideoControlBarHeight, kVideoControlBarHeight);
        [_pauseButton addTarget:self action:@selector(pauseButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pauseButton;
}

- (UIButton *)fullScreenButton {
    if (!_fullScreenButton) {
        _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenButton setImage:[UIImage imageNamed:[self videoImageName:@"kr-video-player-fullscreen"]] forState:UIControlStateNormal];
        _fullScreenButton.bounds = CGRectMake(0, 0, kVideoControlBarHeight, kVideoControlBarHeight);
        [_fullScreenButton addTarget:self action:@selector(fullScreenButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScreenButton;
}

- (UIButton *)shrinkScreenButton {
    if (!_shrinkScreenButton) {
        _shrinkScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shrinkScreenButton setImage:[UIImage imageNamed:[self videoImageName:@"kr-video-player-shrinkscreen"]] forState:UIControlStateNormal];
        _shrinkScreenButton.bounds = CGRectMake(0, 0, kVideoControlBarHeight, kVideoControlBarHeight);
        [_shrinkScreenButton addTarget:self action:@selector(shrinkScreenButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shrinkScreenButton;
}

- (UISlider *)progressSlider {
    if (!_progressSlider) {
        _progressSlider = [[UISlider alloc] init];
        [_progressSlider setThumbImage:[UIImage imageNamed:[self videoImageName:@"kr-video-player-point"]] forState:UIControlStateNormal];
        [_progressSlider setMinimumTrackTintColor:[UIColor whiteColor]];
        [_progressSlider setMaximumTrackTintColor:[UIColor lightGrayColor]];
        _progressSlider.value = 0.f;
        _progressSlider.continuous = YES;
        [_progressSlider addTarget:self action:@selector(progressSliderValueDidChanged:) forControlEvents:UIControlEventValueChanged];
        [_progressSlider addTarget:self action:@selector(progressSliderActionDown:) forControlEvents:UIControlEventTouchDown];
        [_progressSlider addTarget:self action:@selector(progressSliderActionUp:) forControlEvents:UIControlEventTouchUpInside];
        [_progressSlider addTarget:self action:@selector(progressSliderActionUp:) forControlEvents:UIControlEventTouchCancel];
    }
    return _progressSlider;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:[self videoImageName:@"kr-video-player-close"]] forState:UIControlStateNormal];
        _closeButton.bounds = CGRectMake(0, 0, kVideoControlBarHeight, kVideoControlBarHeight);
        [_closeButton addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:kVideoControlTimeLabelFontSize];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.bounds = CGRectMake(0, 0, kVideoControlTimeLabelFontSize, kVideoControlTimeLabelFontSize);
    }
    return _timeLabel;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_indicatorView stopAnimating];
    }
    return _indicatorView;
}
@end