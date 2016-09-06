//
//  CameraViewController.h
//  ImgSampler
//
//  Created by Hartisan on 15/10/2.
//  Copyright © 2015年 Hartisan. All rights reserved.
//

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/imgproc/types_c.h>
#import <CoreMotion/CoreMotion.h>
#import <opencv2/features2d.hpp>

@interface CameraViewController : UIViewController <CvVideoCameraDelegate> {
    
    // OpenCV摄像机
    CvVideoCamera* _videoCamera;
    
    // 控件
    IBOutlet UIImageView* _imgView;
    IBOutlet UIButton* _btnCamera;
    IBOutlet UIButton* _btnTrack;

    // 状态
    bool _cameraOn;
    bool _trackOn;
    bool _isTracking;
    
    // Data
    cv::Mat _preFrame;
    cv::Mat _currFrame;
    std::vector<cv::Point2f> _preKeyPts;
    std::vector<cv::Point2f> _currKeyPts;
    std::vector<unsigned char> _trackStatus;
    cv::Ptr<cv::ORB> _detector;
}

@property (nonatomic, strong) CvVideoCamera* _videoCamera;
@property (nonatomic, strong) IBOutlet UIImageView* _imgView;
@property (nonatomic, strong) IBOutlet UIButton* _btnCamera;
@property (nonatomic, strong) IBOutlet UIButton* _btnTrack;
@property bool _cameraOn;
@property bool _trackOn;
@property bool _isTracking;
@property cv::Ptr<cv::ORB> _detector;;

-(IBAction) btnCameraPressed:(id)sender;
-(IBAction) btnTrackPressed:(id)sender;
-(void) setFirstFrame:(cv::Mat&)frame;
-(void) trackWithFrame:(cv::Mat&)frame;

@end
