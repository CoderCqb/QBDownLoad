//
//  QBDownLoader.m
//  QBDownLoad
//
//  Created by cqb on 17/4/17.
//  Copyright © 2017年 cqb. All rights reserved.
//

#import "QBDownLoader.h"
#import "NSString+QBDownLoadFileExtension.h"
#import "QBDownLoadFileTool.h"
#import "NSMutableDictionary+QBMutableDictionaryExtension.h"

@interface QBDownLoader ()<NSURLSessionDataDelegate>

@property (nonatomic,assign)NSInteger bytesWriten;

@property (nonatomic,assign)NSInteger totalBytesWriten;

@property (nonatomic,assign)NSInteger totalExpectedToWriten;

@property (nonatomic,copy)NSString *fileCachePath;

@property (nonatomic,assign)QBDownLoadState downLoadState;

@property (nonatomic ,strong)NSURL *downLoadUrl;

@property (nonatomic ,strong)NSURLSession *session;

@property (nonatomic ,strong)NSURLSessionDataTask *task;

@property (nonatomic ,strong)NSOutputStream *stream;

@property (nonatomic ,strong)NSOperationQueue *queue;

@property (nonatomic ,strong)NSMutableDictionary *filePathDic;

@property (nonatomic ,strong)NSMutableDictionary *fileSizeDic;

@end

@implementation QBDownLoader


- (NSMutableDictionary *)filePathDic {
    
    if (!_filePathDic) {
        
        _filePathDic = [QBDownLoadFileTool getCachesFile:YES];
        if (!_filePathDic) {
            
            _filePathDic = [NSMutableDictionary dictionary];
        }
    }
    return _filePathDic;
}

- (NSMutableDictionary *)fileSizeDic {
    
    if (!_fileSizeDic) {
        
        _fileSizeDic = [QBDownLoadFileTool getCachesFile:NO];
        if (!_fileSizeDic) {
            
            _fileSizeDic = [NSMutableDictionary dictionary];
        }
    }
    return _fileSizeDic;
}


- (NSOperationQueue *)queue {
    
    if (!_queue) {
        
        _queue = [NSOperationQueue mainQueue];
    }
    return _queue;
}

- (NSURLSession *)session {
    
    if (!_session) {
        
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:self.queue];
    }
    
    return _session;
}


+ (instancetype)defaultDownLoader {
    
    return [[self alloc]init];
}


- (void)downLoad:(NSURL *)url {
    
    if (!url) return;
    self.downLoadUrl = url;
    NSString *filePath = [QBDownLoadFileTool cachesPath:url.lastPathComponent];
    if ([QBDownLoadFileTool fileExistsAtPath:filePath]) {
        
        self.downLoadState = QBDownLoadStateSuccess;
        [self.filePathDic qb_setPathObject:filePath forKey:url.lastPathComponent];
        NSInteger totalExpendWriten = [[self.fileSizeDic valueForKey:url.lastPathComponent] integerValue];
        if (self.downLoadSuccess) {
            self.downLoadSuccess(totalExpendWriten,filePath);
        }
        return;
     }
    
    if ([url isEqual:self.task.originalRequest.URL]) {
        
    if (self.downLoadState == QBDownLoadStateResume) return;
         
        if (self.downLoadState == QBDownLoadStatePause) {
        
            [self resume];
            self.downLoadState = QBDownLoadStateResume;
            return;
        }
    }
    
    [self.task cancel];
    self.totalBytesWriten = [QBDownLoadFileTool fileSizeAtPath:[QBDownLoadFileTool tmpCachesPath:url.absoluteString.md5String]];
    [self downLoad:url offSet:self.totalBytesWriten];
    
}

- (void)downLoad:(NSURL *)url offSet:(long long)offset {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-",offset] forHTTPHeaderField:@"Range"];
    
    self.task = [self.session dataTaskWithRequest:request];
    
    [self.task resume];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    self.totalExpectedToWriten = [httpResponse.allHeaderFields[@"Content-Length"] integerValue];
    if (httpResponse.allHeaderFields[@"Content-Range"]) {
    self.totalExpectedToWriten = [[httpResponse.allHeaderFields[@"Content-Range"] componentsSeparatedByString:@"/"].lastObject integerValue];
    }

    [self.fileSizeDic qb_setSizeObject:@(self.totalExpectedToWriten) forKey:self.downLoadUrl.lastPathComponent];
    
    if (self.totalBytesWriten == self.totalExpectedToWriten) {
        
        self.downLoadState = QBDownLoadStateSuccess;
        BOOL isMoved = [QBDownLoadFileTool moveItemAtPath:[QBDownLoadFileTool tmpCachesPath:self.downLoadUrl.absoluteString.md5String] toPath:self.fileCachePath ?:[QBDownLoadFileTool cachesPath:self.downLoadUrl.lastPathComponent]];
        if (isMoved && self.downLoadSuccess) {
            self.downLoadSuccess(self.totalExpectedToWriten,self.fileCachePath ?:[QBDownLoadFileTool cachesPath:self.downLoadUrl.lastPathComponent]);
        }
        completionHandler(NSURLSessionResponseCancel);
        return;
        
    }
    
    if (self.totalBytesWriten > self.totalExpectedToWriten) {
        
     [QBDownLoadFileTool removeItemAtPath:[QBDownLoadFileTool tmpCachesPath:self.downLoadUrl.absoluteString.md5String]];
     [self downLoad:self.downLoadUrl offSet:0];
      completionHandler(NSURLSessionResponseCancel);
     return;
    }
    
    self.stream = [NSOutputStream outputStreamToFileAtPath:[QBDownLoadFileTool tmpCachesPath:self.downLoadUrl.absoluteString.md5String] append:YES];
    [self.stream open];
    self.downLoadState = QBDownLoadStateResume;
    completionHandler(NSURLSessionResponseAllow);
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    self.totalBytesWriten += data.length;
    if (self.stateChange) {
        self.stateChange(self.downLoadState,data.length,self.totalBytesWriten,self.totalExpectedToWriten);
    }
    [self.stream write:data.bytes maxLength:data.length];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    
    [self.stream close];
    self.stream = nil;
    
    if (!error) {
        
     self.downLoadState = QBDownLoadStateSuccess;
     NSString *cachesPath = self.fileCachePath ?:[QBDownLoadFileTool cachesPath:self.downLoadUrl.lastPathComponent];
     [QBDownLoadFileTool moveItemAtPath:[QBDownLoadFileTool tmpCachesPath:self.downLoadUrl.absoluteString.md5String] toPath:cachesPath];
     if (self.downLoadSuccess) {
         self.downLoadSuccess(self.totalExpectedToWriten,cachesPath);
      }
     [self.filePathDic qb_setPathObject:cachesPath forKey:self.downLoadUrl.lastPathComponent];
     self.totalBytesWriten = 0;
     self.totalExpectedToWriten = 0;
     self.bytesWriten = 0;
    
    }else{
        
     self.downLoadState = QBDownLoadStateFailure;
     [self cancleAndClearTmpMemory];
     self.totalBytesWriten = 0;
     self.totalExpectedToWriten = 0;
     self.bytesWriten = 0;
     [self.fileSizeDic qb_removeSizeObjectforKey:self.downLoadUrl.lastPathComponent];
     if (self.downLoadFailure) {
        self.downLoadFailure(error);
      }
   }
}

- (void)resume {
    
    if (self.downLoadState == QBDownLoadStatePause) {
        [self.task resume];
        self.downLoadState = QBDownLoadStateResume;
    }
}

- (void)pause {
    
    if (self.downLoadState == QBDownLoadStateResume) {
        [self.task suspend];
        self.downLoadState = QBDownLoadStatePause;
    }
}

- (void)cancle {
    
    if (self.downLoadState == QBDownLoadStateResume || self.downLoadState == QBDownLoadStatePause) {
        [self.task cancel];
        self.downLoadState = QBDownLoadStateNone;
    }
}

- (void)cancleAndClearTmpMemory {
    
    [self cancle];
    [QBDownLoadFileTool removeItemAtPath:[QBDownLoadFileTool tmpCachesPath:self.downLoadUrl.absoluteString.md5String]];
}

- (BOOL)clearCache {
    
    NSString *cachesPath = [self.filePathDic objectForKey:self.downLoadUrl.absoluteString.md5String];
    BOOL isSucceed = [QBDownLoadFileTool removeItemAtPath:cachesPath];
    if (isSucceed) {
        [self.filePathDic qb_removePathObjectforKey:self.downLoadUrl.absoluteString.md5String];
        [self.fileSizeDic qb_removeSizeObjectforKey:self.downLoadUrl.absoluteString.md5String];
    }
    return isSucceed;
}

- (void)setDownLoadState:(QBDownLoadState)downLoadState {
    
    if (_downLoadState == downLoadState) return;
    _downLoadState = downLoadState;
    if (self.stateChange) {
        self.stateChange(downLoadState,self.bytesWriten,self.totalBytesWriten,self.totalExpectedToWriten);
    }
}

- (void)downLoad:(NSURL *)url downLoadState:(QBDownLoadStateChange)state success:(QBDownLoadSuccess)success failuer:(QBDownLoadFailure)failure {
    [self downLoad:url toCachesPath:nil downLoadState:state success:success failuer:failure delegateQueue:nil];
}

- (void)downLoad:(NSURL *)url toCachesPath:(NSString *)path downLoadState:(QBDownLoadStateChange)state success:(QBDownLoadSuccess)success failuer:(QBDownLoadFailure)failure delegateQueue:(NSOperationQueue *)queue {
    
    self.downLoadUrl = url;
    self.fileCachePath = path;
    self.stateChange = state;
    self.downLoadSuccess = success;
    self.downLoadFailure = failure;
    self.queue = queue;
    [self downLoad:url];
    
}


@end
