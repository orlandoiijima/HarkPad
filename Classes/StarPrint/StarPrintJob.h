//
// Created by wbison on 21-07-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <StarIO/SMPort.h>
#import "TemplatePrintDelegate.h"
#import "PrintTemplate.h"


@interface StarPrintJob : NSObject
@property(nonatomic, strong) PrintTemplate *template;
@property(nonatomic, strong) SMPort *port;
@property (nonatomic, retain) id<TemplatePrintDelegate> delegate;

+ (StarPrintJob *)jobWithTemplateNamed:(NSString *)templateName delegate: (id) delegate;

@end