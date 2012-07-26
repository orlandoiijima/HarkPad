//
//  Created by wbison on 26-01-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "TemplatePrintDataSource.h"
#import "PrintTemplate.h"

@interface PdfCreator : NSObject {
    id<TemplatePrintDataSource> __strong _delegate;
}


@property (nonatomic, retain) id<TemplatePrintDataSource> dataSource;
@property (retain) PrintTemplate *template;

- (NSString *) createFileNamed: (NSString *)fileName;
+ (PdfCreator *) pdfCreatorWithTemplateNamed: (NSString *) template dataSource: (id)dataSource;
@end