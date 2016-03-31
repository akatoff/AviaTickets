//
//  ASTFilters.h
//

#import <AviasalesSDK/AviasalesFilter.h>

typedef enum ASFilterCellType:NSUInteger {
    ASFilterNoTransferCell,
    ASFilterOneTransferCell,
    ASFilterTwoTransfersCell,
    ASFilterOvernightTransferCell,
    ASFilterPriceSliderCell,
    ASFilterFlightTimeSliderCell,
    ASFilterDelayTimeSliderCell,
    ASFilterOutboundDepartTimeSliderCell,
    ASFilterReturnDepartTimeSliderCell,
    ASFilterOutboundArrivalTimeSliderCell,
    ASFilterReturnArrivalTimeSliderCell,
    ASFilterAlliancesHeader,
    ASFilterAllAlliancesCell,
    ASFilterAllianceCell,
    ASFilterAirlinesHeader,
    ASFilterAllAirlinesCell,
    ASFilterAirlineCell,
    ASFilterAirlineFooterCell,
    ASFilterAirportsHeader,
    ASFilterAllAirportsCell,
    ASFilterAirportsSeparator,
    ASFilterCellWithAirportBig,
    ASFilterCellWithBtn,
    ASFilterGatesHeader,
    ASFilterAllGatesCell,
    ASFilterGateCell
} ASFilterCellType;

@interface ASFilterCellInfo: NSObject

@property (assign, nonatomic) ASFilterCellType type;
@property (strong, nonatomic) NSString *CellIdentifier;
@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) BOOL disabled;
@property (strong, nonatomic) id content;

@end


@interface ASTFilters : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *offersLabel;
@property (weak, nonatomic) IBOutlet UILabel *price;

@property (strong, nonatomic) NSArray *tickets;
@property (strong, nonatomic) AviasalesFilter *filter;

- (void)buildTable;

- (IBAction)dismiss:(id)sender;

@end
