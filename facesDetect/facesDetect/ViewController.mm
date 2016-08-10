//
//  ViewController.m
//  facesDetect
//
//  Created by Yunys_IOS_Dev on 16/8/3.
//  Copyright © 2016年 Yunys_IOS_Dev. All rights reserved.
//

#import "ViewController.h"

#import <opencv2/highgui/ios.h>
#import <opencv2/highgui/cap_ios.h>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/opencv.hpp>
#import <opencv2/objdetect/objdetect.hpp>
#import <opencv2/highgui/highgui.hpp>
#import <opencv2/imgproc/imgproc.hpp>

using namespace cv;
//using namespace std;

@interface ViewController ()<CvVideoCameraDelegate>
{
    cv::Mat dogMat;
    cv::Mat dogMask;
    cv::CascadeClassifier faceDetector;
}

@property(nonatomic,strong)CvVideoCamera *videoCamera;
/* 显示照片 */
@property(nonatomic,strong) UIImageView *imageView;
@property(nonatomic,strong) UIImageView *dogImageView;
@property(nonatomic,strong) UIImage *dogImage;
/*  */
@property(nonatomic,copy) NSString *cascadePath;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.dogImage = [UIImage imageNamed:@"ear3"];
    
    self.imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.imageView];
    self.dogImageView = [[UIImageView alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    self.dogImageView.image = self.dogImage;
//    self.dogImageView.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.dogImageView];
    
    self.videoCamera = [[CvVideoCamera alloc]initWithParentView:self.view];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.delegate = self;
    
    // 添加xml文件
    self.cascadePath = [[NSBundle mainBundle]
                             pathForResource:@"haarcascade_frontalface_alt1"
                             ofType:@"xml"];
    const CFIndex CASCADE_NAME_LEN = 2048;
    char *CASCADE_NAME = (char *) malloc(CASCADE_NAME_LEN);
    CFStringGetFileSystemRepresentation( (CFStringRef)self.cascadePath, CASCADE_NAME, CASCADE_NAME_LEN);
    
    faceDetector.load(CASCADE_NAME);
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.videoCamera start];
    });
}

- (void)processImage:(cv::Mat&)image{
    std::vector<cv::Rect> faces;
    Mat image_gray;
    
    cvtColor(image, image_gray, CV_BGR2GRAY );
    equalizeHist( image_gray, image_gray );
    
    //-- 多尺寸检测人脸
    faceDetector.detectMultiScale( image_gray, faces, 1.1, 2, 0|CV_HAAR_SCALE_IMAGE, cv::Size(30, 30) );
    
    if (faces.size() > 0) {
        
        for( int i = 0; i < faces.size(); i++ )
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view bringSubviewToFront:self.dogImageView];
                CGRect frame = [self zhuanhuan:faces[i]];
                CGPoint center = CGPointMake(frame.origin.x + frame.size.width * 0.5, frame.origin.y + frame.size.height * 0.5);
                frame.size.width = frame.size.width * 2;
                frame.size.height = frame.size.height * 2;
                self.dogImageView.frame = frame;
                self.dogImageView.center = center;
                self.dogImageView.hidden = NO;
            });
        }
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.dogImageView.hidden = YES;
        });
    }
    self.imageView.image = MatToUIImage(image);
    
}

-(CGRect)zhuanhuan:(cv::Rect)rect{
    CGRect frame = CGRectMake(0, 0, 0, 0);
    static CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    static CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    frame.origin.x = rect.x * screenWidth / 480;
    frame.origin.y = rect.y *screenHeight / 640;
    frame.size.width = rect.width *screenWidth / 480;
    frame.size.height = rect.height * screenWidth /640;
    return frame;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
