//
//  Created by wbison on 26-01-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "TemplatePrintDelegate.h"
#import "PrintTemplate.h"

@interface PdfCreator : NSObject {
    id<TemplatePrintDelegate> __strong _delegate;
}


@property (nonatomic, retain) id<TemplatePrintDelegate> delegate;
@property (retain) PrintTemplate *template;

- (NSString *) createFileNamed: (NSString *)fileName;
+ (PdfCreator *) pdfCreatorWithTemplateNamed: (NSString *) template delegate: (id)delegate;
@end