//
//  ViewController.m
//  JCPhotoCustomEdit
//
//  Created by wang on 16/8/11.
//  Copyright © 2016年 wang. All rights reserved.
//

#import "ViewController.h"
#import "JCPhotoEditViewController.h"
#import "ALActionSheetView.h"

@interface ViewController ()<UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *showImg;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)customEdit:(id)sender {
    ALActionSheetView *actionSheetView = [ALActionSheetView showActionSheetWithTitle:@"" cancelButtonTitle:@"取消" destructiveButtonTitle:@"" otherButtonTitles:@[@"拍照", @"手机相册"] handler:^(ALActionSheetView *actionSheetView, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            //                    进入相机
#if !TARGET_IPHONE_SIMULATOR
            UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIImagePickerController* picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                
                picker.sourceType = sourceType;
                
                [self presentViewController:picker animated:YES completion:nil];
            }
#elif TARGET_IPHONE_SIMULATOR
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"模拟器不支持调起相机" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
            [alert show];
#endif
            
        }else if (buttonIndex == 1){
            //                    进入相册
            UIImagePickerController* picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:picker animated:YES completion:nil];        }
        
    }];
    [actionSheetView show];

}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:NO completion:nil];
    //320 160这里是自己设置的宽高，我是自己项目需求灵活的剪裁比例才这样写的，也可以自己把这个改成一定比例值传进去
    JCPhotoEditViewController *cutVC = [[JCPhotoEditViewController alloc]initWithImage:image withScale:320 andHeight:160 complentBlock:^(UIImage *image) {
        [self.showImg setImage:image];
        [self dismissViewControllerAnimated:YES completion:nil];
    } cancelBlock:^(id sender) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [self presentViewController:cutVC animated:YES completion:nil];
    
}
@end
