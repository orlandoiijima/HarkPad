//
// Created by wbison on 22-07-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SalesPdf.h"
#import "PdfCreator.h"
#import "NSDate-Utilities.h"
#import "Cache.h"
#import "PrintInfo.h"

@implementation SalesPdf {

@private
    NSDate *_from;
    NSDate *_to;
}

@synthesize from = _from;
@synthesize to = _to;

+ (SalesPdf *) salesFrom: (NSDate *)from to: (NSDate *)to {
    SalesPdf *pdf = [[SalesPdf alloc] init];
    pdf.from = from;
    pdf.to = to;
    return pdf;
}

- (NSString *)create
{
    PrintTemplate *template = [[[Cache getInstance] printInfo] getTemplateNamed:@"sales"];
    PdfCreator *creator = [PdfCreator pdfCreatorWithTemplate: template dataSource:self];
    NSString *fileName = [NSString stringWithFormat:@"Sales %@-%@.pdf", [_from flatDateString], [_to flatDateString] ];

    return  [creator createFileNamed: fileName];
}

@end