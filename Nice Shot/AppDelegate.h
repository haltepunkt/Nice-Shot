#import <Cocoa/Cocoa.h>

#import "Initialization.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    
    NSWindow *window;

    NSDictionary *settingsDict;
    
    NSString *initializationPath;
    Initialization *ini;
    
}

- (IBAction)showGithubHelp:(id)sender;

@end
