//
//  SDView.m
//  7.27-手势解锁
//
//  Created by sundan on 15-7-27.
//  Copyright (c) 2015年 sundan. All rights reserved.
//

#import "SDView.h"

#import <LocalAuthentication/LocalAuthentication.h>

#define SDShow(fmt, ...) UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:fmt,##__VA_ARGS__] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]; [alert show];

@interface SDView ()

@property (nonatomic,strong)NSMutableArray *buttonArray;
@property (nonatomic,assign) CGPoint point ;

@end

@implementation SDView

- (NSMutableArray *)buttonArray{
    
    if (nil == _buttonArray) {
        
        _buttonArray = [NSMutableArray array];
        
    }
    return _buttonArray;
}


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self loadButton];
    }
    return self;
}
- (void)loadButton{
    for (int index = 0; index <9; index++) {
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [button setBackgroundImage:[UIImage imageNamed:@"unSelected"] forState:(UIControlStateNormal)];
        [button setBackgroundImage:[UIImage imageNamed:@"selected"] forState:(UIControlStateSelected)];
        //[button setBackgroundImage:[self createImageWithColor:[UIColor lightGrayColor]] forState:(UIControlStateNormal)];
        //[button setBackgroundImage:[self createImageWithColor:[UIColor orangeColor]] forState:(UIControlStateSelected)];
        button.userInteractionEnabled = NO;
        [self addSubview:button];
    }
}
-(UIImage*) createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    int i = 0;
    for (UIButton *btn in self.subviews) {
        CGFloat sp = (self.bounds.size.width-40-3*74)/2;
        [btn setFrame:CGRectMake(20+i%3*(74+sp), 40+i/3*(74+sp), 74, 74)];
        i++;
    }
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point  = [touch locationInView:touch.view];
    
    for (UIButton *button in self.subviews) {
        if (CGRectContainsPoint(button.frame, point)) {
            //在范围内
            if (button.selected == NO) {
                [self.buttonArray addObject:button];
            }
            button.selected = YES;
            
        }
        
    }
    self.point = point;
    [self setNeedsDisplay];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point  = [touch locationInView:touch.view];
    
    for (UIButton *button in self.subviews) {
        if (CGRectContainsPoint(button.frame, point)) {
            //在范围内
            if (button.selected == NO) {
                [self.buttonArray addObject:button];
            }
            button.selected = YES;
        }
      
        
    }
    self.point = point;

    [self setNeedsDisplay];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UIButton *btn in self.subviews) {
        btn.selected = NO;
    }
    self.point = CGPointZero;
    [self.buttonArray removeAllObjects];
    [self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect{
    
    CGContextRef ref = UIGraphicsGetCurrentContext();
    int i = 0;
    for (UIButton *btn in self.buttonArray) {
        if (i == 0) {
            //第一个button － 第一个点
            CGContextMoveToPoint(ref, btn.center.x, btn.center.y);
        }
        
        else {
            CGContextAddLineToPoint(ref, btn.center.x, btn.center.y);
        }
        
        if (i == self.buttonArray.count - 1) {
            CGContextAddLineToPoint(ref, self.point.x, self.point.y);
        }
        i++ ;
        
    }
    CGContextSetLineWidth(ref, 10);
    CGContextSetLineJoin(ref, kCGLineJoinRound);
    CGContextSetLineCap(ref, kCGLineCapRound);
    [[UIColor purpleColor]set];
    CGContextStrokePath(ref);
}
//TouchID解锁
- (void)openLockWithTouchId{
    LAContext * context = [[LAContext alloc] init];
    BOOL canUseTouchID = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil] ;
    if (canUseTouchID) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"TouchID解锁" reply:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    SDShow(@"验证成功");
                }else {
                    SDShow(@"验证失败") ;
                }
            });
        }];
    }else {
        NSLog(@"无法使用TouchID");
    }
}


@end
