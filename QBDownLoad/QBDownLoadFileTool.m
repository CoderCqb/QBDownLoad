//
//  QBDownLoadFileTool.m
//  QBDownLoad
//
//  Created by cqb on 17/4/17.
//  Copyright © 2017年 cqb. All rights reserved.
//

#import "QBDownLoadFileTool.h"
#import "NSMutableDictionary+QBMutableDictionaryExtension.h"
#import "NSString+QBDownLoadFileExtension.h"
#import "QBConst.h"
#define kCachesPath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) .lastObject

#define kTmpCachesPath  NSTemporaryDirectory()

@implementation QBDownLoadFileTool

+ (NSString *)cachesPath:(NSString *)fileName {
    
    return [kCachesPath stringByAppendingPathComponent:fileName];
}

+ (NSString *)tmpCachesPath:(NSString *)fileName {
    
    return [kTmpCachesPath stringByAppendingPathComponent:fileName];
}

+ (BOOL)fileExistsAtPath:(NSString *)path {
    
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:path];
    
    return exist;
}

+ (long long)fileSizeAtPath:(NSString *)path {
    
    if (![self fileExistsAtPath:path]) return 0;
    
    NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    long long fileSize = [fileInfo[NSFileSize] longLongValue];
    
    return fileSize;
}

+ (BOOL)moveItemAtPath:(NSString *)path toPath:(NSString *)toPath {
    
    if (![self fileExistsAtPath:path] || !toPath || [toPath isEqualToString:@""]) return NO;
    
    return [[NSFileManager defaultManager] moveItemAtPath:path toPath:toPath error:nil];
}

+ (BOOL)removeItemAtPath:(NSString *)path {
    
    BOOL exist = [self fileExistsAtPath:path];
    if (exist == NO) return NO;
    return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

+ (void)writeTofile:(NSMutableDictionary *)file isCachesPathDic:(BOOL)isPathDic {
    
    if (!file) return;
    NSString  *caches = isPathDic ? FilePathCachesDicPath : FileSizeCachesDicPath;
    [file writeToFile:[self cachesPath:caches] atomically:YES];
}

+ (NSMutableDictionary *)getCachesFile:(BOOL)isPathDic {
    
   NSString  *caches = isPathDic ? FilePathCachesDicPath : FileSizeCachesDicPath;
    
   NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithContentsOfFile:[self cachesPath:caches]];
    
   return dataDic;
}

+ (void)removeDicCaches:(NSURL *)url {
    
    if (!url) return;
    
    NSMutableDictionary *pathDic = [self getCachesFile:YES];
    NSMutableDictionary *sizeDic = [self getCachesFile:NO];
    
    NSString *key = url.lastPathComponent;
    [pathDic qb_removePathObjectforKey:key];
    [sizeDic qb_removeSizeObjectforKey:key];
}

+ (void)removeAllCachesDic {
    
    NSMutableDictionary *pathDic = [self getCachesFile:YES];
    NSMutableDictionary *sizeDic = [self getCachesFile:NO];
    
    if (pathDic.allKeys.count > 0) [pathDic removeAllObjects];
    if (sizeDic.allKeys.count > 0) [sizeDic removeAllObjects];
    
    [self writeTofile:pathDic isCachesPathDic:YES];
    [self writeTofile:sizeDic isCachesPathDic:NO];
}
@end
