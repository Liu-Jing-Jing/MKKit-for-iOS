//
//  MKDateTools.h
//  Pure-Weibo
//
//  Created by Mark Lewis on 16-8-16.
//  Copyright (c) 2016年 MarkLewis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKDateTools : NSObject
+ (NSString*) stringFromFomate:(NSDate*) date formate:(NSString*)formate;
+ (NSString *)weiboDateFomateString:(NSString *)datestring;
@end
