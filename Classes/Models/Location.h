//
// Created by wbison on 28-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "DTO.h"

@interface Location : DTO
@property(nonatomic, strong) id name;
@property(nonatomic) int id;

@property(nonatomic, strong) UIImage *logo;

+ (Location *)locationFromJsonDictionary:(NSDictionary *)jsonDictionary;

@end