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

@property(nonatomic) int y;

@property(nonatomic) int tableOffset;

+ (StarPrintJob *)jobWithTemplateNamed:(NSString *)templateName dataSource: (id) dataSource  ip:(NSString *)ip;
- (void) print;
- (void)printImageWithPortname:(NSString *)portName portSettings: (NSString*)portSettings imageToPrint: (UIImage*)imageToPrint maxWidth: (int)maxWidth;
-(float) print:(Run *)run row:(int)row section:(int)section pointSize:(float)pointSize;
@end