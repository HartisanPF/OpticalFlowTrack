//
//  CameraViewController.m
//  ImgSampler
//
//  Created by Hartisan on 15/10/2.
//  Copyright © 2015年 Hartisan. All rights reserved.
//

#import "CameraViewController.h"

@implementation CameraViewController

@synthesize _imgView, _videoCamera, _btnCamera, _cameraOn, _btnTrack, _trackOn, _isTracking, _detector;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 初始化摄像头
    CvVideoCamera* camera = [[CvVideoCamera alloc] initWithParentView:_imgView];
    self._videoCamera = camera;
    self._videoCamera.delegate = self;
    self._videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self._videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    self._videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationLandscapeRight;
    self._videoCamera.defaultFPS = 30;
    
    // 初始化状态
    self._cameraOn = false;
    self._trackOn = false;
    self._isTracking = false;
    
    // 初始化检测器
    self._detector = cv::ORB::create();
    self._detector->setMaxFeatures(300);
}


// 对每一帧图像进行处理
- (void) processImage:(cv::Mat&)image {
    
    if (!image.empty()) {
        
        cv::Mat grayFrame;
        cv::cvtColor(image, grayFrame, CV_BGRA2GRAY);
        
        if (self._trackOn) {
            
            if (!self._isTracking) {
                
                // 设置起始帧
                [self setFirstFrame:grayFrame];
                
                self._isTracking = true;
                
            } else {
                
                // 利用上一帧进行跟踪
                [self trackWithFrame:grayFrame];
                
                // 绘制跟踪结果
                for (auto point : _currKeyPts) {
                    
                    cv::circle(image, point, 3, cv::Scalar(0,250,0), -1);
                }
            }
        }
    }
}


// 设置起始帧
-(void) setFirstFrame:(cv::Mat&)frame {
    
    _preFrame = frame.clone();
    //cv::goodFeaturesToTrack(frame, _preKeyPts, 80, 0.1, 5);
    
    std::vector<cv::KeyPoint> orbKeyPts;
    self._detector->detect(frame, orbKeyPts);
    _preKeyPts.clear();
    for (auto keyPt : orbKeyPts) {
        _preKeyPts.push_back(keyPt.pt);
    }
}

// 利用前帧对当前帧进行跟踪
-(void) trackWithFrame:(cv::Mat&)frame {
    
    _currFrame = frame.clone();
    _currKeyPts.clear();
    std::vector<float> err;
    cv::calcOpticalFlowPyrLK(_preFrame, _currFrame, _preKeyPts, _currKeyPts, _trackStatus, err, cv::Size(21,21), 3);
    
    // 统计成功跟踪的特征点数量
    std::vector<cv::Point2f> trackedPts;
    for (size_t i = 0; i < _trackStatus.size(); i++)
    {
        if (_trackStatus[i]) {
            
            trackedPts.push_back(_currKeyPts[i]);        }
    }
    
    if (trackedPts.size() < 10) {
        
        self._isTracking = false;
        self._trackOn = false;
        
    } else {
        
        _preFrame = _currFrame.clone();
        _currKeyPts = trackedPts;
        _preKeyPts = trackedPts;
    }
}


// 按钮
-(IBAction) btnTrackPressed:(id)sender {
    
    self._trackOn = true;
    
}


-(IBAction) btnCameraPressed:(id)sender {
    
    if (self._cameraOn) {
        
        [self._videoCamera stop];
        [self._btnCamera setTitle:@"Camera On" forState:UIControlStateNormal];
        
        self._cameraOn = false;
        self._trackOn = false;
        self._isTracking = false;
        
    } else {
        
        [self._videoCamera start];
        [self._btnCamera setTitle:@"Camera Off" forState:UIControlStateNormal];
        
        self._cameraOn = true;
    }
}

@end
