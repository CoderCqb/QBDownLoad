//
//  NSMutableDictionary+QBMutableDictionaryExtension.h
//  QBDownLoad
//
//  Created by cqb on 17/4/19.
//  Copyright © 2017年 cqb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (QBMutableDictionaryExtension)

- (void)qb_setPathObject:(id)value forKey:(id)key;

- (void)qb_removePathObjectforKey:(id)key;

- (void)qb_setSizeObject:(id)value forKey:(id)key;

- (void)qb_removeSizeObjectforKey:(id)key;

@end
