//
//  ASTResults.h
//

#import <AviasalesSDK/AviasalesSDK.h>
#import <AviasalesSDK/AviasalesFilter.h>
#import <UIKit/UIKit.h>

@interface ASTResults : UIViewController <UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate, AviasalesFilterDelegate>

- (IBAction)showCurrenciesList:(id)sender;
- (IBAction)showFilters:(id)sender;

@property (nonatomic, strong) AviasalesSearchResponse *response;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *currencyButton;
@property (nonatomic, weak) IBOutlet UIView *waitingView;

@property (nonatomic, weak) IBOutlet UIView *emptyView;
@property (nonatomic, weak) IBOutlet UILabel *emptyLabel;

@property (nonatomic, weak) IBOutlet UIProgressView *progressView;
@property (nonatomic, weak) IBOutlet UILabel *progressLabel;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *filters;

@end
