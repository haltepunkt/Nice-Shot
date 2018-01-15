#import "Initialization.h"

@implementation Initialization

- (id)initWithDictionary:(NSDictionary *)aDictionary {
     self = [super init];
    
    if (self) {
        NSArray *types = @[[NSDictionary class], [NSString class], [NSNumber class]];
        
        for (NSObject *object in [dictionary allValues]) {
            if (![types containsObject:[object class]]) {
                return nil;
            }
            
            if ([object isKindOfClass:[NSDictionary class]]) {
                for (NSObject *child in [(NSDictionary *)object allValues]) {
                    if (![[types subarrayWithRange:NSMakeRange(1, [types count] - 1)] containsObject:[child class]]) {
                        return nil;
                    }
                }
            }
        }
        
        dictionary = [NSMutableDictionary dictionaryWithDictionary:aDictionary];
    }
    
    return self;
}

- (id)initWithContentsOfFile:(NSString *)aPath {
    self = [super init];
    
    if (self) {
        dictionary = [NSMutableDictionary dictionary];
        
        NSString *contents = [NSString stringWithContentsOfFile:aPath encoding:NSUTF8StringEncoding error:NULL];
        
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

- (NSString *)nameForKey:(NSString *)aKey {
    NSMutableString *name = [NSMutableString string];
    
    for (NSUInteger idx = 0; idx < [aKey length]; idx++) {
        if ([aKey characterAtIndex:idx] != '=') {
            [name appendFormat:@"%c", [aKey characterAtIndex:idx]];
        }
        
        else {
            break;
        }
    }
    
    return [NSString stringWithString:name];
}

- (NSObject *)valueForKey:(NSString *)aKey {
    NSMutableString *value = [NSMutableString string];
    
    BOOL d = NO;
    
    for (NSUInteger idx = 0; idx < [aKey length]; idx++) {
        if (d) {
            [value appendFormat:@"%c", [aKey characterAtIndex:idx]];
        }
        
        if ([aKey characterAtIndex:idx] == '=' && d == 0) {
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

- (NSObject *)valueForName:(NSString *)aName section:(NSString *)aSection {
    NSObject *value = NULL;
    
    if (aSection) {
        if ([dictionary objectForKey:aSection]) {
            value = [[dictionary objectForKey:aSection] objectForKey:aName];
        }
    }
    
    else {
        value = [dictionary objectForKey:aName];
    }
    
    return value;
}

- (void)setValue:(NSObject *)aValue forName:(NSString *)aName section:(NSString *)aSection {
    if (aSection) {
        if ([dictionary objectForKey:aSection]) {
            [[dictionary objectForKey:aSection] setObject:aValue forKey:aName];
        }
        
        else {
            [dictionary setObject:[NSMutableDictionary dictionary] forKey:aSection];
            
            [[dictionary objectForKey:aSection] setObject:aValue forKey:aName];
        }
    }
    
    else {
        [dictionary setObject:aValue forKey:aName];
    }
}

- (BOOL)containsSection:(NSString *)aSection {
    return [[dictionary allKeys] containsObject:aSection];
}

- (BOOL)writeToFile:(NSString *)aPath {
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
    
    return [initialization writeToFile:aPath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
}

- (NSString *)stringFromValue:(NSObject *)aValue {
    if ([aValue isKindOfClass:[NSString class]]) {
        return (NSString *)aValue;
    }
    
   else if ([aValue isKindOfClass:[NSNumber class]]) {
        if (!strcmp([(NSNumber *)aValue objCType], @encode(BOOL))) {
            if ([aValue isEqual:@YES]) {
                return @"true";
            }
            
            else if ([aValue isEqual:@NO]) {
                return @"false";
            }
        }
        
        CFNumberRef numberRef = (__bridge CFNumberRef)(NSNumber *)aValue;
        
        if (CFNumberIsFloatType(numberRef)) {
            return [NSString stringWithFormat:@"%.6f", [(NSNumber *)aValue floatValue]];
        }
        
        else if (CFNumberGetType(numberRef) == kCFNumberSInt32Type || CFNumberGetType(numberRef) == kCFNumberSInt64Type) {
            return [NSString stringWithFormat:@"%i", [(NSNumber *)aValue intValue]];
        }
    }
    
    return NULL;
}

@end
