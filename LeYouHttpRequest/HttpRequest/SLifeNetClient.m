//
//  HXNetClient.m
//  HXTG
//
//  Created by grx on 2017/2/15.
//  Copyright © 2017年 grx. All rights reserved.
//

#import "SLifeNetClient.h"
/**
 *  是否开启https SSL 验证
 *
 *  @return YES为开启，NO为关闭
 */
#define openHttpsSSL YES
/**
 *  SSL 证书名称，仅支持cer格式。“app.bishe.com.cer”,则填“app.bishe.com”
 */
//#define certificate @"tougubang.com"
//#define certificate @"ca"

@implementation SLifeNetClient

+ (SLifeNetClient *)sharedInstance
{
    static SLifeNetClient *_netWorkEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _netWorkEngine = [[SLifeNetClient alloc]init];
    });
    return _netWorkEngine;
}

#pragma 监测网络的可链接性

- (void)netWorkReachabilityWithReturnNetWorkStatusBlock:(SLNetWorkStatusBlock)block
{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
     {
         switch (status)
         {
             case AFNetworkReachabilityStatusNotReachable:
             {
                 block(AFNetworkReachabilityStatusNotReachable);
                 
                 break;
             }
                 
             case AFNetworkReachabilityStatusReachableViaWiFi:
             {
                 block(AFNetworkReachabilityStatusReachableViaWiFi);
                 break;
                 
             }
                 
             case AFNetworkReachabilityStatusReachableViaWWAN:{
                 
                 block(AFNetworkReachabilityStatusReachableViaWWAN);
                 break;
                 
             }
                 
             default:
                 block(AFNetworkReachabilityStatusUnknown);
                 break;
         }
     }];
}

/***************************************
 在这做判断如果有网络环境
 调用block(dic)
 没有则调用failureBlock()
 **************************************/

#pragma --mark GET请求方式

- (void)NetRequestGETWithRequestURL: (NSString *) requestURLString
                      WithParameter: (NSDictionary *) parameter
               WithReturnValeuBlock: (SLReturnValueBlock) block
                     WithErrorBlock: (SLErroeBlock) errorBlock
                   WithFailureBlock: (SLFailureBlock) failureBlock
{
    [self netWorkReachabilityWithReturnNetWorkStatusBlock:^(AFNetworkReachabilityStatus status) {
        if (status==0) {
            failureBlock();
        }else{
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            /*! 以json形式返回数据 */
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            NSMutableString *httpURL = [BYBASEURL mutableCopy];
            [httpURL appendString:requestURLString];
            /*! 开启本地https验证 */
            [self openHttpsSSLSetting:manager];
            [manager GET:requestURLString parameters:parameter progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
                block(task, dic);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                errorBlock(task, error);
                
            }];
        }
    }];
}

#pragma --mark POST请求方式

- (void)NetRequestPOSTWithRequestURL: (NSString *) requestURLString
                       WithParameter: (NSDictionary *) parameter
                WithReturnValeuBlock: (SLReturnValueBlock)block
                      WithErrorBlock: (SLErroeBlock) errorBlock
                    WithFailureBlock: (SLFailureBlock) failureBlock
{
    
    [self netWorkReachabilityWithReturnNetWorkStatusBlock:^(AFNetworkReachabilityStatus status) {
        if (status==0) {
           
            failureBlock();
        }else{
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            NSMutableString *httpURL = [BYBASEURL mutableCopy];
            [httpURL appendString:requestURLString];
            /*! 开启本地https验证 */
            [self openHttpsSSLSetting:manager];
            [manager POST:httpURL parameters:parameter progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
                NSString *status = [NSString stringWithFormat:@"%@",dic[@"code"]];
                
                block(task, dic);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                errorBlock(task, error);
            }];
        }
    }];
}



#pragma --mark POST上传单张图片

- (void)NetRequestPOSTIMGWithRequestURL: (NSString *) requestURLString
                          WithParameter: (NSDictionary *) parameter
                          WithUpLoadImg: (UIImage *) image
                   WithReturnValeuBlock: (SLReturnValueBlock) block
                         WithErrorBlock: (SLErroeBlock) errorBlock
                       WithFailureBlock: (SLFailureBlock) failureBlock
{
//    [self netWorkReachabilityWithReturnNetWorkStatusBlock:^(AFNetworkReachabilityStatus status) {
//        if (status==0) {
//            failureBlock();
//        }else{
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            [manager.requestSerializer setValue:@"000006" forHTTPHeaderField:@"developToken"];
            [manager.requestSerializer setValue:@"1qaz2wsx" forHTTPHeaderField:@"tokenPassword"];
            [manager.requestSerializer setValue:@"head_image" forHTTPHeaderField:@"fileFlag"];
            NSMutableString *httpURL = [BYImageUploadURL mutableCopy];
            [httpURL appendString:requestURLString];
            /*! 开启本地https验证 */
            [self openHttpsSSLSetting:manager];
            [manager POST:httpURL parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                
                if (image)
                {
//                    NSData *imageData = [self resetSizeOfImageData:image maxSize:18];
                    NSData *imageData = UIImageJPEGRepresentation(image,0.5);
                    NSString *imageNameID = @"product.jpg";
                    [formData appendPartWithFileData:imageData name:@"product"
                                            fileName:imageNameID mimeType:@"image/jpeg"];
                }
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
                block(task, dic);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                errorBlock(task, error);
                
            }];
//        }
//    }];
}

#pragma --mark POST上传多张图片

- (void)NetRequestPOSTMoreImgWithRequestURL: (NSString *) requestURLString
                              WithParameter: (NSDictionary *) parameter
                              WithUpLoadImg: (NSMutableArray *) imageArray
                       WithReturnValeuBlock: (SLReturnValueBlock) block
                             WithErrorBlock: (SLErroeBlock) errorBlock
                           WithFailureBlock: (SLFailureBlock) failureBlock
{
    [self netWorkReachabilityWithReturnNetWorkStatusBlock:^(AFNetworkReachabilityStatus status) {
        if (status==0) {
            failureBlock();
        }else{
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            /*! 以json形式返回数据 */
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            [manager.requestSerializer setValue:@"000006" forHTTPHeaderField:@"developToken"];
            [manager.requestSerializer setValue:@"1qaz2wsx" forHTTPHeaderField:@"tokenPassword"];
            [manager.requestSerializer setValue:@"suiBianXieDouKeYi" forHTTPHeaderField:@"fileFlag"];
            NSMutableString *httpURL = [BYImageUploadURL mutableCopy];
            [httpURL appendString:requestURLString];
            /*! 开启本地https验证 */
            [self openHttpsSSLSetting:manager];
            [manager POST:httpURL parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                
                /*! 上传多张图片 */
                for(NSInteger i = 0; i < imageArray.count; i++)
                {
//                    NSData *imageData = [self resetSizeOfImageData:imageArray[i] maxSize:18];
                    NSData *imageData = UIImageJPEGRepresentation(imageArray[i],0.5);
                    /*! 上传的参数名 */
                    NSString * Name = [NSString stringWithFormat:@"product%ld",(long)i+1];
                    /*! 上传filename */
                    NSString * fileName = [NSString stringWithFormat:@"%@.jpg", Name];
                    
                    [formData appendPartWithFileData:imageData name:Name fileName:fileName mimeType:@"image/jpeg"];
                    
                }
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
                block(task, dic);
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                errorBlock(task, error);
                UIWindow *window = [UIApplication sharedApplication].keyWindow;
            }];
        }
    }];
}

#pragma mark --- 压缩图片
- (NSData *)resetSizeOfImageData:(UIImage *)source_image maxSize:(NSInteger)maxSize {
    //先调整分辨率
    CGSize newSize = CGSizeMake(source_image.size.width, source_image.size.height);
    
    CGFloat tempHeight = newSize.height / 1024;
    CGFloat tempWidth = newSize.width / 1024;
    
    if (tempWidth > 1.0 && tempWidth > tempHeight) {
        newSize = CGSizeMake(source_image.size.width / tempWidth, source_image.size.height / tempWidth);
    }
    else if (tempHeight > 1.0 && tempWidth < tempHeight){
        newSize = CGSizeMake(source_image.size.width / tempHeight, source_image.size.height / tempHeight);
    }
    
    UIGraphicsBeginImageContext(newSize);
    [source_image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //调整大小
    NSData *imageData = UIImageJPEGRepresentation(newImage,1.0);
    NSUInteger sizeOrigin = [imageData length];
    NSUInteger sizeOriginKB = sizeOrigin / 1024;
    if (sizeOriginKB > maxSize) {
        NSData *finallImageData = UIImageJPEGRepresentation(newImage,0.50);
        return finallImageData;
    }
    return imageData;
}

#pragma mark - 开启本地https验证
-(void)openHttpsSSLSetting:(AFHTTPSessionManager *)manager
{
    /*! 设置自定义请求头 */
    //    [manager.requestSerializer setValue:[self gaintHttpUserAgent] forHTTPHeaderField:@"user-agent"];
    /*! 加上这行代码，https ssl 验证 */
    //    if(openHttpsSSL)
    //    {
    //        [manager setSecurityPolicy:[self customSecurityPolicy]];
    //    }
}

//- (AFSecurityPolicy*)customSecurityPolicy
//{
//    // /先导入证书
//    NSString *cerPath = [[NSBundle mainBundle] pathForResource:certificate ofType:@"cer"];//证书的路径
//    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
//    
//    // AFSSLPinningModeCertificate 使用证书验证模式
//    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
//    
//    // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
//    // 如果是需要验证自建证书，需要设置为YES
//    securityPolicy.allowInvalidCertificates = YES;
//    
//    //validatesDomainName 是否需要验证域名，默认为YES；
//    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
//    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
//    //如置为NO，建议自己添加对应域名的校验逻辑。
//    securityPolicy.validatesDomainName = NO;
//    
//    securityPolicy.pinnedCertificates = @[certData];
//    
//    return securityPolicy;
//}
//

//TouGuBang/4.0.0 (iPhone; iOS 8.4.1; Scale/3.00)
/*! 自定义获取请求头 */
//-(NSString *)gaintHttpUserAgent
//{
//    return [NSString stringWithFormat:@"TouGuBang/%@ (iPhone; iOS %@; Scale/3.00)",[UtilityFunction gaintVersion],[UtilityFunction gaintDeviceVersion]];
//}



@end
