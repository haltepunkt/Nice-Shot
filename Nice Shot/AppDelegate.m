#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    window = [[[NSApplication sharedApplication] windows] firstObject];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setValueForName:) name:@"setValueForName" object:nil];
    
    initializationPath = [@"~/Library/Application Support/Rocket League/TAGame/Config/Mac-TASystemSettings.ini" stringByStandardizingPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:initializationPath]) {
        if (![self openInitializationAtPath:initializationPath]) {
            [self runAlert];
        }
    }
    
    else {
        [self runAlert];
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application {
    return TRUE;
}

- (IBAction)showGithubHelp:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/haltepunkt/Nice-Shot"]];
}

- (void)runAlert {
    NSAlert *alert = [NSAlert new];
    
    [alert setMessageText:@"Initialization not found!"];
    [alert setInformativeText:@"Please locate the initialization file Mac-TASystemSettings.ini"];
    [alert addButtonWithTitle:@"Locate…"];
    [alert addButtonWithTitle:@"Quit"];
    [alert setAlertStyle:NSAlertStyleCritical];
    
    [alert beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
        if (result == NSAlertFirstButtonReturn) {
            NSOpenPanel *panel = [NSOpenPanel openPanel];
            
            [panel setDirectoryURL:[NSURL URLWithString:[@"~/Library/" stringByStandardizingPath]]];
            [panel setAllowedFileTypes:@[@"ini"]];
            
            [panel beginWithCompletionHandler:^(NSInteger result) {
                if (result == NSFileHandlingPanelOKButton) {
                    NSString *path = [[panel URL] path];
                    
                    if ([[path lastPathComponent] isEqualToString:@"Mac-TASystemSettings.ini"]) {
                        initializationPath = path;
                        
                        if (![self openInitializationAtPath:initializationPath]) {
                            [self runAlert];
                        }
                    }
                    
                    else {
                        [self runAlert];
                    }
                }
                
                else {
                    [self runAlert];
                }
            }];
        }
        
        else if (result == NSAlertSecondButtonReturn) {
            [[NSApplication sharedApplication] terminate:NULL];
        }
    }];
}

- (BOOL)openInitializationAtPath:(NSString *)path {
    ini = [[Initialization alloc] initWithContentsOfFile:path];
    
    if ([ini containsSection:@"SystemSettings"]) {
        settingsDict = [NSMutableDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"]];
        
        NSArray *names = [[settingsDict allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        
        NSMutableArray *array = [NSMutableArray array];
        
        for (NSString *name in names) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            
            [dict setValuesForKeysWithDictionary:[settingsDict objectForKey:name]];
            
            [dict setObject:name forKey:@"name"];
            
            NSObject *value = [ini valueForName:name section:@"SystemSettings"];
            
            if (value) {
                if ([[dict objectForKey:@"type"] isEqualToString:@"float"] && [[dict objectForKey:@"possibleValues"] containsObject:[NSString stringWithFormat:@"%.1f", [(NSString *)value floatValue]]]) {
                    value = [NSString stringWithFormat:@"%.1f", [(NSString *)value floatValue]];
                }
                
                else if (![[dict objectForKey:@"possibleValues"] containsObject:value]) {
                    [[dict objectForKey:@"possibleValues"] insertObject:value atIndex:0];
                    [[dict objectForKey:@"descriptionsOfPossibleValues"] insertObject:@"Custom" atIndex:0];
                }
                
                [dict setObject:value forKey:@"value"];
                
                [array addObject:dict];
            }
        }
        
        if ([array count] > 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Data" object:array];
            
            [window setTitle:[initializationPath stringByAbbreviatingWithTildeInPath]];
            
            return TRUE;
        }
    }
    
    return FALSE;
}

- (void)setValueForName:(NSNotification *)notification {
    NSString *name = [[notification object] objectForKey:@"name"];
    
    NSObject *value = [[notification object] objectForKey:@"value"];
    
    [ini setValue:value forName:name section:@"SystemSettings"];
    
    [ini writeToFile:initializationPath];
}

@end
