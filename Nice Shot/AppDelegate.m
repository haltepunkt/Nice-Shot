#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    window = [[[NSApplication sharedApplication] windows] firstObject];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setValueForName:) name:@"setValueForName" object:nil];
    
    initializationPath = [@"~/Library/Application Support/Rocket League/TAGame/Config/Mac-TASystemSettings.ini" stringByStandardizingPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:initializationPath]) {
        if (![self openInitializationAtPath:initializationPath]) {
            [self runAlertWithMessageText:@"Initialization could not be read!" informativeText:@"The “Mac-TASystemSettings.ini“ initialization file could not be read."];
        }
    }
    
    else {
        [self runAlertWithMessageText:@"Initialization not found!" informativeText:@"Please locate the “Mac-TASystemSettings.ini“ initialization file."];
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application {
    return TRUE;
}

- (IBAction)resetToDefaults:(id)sender {
    NSAlert *alert = [NSAlert new];
    
    [alert setMessageText:@"Do you really want to reset the initialization to its defaults?"];
    [alert setInformativeText:@"This action will move the “Mac-TASystemSettings.ini“ initialization file to the Trash. Rocket League will create a default initialization the next time it is launched."];
    [alert addButtonWithTitle:@"Reset to Defaults"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setAlertStyle:NSAlertStyleCritical];
    
    [alert beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
        if (result == NSAlertFirstButtonReturn) {
            NSError *error;
            
            if ([[NSFileManager defaultManager] trashItemAtURL:[NSURL fileURLWithPath:initializationPath] resultingItemURL:NULL error:&error]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Data" object:NULL];
                
                [resetToDefaultsMenuItem setEnabled:NO];
                
                [window setTitle:@"Nice Shot"];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self runAlertWithMessageText:@"Initialization not found!" informativeText:@"Please locate the “Mac-TASystemSettings.ini“ initialization file."];
                });
            }
            
            else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSAlert *alert = [NSAlert new];
                    
                    [alert setMessageText:@"Could not move “Mac-TASystemSettings.ini“ to the Trash."];
                    [alert setInformativeText:[error localizedDescription]];
                    [alert addButtonWithTitle:@"Close"];
                    [alert setAlertStyle:NSAlertStyleCritical];
                    
                    [alert beginSheetModalForWindow:window completionHandler:NULL];
                });
            }
        }
    }];
}

- (IBAction)showHelp:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/haltepunkt/Nice-Shot"]];
}

- (void)runAlertWithMessageText:(NSString *)messageText informativeText:(NSString *)informativeText {
    NSAlert *alert = [NSAlert new];
    
    [alert setMessageText:messageText];
    [alert setInformativeText:informativeText];
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
                            [self runAlertWithMessageText:@"Initialization could not be read!" informativeText:@"The “Mac-TASystemSettings.ini“ initialization file could not be read."];
                        }
                    }
                    
                    else {
                        [self runAlertWithMessageText:@"Wrong initialization file chosen!" informativeText:@"Please locate the “Mac-TASystemSettings.ini“ initialization file."];
                    }
                }
                
                else {
                    [self runAlertWithMessageText:@"Initialization not found!" informativeText:@"Please locate the “Mac-TASystemSettings.ini“ initialization file."];
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
            
            [resetToDefaultsMenuItem setEnabled:YES];
            
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
