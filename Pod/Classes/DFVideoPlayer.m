//
//  ViewController.m
//  DFVitamioVideoPlayer
//
//  Created by zhudf on 15/5/29.
//  Copyright (c) 2015年 朱东方. All rights reserved.
//

#import "DFVideoPlayer.h"
#import "DFVideoControlView.h"
#import "Vitamio.h"

@interface DFVideoPlayer ()<VMediaPlayerDelegate, DFVideoControlViewDelegate>

@property (nonatomic, strong) VMediaPlayer *mediaPlayer;

@property (nonatomic, strong)   UIView              *view;
@property (nonatomic, strong)   UIView              *carrierView;
@property (nonatomic, strong)   DFVideoControlView  *videoControlView;

@property (nonatomic, weak)     UIView              *parentView;

@property (nonatomic, copy)     NSURL               *videoUrl;

@property (nonatomic, assign)   long                duration;
@property (nonatomic, strong)   NSTimer             *durationTimer;

@property (nonatomic, assign)   BOOL                progressDragging;
@property (nonatomic, assign)   BOOL                mediaPlayerInited;

@property (nonatomic, copy)     NSArray             *constraints;

@end

@implementation DFVideoPlayer

#pragma mark - Life Cycle

- (instancetype)initWithURL:(NSURL *)videoUrl
{
    if (self = [super init]) {
        self.videoUrl = videoUrl;
    }
    return self;
}

- (void)showInWindow
{
    UIWindow *windown = [UIApplication sharedApplication].keyWindow;
    if (!windown) {
        windown = [[UIApplication sharedApplication].windows firstObject];
    }
    [self.view addSubview:self.carrierView];
    [self.view addSubview:self.videoControlView];
    [windown addSubview:self.view];
    
    self.parentView = windown;
    [self addFixedConstraintsForSubviews];
    [self updateConstraints];
    
    [self start];
}

- (void)showInParentView:(UIView *)parentView
{
    [self.view addSubview:self.carrierView];
    [self.view addSubview:self.videoControlView];
    [parentView addSubview:self.view];
    
    self.parentView = parentView;
    [self addFixedConstraintsForSubviews];
    [self updateConstraints];
    
    [self start];
}

- (void)start
{
    [self startPlayerWithUrl:self.videoUrl];
}

- (void)dismiss
{
    [self stopPlayer];
    [self.view removeFromSuperview];
}

- (void)updateViewWithInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [self updateConstraintsForInterfaceOrientation:interfaceOrientation];
}

- (void)updateConstraints
{
    UIInterfaceOrientation interfaceOrientaion = [UIApplication sharedApplication].statusBarOrientation;
    [self updateConstraintsForInterfaceOrientation:interfaceOrientaion];
}

/* 这块的处理是从AdaptivePhoto项目中学到的 */
- (void)updateConstraintsForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSMutableArray *newConstraints;
    NSDictionary *views = @{@"view":self.view};
    newConstraints = [NSMutableArray array];
    
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:views]];
        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[view]"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:views]];
        [newConstraints addObject:[NSLayoutConstraint constraintWithItem:self.view
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.parentView
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:(9.0 / 16.0)
                                                                constant:0.0]];
    } else {
        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:views]];
        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:views]];
    }

    if (self.constraints) {
        [self.parentView removeConstraints:self.constraints];
    }
    self.constraints = newConstraints;
    [self.parentView addConstraints:self.constraints];
    
    // 强制刷新，必须要得到carrierView的frame。因为Vitamio不支持autolayout
    // How can I get a view's current width and height when using autolayout constraints
    // http://stackoverflow.com/a/13542580/3355097
    [self.parentView layoutIfNeeded];
}

- (void)addFixedConstraintsForSubviews
{
    NSDictionary *views = @{@"carrierView":self.carrierView, @"videoControlView":self.videoControlView};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[carrierView]|"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[videoControlView]|"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[carrierView]|"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[videoControlView]|"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:views]];
}

#pragma mark - DFVideoControlViewDelegate

- (void)videoControlView:(DFVideoControlView *)controlView didPlayButtonClicked:(UIButton *)playerButton
{
    if (self.mediaPlayerInited) {
        if (![self.mediaPlayer isPlaying]) {
            [self.mediaPlayer start];
        }
    } else {
        [self start];
    }
}

- (void)videoControlView:(DFVideoControlView *)controlView didPauseButtonClicked:(UIButton *)pauseButton
{
    if (self.mediaPlayerInited) {
        if ([self.mediaPlayer isPlaying]) {
            [self.mediaPlayer pause];
        }
    } else {
        [self start];
    }
}

- (void)videoControlView:(DFVideoControlView *)controlView didCloseButtonClicked:(UIButton *)closeButton
{
    [self dismiss];
}

- (void)videoControlView:(DFVideoControlView *)controlView didFullScreenButtonClicked:(UIButton *)fullScrrenButton
{
    [self setDeviceOrientation:UIDeviceOrientationLandscapeLeft];
}

- (void)videoControlView:(DFVideoControlView *)controlView didShrinkScreenButtonClicked:(UIButton *)shrinkScreenButton
{
    [self setDeviceOrientation:UIDeviceOrientationPortrait];
}

- (void)videoControlView:(DFVideoControlView *)controlView didProgressSliderDragBegan:(UISlider *)sener
{
    // 控制Timer
    self.progressDragging = YES;
}

- (void)videoControlView:(DFVideoControlView *)controlView didProgressSliderDragEnded:(UISlider *)sener
{
    if (self.mediaPlayerInited) {
        [self.mediaPlayer seekTo:sener.value * self.duration];
    }
}

#pragma mark - VMediaPlayerDelegate required

- (void)mediaPlayer:(VMediaPlayer *)player didPrepared:(id)arg
{
    [player start];
    self.duration = [player getDuration];
    [self startDurationTimer];
    
    [self.videoControlView setPlaying:YES];
}

- (void)mediaPlayer:(VMediaPlayer *)player playbackComplete:(id)arg
{
    [player seekTo:(long)0];
    [player pause];
    
    [self.videoControlView setPlaying:NO];
    [self.videoControlView alignmentRectInsets];
}

- (void)mediaPlayer:(VMediaPlayer *)player error:(id)arg
{
    [self.videoControlView setPlaying:NO];
}

#pragma mark - VMediaPlayerDelegate optional
/**
 * Called when set the data source to player.
 *
 * You can tell media player manager what preference are you like in this call back method.
 * e.g. set `player.decodingSchemeHint` or `player.autoSwitchDecodingScheme`,
 * `player.useCache` ect.
 *
 * @param player The shared media player instance.
 * @param arg Not use.
 */
- (void)mediaPlayer:(VMediaPlayer *)player setupManagerPreference:(id)arg
{
	player.decodingSchemeHint = VMDecodingSchemeSoftware;
	player.autoSwitchDecodingScheme = NO;
}

/**
 * Called when the VMediaPlayer try to open media strem with another decoding schmeme.
 *
 * If `autoSwitchDecodingScheme' is YES and VMedaiPlayer failed to open stream with
 * `decodingSchemeHint` scheme, VMediaPlayer will try to a new scheme, the old and new
 * scheme return in `arg`.
 *
 * @param player The shared media player instance.
 * @param arg *NSArray|NSNumber*, int value. Contain the old&new decoding scheme.
 */
- (void)mediaPlayer:(VMediaPlayer *)player setupPlayerPreference:(id)arg
{
	// Set buffer size, default is 1024KB(1024*1024).
	[player setBufferSize:512*1024];
	[player setVideoQuality:VMVideoQualityHigh];
    [player setVideoFillMode:VMVideoFillModeFit];
}

- (void)mediaPlayer:(VMediaPlayer *)player seekComplete:(id)arg
{
    self.progressDragging = NO;
}

- (void)mediaPlayer:(VMediaPlayer *)player notSeekable:(id)arg
{
	self.progressDragging = NO;
}

- (void)mediaPlayer:(VMediaPlayer *)player bufferingStart:(id)arg
{
    [self.mediaPlayer pause];
    
	self.progressDragging = YES;
    [self.videoControlView setBuffering:YES];
}

- (void)mediaPlayer:(VMediaPlayer *)player bufferingUpdate:(id)arg
{
//    [self.videoControlView updateBufferedProgress:[arg intValue]];
}

- (void)mediaPlayer:(VMediaPlayer *)player bufferingEnd:(id)arg
{
    [self.mediaPlayer start];
    
	self.progressDragging = NO;
    [self.videoControlView setBuffering:NO];
}

- (void)mediaPlayer:(VMediaPlayer *)player downloadRate:(id)arg
{
}

#pragma mark - Event reponse

- (void)timerTask
{
	if (!self.progressDragging && self.mediaPlayerInited) {
        [self.videoControlView updateProgress:[self.mediaPlayer getCurrentPosition] totalTime:self.duration];
	}
}

#pragma mark - Private methods

- (void)startPlayerWithUrl:(NSURL *)url
{
    [self.mediaPlayer setDataSource:url];
    [self.mediaPlayer prepareAsync];
    
    self.mediaPlayerInited = YES;
}

- (void)stopPlayer
{
    [self stopDurationTimer];
    [self.mediaPlayer reset];
    
    self.mediaPlayerInited = NO;
}

- (void)startDurationTimer
{
    self.durationTimer = [NSTimer timerWithTimeInterval:1.0
                                                 target:self
                                               selector:@selector(timerTask)
                                               userInfo:nil
                                                repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.durationTimer forMode:NSRunLoopCommonModes];
}

- (void)stopDurationTimer
{
    [self.durationTimer invalidate];
}

- (void)setDeviceOrientation:(UIDeviceOrientation)orientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    
}

#pragma mark - Getters and Setters

- (DFVideoControlView *)videoControlView
{
    if (!_videoControlView) {
        _videoControlView = [[DFVideoControlView alloc] init];
        _videoControlView.userInteractionEnabled = YES;
        _videoControlView.delegate = self;
        _videoControlView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _videoControlView;
}

- (UIView *)view
{
    if (!_view) {
        _view = [[UIView alloc] init];
        [_view setClipsToBounds:YES];
        _view.backgroundColor = [UIColor blackColor];
        _view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _view;
}

- (UIView *)carrierView
{
    if (!_carrierView) {
        _carrierView = [[UIView alloc] init];
        _carrierView.backgroundColor = [UIColor clearColor];
        _carrierView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _carrierView;
}

- (VMediaPlayer *)mediaPlayer
{
    if (!_mediaPlayer) {
        _mediaPlayer = [VMediaPlayer sharedInstance];
        [_mediaPlayer setupPlayerWithCarrierView:self.carrierView withDelegate:self];
    }
    return _mediaPlayer;
}
@end