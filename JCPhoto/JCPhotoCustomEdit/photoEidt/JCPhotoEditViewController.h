//
//  JCPhotoEditViewController.h
//  YUXiu
//
//  Created by wang on 16/8/8.
//  Copyright © 2016年 Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCPhotoEditViewController : UIViewController

/*
 @params image 要剪裁的图片
 @params width height 设定的剪裁宽高，可以自己设比例
 @params 回调block
 */
-(instancetype)initWithImage:(UIImage *)image withScale:(CGFloat)width andHeight:(CGFloat)height complentBlock:(void (^)(UIImage* image))complentBlock cancelBlock:(void (^)(id sender))cancelBlock;


@end
