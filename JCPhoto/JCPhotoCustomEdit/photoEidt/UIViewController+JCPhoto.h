//
//  UIViewController+JCPhoto.h
//  YUXiu
//
//  Created by wang on 16/8/8.
//  Copyright © 2016年 Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^photoBlock)(UIImage *photo);

@interface UIViewController (JCPhoto)

/**
 *  照片选择->图库/相机
 *
 *  @param edit  照片是否需要裁剪,默认NO
 *  @param block 照片回调
 */
-(void)showCanEdit:(BOOL)edit photo:(photoBlock)block;

@end
