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
#import "UIColor+MWUtil.h"

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
@property (nonatomic, copy) NSString *tempLowLocalPath;

@end

@implementation EVRecordVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tempLocalPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.mov"];
    [self deleteTempLocalVideo];
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

- (void)deleteTempLocalVideo {
    NSError *error = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.tempLocalPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.tempLocalPath error:&error];
        if (error) {
            NSLog(@"删除视频错误:%@",error.localizedDescription);
        }
    }
}

#pragma mark -
#pragma mark Action
- (void)clickCancelButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)clickRecordButton:(UIButton *)sender {
    [sender setSelected:!sender.isSelected];
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
        self.recordButton.enabled = NO;
        self.cancelButton.enabled = NO;
        [self performSelector:@selector(playVideo) withObject:nil afterDelay:1.f];
    }
}

- (void)clickResetButton {
    [self.playerView stop];
    self.playerView.hidden = YES;
    self.recordButton.enabled = YES;
    self.cancelButton.enabled = YES;
}

- (void)clickFinishButton {
    NSLog(@"begin");
    NSURL *tempurl = [NSURL fileURLWithPath:self.tempLocalPath];
    self.tempLowLocalPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tempLow.mov"];
    //加载视频资源
    AVAsset *asset = [AVAsset assetWithURL:tempurl];
    //创建视频资源导出会话
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    //创建导出视频的URL
    session.outputURL = [NSURL fileURLWithPath:self.tempLowLocalPath];
    //必须配置输出属性
    session.outputFileType = @"com.apple.quicktime-movie";
    //导出视频
    __weak typeof(self) weakSelf = self;
    [session exportAsynchronouslyWithCompletionHandler:^{
        [self dismissViewControllerAnimated:YES completion:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if ([strongSelf.delegate respondsToSelector:@selector(recordVideoViewController:finishRecordWithLocalPath:)]) {
                [strongSelf.delegate recordVideoViewController:strongSelf finishRecordWithLocalPath:strongSelf.tempLowLocalPath];
            }
        }];
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
        [_cancelButton setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
        CGFloat buttonWidth = 60.f;
        _cancelButton.frame = CGRectMake((CGRectGetWidth(self.view.bounds)/2.f-buttonWidth-CGRectGetWidth(self.resetButton.bounds)/2.f)/2.f, CGRectGetMinY(self.recordButton.frame)+(CGRectGetHeight(self.recordButton.bounds)-buttonWidth)/2.f, buttonWidth, buttonWidth);
        [_cancelButton addTarget:self action:@selector(clickCancelButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)recordButton {
    if (!_recordButton) {
        CGFloat buttonWidth = 80.f;
        self.recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _recordButton.layer.cornerRadius = buttonWidth/2.f;
        _recordButton.backgroundColor = [UIColor whiteColor];
        [_recordButton setTitle:@"录制" forState:UIControlStateNormal];
        [_recordButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_recordButton setTitle:@"停止" forState:UIControlStateSelected];
        [_recordButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
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
        _resetButton.backgroundColor = [UIColor mw_colorWithHexString:@"F5F5F5"];
        [_resetButton setImage:[UIImage imageNamed:@"reset"] forState:UIControlStateNormal];
        CGFloat buttonWidth = 60.f;
        _resetButton.layer.cornerRadius = buttonWidth/2.f;
        _resetButton.frame = CGRectMake((CGRectGetWidth(self.view.bounds)/2.f-buttonWidth)/2.f, CGRectGetMinY(self.recordButton.frame)+(CGRectGetHeight(self.recordButton.bounds)-buttonWidth)/2.f, buttonWidth, buttonWidth);
        [_resetButton addTarget:self action:@selector(clickResetButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetButton;
}

- (UIButton *)finishButton {
    if (!_finishButton) {
        self.finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _finishButton.backgroundColor = [UIColor mw_colorWithHexString:@"F5F5F5"];
        [_finishButton setImage:[UIImage imageNamed:@"confirm"] forState:UIControlStateNormal];
        CGFloat buttonWidth = 60.f;
        _finishButton.layer.cornerRadius = buttonWidth/2.f;
        _finishButton.frame = CGRectMake((CGRectGetWidth(self.view.bounds)*3/2.f-buttonWidth)/2.f, CGRectGetMinY(self.recordButton.frame)+(CGRectGetHeight(self.recordButton.bounds)-buttonWidth)/2.f, buttonWidth, buttonWidth);
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
