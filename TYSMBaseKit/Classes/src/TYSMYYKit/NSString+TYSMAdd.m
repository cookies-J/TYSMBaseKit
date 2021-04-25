//
//  NSString+TYSMAdd.m
//  TYSMKit <https://github.com/ibireme/TYSMKit>
//
//  Created by ibireme on 13/4/3.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "NSString+TYSMAdd.h"
#import "NSData+TYSMAdd.h"
#import "NSNumber+TYSMAdd.h"
#import "UIDevice+TYSMAdd.h"
#import "TYSMKitMacro.h"

TYSMSYNTH_DUMMY_CLASS(NSString_TYSMAdd)


@implementation NSString (TYSMAdd)

- (NSString *)tysm_md2String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] tysm_md2String];
}

- (NSString *)tysm_md4String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] tysm_md4String];
}

- (NSString *)tysm_md5String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] tysm_md5String];
}

- (NSString *)tysm_sha1String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] tysm_sha1String];
}

- (NSString *)tysm_sha224String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] tysm_sha224String];
}

- (NSString *)tysm_sha256String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] tysm_sha256String];
}

- (NSString *)tysm_sha384String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] tysm_sha384String];
}

- (NSString *)tysm_sha512String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] tysm_sha512String];
}

- (NSString *)tysm_crc32String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] tysm_crc32String];
}

- (NSString *)tysm_hmacMD5StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding]
            tysm_hmacMD5StringWithKey:key];
}

- (NSString *)tysm_hmacSHA1StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding]
            tysm_hmacSHA1StringWithKey:key];
}

- (NSString *)tysm_hmacSHA224StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding]
            tysm_hmacSHA224StringWithKey:key];
}

- (NSString *)tysm_hmacSHA256StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding]
            tysm_hmacSHA256StringWithKey:key];
}

- (NSString *)tysm_hmacSHA384StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding]
            tysm_hmacSHA384StringWithKey:key];
}

- (NSString *)tysm_hmacSHA512StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding]
            tysm_hmacSHA512StringWithKey:key];
}

- (NSString *)tysm_base64EncodedString {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] tysm_base64EncodedString];
}

+ (NSString *)stringWithBase64EncodedString:(NSString *)base64EncodedString {
    NSData *data = [NSData dataWithBase64EncodedString:base64EncodedString];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSString *)tysm_stringByURLEncode {
    if ([self respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
        /**
         AFNetworking/AFURLRequestSerialization.m
         
         Returns a percent-escaped string following RFC 3986 for a query string key or value.
         RFC 3986 states that the following characters are "reserved" characters.
            - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
            - Sub-Delimiters: "!", "$", "&", "'", "(", ")tysm_", "*", "+", ",", ";", "="
         In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
         query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
         should be percent-escaped in the query string.
            - parameter string: The string to be percent-escaped.
            - returns: The percent-escaped string.
         */
        static NSString * const kAFCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
        static NSString * const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
        
        NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
        [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];
        static NSUInteger const batchSize = 50;
        
        NSUInteger index = 0;
        NSMutableString *escaped = @"".mutableCopy;
        
        while (index < self.length) {
            NSUInteger length = MIN(self.length - index, batchSize);
            NSRange range = NSMakeRange(index, length);
            // To avoid breaking up character sequences such as 👴🏻👮🏽
            range = [self rangeOfComposedCharacterSequencesForRange:range];
            NSString *substring = [self substringWithRange:range];
            NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
            [escaped appendString:encoded];
            
            index += range.length;
        }
        return escaped;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CFStringEncoding cfEncoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
        NSString *encoded = (__bridge_transfer NSString *)
        CFURLCreateStringByAddingPercentEscapes(
                                                kCFAllocatorDefault,
                                                (__bridge CFStringRef)self,
                                                NULL,
                                                CFSTR("!#$&'()*+,/:;=?@[]"),
                                                cfEncoding);
        return encoded;
#pragma clang diagnostic pop
    }
}

- (NSString *)tysm_stringByURLDecode {
    if ([self respondsToSelector:@selector(stringByRemovingPercentEncoding)]) {
        return [self stringByRemovingPercentEncoding];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CFStringEncoding en = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
        NSString *decoded = [self stringByReplacingOccurrencesOfString:@"+"
                                                            withString:@" "];
        decoded = (__bridge_transfer NSString *)
        CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
                                                                NULL,
                                                                (__bridge CFStringRef)decoded,
                                                                CFSTR(""),
                                                                en);
        return decoded;
#pragma clang diagnostic pop
    }
}

- (NSString *)tysm_stringByEscapingHTML {
    NSUInteger len = self.length;
    if (!len) return self;
    
    unichar *buf = malloc(sizeof(unichar) * len);
    if (!buf) return self;
    [self getCharacters:buf range:NSMakeRange(0, len)];
    
    NSMutableString *result = [NSMutableString string];
    for (int i = 0; i < len; i++) {
        unichar c = buf[i];
        NSString *esc = nil;
        switch (c) {
            case 34: esc = @"&quot;"; break;
            case 38: esc = @"&amp;"; break;
            case 39: esc = @"&apos;"; break;
            case 60: esc = @"&lt;"; break;
            case 62: esc = @"&gt;"; break;
            default: break;
        }
        if (esc) {
            [result appendString:esc];
        } else {
            CFStringAppendCharacters((CFMutableStringRef)result, &c, 1);
        }
    }
    free(buf);
    return result;
}

- (CGSize)tysm_sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode {
    CGSize result;
    if (!font) font = [UIFont systemFontOfSize:12];
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableDictionary *attr = [NSMutableDictionary new];
        attr[NSFontAttributeName] = font;
        if (lineBreakMode != NSLineBreakByWordWrapping) {
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.lineBreakMode = lineBreakMode;
            attr[NSParagraphStyleAttributeName] = paragraphStyle;
        }
        CGRect rect = [self boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attr context:nil];
        result = rect.size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        result = [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
    }
    return result;
}

- (CGFloat)tysm_widthForFont:(UIFont *)font {
    CGSize size = [self tysm_sizeForFont:font size:CGSizeMake(HUGE, HUGE) mode:NSLineBreakByWordWrapping];
    return size.width;
}

- (CGFloat)tysm_heightForFont:(UIFont *)font width:(CGFloat)width {
    CGSize size = [self tysm_sizeForFont:font size:CGSizeMake(width, HUGE) mode:NSLineBreakByWordWrapping];
    return size.height;
}

- (BOOL)tysm_matchesRegex:(NSString *)regex options:(NSRegularExpressionOptions)options {
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:NULL];
    if (!pattern) return NO;
    return ([pattern numberOfMatchesInString:self options:0 range:NSMakeRange(0, self.length)] > 0);
}

- (void)tysm_enumerateRegexMatches:(NSString *)regex
                      options:(NSRegularExpressionOptions)options
                   usingBlock:(void (^)(NSString *match, NSRange matchRange, BOOL *stop))block {
    if (regex.length == 0 || !block) return;
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:nil];
    if (!regex) return;
    [pattern enumerateMatchesInString:self options:kNilOptions range:NSMakeRange(0, self.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        block([self substringWithRange:result.range], result.range, stop);
    }];
}

- (NSString *)tysm_stringByReplacingRegex:(NSString *)regex
                             options:(NSRegularExpressionOptions)options
                          withString:(NSString *)replacement; {
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:nil];
    if (!pattern) return self;
    return [pattern stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:replacement];
}

- (char)tysm_charValue {
    return self.tysm_numberValue.charValue;
}

- (unsigned char)tysm_unsignedCharValue {
    return self.tysm_numberValue.unsignedCharValue;
}

- (short)tysm_shortValue {
    return self.tysm_numberValue.shortValue;
}

- (unsigned short)tysm_unsignedShortValue {
    return self.tysm_numberValue.unsignedShortValue;
}

- (unsigned int)tysm_unsignedIntValue {
    return self.tysm_numberValue.unsignedIntValue;
}

- (long)tysm_longValue {
    return self.tysm_numberValue.longValue;
}

- (unsigned long)tysm_unsignedLongValue {
    return self.tysm_numberValue.unsignedLongValue;
}

- (unsigned long long)tysm_unsignedLongLongValue {
    return self.tysm_numberValue.unsignedLongLongValue;
}

- (NSUInteger)tysm_unsignedIntegerValue {
    return self.tysm_numberValue.unsignedIntegerValue;
}


+ (NSString *)tysm_stringWithUUID {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return (__bridge_transfer NSString *)string;
}

+ (NSString *)tysm_stringWithUTF32Char:(UTF32Char)char32 {
    char32 = NSSwapHostIntToLittle(char32);
    return [[NSString alloc] initWithBytes:&char32 length:4 encoding:NSUTF32LittleEndianStringEncoding];
}

+ (NSString *)tysm_stringWithUTF32Chars:(const UTF32Char *)char32 length:(NSUInteger)length {
    return [[NSString alloc] initWithBytes:(const void *)char32
                                    length:length * 4
                                  encoding:NSUTF32LittleEndianStringEncoding];
}

- (void)tysm_enumerateUTF32CharInRange:(NSRange)range usingBlock:(void (^)(UTF32Char char32, NSRange range, BOOL *stop))block {
    NSString *str = self;
    if (range.location != 0 || range.length != self.length) {
        str = [self substringWithRange:range];
    }
    NSUInteger len = [str lengthOfBytesUsingEncoding:NSUTF32StringEncoding] / 4;
    UTF32Char *char32 = (UTF32Char *)[str cStringUsingEncoding:NSUTF32LittleEndianStringEncoding];
    if (len == 0 || char32 == NULL) return;
    
    NSUInteger location = 0;
    BOOL stop = NO;
    NSRange subRange;
    UTF32Char oneChar;
    
    for (NSUInteger i = 0; i < len; i++) {
        oneChar = char32[i];
        subRange = NSMakeRange(location, oneChar > 0xFFFF ? 2 : 1);
        block(oneChar, subRange, &stop);
        if (stop) return;
        location += subRange.length;
    }
}

- (NSString *)tysm_stringByTrim {
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [self stringByTrimmingCharactersInSet:set];
}

- (NSString *)tysm_stringByAppendingNameScale:(CGFloat)scale {
    if (fabs(scale - 1)<= __FLT_EPSILON__ || self.length == 0 || [self hasSuffix:@"/"]) return self.copy;
    return [self stringByAppendingFormat:@"@%@x", @(scale)];
}

- (NSString *)tysm_stringByAppendingPathScale:(CGFloat)scale {
    if (fabs(scale - 1)<= __FLT_EPSILON__ || self.length == 0 || [self hasSuffix:@"/"]) return self.copy;
    NSString *ext = self.pathExtension;
    NSRange extRange = NSMakeRange(self.length - ext.length, 0);
    if (ext.length > 0) extRange.location -= 1;
    NSString *scaleStr = [NSString stringWithFormat:@"@%@x", @(scale)];
    return [self stringByReplacingCharactersInRange:extRange withString:scaleStr];
}

- (CGFloat)tysm_pathScale {
    if (self.length == 0 || [self hasSuffix:@"/"]) return 1;
    NSString *name = self.stringByDeletingPathExtension;
    __block CGFloat scale = 1;
    [name tysm_enumerateRegexMatches:@"@[0-9]+\\.?[0-9]*x$" options:NSRegularExpressionAnchorsMatchLines usingBlock: ^(NSString *match, NSRange matchRange, BOOL *stop) {
        scale = [match substringWithRange:NSMakeRange(1, match.length - 2)].doubleValue;
    }];
    return scale;
}

- (BOOL)tysm_isNotBlank {
    NSCharacterSet *blank = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    for (NSInteger i = 0; i < self.length; ++i) {
        unichar c = [self characterAtIndex:i];
        if (![blank characterIsMember:c]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)tysm_containsString:(NSString *)string {
    if (string == nil) return NO;
    return [self rangeOfString:string].location != NSNotFound;
}

- (BOOL)tysm_containsCharacterSet:(NSCharacterSet *)set {
    if (set == nil) return NO;
    return [self rangeOfCharacterFromSet:set].location != NSNotFound;
}

- (NSNumber *)tysm_numberValue {
    return [NSNumber numberWithString:self];
}

- (NSData *)tysm_dataValue {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSRange)tysm_rangeOfAll {
    return NSMakeRange(0, self.length);
}

- (id)tysm_jsonValueDecoded {
    return [[self tysm_dataValue] tysm_jsonValueDecoded];
}

+ (NSString *)tysm_stringNamed:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@""];
    NSString *str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    if (!str) {
        path = [[NSBundle mainBundle] pathForResource:name ofType:@"txt"];
        str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    }
    return str;
}

@end
