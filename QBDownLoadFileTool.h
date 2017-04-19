//
//  QBDownLoadFileTool.h
//  QBDownLoad
//
//  Created by cqb on 17/4/17.
//  Copyright © 2017年 cqb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBDownLoadFileTool : NSObject

/**
 文件的下载缓存路径

 @param fileName 文件名
 @return 文件的下载缓存路径
 */
+ (NSString *)cachesPath:(NSString *)fileName;


/**
 文件缓存的临时路径

 @param fileName 文件名
 @return 临时路径
 */
+ (NSString *)tmpCachesPath:(NSString *)fileName;


/**
 路径下是否存在文件

 @param path 缓存路径
 @return 是否包含
 */
+ (BOOL)fileExistsAtPath:(NSString *)path;

/**
 路径下的文件大小

 @param path 文件路径
 @return 文件大小
 */
+ (long long)fileSizeAtPath:(NSString *)path;


/**
 移动文件

 @param path 指定的文件路径
 @return 是否移动成功
 */
+ (BOOL)moveItemAtPath:(NSString *)path toPath:(NSString *)toPath;


/**
 删除缓存中的文件

 @param path 文件路径
 @return 是否成功
 */
+ (BOOL)removeItemAtPath:(NSString *)path;


/**
 数据序列化

 @param file 序列化字典
 @param isPathDic 是否缓存path字典，传no，则默认缓存size字典
 */
+ (void)writeTofile:(NSMutableDictionary *)file  isCachesPathDic:(BOOL)isPathDic;


/**
 获取数据
 @param isPathDic 是否缓存path字典，传no，则默认缓存size字典
 @return 数组，字典等
 */
+ (NSMutableDictionary *)getCachesFile:(BOOL)isPathDic;


/**
 清除序列化列表数据
 @param url url路径
 */
+ (void)removeDicCaches:(NSURL *)url;


/**
 清除size缓存和path缓存
 */
+ (void)removeAllCachesDic;

@end
