//
//  DFViewController.m
//  DFVideoPlayer
//
//  Created by zhudf on 06/07/2015.
//  Copyright (c) 2014 zhudf. All rights reserved.
//

#import "DFViewController.h"
#import <DFVideoPlayer/DFVideoPlayer.h>

@interface DFViewController ()

@property (nonatomic, retain) DFVideoPlayer *player;

@end

@implementation DFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
self.player = [[DFVideoPlayer alloc] initWithURL:[NSURL URLWithString:@"http://krtv.qiniudn.com/150522nextapp"]];
//    [self.player showInWindow];
//    [self.player showInView:self.view];
[self.player showInView:self.view inset:UIEdgeInsetsMake(20, 0, 0, 0)];
}

@end
