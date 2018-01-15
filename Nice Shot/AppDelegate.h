#import <Cocoa/Cocoa.h>

#import "Initialization.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    
    NSWindow *window;

    NSDictionary *settingsDict;
    
    NSString *initializationPath;
    Initialization *ini;
    
    IBOutlet NSMenuItem *resetToDefaultsMenuItem;
    
}

- (IBAction)resetToDefaults:(id)sender;
- (IBAction)showHelp:(id)sender;

@end
