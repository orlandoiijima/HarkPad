//
// Created by wbison on 21-07-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <StarIO/SMPort.h>
#import "TemplatePrintDataSource.h"
#import "PrintTemplate.h"


@interface StarPrintJob : NSObject
@property(nonatomic, strong) PrintTemplate *template;
@property(nonatomic, strong) SMPort *port;
@property (nonatomic, retain) id<TemplatePrintDataSource> dataSource;
@property(nonatomic, assign) NSString *ip;
@property(nonatomic) float y;
@property(nonatomic) float x;
@property(nonatomic) float tableOffset;

@property(nonatomic, strong) UIPopoverController *popover;

@property(nonatomic) CGFloat lineHeight;

@property(nonatomic) CGFloat imageHeight;

+ (StarPrintJob *)jobWithTemplate:(PrintTemplate *)template dataSource: (id) dataSource  ip:(NSString *)ip;
- (void) print;
-(float) print:(Run *)run row:(int)row section:(int)section pointSize:(float)pointSize;
@end