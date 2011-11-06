#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OrderLine.h"

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
@property bool showProductProperties;
+ (OrderLineCell *) cellWithOrderLine: (OrderLine *) line;

@end
