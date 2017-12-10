#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[self tableView] setDelegate:self];
    [[self tableView] setDataSource:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedData:) name:@"Data" object:nil];
}

- (void)receivedData:(NSNotification *)notification {
    array = [notification object];
    
    [[self tableView] reloadData];
}

- (void)setValue:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setValueForName" object:@{@"name": [[sender representedObject] objectForKey:@"name"], @"value": [[sender representedObject] objectForKey:@"value"]}];
}

- (void)setBooleanValue:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setValueForName" object:@{@"name": [sender representedObject], @"value": [NSNumber numberWithLong:[sender state]]}];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([[tableColumn identifier] isEqualToString:@"Names"]) {
        DescriptionTableCellView *cellView = [tableView makeViewWithIdentifier:[tableColumn identifier] owner:self];
        
        [[cellView textField] setStringValue:[[array objectAtIndex:row] objectForKey:@"name"]];
        [[cellView descriptionTextField] setStringValue:[[array objectAtIndex:row] objectForKey:@"description"]];
        
        return cellView;
    }
    
    else if ([[tableColumn identifier] isEqualToString:@"Values"]) {
        NSString *type = [[array objectAtIndex:row] objectForKey:@"type"];
        
        if ([type isEqualToString:@"boolean"]) {
            CheckBoxTableCellView *cellView = [tableView makeViewWithIdentifier:@"CheckBox" owner:self];
            
            [[[cellView checkBoxButton] cell] setRepresentedObject:[[array objectAtIndex:row] objectForKey:@"name"]];
            
            [[cellView checkBoxButton] setAction:@selector(setBooleanValue:)];
            
            [[cellView checkBoxButton] setState:(NSControlStateValue)[[[array objectAtIndex:row] objectForKey:@"value"] longValue]];
            
            return cellView;
        }
        
        else {
            PopUpTableCellView *cellView = [tableView makeViewWithIdentifier:@"PopUp" owner:self];
            
            [[cellView popUpButton] addItemsWithTitles:[[array objectAtIndex:row] objectForKey:@"descriptionsOfPossibleValues"]];
            
            NSInteger idx = 0;
            for (NSMenuItem *item in [[cellView popUpButton] itemArray]) {
                NSDictionary *dict = @{@"name": [[array objectAtIndex:row] objectForKey:@"name"], @"value": [[[array objectAtIndex:row] objectForKey:@"possibleValues"] objectAtIndex:idx]};
                
                [item setRepresentedObject:dict];
                
                idx++;
            }
            
            [[cellView popUpButton] setAction:@selector(setValue:)];
            
            NSString *value = [[array objectAtIndex:row] objectForKey:@"value"];
            NSArray *possibleValues = [[array objectAtIndex:row] objectForKey:@"possibleValues"];
            
            for (NSString *possibleValue in possibleValues) {
                if ([value isEqualToString:possibleValue]) {
                    [[cellView popUpButton] selectItemAtIndex:[possibleValues indexOfObject:value]];
                }
            }
            
            return cellView;
        }
    }
    
    else if ([[tableColumn identifier] isEqualToString:@"Tweaks"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:[tableColumn identifier] owner:self];
        
        [[cellView textField] setStringValue:[[array objectAtIndex:row] objectForKey:@"tweak"]];
        
        return cellView;
    }
    
    return NULL;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [array count];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if ([[notification object] selectedRow] >= 0) {
        
    }
}

- (NSIndexSet *)tableView:(NSTableView *)tableView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes {
    return NULL;
}

@end
