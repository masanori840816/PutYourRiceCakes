//
//  ImageController.m
//  PutYourRiceCakes
//
//  Created by Masui Masanori on 2014/12/13.
//  Copyright (c) 2014年 masanori_msl. All rights reserved.
//
#import "PutYourRiceCakes-Bridging-Header.h"
#import <opencv2/opencv.hpp>
#import "opencv2/imgcodecs/ios.h"

@interface ImageController()
@property (nonatomic)CVImageBufferRef ibrImageBuffer;
@property (nonatomic)CGColorSpaceRef csrColorSpace;
@property (nonatomic)uint8_t *baseAddress;
@property (nonatomic)size_t sztBytesPerRow;
@property (nonatomic)size_t sztWidth;
@property (nonatomic)size_t sztHeight;
@property (nonatomic)CGContextRef cnrContext;
@property (nonatomic)CGImageRef imrImage;
@property (nonatomic, strong)UIImage *imgCreatedImage;
@property (nonatomic, strong)UIImage *imgGray;
@property (nonatomic) cv::Scalar sclLineColor;
@end
@implementation ImageController

- (void) initImageController
{
    _sclLineColor = cv::Scalar(255, 255, 255);
}
- (UIImage *) createImageFromBuffer:(CMSampleBufferRef) sbrBuffer
{
    _ibrImageBuffer = CMSampleBufferGetImageBuffer(sbrBuffer);
    // ピクセルバッファのベースアドレスをロックする.
    CVPixelBufferLockBaseAddress(_ibrImageBuffer, 0);
    // ベースアドレスの取得.
    _baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(_ibrImageBuffer, 0);
    // サイズの取得.
    _sztWidth = CVPixelBufferGetWidth(_ibrImageBuffer);
    _sztHeight = CVPixelBufferGetHeight(_ibrImageBuffer);
    
    cv::Mat matCamera((int)_sztHeight, (int)_sztWidth, CV_8UC4, (void*)_baseAddress);
    
    // 90°回転.
    cv::transpose(matCamera, matCamera);
    // 左右反転.
    cv::flip(matCamera, matCamera, 1);
    // カラーの指定.
    cv::cvtColor(matCamera, matCamera, cv::COLOR_RGBA2BGRA);
    
    // cv::matからUIImageに変換.
    _imgCreatedImage = MatToUIImage(matCamera);
    
    matCamera.release();
    
    // ベースアドレスのロックを解除
    CVPixelBufferUnlockBaseAddress(_ibrImageBuffer, 0);
    
    return _imgCreatedImage;
}
@end
