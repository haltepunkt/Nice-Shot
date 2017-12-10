#import "Initialization.h"

@implementation Initialization

- (id)initWithContentsOfFile:(NSString *)path {
    self = [super init];
    
    if (self) {
        dictionary = [NSMutableDictionary dictionary];
        
        NSString *contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
        
        if (contents) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            
            NSString *section;
            
            for (NSString *line in [contents componentsSeparatedByString:@"\n"]) {
                if ([line hasPrefix:@"["] && [line hasSuffix:@"]"]) {
                    section = [line stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[]"]];
                    
                    [dict setObject:[NSMutableDictionary dictionary] forKey:section];
                }
                
                else if (![line isEqualToString:@""] && [line containsString:@"="]) {
                    NSString *name = [self nameForKey:line];
                    NSObject *value = [self valueForKey:line];
                    
                    
                    if (section) {
                        [[dict objectForKey:section] setObject:value forKey:name];
                    }
                    
                    else {
                        [dict setObject:value forKey:name];
                    }
                }
            }
            
            if ([dict count] != 0) {
                dictionary = dict;
            }
        }
    }
    
    return self;
}

- (NSString *)nameForKey:(NSString *)key {
    NSMutableString *name = [NSMutableString string];
    
    for (NSUInteger idx = 0; idx < [key length]; idx++) {
        if ([key characterAtIndex:idx] != '=') {
            [name appendFormat:@"%c", [key characterAtIndex:idx]];
        }
        
        else {
            break;
        }
    }
    
    return [NSString stringWithString:name];
}

- (NSObject *)valueForKey:(NSString *)key {
    NSMutableString *value = [NSMutableString string];
    
    BOOL d = NO;
    
    for (NSUInteger idx = 0; idx < [key length]; idx++) {
        if (d) {
            [value appendFormat:@"%c", [key characterAtIndex:idx]];
        }
        
        if ([key characterAtIndex:idx] == '=' && d == 0) {
            d = YES;
        }
    }
    
    if ([[value lowercaseString] isEqualToString:@"true"]) {
        return @YES;
    }
    
    else if ([[value lowercaseString] isEqualToString:@"false"]) {
        return @NO;
    }
    
    return [NSString stringWithString:value];
}

- (NSObject *)valueForName:(NSString *)name section:(NSString *)section {
    NSObject *value = NULL;
    
    if (section) {
        if ([dictionary objectForKey:section]) {
            value = [[dictionary objectForKey:section] objectForKey:name];
        }
    }
    
    else {
        value = [dictionary objectForKey:name];
    }
    
    return value;
}

- (void)setValue:(NSObject *)value forName:(NSString *)name section:(NSString *)section {
    if (section) {
        if ([dictionary objectForKey:section]) {
            [[dictionary objectForKey:section] setObject:value forKey:name];
        }
        
        else {
            [dictionary setObject:[NSMutableDictionary dictionary] forKey:section];
            
            [[dictionary objectForKey:section] setObject:value forKey:name];
        }
    }
    
    else {
        [dictionary setObject:value forKey:name];
    }
}

- (BOOL)containsSection:(NSString *)section {
    return [[dictionary allKeys] containsObject:section];
}

- (BOOL)writeToFile:(NSString *)path {
    NSMutableString *initialization = [NSMutableString string];
    
    for (NSString *keyOrSection in [[dictionary allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
        if (![[dictionary objectForKey:keyOrSection] isKindOfClass:[NSMutableDictionary class]]) {
            [initialization appendFormat:@"%@=%@\n", keyOrSection, [self stringFromValue:[dictionary objectForKey:keyOrSection]]];
        }
        
        else {
            if ([initialization length] > 0) {
                [initialization appendString:@"\n"];
            }
            
            [initialization appendFormat:@"[%@]\n", keyOrSection];
            
            for (NSString *key in [[[dictionary objectForKey:keyOrSection] allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
                [initialization appendFormat:@"%@=%@\n", key, [self stringFromValue:[[dictionary objectForKey:keyOrSection] objectForKey:key]]];
            }
        }
    }
    
    return [initialization writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:NULL];
}

- (NSString *)stringFromValue:(NSObject *)value {
    if ([value isKindOfClass:[NSString class]]) {
        return (NSString *)value;
    }
    
    else if ([value isEqual:@YES]) {
        return @"true";
    }
    
    else if ([value isEqual:@NO]) {
        return @"false";
    }
    
    return NULL;
}

@end
