
//
//  QBDownLoaderManager.m
//  QBDownLoad
//
//  Created by cqb on 17/4/17.
//  Copyright © 2017年 cqb. All rights reserved.
//

#import "QBDownLoaderManager.h"
#import "NSString+QBDownLoadFileExtension.h"
#import "QBDownLoadFileTool.h"
@interface QBDownLoaderManager ()<NSCopying,NSMutableCopying>

@property (nonatomic ,strong)NSMutableDictionary *downLoaderDic;

@end

@implementation QBDownLoaderManager

- (NSMutableDictionary *)downLoaderDic {
    
    if (!_downLoaderDic) {
        
        _downLoaderDic = [NSMutableDictionary dictionary];
    }
    return _downLoaderDic;
}


+ (void)load {
    
    [self sharedInstance];
}

static QBDownLoaderManager *_downLoaderManager = nil;
+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (!_downLoaderManager) {
            
            _downLoaderManager = [[self alloc]init];
        }
        
    });
    
    return _downLoaderManager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (!_downLoaderManager) {
            
            _downLoaderManager = [super allocWithZone:zone];
        }
    });
    return _downLoaderManager;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    
    return _downLoaderManager;
}

- (instancetype)mutableCopyWithZone:(NSZone *)zone {
    
    return _downLoaderManager;
}

- (QBDownLoader *)downLoadForUrl:(NSURL *)url {
    
    if (!url) nil;
    
    __weak typeof (self) weakSelf = self;

    QBDownLoader *downLoader = self.downLoaderDic[url.absoluteString.md5String];
    __weak typeof (downLoader) weakDownLoader = downLoader;
    
    if (downLoader) {
        
        [downLoader downLoad:url];

        downLoader.downLoadSuccess = ^(NSInteger totalBytesWriten,NSString *fileCachePath){
            [weakSelf.downLoaderDic removeObjectForKey:url.absoluteString.md5String];
        };
        
        downLoader.downLoadFailure = ^(NSError *error){
            [weakDownLoader cancleAndClearTmpMemory];
            [weakSelf.downLoaderDic removeObjectForKey:url.absoluteString.md5String];
        };
        
     return downLoader;
    }
    
    
    QBDownLoader *newdownLoader = [QBDownLoader defaultDownLoader];
    [self.downLoaderDic setValue:newdownLoader forKey:url.absoluteString.md5String];
    __weak typeof (newdownLoader) weakNewdownLoader = newdownLoader;
    [newdownLoader downLoad:url downLoadState:^(QBDownLoadState downLoadState, NSInteger bytesWriten, NSInteger totalBytesWriten, NSInteger totalExpectedToWriten) {
    

    } success:^(NSInteger totalBytesWriten, NSString *fileCachePath) {
        
        [weakSelf.downLoaderDic removeObjectForKey:url.absoluteString.md5String];

    } failuer:^(NSError *error) {

        [weakNewdownLoader cancleAndClearTmpMemory];
        [weakSelf.downLoaderDic removeObjectForKey:url.absoluteString.md5String];
        
    }];
    
    return newdownLoader;
    
}

- (void)downLoad:(NSURL *)url toCachesPath:(NSString *)path  state:(QBDownLoadStateChange)state success:(QBDownLoadSuccess)success failure:(QBDownLoadFailure)failure delegateQueue:(NSOperationQueue *)queue {
    
    
    if (!url) return;
    
    __weak typeof (self) weakSelf = self;
    QBDownLoader *downLoader = self.downLoaderDic[url.absoluteString.md5String];
    __weak typeof (downLoader) weakDownLoader =  downLoader;
    
    if (downLoader) {
    
        [downLoader downLoad:url downLoadState:^(QBDownLoadState downLoadState, NSInteger bytesWriten, NSInteger totalBytesWriten, NSInteger totalExpectedToWriten) {
            if (state) {
                state(downLoadState,bytesWriten,totalBytesWriten,totalExpectedToWriten);
            }
        } success:^(NSInteger totalBytesWriten, NSString *fileCachePath) {
            QBDownLoader *downLoader = self.downLoaderDic[url.absoluteString.md5String];
            if (downLoader) {
                [weakSelf.downLoaderDic removeObjectForKey:url.absoluteString.md5String];
            }
            if (success) {
                success(totalBytesWriten,fileCachePath);
            }
        } failuer:^(NSError *error) {
            
            [weakDownLoader cancleAndClearTmpMemory];
            QBDownLoader *downLoader = self.downLoaderDic[url.absoluteString.md5String];
            if (downLoader) {
                [weakSelf.downLoaderDic removeObjectForKey:url.absoluteString.md5String];
            }
            if (failure) {
                failure(error);
            }
        }];
    
        return;
    }
    
    QBDownLoader *newdownLoader = [QBDownLoader defaultDownLoader];
    __weak typeof (newdownLoader) weakNewDownLoader =  newdownLoader;
    [self.downLoaderDic setValue:newdownLoader forKey:url.absoluteString.md5String];
    [newdownLoader downLoad:url toCachesPath:path downLoadState:^(QBDownLoadState downLoadState, NSInteger bytesWriten, NSInteger totalBytesWriten, NSInteger totalExpectedToWriten) {
        if (state) {
            state(downLoadState,bytesWriten,totalBytesWriten,totalExpectedToWriten);
        }
    } success:^(NSInteger totalBytesWriten, NSString *fileCachePath) {
         QBDownLoader *downLoader = self.downLoaderDic[url.absoluteString.md5String];
        if (downLoader) {
             [weakSelf.downLoaderDic removeObjectForKey:url.absoluteString.md5String];
        }
        if (success) {
            success(totalBytesWriten,fileCachePath);
        }
    } failuer:^(NSError *error) {
        [weakNewDownLoader cancleAndClearTmpMemory];
        QBDownLoader *downLoader = self.downLoaderDic[url.absoluteString.md5String];
        if (downLoader) {
         [weakSelf.downLoaderDic removeObjectForKey:url.absoluteString.md5String];
        }
        if (failure) {
            failure(error);
        }
    } delegateQueue:queue];
    
}

- (void)pasuse:(NSURL *)url {
    if (!url || self.downLoaderDic.allValues.count == 0) return;
    QBDownLoader *downLoader = self.downLoaderDic[url.absoluteString.md5String];
    [downLoader pause];
}

- (void)resume:(NSURL *)url {
    if (!url || self.downLoaderDic.allValues.count == 0) return;
    QBDownLoader *downLoader = self.downLoaderDic[url.absoluteString.md5String];
    [downLoader resume];
}

- (void)cancle:(NSURL *)url {
    if (!url || self.downLoaderDic.allValues.count == 0) return;
    QBDownLoader *downLoader = self.downLoaderDic[url.absoluteString.md5String];
    [downLoader cancle];
}

- (void)cancleAndClearTmpCaches:(NSURL *)url {
    if (!url || self.downLoaderDic.allValues.count == 0) return;
    QBDownLoader *downLoader = self.downLoaderDic[url.absoluteString.md5String];
    [downLoader cancleAndClearTmpMemory];
}

- (BOOL)clearCaches:(NSURL *)url {
   if (!url) return NO;
   NSMutableDictionary *filePathDic = [QBDownLoadFileTool getCachesFile:YES];
   BOOL isClear = [QBDownLoadFileTool removeItemAtPath:filePathDic[url.lastPathComponent]];
    
  if (isClear) {
     [QBDownLoadFileTool removeDicCaches:url];
   }
    return isClear;
}

- (void)cancleAll {
    if (self.downLoaderDic.allValues.count == 0) return;
    NSArray *downLoaderArray = self.downLoaderDic.allValues;
    [downLoaderArray makeObjectsPerformSelector:@selector(cancle)];
}

- (void)pauseAll {
    if (self.downLoaderDic.allValues.count == 0) return;
    NSArray *downLoaderArray = self.downLoaderDic.allValues;
    [downLoaderArray makeObjectsPerformSelector:@selector(pause)];
}

- (void)resumeAll {
    if (self.downLoaderDic.allValues.count == 0) return;
    NSArray *downLoaderArray = self.downLoaderDic.allValues;
    [downLoaderArray makeObjectsPerformSelector:@selector(resume)];
}

- (void)cleaarAllCachs {
    
    NSMutableDictionary *filePathDic = [QBDownLoadFileTool getCachesFile:YES];
    if (filePathDic.allValues.count == 0) return;
    for (NSString *filePath in filePathDic.allValues) {
         [QBDownLoadFileTool removeItemAtPath:filePath];
    }
    
    [QBDownLoadFileTool removeAllCachesDic];
}

@end
