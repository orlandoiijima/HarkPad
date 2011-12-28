#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OrderLine.h"
#import "TableCellUpdated.h"

@interface OrderLineCell : UITableViewCell
{
}

@property (retain, nonatomic) OrderLine* orderLine;
@property (retain) IBOutlet UILabel *name;
@property (retain) IBOutlet UILabel *note;
@property (retain) IBOutlet UILabel *price;
@property (retain) IBOutlet UILabel *props;
@property (retain) IBOutlet UIButton *course;
@property (retain) IBOutlet UIButton *seat;
@property (retain) IBOutlet UILabel *quantity;
@property (retain) IBOutlet UIImageView *nLineIcon;
@property (retain) UITextField * notesView;
@property (retain) UIStepper * stepperView;
@property (retain) NSMutableArray *propertyViews;
@property (retain) id<TableCellUpdated> delegate;

@property bool showProductProperties;
@property BOOL isInEditMode;
@property BOOL isEditable;
@property BOOL showPrice;
@property int heightInEditMode;

+ (OrderLineCell *) cellWithOrderLine: (OrderLine *) line isEditable: (BOOL)isEditable showPrice: (bool)showPrice showProperties: (bool)showProperties delegate: (id) delegate rowHeight: (float)rowHeight fontSize: (float) fontSize;
+ (float) getExtraHeightForEditMode: (OrderLine *)line width: (float)width;

@end
