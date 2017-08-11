//
//  ViewController.m
//  微信输入框
//
//  Created by chenlishuang on 2017/8/11.
//  Copyright © 2017年 chenlishuang. All rights reserved.
//

#import "ViewController.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
@interface ViewController ()<UITextViewDelegate>
/** 文本框*/
@property (nonatomic,strong)UITextView *textView;
/** 文本框背景*/
@property (nonatomic,strong)UIView *inputBackgroundView;
/** 键盘工具栏*/
@property (nonatomic,strong)UIView *toolView;
/** 键盘高度*/
@property (nonatomic,assign)CGFloat keyboardHeight;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 确定输入框和背景的初始位置
    CGFloat width = kScreenWidth;
    CGFloat height = kScreenHeight - 40;
    
    self.inputBackgroundView.frame = CGRectMake(0, height, width, 40);
    [self.view addSubview:self.inputBackgroundView];
    
    self.textView.frame = CGRectMake(15, 5, width-30, 30);
    [self.inputBackgroundView addSubview:self.textView];
    
    self.textView.inputAccessoryView = self.toolView;
    
    //键盘的frame即将发生变化时的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
}
/*
 notification = {
 name = UIKeyboardWillChangeFrameNotification; userInfo = {
 UIKeyboardAnimationCurveUserInfoKey = 7;
 UIKeyboardAnimationDurationUserInfoKey = "0.25";键盘离开或收回的时间
 UIKeyboardBoundsUserInfoKey = "NSRect: {{0, 0}, {375, 298}}";//键盘大小
 UIKeyboardCenterBeginUserInfoKey = "NSPoint: {187.5, 539}";键盘改变前的frame
 UIKeyboardCenterEndUserInfoKey = "NSPoint: {187.5, 518}";键盘改变后的frame
 UIKeyboardFrameBeginUserInfoKey = "NSRect: {{0, 411}, {375, 256}}";
 UIKeyboardFrameEndUserInfoKey = "NSRect: {{0, 369}, {375, 298}}";
 UIKeyboardIsLocalUserInfoKey = 1;
 }}
 */
- (void)keyboardChanged:(NSNotification *)notification{
    NSLog(@"%@",notification);
    CGRect frame =[notification.userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGRect currentFrame = self.inputBackgroundView.frame;
    
    [UIView animateWithDuration:0.25 animations:^{
        //输入框最终的位置
        CGRect resultFrame;
        
        if (frame.origin.y == kScreenHeight) {
            resultFrame = CGRectMake(0, kScreenHeight - 40, kScreenWidth, 40);
            self.keyboardHeight = 0;
        }else{
            resultFrame = CGRectMake(0,kScreenHeight-currentFrame.size.height-frame.size.height,kScreenWidth ,40);
            self.keyboardHeight = frame.size.height;
        }
        
        self.inputBackgroundView.frame = resultFrame;
    }];
}

- (void)keyboardEndEdited{
    [self.view endEditing:YES];
    [self textViewDidChange:self.textView];
}

- (void)textViewDidChange:(UITextView *)textView{
    NSString *str = textView.text;
    CGSize maxSize = CGSizeMake(textView.bounds.size.width, MAXFLOAT);
    //NSStringDrawingUsesLineFragmentOrigin:用于多行绘制,因为默认是单行绘制,如果不指定,那么绘制出来的高度就是0
    //NSStringDrawingUsesFontLeading:计算行高时使用字体的间距,也就是行高=行距+字体高度
    //NSStringDrawingUsesDeviceMetrics:计算布局时使用图元字形(而不是印刷字体)
    //NSStringDrawingTruncatesLastVisibleLine:设置的string的bounds放不下文本的话,就会截断,然后再最后一个可见行后面加上省略号,如果NSStringDrawingUsesLineFragmentOrigin不设置的话,只设置这一个选项是会被忽略的,因为如果不设置,模式是单行显示
    //测量strings的大小
    CGRect frame = [str boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:textView.font} context:nil];
    //设置textView的高度,默认30
    CGFloat tarHeight = 30;
    //如果文本框内容的高度+10大于30也就是初始的self.textView的高度的话,设置tarHeight的大小为文本内容+10,其中10是间距
    if (frame.size.height+10>30) {
        tarHeight = frame.size.height+10;
    }
    //如果self.textView的高度大于200时,设置为最高200
    if (tarHeight>200) {
        tarHeight = 200;
    }
    CGFloat width = kScreenWidth;
    //设置输入框背景的frame
    self.inputBackgroundView.frame = CGRectMake(0, kScreenHeight - self.keyboardHeight - (tarHeight + 10), width, tarHeight + 10);
    //设置输入框的frame
    self.textView.frame = CGRectMake(15, (self.inputBackgroundView.bounds.size.height - tarHeight)/2, width - 30, tarHeight);
}

#pragma mark - 懒加载
- (UIView *)toolView{
    if (!_toolView) {
        _toolView = [UIView new];
        _toolView.backgroundColor = [UIColor lightGrayColor];
        _toolView.frame = CGRectMake(0, 0, kScreenWidth, 40);
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"收起键盘" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:13];
        [button setBackgroundColor:[UIColor orangeColor]];
        [button addTarget:self action:@selector(keyboardEndEdited) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(kScreenWidth-60-30, (40-30)/2.0, 60, 30);
        [_toolView addSubview:button];
        
        UIView *topLineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
        topLineView.backgroundColor = [UIColor blackColor];
        [_toolView addSubview:topLineView];
    }
    return _toolView;
}

- (UIView *)inputBackgroundView{
    if (!_inputBackgroundView) {
        _inputBackgroundView = [UIView new];
        _inputBackgroundView.backgroundColor = [UIColor lightGrayColor];
    }
    return _inputBackgroundView;
}

- (UITextView *)textView{
    if (!_textView) {
        _textView = [[UITextView alloc]init];
        _textView.font = [UIFont systemFontOfSize:13];
        _textView.layer.cornerRadius = 5.0;
        _textView.layer.masksToBounds = YES;
        _textView.layer.borderWidth = 1;
        _textView.layer.borderColor = [UIColor grayColor].CGColor;
        _textView.delegate = self;
    }
    return _textView;
}
@end
