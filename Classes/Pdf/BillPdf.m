//
//  Created by wbison on 26-01-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "BillPdf.h"
#import "PdfCreator.h"
#import "Utils.h"
#import "InvoicePrintDataSource.h"
#import "StarPrintJob.h"


@implementation BillPdf {
}

@synthesize order = _order, orderDataSource = _orderDataSource;

+ (BillPdf *)billByOrder: (Order *)order {
    BillPdf *pdf = [[BillPdf alloc] init];
    pdf.order = order;
    return pdf;
}

- (NSString *)createFile
{
    InvoicePrintDataSource *printDataSource = [InvoicePrintDataSource dataSourceForOrder:_order];

    PdfCreator *creator = [PdfCreator pdfCreatorWithTemplateNamed: @"invoice" dataSource:printDataSource];
    NSString *fileName = [NSString stringWithFormat:@"Invoice%d.pdf", _order.id];

    return  [creator createFileNamed: fileName];
}

@end