//
//  JCPhotoEditViewController.m
//  YUXiu
//
//  Created by wang on 16/8/8.
//  Copyright © 2016年 Wang. All rights reserved.
//
#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height


#import "JCPhotoEditViewController.h"
#import "UIImage+JCHelper.h"

@interface JCPhotoEditViewController (){
    UIView* m_bgView;//遮罩层
    UIImageView* m_bgImage;//背景图
    UIView* m_cropView; //透明区域的视图
    
    UIPinchGestureRecognizer* m_pinchView;//拉伸手势
    UIPanGestureRecognizer* m_panBgImage;//拖拽手势
    
    CGFloat pasWidth,pasHeight,currenPinch,imgwidth,imgheight,lastScale;
    CGFloat m_imageScale;//图片比例
}
@property (nonatomic, strong) UIImage* image;
@property (nonatomic, copy) void (^completeBlock)(UIImage* image);
@property (nonatomic, copy) void (^cancelBlock)(id sender);

@end

@implementation JCPhotoEditViewController
- (void)dealloc{
    [m_cropView removeGestureRecognizer:m_pinchView];
    [m_cropView removeGestureRecognizer:m_panBgImage];
}
//传进来透明视图的大小
-(instancetype)initWithImage:(UIImage *)image withScale:(CGFloat)width andHeight:(CGFloat)height complentBlock:(void (^)(UIImage* image))complentBlock cancelBlock:(void (^)(id sender))cancelBlock{
    self = [super init];
    if (self) {
        lastScale = 1;
        self.image = image;
        self.completeBlock = complentBlock;
        self.cancelBlock = cancelBlock;
        pasWidth = width;
        pasHeight = height;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setSubviewsLayout];
    [self loadImage];
    [self resetCropMask];
    
}
#pragma mark - UI设置
-(void)setSubviewsLayout{
    //原图
    m_bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, SCREENWIDTH, SCREENHEIGHT - 64)];
    [m_bgImage setImage:self.image];
    [self.view addSubview:m_bgImage];
    
    //遮罩层
    m_bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    m_pinchView = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(moveCropView:)];
    m_panBgImage=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    m_bgView.tag = 100000;
    m_pinchView.cancelsTouchesInView = NO;
    m_panBgImage.cancelsTouchesInView = NO;
    
    [m_bgView addGestureRecognizer:m_panBgImage];
    [m_bgView addGestureRecognizer:m_pinchView];
    [m_bgView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.8]];
    [self.view addSubview:m_bgView];
    
    //  透明区域，pinch手势
    m_cropView = [[UIView alloc]initWithFrame:CGRectMake((SCREENWIDTH - pasWidth)/2, (SCREENHEIGHT-pasHeight)/2, pasWidth, pasHeight)];
    [m_bgView addSubview:m_cropView];
    
    
    // todo 临时使用,假导航栏
    UIView* barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64)];
    [barView setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:barView];
    
    UIButton* rltButton = [[UIButton alloc] initWithFrame:CGRectMake(12, 20, 100, 44)];
    [rltButton setTitle:@"取消" forState:UIControlStateNormal];
    [rltButton setTitleColor:[UIColor orangeColor] forState:0];
    [rltButton addTarget:self action:@selector(returnBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [barView addSubview:rltButton];
    
    UIButton* comBtn = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 112, 20, 100, 44)];
    [comBtn setTitle:@"完成" forState:UIControlStateNormal];
    [comBtn setTitleColor:[UIColor orangeColor] forState:0];

    [comBtn addTarget:self action:@selector(completeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [barView addSubview:comBtn];
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 44)];
    titleLabel.textColor = [UIColor orangeColor];
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"照片编辑";
    [barView addSubview:titleLabel];
    
}
- (void)loadImage
{
    CGRect frame = m_bgImage.frame;
    CGPoint center = CGPointMake(SCREENWIDTH / 2.0, (SCREENHEIGHT - 64) / 2.0 + 64);
    CGFloat wscale = self.image.size.width / CGRectGetWidth(m_bgImage.frame);
    CGFloat hscale = self.image.size.height / CGRectGetHeight(m_bgImage.frame);
    frame.size.height = self.image.size.height / MAX(wscale, hscale);
    frame.size.width = self.image.size.width / MAX(wscale, hscale);
    m_imageScale = MAX(wscale, hscale);
    m_bgImage.frame = frame;
    m_bgImage.center = center;
    m_bgImage.contentMode = UIViewContentModeScaleToFill;
    [m_bgImage setNeedsUpdateConstraints];
    
    imgwidth = m_bgImage.frame.size.width;
    imgheight = m_bgImage.frame.size.height;
    
}
/**
 *  @author fangbmian, 16-06-12 13:06:42
 *
 *  根据当前裁剪区域的位置和尺寸将黑色蒙板的相应区域抠成透明
 */
- (void)resetCropMask
{
    UIBezierPath* path = [UIBezierPath bezierPathWithRect:m_bgView.bounds];
    UIBezierPath* clearPath = [[UIBezierPath bezierPathWithRect:CGRectMake(CGRectGetMinX(m_cropView.frame), CGRectGetMinY(m_cropView.frame), CGRectGetWidth(m_cropView.frame), CGRectGetHeight(m_cropView.frame))] bezierPathByReversingPath];
    [path appendPath:clearPath];
    
    CAShapeLayer* shapeLayer = (CAShapeLayer*)m_bgView.layer.mask;
    if (!shapeLayer) {
        shapeLayer = [CAShapeLayer layer];
        [m_bgView.layer setMask:shapeLayer];
    }
    shapeLayer.path = path.CGPath;
}
//捏合手势ok,设置最大最小比例
-(void)moveCropView:(UIPinchGestureRecognizer *)paramSender{
    
    if (paramSender.state == UIGestureRecognizerStateEnded) {
        lastScale = paramSender.scale;
    }else if(paramSender.state == UIGestureRecognizerStateBegan && lastScale != 0.0f){
        paramSender.scale = lastScale;
    }
    if (paramSender.scale !=NAN && paramSender.scale != 0.0) {
        m_bgImage.transform = CGAffineTransformMakeScale(paramSender.scale, paramSender.scale);
    }
    if (lastScale > 3 || lastScale < 0.5) {
        [UIView animateWithDuration:.3 animations:^{
            m_bgImage.transform = CGAffineTransformMakeScale(1, 1);
        } completion:nil];
        lastScale = 1;
    }
}
//pan手势
-(void)pan:(UIPanGestureRecognizer *)gesPan{
    //    NSLog(@"pan手势。。。。。mbimgframe:%@",NSStringFromCGRect(m_bgImage.frame));
    if (gesPan.view.tag == 100000) {
        //locationInView,得到触点移动的绝对位置
        CGPoint point = [gesPan locationInView:self.view];
        NSLog(@"location:(%.2f,%.2f)",point.x
              ,point.y);
        
        //触点离动作起始触点的相对距离
        //记录了触点移动的横向和纵向距离
        CGPoint translation=[gesPan translationInView:self.view];
//        NSLog(@"trans:(%.2f,%.2f)",translation.x,translation.y);
        
        NSLog(@"frame:%@",NSStringFromCGRect(m_bgImage.frame));
        
        CGPoint center=CGPointMake(m_bgImage.center.x+translation.x, m_bgImage.center.y+translation.y);
        m_bgImage.center=center;
        [gesPan setTranslation:CGPointZero inView:self.view];
        if (m_bgImage.frame.origin.x < -(m_bgImage.frame.size.width - self.view.frame.size.width) || m_bgImage.frame.origin.x>self.view.frame.size.width/2 || m_bgImage.frame.origin.y>m_cropView.frame.origin.y + m_cropView.frame.size.height || m_bgImage.frame.origin.y + m_bgImage.frame.size.height < m_cropView.frame.origin.y) {
            [UIView animateWithDuration:.3 animations:^{
                m_bgImage.center = self.view.center;
            }];
        }

    }
    
}
- (void)returnBtnClick:(id)sender
{
    if (self.cancelBlock)
        self.cancelBlock(nil);
}
- (void)completeBtnClick:(id)sender
{
    if (self.completeBlock) {
        
        CGRect cropAreaInImageView = [m_bgView convertRect:m_cropView.frame toView:m_bgImage];
        CGRect cropAreaInImage;
        cropAreaInImage.origin.x = cropAreaInImageView.origin.x * m_imageScale;
        cropAreaInImage.origin.y = cropAreaInImageView.origin.y * m_imageScale;
        cropAreaInImage.size.width = cropAreaInImageView.size.width * m_imageScale;
        cropAreaInImage.size.height = cropAreaInImageView.size.height * m_imageScale;
        
        UIImage* cropImage = [self.image imageAtRect:cropAreaInImage];
        NSLog(@"rect:%@",NSStringFromCGRect(cropAreaInImageView));
        self.completeBlock(cropImage);
    }
}


@end
