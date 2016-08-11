# UIViewController + JCHelper分类 
* 一行代码搞定照片选择,支持相册/相机及设置是否裁剪
使用方法，在需要的地方
 这里是系统编辑方法，只有1:1
eg:
[self showCanEdit:YES photo:^(UIImage *photo) {
[sender setBackgroundImage:photo forState:UIControlStateNormal];
}];

若要自定义剪裁比例，调用另一个类，JCPhotoViewController.h

在需要的VC里，这是遵守的协议，<UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

点击调取相机相册的方法里写个这个定义的actionsheet
 例如：
-(void)点击事件方法{

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

最后是UIImagePickerControllerDelegate方法，本地取回image后的回调方法,在这里开始调 JCPhotoViewController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
[picker dismissViewControllerAnimated:NO completion:nil];
//320 160这里是自己设置的宽高，我是自己项目需求灵活的剪裁比例才这样写的，也可以自己把这个改成一定比例值传进去
JCPhotoEditViewController *cutVC = [[JCPhotoEditViewController alloc]initWithImage:image withScale:320 andHeight:160 complentBlock:^(UIImage *image) {
[self.showImage setImage:image];
[self dismissViewControllerAnimated:YES completion:nil];
} cancelBlock:^(id sender) {
[self dismissViewControllerAnimated:YES completion:nil];
}];
[self presentViewController:cutVC animated:YES completion:nil];

}