//
//  NSMutableDictionary+QBMutableDictionaryExtension.m
//  QBDownLoad
//
//  Created by cqb on 17/4/19.
//  Copyright © 2017年 cqb. All rights reserved.
//

#import "NSMutableDictionary+QBMutableDictionaryExtension.h"
#import "QBDownLoadFileTool.h"

@implementation NSMutableDictionary (QBMutableDictionaryExtension)

- (void)qb_setPathObject:(id)value forKey:(id)key {
    
    [self setObject:value forKey:key];
    [self cachePathDic:YES];
}

- (void)qb_removePathObjectforKey:(id)key {
    
    [self removeObjectForKey:key];
    [self cachePathDic:YES];
   
}

- (void)qb_setSizeObject:(id)value forKey:(id)key {
    
    [self setObject:value forKey:key];
    [self cachePathDic:NO];
}

- (void)qb_removeSizeObjectforKey:(id)key {
    
    [self removeObjectForKey:key];
    [self cachePathDic:NO];
}

- (void)cachePathDic:(BOOL)isCache {
    
  [QBDownLoadFileTool writeTofile:self isCachesPathDic:isCache];
}

@end
