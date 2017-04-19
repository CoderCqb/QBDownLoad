//
//  QBDownLoader.h
//  QBDownLoad
//
//  Created by cqb on 17/4/17.
//  Copyright © 2017年 cqb. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
  下载的状态state
 */
typedef NS_ENUM(NSInteger,QBDownLoadState){
    
    QBDownLoadStateNone = 0,//未知状态
    QBDownLoadStateResume,//正在下载
    QBDownLoadStatePause,//暂停
    QBDownLoadStateSuccess,//成功
    QBDownLoadStateFailure //失败
};

/**
  文件下载状态的回调

 @param downLoadState  文件的下载状态
 @param bytesWriten 本次写入文件的大小
 @param totalBytesWriten 已经写入的文件大小
 @param totalExpectedToWriten 文件的总大小
 */
typedef void(^QBDownLoadStateChange)(QBDownLoadState downLoadState,NSInteger bytesWriten,NSInteger totalBytesWriten,NSInteger totalExpectedToWriten);


/**
 文件下载成功的回调
 
 @param totalBytesWriten 写入文件的总大小
 @param fileCachePath 文件的缓存路径
 */
typedef void(^QBDownLoadSuccess)(NSInteger totalBytesWriten,NSString *fileCachePath);

/**
 下载失败的回调

 @param error 下载失败的error信息
 */
typedef void(^QBDownLoadFailure)(NSError *error);


@interface QBDownLoader : NSObject

@property (nonatomic,assign,readonly)NSInteger bytesWriten;

@property (nonatomic,assign,readonly)NSInteger totalBytesWriten;

@property (nonatomic,assign,readonly)NSInteger totalExpectedToWriten;

@property (nonatomic,copy,readonly)NSString *fileCachePath;

@property (nonatomic,assign,readonly)QBDownLoadState downLoadState;

@property (nonatomic,copy)QBDownLoadStateChange stateChange;

@property (nonatomic,copy)QBDownLoadSuccess downLoadSuccess;

@property (nonatomic,copy)QBDownLoadFailure downLoadFailure;

/**
  初始化
 */
+ (instancetype)defaultDownLoader;


/**
 根据url执行下载操作
 主队列任务
 @param url 下载文件的url
 */
- (void)downLoad:(NSURL *)url;


/**
  根据url执行下载操作
 @param url 下载文件的url
 @param state 状态回调
 @param success 成功回调
 @param failure 失败回调
 */
- (void)downLoad:(NSURL *)url downLoadState:(QBDownLoadStateChange)state success:(QBDownLoadSuccess)success failuer:(QBDownLoadFailure)failure;



/**
  根据url执行下载操作
  默认主队列，可传入串行，并发队列
 @param url 下载文件的url
 @param path 文件下载成功后的缓存路径
 @param state 状态回调
 @param success 成功回调
 @param failure 失败回调
 @param queue 任务所在队列
 */
- (void)downLoad:(NSURL *)url toCachesPath:(NSString *)path downLoadState:(QBDownLoadStateChange)state success:(QBDownLoadSuccess)success failuer:(QBDownLoadFailure)failure delegateQueue:(NSOperationQueue *)queue;

/**
 开始下载
 */
- (void)resume;


/**
 暂停下载
 */
- (void)pause;


/*
 取消下载
 */
- (void)cancle;


/*
 取消并清除临时路径缓存
 */
- (void)cancleAndClearTmpMemory;


/*
 删除本地的缓存文件
 */
- (BOOL)clearCache;

@end
