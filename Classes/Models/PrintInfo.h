//
// Created by wbison on 15-07-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface PrintInfo : NSObject
@property(nonatomic, strong) NSMutableArray *templates;

+ (PrintInfo *) infoFromJson:(NSMutableArray *)infoJson;

@end