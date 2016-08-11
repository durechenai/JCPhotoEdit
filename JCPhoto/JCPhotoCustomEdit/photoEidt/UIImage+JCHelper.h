//
//  UIImage+JCHelper.h
//  YUXiu
//
//  Created by wang on 16/8/8.
//  Copyright © 2016年 Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (JCHelper)

- (UIImage*)imageAtRect:(CGRect)rect;

- (UIImage*)fixOrientation;

@end
