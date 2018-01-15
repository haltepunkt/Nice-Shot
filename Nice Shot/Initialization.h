#import <Foundation/Foundation.h>

@interface Initialization : NSObject {
    
    NSMutableDictionary *dictionary;
    
}

/**
 Creates and returns an Initialization containing the keys and values from another given dictionary

 @param aDictionary A dictionary containing the keys and values with which to initialize the new Initialization.
 
        Accepts only certains types of data: NSDictionary, NSString, and NSNumber.
 
 @return An Initialization object.
 */
- (id)initWithDictionary:(NSDictionary *)aDictionary;

/**
 Creates and returns an Initialization created by reading data from the file at a given path.

 @param aPath A path to a file.
 @return An Initialization object.
 */
- (id)initWithContentsOfFile:(NSString *)aPath;

/**
 Returns the value associated with a given name and a given section.

 @param aName The name for which to return the corresponding value.
 @param aSection The section for which to return the corresponding value.
 @return The value associated with name and section, or nil if no value is associated with name and section.
 */
- (NSObject *)valueForName:(NSString *)aName section:(NSString *)aSection;


/**
 Adds a given name-value pair to the Initialization or to a given section of the Initialization.

 @param aValue The value for aValue.
 @param aName The name for aValue.
 @param aSection The section for aValue
 */
- (void)setValue:(NSObject *)aValue forName:(NSString *)aName section:(NSString *)aSection;


/**
 Returns a Boolean value that indicates whether a given section is present in the Initialization.

 @param aSection aSection to look for in the Initialization.
 @return YES if aSection is present in the Initialization, otherwise NO.
 */
- (BOOL)containsSection:(NSString *)aSection;

/**
 Writes the contents of the receiver to a file at a given path.
 
 This method overwrites any existing file at aPath.

 @param aPath The file to which to write the receiver.
 
        Any path that contains a tilde character must be expanded with stringByExpandingTildeInPath before invoking this method.
 
 @return YES if the file is written successfully, otherwise NO.
 */
- (BOOL)writeToFile:(NSString *)aPath;

@end
