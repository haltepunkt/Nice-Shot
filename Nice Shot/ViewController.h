#import <Cocoa/Cocoa.h>

#import "CheckBoxTableCellView.h"
#import "DescriptionTableCellView.h"
#import "PopUpTableCellView.h"

@interface ViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource> {
    
    NSMutableArray *array;
    
}

@property IBOutlet NSTableView *tableView;

@end
