//
//  SyViewController.m
//  JCPhotoCustomEdit
//
//  Created by wang on 16/8/11.
//  Copyright © 2016年 wang. All rights reserved.
//

#import "SyViewController.h"
#import "UIViewController+JCPhoto.h"

@interface SyViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *show;

@end

@implementation SyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)edit:(id)sender {
    
    [self showCanEdit:YES photo:^(UIImage *photo) {
        [_show setImage:photo];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
