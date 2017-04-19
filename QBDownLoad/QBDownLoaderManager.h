//
//  QBDownLoaderManager.h
//  QBDownLoad
//
//  Created by cqb on 17/4/17.
//  Copyright © 2017年 cqb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBDownLoader.h"
@interface QBDownLoaderManager : NSObject

/**
 初始化
 @return 管理类对象
 */
+ (instancetype)sharedInstance;


/**
 根据url执行下载操作，返回QBDownLoader
 在主队列执行操作
 @param url 下载url
 @return QBDownLoader
 */
- (QBDownLoader *)downLoadForUrl:(NSURL *)url;


/**
 根据url执行下载操作

 @param url 下载url
 @param path 缓存路径
 @param state 下载状态
 @param success 成功回调
 @param failure 失败回调
 @param queue 任务执行队列
 */
- (void)downLoad:(NSURL *)url toCachesPath:(NSString *)path  state:(QBDownLoadStateChange)state success:(QBDownLoadSuccess)success failure:(QBDownLoadFailure)failure delegateQueue:(NSOperationQueue *)queue;


/**
 暂停下载

 @param url 下载url
 */
- (void)pasuse:(NSURL *)url;


/**
 开始下载

 @param url 下载url
 */
- (void)resume:(NSURL *)url;


/**
 取消下载

 @param url 下载url
 */
- (void)cancle:(NSURL *)url;


/**
 取消下载并清除临时路径缓存

 @param url 下载url
 */
- (void)cancleAndClearTmpCaches:(NSURL *)url;


/**
 清除下载缓存
 @param url 下载的url
 */
- (BOOL)clearCaches:(NSURL *)url;

/**
 取消下载全部
 */
- (void)cancleAll;


/**
 暂停全部
 */
- (void)pauseAll;


/**
 开始全部下载
 */
- (void)resumeAll;


/**
 清除下载的所有缓存
 */
- (void)cleaarAllCachs;

@end
