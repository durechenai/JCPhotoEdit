//
//  UIViewController+JCPhoto.m
//  YUXiu
//
//  Created by wang on 16/8/8.
//  Copyright © 2016年 Wang. All rights reserved.
//

#import "UIViewController+JCPhoto.h"
#import "objc/runtime.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
#import "ALActionSheetView.h"

#ifdef DEBUG
#define debugLog(...)    NSLog(__VA_ARGS__)
#else
#define debugLog(...)
#endif

static  BOOL canEdit = NO;
static  char blockKey;

@interface UIViewController()<UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIAlertViewDelegate>

@property (nonatomic,copy)photoBlock photoBlock;

@end

@implementation UIViewController (JCPhoto)

#pragma mark-set
-(void)setPhotoBlock:(photoBlock)photoBlock
{
    objc_setAssociatedObject(self, &blockKey, photoBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
#pragma mark-get
- (photoBlock )photoBlock
{
    return objc_getAssociatedObject(self, &blockKey);
}

-(void)showCanEdit:(BOOL)edit photo:(photoBlock)block
{
    if(edit) canEdit = edit;
    
    self.photoBlock = [block copy];
    
            ALActionSheetView *actionSheetView = [ALActionSheetView showActionSheetWithTitle:@"" cancelButtonTitle:@"取消" destructiveButtonTitle:@"" otherButtonTitles:@[@"拍照", @"手机相册"] handler:^(ALActionSheetView *actionSheetView, NSInteger buttonIndex) {
                
                //跳转到相机/相册页面
                UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
                imagePickerController.delegate = self;
                imagePickerController.allowsEditing = canEdit;

                if (buttonIndex == 0) {
                    //                    进入相机
    #if !TARGET_IPHONE_SIMULATOR
                    //是否支持相机
                    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                    {
                        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                        [self presentViewController:imagePickerController animated:YES completion:NULL];
                    }
                    else
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"该设备不支持相机" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alert show];
                    }

                    
    #elif TARGET_IPHONE_SIMULATOR
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"模拟器不支持调起相机" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
                    [alert show];
    #endif
    
                }else if (buttonIndex == 1){
                    //                    进入相册
                    //相册
                    imagePickerController.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
                    [self presentViewController:imagePickerController animated:YES completion:NULL];
                }
            }];
            
            [actionSheetView show];

    
}

#pragma mark - image picker delegte,成功获得相片还是视频后的回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage *image;
    //是否要裁剪
    if ([picker allowsEditing]){
        
        //编辑之后的图像,系统默认的是1:1，屏幕宽度
        image = [info objectForKey:UIImagePickerControllerEditedImage];
        
    } else {
        
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    if(self.photoBlock)
    {
        self.photoBlock(image);
    }
}

@end
