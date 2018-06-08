//
//  ViewController.m
//  localAuthenticationID
//
//  Created by peony on 2018/6/4.
//  Copyright © 2018年 peony. All rights reserved.
//

#import "ViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (IBAction)buttonClick:(id)sender {
    [self beginAuthentication];
}
- (void)beginAuthentication {
    //判断是否大于iOS 9.0
#ifdef NSFoundationVersionNumber_iOS_8_0
    //初始化上下文对象
    
    LAContext* context = [[LAContext alloc] init];
    
    //这个设置的使用密码的字体，当text=@""时，按钮将被隐藏
    
    context.localizedFallbackTitle=@"支付密码";
    
    //这个设置的取消按钮的字体
    
    context.localizedCancelTitle=@"取消";
    
    //    context.maxBiometryFailures = [NSNumber numberWithInt:5];
    
    //错误对象
    
    NSError* error = nil;
    
    
    
    //首先使用canEvaluatePolicy 判断设备支持状态
    
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        
        //支持指纹验证
        
        [self start:context];
        
        
    } else {
        
        //不支持指纹识别，LOG出错误详情
        
        switch (error.code) {
            case LAErrorBiometryLockout: {
                [self startPassword:context];
                break;
            }
                
            case LAErrorTouchIDNotEnrolled: {
                
                [self showAlert:@"touch id未启用"];
                
                break;
                
            }
                
            case LAErrorPasscodeNotSet: {
                
                //实际上是因为密码未启用
                [self showAlert:@"touch id未启用"];
                break;
                
            }
            case LAErrorTouchIDNotAvailable:{
                [self showAlert:@"手机不支持touch id"];
                break;
            }
            default: {
                
                //NSLog(@"TouchID not available");
                
                break;
                
            }
                
        }
        
        //NSLog(@"%@",error.localizedDescription);
        
    }
#else
    [[[UIAlertView alloc] initWithTitle:@"" message:@"暂不支持指纹支付" delegate:nil cancelButtonTitle:@"done" otherButtonTitles:nil, nil] show];
#endif
}
- (void)start:(LAContext *)context{
    NSString* result = @"需要验证您的touch ID";
    if (context.biometryType == LABiometryTypeFaceID) {
        result = @"需要验证您的face ID";
    }
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:result reply:^(BOOL success, NSError *error) {
        
        if (success) {
            
            //验证成功，主线程处理UI
            
            //NSLog(@"验证成功");
            [self showAlert:@"验证成功"];
            
        }
        
        else
            
        {
            
            //NSLog(@"%@",error.localizedDescription);
            
            switch (error.code) {
                    
                case LAErrorSystemCancel: {
                    
                    //NSLog(@"Authentication was cancelled by the system");
                    
                    //切换到其他APP，系统取消验证Touch ID
                    [self showPassword];
                    
                    break;
                    
                }
                    
                case LAErrorUserCancel: {
                    
                    //NSLog(@"Authentication was cancelled by the user");
                    
                    //用户取消验证Touch ID
                    [self showQuestion];
                    break;
                    
                }
                case LAErrorAuthenticationFailed: {
                    //验证失败
                    //展示验证失败的toast，并展示支付密码界面
                    
                    [self showPassword];
                    break;
                }
                    
                case LAErrorUserFallback: {
                    //点击了自定义的按钮，展示输入密码
                    [self showPassword];
                    
                    break;
                    
                }
                case LAErrorBiometryLockout: {
                    [self startPassword:context];
                    break;
                }
                default: {
                    
                    //其他所有情况，输入支付密码
                    [self showPassword];
                    
                    break;
                    
                }
                    
            }
            
        }
        
    }];
}
- (void)startPassword:(LAContext *)context {//调起系统密码
#ifdef NSFoundationVersionNumber_iOS_9_0
    NSString* result = @"需要验证您的touch ID";
    if (context.biometryType == LABiometryTypeFaceID) {
        result = @"需要验证您的face ID";
    }
    __weak typeof(self) weakself = self;
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:result reply:^(BOOL success, NSError *error) {
        
        if (success) {
            
            [weakself start:context];
            
        } else {
            
            [weakself showQuestion];
        }
        
    }];
#else
    //不支持，展示支付密码
    [self showPassword];
#endif
}
- (void)showPassword {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc] initWithTitle:@"" message:@"展示的是支付密码" delegate:nil cancelButtonTitle:@"done" otherButtonTitles:nil, nil] show];
    });
}
- (void)showQuestion {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc] initWithTitle:nil message:@"确定要退出吗？" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:@"输入密码", nil] show];
        //                NSLog(@"%@",message);
    });
}
- (void)showAlert:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"done" otherButtonTitles:nil, nil] show];
        //        NSLog(@"%@",message);
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
