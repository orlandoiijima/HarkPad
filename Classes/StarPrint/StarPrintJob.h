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

+ (StarPrintJob *)jobWithTemplateNamed:(NSString *)templateName dataSource: (id) dataSource;

@end