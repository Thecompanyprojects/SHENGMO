//
//  LDLoginViewController.m
//  com.aiwujie.shengmo
//
//  Created by a on 16/12/15.
//  Copyright © 2016年 a. All rights reserved.
//

#import "LDLoginViewController.h"
#import "LDRegisterViewController.h"
#import "LDFindPasswordViewController.h"
#import "LDMainTabViewController.h"
#import "LDResigerNextViewController.h"
#import "LDHelpCenterViewController.h"
#import "LDEmailRegisterViewController.h"
#import "QQViewController.h"
#import "AppDelegate.h"
#import "LDswitchManager.h"
#import "LDswitchModel.h"

@interface LDLoginViewController ()<UITextFieldDelegate,TencentSessionDelegate>{
    
    TencentOAuth *_tencentOAuth;
}

@property (weak, nonatomic) IBOutlet UIButton *findPasswordButton;
@property (weak, nonatomic) IBOutlet UIView *phoneView;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *wxButton;
@property (weak, nonatomic) IBOutlet UIButton *qqButton;
@property (weak, nonatomic) IBOutlet UIButton *weiboButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fastH;
@end

@implementation LDLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (WIDTH == 320) {
        
        _fastH.constant = 29;
        
    }else if (WIDTH == 375){
    
        _fastH.constant = 58; 
        
    }else{
    
        _fastH.constant = 80;
    }
    
    self.phoneView.layer.cornerRadius = 2;
    self.phoneView.clipsToBounds = YES;
    
    self.passwordView.layer.cornerRadius = 2;
    self.passwordView.clipsToBounds = YES;
    
    self.loginButton.layer.cornerRadius = 2;
    self.loginButton.clipsToBounds = YES;
    
    self.navigationItem.title = @"登录";
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"accountNumber"] length] != 0) {
        
        self.phoneField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountNumber"];
    }
    
    //判断微信用户是否安装
    if ([WXApi isWXAppInstalled] == NO) {
        
        self.wxButton.hidden = YES;
        
    }else{
        
        self.wxButton.hidden = NO;
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerWX) name:@"register" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerWb) name:@"wbregister" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginWX) name:@"wxLogin" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginWX) name:@"wbLogin" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = YES;
}

-(void)loginWX{

    LDMainTabViewController *mvc = [[LDMainTabViewController alloc] initWithNibName:@"LDMainTabViewController" bundle:nil];
    
    /**
     
     融云聊天集成
     
     */
    [[RCIM sharedRCIM] connectWithToken:[[NSUserDefaults standardUserDefaults]objectForKey:@"token"] success:^(NSString *userId) {
        
        NSLog(@"登陆成功。当前登录的用户ID：%@", userId);
        
        [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"userId"];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            UITabBarItem * item=[mvc.tabBar.items objectAtIndex:2];
            
            NSInteger badge = [[RCIMClient sharedRCIMClient] getTotalUnreadCount];
            
            if (badge <= 0) {
                
                item.badgeValue = 0;
                
            }else{
                
                item.badgeValue = [NSString stringWithFormat:@"%ld",(long)badge];
            }
        });
        
    } error:^(RCConnectErrorCode status) {
        NSLog(@"登陆的错误码为:%ld", (long)status);
    } tokenIncorrect:^{
        //token过期或者不正确。
        //如果设置了token有效期并且token过期，请重新请求您的服务器获取新的token
        //如果没有设置token有效期却提示token错误，请检查您客户端和服务器的appkey是否匹配，还有检查您获取token的流程。
        NSLog(@"token错误");
    }];
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.window.rootViewController = mvc;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

-(void)registerWb{

    LDResigerNextViewController *nvc = [[LDResigerNextViewController alloc] init];
    
    nvc.loginState = @"wb";
    
    [self.navigationController pushViewController:nvc animated:YES];
}

-(void)registerWX{
    
    LDResigerNextViewController *nvc = [[LDResigerNextViewController alloc] init];
    nvc.loginState = @"wx";
    [self.navigationController pushViewController:nvc animated:YES];
    
}


//textField代理方法
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    [self status];
    
    return YES;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self status];
    
    [self.view endEditing:YES];
}

-(void)status{
    
    if (self.phoneField.text.length != 0 &&self.passwordField.text.length != 0) {
        
        [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [self.loginButton setBackgroundColor:MainColor];
        
        self.loginButton.userInteractionEnabled = YES;
        
    }else{
        
        [self.loginButton setTitleColor:[UIColor colorWithRed:183/255.0 green:183/255.0 blue:183/255.0 alpha:1] forState:UIControlStateNormal];
        
        [self.loginButton setBackgroundColor:[UIColor colorWithRed:239/255.0 green:240/255.0 blue:242/255.0 alpha:1]];
        
        self.loginButton.userInteractionEnabled = NO;
    }
    
}

- (IBAction)findPasswordButtonClick:(id)sender {
    
    [self.view endEditing:YES];
    
    LDFindPasswordViewController *fvc = [[LDFindPasswordViewController alloc] init];
    
     [self.navigationController pushViewController:fvc animated:YES];
}

- (IBAction)loginButtonClick:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSDictionary *basicDic = @{@"user_name":self.phoneField.text,@"password":self.passwordField.text};
    
    NSString *lat;
    
    NSString *lng;
    
    NSString *city;
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:latitude] length] == 0) {
        
        lat = @"";
        
    }else{
        
        lat = [[NSUserDefaults standardUserDefaults] objectForKey:latitude];
    }
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:longitude] length] == 0) {
        
        lng = @"";
        
    }else{
        
        lng = [[NSUserDefaults standardUserDefaults] objectForKey:longitude];
    }
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"city"] length] == 0) {
        city = @"";
    }else{
        city = [[NSUserDefaults standardUserDefaults] objectForKey:@"city"];
    }
    
    NSDictionary *locationDic = @{@"lat":lat,@"lng":lng,@"city":city};
    
    NSString *device;
    
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:@"com.aiwujie.shengmoApp"];
    
    if ([keychain[@"device_token"] length] == 0) {
        
        device = @"";
        
    }else{
        
        device = keychain[@"device_token"];
    }
    
    NSString *new_device_brand = [[LDFromwebManager defaultTool] getCurrentDeviceModel];
    
    NSString *new_device_version = [[UIDevice currentDevice] systemVersion];
    
    NSString *new_device_appversion = [NSString stringWithFormat:@"%@", [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    
    NSDictionary *deviceDic = @{@"device_token":device,@"new_device_brand":new_device_brand?:@"",@"new_device_version":new_device_version?:@"",@"new_device_appversion":new_device_appversion?:@""};
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",PICHEADURL,@"Api/Users/login_pw"]];
    
    NSMutableURLRequest * postRequest=[NSMutableURLRequest requestWithURL:url];
    
    NSDictionary *d = @{@"basic":basicDic,@"location":locationDic,@"device_info":deviceDic};
    
    NSData* da = [NSJSONSerialization dataWithJSONObject:d options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString *bodyData = [[NSString alloc] initWithData:da encoding:NSUTF8StringEncoding];
    
    [postRequest setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];
    
    [postRequest setHTTPMethod:@"POST"];
    
    [postRequest setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:postRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            NSDictionary *responseDic = [NSObject parseJSONStringToNSDictionary:result];
            
            if ([responseDic[@"retcode"] intValue] == 2000) {
                
                LDswitchModel *model = [LDswitchModel new];
                model.account = self.phoneField.text;
                model.password = self.passwordField.text;
                model.uid = responseDic[@"data"][@"uid"];
                model.nickname = responseDic[@"data"][@"nickname"];
                model.imageUrl = responseDic[@"data"][@"match_photo"];
                model.token = responseDic[@"data"][@"r_token"];
                model.sexual = [NSString stringWithFormat:@"%@",responseDic[@"data"][@"sexual"]];
                model.sex = [NSString stringWithFormat:@"%@",responseDic[@"data"][@"sex"]];
                model.chatstatus = responseDic[@"data"][@"chatstatus"];
                model.way = @"0";
                [[LDswitchManager sharedClient] insertInfowith:model];
                
                //存储用户的登录的账号
                [[NSUserDefaults standardUserDefaults] setObject:self.phoneField.text forKey:@"accountNumber"];
                
                [[NSUserDefaults standardUserDefaults] setObject:responseDic[@"data"][@"sex"] forKey:@"newestSex"];
                
                [[NSUserDefaults standardUserDefaults] setObject:responseDic[@"data"][@"sexual"] forKey:@"newestSexual"];
                
                if ([responseDic[@"data"][@"uid"] intValue] == 11 || [responseDic[@"data"][@"uid"] intValue] == 14514 || [responseDic[@"data"][@"uid"] intValue] == 14518) {
                    
                    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"searchSwitch"];
                    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"sexButton"];
                    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"sexualButton"];
                    
                    //根据我的性取向展示感兴趣的动态
                    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"动态筛选"];
                    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"dynamicSex"];
                    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"dynamicSexual"];
                }
                
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",responseDic[@"data"][@"uid"]] forKey:@"uid"];
                
                [[NSUserDefaults standardUserDefaults] setObject:responseDic[@"data"][@"r_token"] forKey:@"token"];
                
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",responseDic[@"data"][@"chatstatus"]] forKey:@"ableOrDisable"];
                
                LDMainTabViewController *mvc = [[LDMainTabViewController alloc] initWithNibName:@"LDMainTabViewController" bundle:nil];
                
                /**
                 
                 融云聊天集成
                 
                 */
                [[RCIM sharedRCIM] connectWithToken:[[NSUserDefaults standardUserDefaults]objectForKey:@"token"] success:^(NSString *userId) {
                    
                    NSLog(@"登陆成功。当前登录的用户ID：%@", userId);
                    //[self createData:userId];
                    [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"userId"];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        UITabBarItem * item=[mvc.tabBar.items objectAtIndex:2];
                        
                        NSInteger badge = [[RCIMClient sharedRCIMClient] getTotalUnreadCount];
                        
                        if (badge <= 0) {
                            
                            item.badgeValue = 0;
                            
                        }else{
                            
                            item.badgeValue = [NSString stringWithFormat:@"%ld",(long)badge];
                        }
                    });
                    
                } error:^(RCConnectErrorCode status) {
                    
                    NSLog(@"登陆的错误码为:%ld", (long)status);
                    
                } tokenIncorrect:^{
                    //token过期或者不正确。
                    //如果设置了token有效期并且token过期，请重新请求您的服务器获取新的token
                    //如果没有设置token有效期却提示token错误，请检查您客户端和服务器的appkey是否匹配，还有检查您获取token的流程。
                    NSLog(@"token错误");
                }];
                
                AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
                
                app.window.rootViewController = mvc;
                
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
                
                
            }else{
                
                [AlertTool alertWithViewController:self andTitle:@"提示" andMessage:[responseDic objectForKey:@"msg"]];
            
            }
            
        });
    }];
}

- (IBAction)wxButtonClick:(id)sender {
    //构造SendAuthReq结构体
    SendAuthReq* req =[[SendAuthReq alloc ] init];
    req.scope = @"snsapi_userinfo" ;
    req.state = @"123WX" ;
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];

}
- (IBAction)qqButtonClikc:(id)sender {
    
    _tencentOAuth =
    [[TencentOAuth alloc] initWithAppId:@"1105968084" andDelegate:self];
    
    NSArray* permissions = [NSArray arrayWithObjects:
                            kOPEN_PERMISSION_GET_USER_INFO,kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                            kOPEN_PERMISSION_GET_INFO,kOPEN_PERMISSION_ADD_SHARE , nil];
    
    _tencentOAuth.sessionDelegate = self;
    [_tencentOAuth authorize:permissions inSafari:NO];
}

- (void)tencentDidLogin {
    
    if ([_tencentOAuth getUserInfo]) {
        [[NSUserDefaults standardUserDefaults] setObject:[_tencentOAuth getUserOpenID] forKey:@"openid"];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"message:@"获取个人信息失败" delegate:nil cancelButtonTitle:NSLocalizedString(@"确定", nil)otherButtonTitles:nil];
        [alert show];
    }
    
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    
    if (cancelled == YES) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"取消授权" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
        [alertView show];

    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"授权失败" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
        [alertView show];
    }
}

//
- (void)tencentDidNotNetWork {

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络错误,授权失败" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
    [alertView show];

}

//qq登录回调方法
-(void)getUserInfoResponse:(APIResponse *)response
{
    [[NSUserDefaults standardUserDefaults] setObject:response.jsonResponse forKey:@"response"];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",PICHEADURL,charge_openidUrl];
    
    NSString *device;
    
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:@"com.aiwujie.shengmoApp"];
    
    if ([keychain[@"device_token"] length] == 0) {
        
        device = @"";
        
    }else{
        
        device = keychain[@"device_token"];
    }

    NSString *new_device_brand = [[LDFromwebManager defaultTool] getCurrentDeviceModel];
    
    NSString *new_device_version = [[UIDevice currentDevice] systemVersion];
    
    NSString *new_device_appversion = [NSString stringWithFormat:@"%@", [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    
   
    NSString *access_token = _tencentOAuth.accessToken;
    NSString *newurl = [NSString stringWithFormat:@"%@%@%@",@"https://graph.qq.com/oauth2.0/me?access_token=",access_token,@"&unionid=1"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/javascript" ,@"text/plain",@"text/html" , nil];
    [manager GET:newurl parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
      
        NSString *resultString  =[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSString *str2 = [resultString substringFromIndex:9];
        NSString *str1 = [str2 substringToIndex:str2.length-3];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[str1 dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        NSString *unionid = [dic objectForKey:@"unionid"];
        NSLog(@"unic-----%@",unionid);
        
        
        NSDictionary *parameters = @{@"openid":[_tencentOAuth getUserOpenID],@"channel":@"2",@"device_token":device,@"new_device_brand":new_device_brand?:@"",@"new_device_version":new_device_version?:@"",@"new_device_appversion":new_device_appversion?:@"",@"unionid":unionid?:@""};
          
        
        [NetManager afPostRequest:url parms:parameters finished:^(id responseObj) {
               
               NSInteger integer = [[responseObj objectForKey:@"retcode"] integerValue];
               
               if (integer == 4000) {
                   
                   [MBProgressHUD hideHUDForView:self.view animated:YES];
                   
                   LDResigerNextViewController *nvc = [[LDResigerNextViewController alloc] init];
                   
                   nvc.loginState = @"qq";
                   
                   [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",responseObj[@"data"][@"channel"]] forKey:@"loginChannel"];
                   
                   [self.navigationController pushViewController:nvc animated:YES];
                   
               }else if(integer == 2000){
                   
                   [MBProgressHUD hideHUDForView:self.view animated:YES];
                   
                   [[NSUserDefaults standardUserDefaults] setObject:responseObj[@"data"][@"sex"] forKey:@"newestSex"];
                   
                   [[NSUserDefaults standardUserDefaults] setObject:responseObj[@"data"][@"sexual"] forKey:@"newestSexual"];
                   
                   [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",responseObj[@"data"][@"uid"]] forKey:@"uid"];
                   
                   [[NSUserDefaults standardUserDefaults] setObject:responseObj[@"data"][@"r_token"] forKey:@"token"];
                   
                   [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",responseObj[@"data"][@"chatstatus"]] forKey:@"ableOrDisable"];

                   if ([[LDswitchManager sharedClient] iscaninsert]) {
                       LDswitchModel *model = [LDswitchModel new];
                       model.account = @"";
                       model.password = @"";
                       model.uid = responseObj[@"data"][@"uid"];
                       model.nickname = responseObj[@"data"][@"nickname"];
                       model.imageUrl = responseObj[@"data"][@"head_pic"];
                       model.token = responseObj[@"data"][@"r_token"];
                       model.sexual = [NSString stringWithFormat:@"%@",responseObj[@"data"][@"sexual"]];
                       model.sex = [NSString stringWithFormat:@"%@",responseObj[@"data"][@"sex"]];
                       model.chatstatus = responseObj[@"data"][@"chatstatus"];
                       model.way = @"1";
                       [[LDswitchManager sharedClient] insertInfowith:model];
                   }
                   
                   LDMainTabViewController *mvc = [[LDMainTabViewController alloc] initWithNibName:@"LDMainTabViewController" bundle:nil];
                   
                   /**
                    
                    融云聊天集成
                    
                    */
                   [[RCIM sharedRCIM] connectWithToken:[[NSUserDefaults standardUserDefaults]objectForKey:@"token"] success:^(NSString *userId) {
                       
                       NSLog(@"登陆成功。当前登录的用户ID：%@", userId);
                       
                       [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"userId"];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           UITabBarItem * item=[mvc.tabBar.items objectAtIndex:2];
                           NSInteger badge = [[RCIMClient sharedRCIMClient] getTotalUnreadCount];
                           if (badge <= 0) {
                               
                               item.badgeValue = 0;
                               
                           }else{
                               
                               item.badgeValue = [NSString stringWithFormat:@"%ld",(long)badge];
                           }
                       });
                       
                   } error:^(RCConnectErrorCode status) {
                       NSLog(@"登陆的错误码为:%ld", (long)status);
                   } tokenIncorrect:^{
                       //token过期或者不正确。
                       //如果设置了token有效期并且token过期，请重新请求您的服务器获取新的token
                       //如果没有设置token有效期却提示token错误，请检查您客户端和服务器的appkey是否匹配，还有检查您获取token的流程。
                       NSLog(@"token错误");
                   }];
                   
                   AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
                   app.window.rootViewController = mvc;
               }else{
                   [MBProgressHUD hideHUDForView:self.view animated:YES];
                   [AlertTool alertWithViewController:self andTitle:@"提示" andMessage:[responseObj objectForKey:@"msg"]];
               }
           } failed:^(NSString *errorMsg) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
           }];
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];

}

- (IBAction)weiboButtonClick:(id)sender {
    
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = kRedirectURI;
    request.scope = @"all";
    [WeiboSDK sendRequest:request];
}

- (IBAction)helpButtonClick:(id)sender {
    
    LDHelpCenterViewController *hvc = [[LDHelpCenterViewController alloc] init];
    
    [self.navigationController pushViewController:hvc animated:YES];
}

- (IBAction)phoneNumberRegesterClick:(id)sender {
    [self.view endEditing:YES];
    LDRegisterViewController *rvc = [[LDRegisterViewController alloc] init];
    [self.navigationController pushViewController:rvc animated:YES];
}

- (IBAction)emailRegesterClick:(id)sender {
    [self.view endEditing:YES];
    LDEmailRegisterViewController *evc = [[LDEmailRegisterViewController alloc] init];
    [self.navigationController pushViewController:evc animated:YES];
}

- (IBAction)QQclick:(id)sender {
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
