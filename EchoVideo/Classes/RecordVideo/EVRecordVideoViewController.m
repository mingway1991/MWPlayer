//
//  EVRecordVideoViewController.m
//  EchoVideo
//
//  Created by 石茗伟 on 2019/5/9.
//  Copyright © 2019 聽風入髓. All rights reserved.
//

#import "EVRecordVideoViewController.h"
#import "MWPlayerView.h"
#import "MWPlayerConfiguration.h"

@import AVFoundation;

@interface EVRecordVideoViewController () <AVCaptureFileOutputRecordingDelegate, MWPlayerViewDelegate>

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *recordButton;

@property (nonatomic, strong) UIButton *resetButton;
@property (nonatomic, strong) UIButton *finishButton;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureMovieFileOutput *captureMovieFileOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, strong) MWPlayerView *playerView;
@property (nonatomic, copy) NSString *tempLocalPath;

@end

@implementation EVRecordVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.captureSession startRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.captureSession stopRunning];
}

- (void)dealloc {
    [_playerView stop];
    [_playerView removeFromSuperview];
}

- (void)initUI {
    [self setupCamera];
    [self.view addSubview:self.recordButton];
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.playerView];
}

- (void)setupCamera {
    NSError *error = nil;
    [self setupSessionInputs:&error];
    if (error) {
        NSLog(@"%@",error.localizedDescription);
        return;
    }
    
    // 添加预览图层
    self.captureVideoPreviewLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self.view.layer addSublayer:self.captureVideoPreviewLayer];
    self.view.layer.masksToBounds = YES;
    
    // 添加输出文件信息
    if ([self.captureSession canAddOutput:self.captureMovieFileOutput]) {
        [self.captureSession addOutput:self.captureMovieFileOutput];
    }
}

/* 初始化设备信息，摄像头、话筒 */
- (BOOL)setupSessionInputs:(NSError **)error {
    // 添加 摄像头
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:({
        [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }) error:error];
    
    if (!videoInput) { return NO; }
    
    if ([self.captureSession canAddInput:videoInput]) {
        [self.captureSession addInput:videoInput];
    } else {
        return NO;
    }
    
    // 添加 话筒
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:({
        [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    }) error:error];
    
    if (!audioInput)  { return NO; }
    
    if ([self.captureSession canAddInput:audioInput]) {
        [self.captureSession addInput:audioInput];
    } else {
        return NO;
    }
    
    return YES;
}

- (void)playVideo {
    self.playerView.hidden = NO;
    self.playerView.localUrl = self.tempLocalPath;
    [self.playerView play];
}

// 视频压缩
- (void)videoCompression{
    NSLog(@"begin");
    NSURL *tempurl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.mov"]];
    //加载视频资源
    AVAsset *asset = [AVAsset assetWithURL:tempurl];
    //创建视频资源导出会话
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    //创建导出视频的URL
    session.outputURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"tempLow.mov"]];
    //必须配置输出属性
    session.outputFileType = @"com.apple.quicktime-movie";
    //导出视频
    [session exportAsynchronouslyWithCompletionHandler:^{
        NSLog(@"end");
    }];
}

#pragma mark -
#pragma mark Action
- (void)clickCancelButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)clickRecordButton:(UIButton *)sender {
    [sender setSelected:!sender.isSelected];
    self.tempLocalPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.mov"];
    if (![self.captureMovieFileOutput isRecording]) {
        NSLog(@"开始录制");
        AVCaptureConnection *captureConnection = [self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        captureConnection.videoOrientation = [self.captureVideoPreviewLayer connection].videoOrientation;
        [self.captureMovieFileOutput startRecordingToOutputFileURL:({
            // 录制 缓存地址。
            NSURL *url = [NSURL fileURLWithPath:self.tempLocalPath];
            if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
                [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
            }
            url;
        }) recordingDelegate:self];
    } else {
        NSLog(@"停止录制");
        [self.captureMovieFileOutput stopRecording];
        [self performSelector:@selector(playVideo) withObject:nil afterDelay:1.f];
    }
}

- (void)clickResetButton {
    [self.playerView stop];
    self.playerView.hidden = YES;
}

- (void)clickFinishButton {
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(recordVideoViewController:finishRecordWithLocalPath:)]) {
            [strongSelf.delegate recordVideoViewController:strongSelf finishRecordWithLocalPath:strongSelf.tempLocalPath];
        }
    }];
}

#pragma mark -
#pragma mark AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(nonnull AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(nonnull NSURL *)outputFileURL fromConnections:(nonnull NSArray<AVCaptureConnection *> *)connections error:(nullable NSError *)error {
    
}

#pragma mark -
#pragma mark MWPlayerViewDelegate
- (void)playerViewLoadBreak:(MWPlayerView *)playerView {
    NSLog(@"加载视频失败");
}

#pragma mark -
#pragma mark LazyLoad
- (UIButton *)cancelButton {
    if (!_cancelButton) {
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.backgroundColor = [UIColor redColor];
        CGFloat buttonWidth = 60.f;
        CGFloat buttonHeight = 40.f;
        _cancelButton.frame = CGRectMake((CGRectGetWidth(self.view.bounds)/2.f-buttonWidth)/2.f, CGRectGetMinY(self.recordButton.frame)+(CGRectGetHeight(self.recordButton.bounds)-buttonHeight)/2.f, buttonWidth, buttonHeight);
        [_cancelButton addTarget:self action:@selector(clickCancelButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)recordButton {
    if (!_recordButton) {
        CGFloat buttonWidth = 80.f;
        self.recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _recordButton.backgroundColor = [UIColor redColor];
        [_recordButton setTitle:@"录制" forState:UIControlStateNormal];
        [_recordButton setTitle:@"停止" forState:UIControlStateSelected];
        _recordButton.frame = CGRectMake((CGRectGetWidth(self.view.bounds)-buttonWidth)/2.f, CGRectGetHeight(self.view.bounds)-buttonWidth-50.f, buttonWidth, buttonWidth);
        [_recordButton addTarget:self action:@selector(clickRecordButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recordButton;
}

- (AVCaptureSession *)captureSession {
    if (!_captureSession) {
        self.captureSession = [[AVCaptureSession alloc] init];
        if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetHigh]) {
            [_captureSession setSessionPreset:AVCaptureSessionPresetHigh];
        }
    }
    return _captureSession;
}

- (UIButton *)resetButton {
    if (!_resetButton) {
        self.resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _resetButton.backgroundColor = [UIColor redColor];
        CGFloat buttonWidth = 60.f;
        CGFloat buttonHeight = 40.f;
        _resetButton.frame = CGRectMake((CGRectGetWidth(self.view.bounds)/2.f-buttonWidth)/2.f, CGRectGetMinY(self.recordButton.frame)+(CGRectGetHeight(self.recordButton.bounds)-buttonHeight)/2.f, buttonWidth, buttonHeight);
        [_resetButton addTarget:self action:@selector(clickResetButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetButton;
}

- (UIButton *)finishButton {
    if (!_finishButton) {
        self.finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _finishButton.backgroundColor = [UIColor redColor];
        CGFloat buttonWidth = 60.f;
        CGFloat buttonHeight = 40.f;
        _finishButton.frame = CGRectMake((CGRectGetWidth(self.view.bounds)*3/2.f-buttonWidth)/2.f, CGRectGetMinY(self.recordButton.frame)+(CGRectGetHeight(self.recordButton.bounds)-buttonHeight)/2.f, buttonWidth, buttonHeight);
        [_finishButton addTarget:self action:@selector(clickFinishButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishButton;
}

- (MWPlayerView *)playerView {
    if (!_playerView) {
        self.playerView = [[MWPlayerView alloc] initWithFrame:self.view.bounds];
        _playerView.hidden = YES;
        _playerView.delegate = self;
        
        MWPlayerConfiguration *configuration = [MWPlayerConfiguration defaultConfiguration];
        configuration.needCoverView = NO;
        configuration.needLoop = YES;
        _playerView.configuration = configuration;
        
        [_playerView addSubview:self.resetButton];
        [_playerView addSubview:self.finishButton];
    }
    return _playerView;
}

- (AVCaptureMovieFileOutput *)captureMovieFileOutput {
    if (!_captureMovieFileOutput) {
        self.captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc]init];
        // 设置录制模式
        AVCaptureConnection *captureConnection = [_captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([captureConnection isVideoStabilizationSupported]) {
            captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
    }
    return _captureMovieFileOutput;
}

- (AVCaptureVideoPreviewLayer *)captureVideoPreviewLayer {
    if (!_captureVideoPreviewLayer) {
        self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
        _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _captureVideoPreviewLayer;
}

@end
