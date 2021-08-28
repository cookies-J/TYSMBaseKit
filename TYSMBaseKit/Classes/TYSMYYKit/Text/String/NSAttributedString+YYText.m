//
//  NSAttributedString+YYText.m
//  YYKit <https://github.com/ibireme/YYKit>
//
//  Created by ibireme on 14/10/7.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "NSAttributedString+YYText.h"
#import "YYKitMacro.h"
#import "UIDevice+TYSMAdd.h"
#import "UIFont+TYSMAdd.h"
#import "NSParagraphStyle+YYText.h"
#import "TYSMTextArchiver.h"
#import "YYTextRunDelegate.h"
#import "TYSM_AnimatedImageView.h"
#import "YYTextUtilities.h"
#import <CoreFoundation/CoreFoundation.h>

YYSYNTH_DUMMY_CLASS(NSAttributedString_YYText)


@implementation NSAttributedString (TYSMText)

- (NSData *)tysm_archiveToData {
    NSData *data = nil;
    @try {
        data = [TYSMTextArchiver archivedDataWithRootObject:self];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    return data;
}

+ (instancetype)tysm_unarchiveFromData:(NSData *)data {
    NSAttributedString *one = nil;
    @try {
        one = [TYSMTextUnarchiver unarchiveObjectWithData:data];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    return one;
}

- (NSDictionary *)tysm_attributesAtIndex:(NSUInteger)index {
    if (index > self.length || self.length == 0) return nil;
    if (self.length > 0 && index == self.length) index--;
    return [self attributesAtIndex:index effectiveRange:NULL];
}

- (id)tysm_attribute:(NSString *)attributeName atIndex:(NSUInteger)index {
    if (!attributeName) return nil;
    if (index > self.length || self.length == 0) return nil;
    if (self.length > 0 && index == self.length) index--;
    return [self attribute:attributeName atIndex:index effectiveRange:NULL];
}

- (NSDictionary *)tysm_attributes {
    return [self tysm_attributesAtIndex:0];
}

- (UIFont *)tysm_font {
    return [self tysm_fontAtIndex:0];
}

- (UIFont *)tysm_fontAtIndex:(NSUInteger)index {
    /*
     In iOS7 and later, UIFont is toll-free bridged to CTFontRef,
     although Apple does not mention it in documentation.
     
     In iOS6, UIFont is a wrapper for CTFontRef, so CoreText can alse use UIfont,
     but UILabel/UITextView cannot use CTFontRef.
     
     We use UIFont for both CoreText and UIKit.
     */
    UIFont *font = [self tysm_attribute:NSFontAttributeName atIndex:index];
    if (kTYSMSystemVersion <= 6) {
        if (font) {
            if (CFGetTypeID((__bridge CFTypeRef)(font)) == CTFontGetTypeID()) {
                font = [UIFont tysm_fontWithCTFont:(CTFontRef)font];
            }
        }
    }
    return font;
}

- (NSNumber *)tysm_kern {
    return [self tysm_kernAtIndex:0];
}

- (NSNumber *)tysm_kernAtIndex:(NSUInteger)index {
    return [self tysm_attribute:NSKernAttributeName atIndex:index];
}

- (UIColor *)tysm_color {
    return [self tysm_colorAtIndex:0];
}

- (UIColor *)tysm_colorAtIndex:(NSUInteger)index {
    UIColor *color = [self tysm_attribute:NSForegroundColorAttributeName atIndex:index];
    if (!color) {
        CGColorRef ref = (__bridge CGColorRef)([self tysm_attribute:(NSString *)kCTForegroundColorAttributeName atIndex:index]);
        color = [UIColor colorWithCGColor:ref];
    }
    if (color && ![color isKindOfClass:[UIColor class]]) {
        if (CFGetTypeID((__bridge CFTypeRef)(color)) == CGColorGetTypeID()) {
            color = [UIColor colorWithCGColor:(__bridge CGColorRef)(color)];
        } else {
            color = nil;
        }
    }
    return color;
}

- (UIColor *)tysm_backgroundColor {
    return [self tysm_backgroundColorAtIndex:0];
}

- (UIColor *)tysm_backgroundColorAtIndex:(NSUInteger)index {
    return [self tysm_attribute:NSBackgroundColorAttributeName atIndex:index];
}

- (NSNumber *)tysm_strokeWidth {
    return [self tysm_strokeWidthAtIndex:0];
}

- (NSNumber *)tysm_strokeWidthAtIndex:(NSUInteger)index {
    return [self tysm_attribute:NSStrokeWidthAttributeName atIndex:index];
}

- (UIColor *)tysm_strokeColor {
    return [self tysm_strokeColorAtIndex:0];
}

- (UIColor *)tysm_strokeColorAtIndex:(NSUInteger)index {
    UIColor *color = [self tysm_attribute:NSStrokeColorAttributeName atIndex:index];
    if (!color) {
        CGColorRef ref = (__bridge CGColorRef)([self tysm_attribute:(NSString *)kCTStrokeColorAttributeName atIndex:index]);
        color = [UIColor colorWithCGColor:ref];
    }
    return color;
}

- (NSShadow *)tysm_shadow {
    return [self tysm_shadowAtIndex:0];
}

- (NSShadow *)tysm_shadowAtIndex:(NSUInteger)index {
    return [self tysm_attribute:NSShadowAttributeName atIndex:index];
}

- (NSUnderlineStyle)tysm_strikethroughStyle {
    return [self tysm_strikethroughStyleAtIndex:0];
}

- (NSUnderlineStyle)tysm_strikethroughStyleAtIndex:(NSUInteger)index {
    NSNumber *style = [self tysm_attribute:NSStrikethroughStyleAttributeName atIndex:index];
    return style.integerValue;
}

- (UIColor *)tysm_strikethroughColor {
    return [self tysm_strikethroughColorAtIndex:0];
}

- (UIColor *)tysm_strikethroughColorAtIndex:(NSUInteger)index {
    if (kTYSMSystemVersion >= 7) {
        return [self tysm_attribute:NSStrikethroughColorAttributeName atIndex:index];
    }
    return nil;
}

- (NSUnderlineStyle)tysm_underlineStyle {
    return [self tysm_underlineStyleAtIndex:0];
}

- (NSUnderlineStyle)tysm_underlineStyleAtIndex:(NSUInteger)index {
    NSNumber *style = [self tysm_attribute:NSUnderlineStyleAttributeName atIndex:index];
    return style.integerValue;
}

- (UIColor *)tysm_underlineColor {
    return [self tysm_underlineColorAtIndex:0];
}

- (UIColor *)tysm_underlineColorAtIndex:(NSUInteger)index {
    UIColor *color = nil;
    if (kTYSMSystemVersion >= 7) {
        color = [self tysm_attribute:NSUnderlineColorAttributeName atIndex:index];
    }
    if (!color) {
        CGColorRef ref = (__bridge CGColorRef)([self tysm_attribute:(NSString *)kCTUnderlineColorAttributeName atIndex:index]);
        color = [UIColor colorWithCGColor:ref];
    }
    return color;
}

- (NSNumber *)tysm_ligature {
    return [self tysm_ligatureAtIndex:0];
}

- (NSNumber *)tysm_ligatureAtIndex:(NSUInteger)index {
    return [self tysm_attribute:NSLigatureAttributeName atIndex:index];
}

- (NSString *)tysm_textEffect {
    return [self tysm_textEffectAtIndex:0];
}

- (NSString *)tysm_textEffectAtIndex:(NSUInteger)index {
    if (kTYSMSystemVersion >= 7) {
        return [self tysm_attribute:NSTextEffectAttributeName atIndex:index];
    }
    return nil;
}

- (NSNumber *)tysm_obliqueness {
    return [self tysm_obliquenessAtIndex:0];
}

- (NSNumber *)tysm_obliquenessAtIndex:(NSUInteger)index {
    if (kTYSMSystemVersion >= 7) {
        return [self tysm_attribute:NSObliquenessAttributeName atIndex:index];
    }
    return nil;
}

- (NSNumber *)tysm_expansion {
    return [self tysm_expansionAtIndex:0];
}

- (NSNumber *)tysm_expansionAtIndex:(NSUInteger)index {
    if (kTYSMSystemVersion >= 7) {
        return [self tysm_attribute:NSExpansionAttributeName atIndex:index];
    }
    return nil;
}

- (NSNumber *)tysm_baselineOffset {
    return [self tysm_baselineOffsetAtIndex:0];
}

- (NSNumber *)tysm_baselineOffsetAtIndex:(NSUInteger)index {
    if (kTYSMSystemVersion >= 7) {
        return [self tysm_attribute:NSBaselineOffsetAttributeName atIndex:index];
    }
    return nil;
}

- (BOOL)tysm_verticalGlyphForm {
    return [self tysm_verticalGlyphFormAtIndex:0];
}

- (BOOL)tysm_verticalGlyphFormAtIndex:(NSUInteger)index {
    NSNumber *num = [self tysm_attribute:NSVerticalGlyphFormAttributeName atIndex:index];
    return num.boolValue;
}

- (NSString *)language {
    return [self languageAtIndex:0];
}

- (NSString *)languageAtIndex:(NSUInteger)index {
    if (kTYSMSystemVersion >= 7) {
        return [self tysm_attribute:(id)kCTLanguageAttributeName atIndex:index];
    }
    return nil;
}

- (NSArray *)writingDirection {
    return [self writingDirectionAtIndex:0];
}

- (NSArray *)writingDirectionAtIndex:(NSUInteger)index {
    return [self tysm_attribute:(id)kCTWritingDirectionAttributeName atIndex:index];
}

- (NSParagraphStyle *)paragraphStyle {
    return [self paragraphStyleAtIndex:0];
}

- (NSParagraphStyle *)paragraphStyleAtIndex:(NSUInteger)index {
    /*
     NSParagraphStyle is NOT toll-free bridged to CTParagraphStyleRef.
     
     CoreText can use both NSParagraphStyle and CTParagraphStyleRef,
     but UILabel/UITextView can only use NSParagraphStyle.
     
     We use NSParagraphStyle in both CoreText and UIKit.
     */
    NSParagraphStyle *style = [self tysm_attribute:NSParagraphStyleAttributeName atIndex:index];
    if (style) {
        if (CFGetTypeID((__bridge CFTypeRef)(style)) == CTParagraphStyleGetTypeID()) { \
            style = [NSParagraphStyle styleWithCTStyle:(__bridge CTParagraphStyleRef)(style)];
        }
    }
    return style;
}

#define ParagraphAttribute(_attr_) \
NSParagraphStyle *style = self.paragraphStyle; \
if (!style) style = [NSParagraphStyle defaultParagraphStyle]; \
return style. _attr_;

#define ParagraphAttributeAtIndex(_attr_) \
NSParagraphStyle *style = [self paragraphStyleAtIndex:index]; \
if (!style) style = [NSParagraphStyle defaultParagraphStyle]; \
return style. _attr_;

- (NSTextAlignment)alignment {
    ParagraphAttribute(alignment);
}

- (NSLineBreakMode)lineBreakMode {
    ParagraphAttribute(lineBreakMode);
}

- (CGFloat)lineSpacing {
    ParagraphAttribute(lineSpacing);
}

- (CGFloat)paragraphSpacing {
    ParagraphAttribute(paragraphSpacing);
}

- (CGFloat)paragraphSpacingBefore {
    ParagraphAttribute(paragraphSpacingBefore);
}

- (CGFloat)firstLineHeadIndent {
    ParagraphAttribute(firstLineHeadIndent);
}

- (CGFloat)headIndent {
    ParagraphAttribute(headIndent);
}

- (CGFloat)tailIndent {
    ParagraphAttribute(tailIndent);
}

- (CGFloat)minimumLineHeight {
    ParagraphAttribute(minimumLineHeight);
}

- (CGFloat)maximumLineHeight {
    ParagraphAttribute(maximumLineHeight);
}

- (CGFloat)lineHeightMultiple {
    ParagraphAttribute(lineHeightMultiple);
}

- (NSWritingDirection)baseWritingDirection {
    ParagraphAttribute(baseWritingDirection);
}

- (float)hyphenationFactor {
    ParagraphAttribute(hyphenationFactor);
}

- (CGFloat)defaultTabInterval {
    if (!kTYSM_iOS7Later) return 0;
    ParagraphAttribute(defaultTabInterval);
}

- (NSArray *)tabStops {
    if (!kTYSM_iOS7Later) return nil;
    ParagraphAttribute(tabStops);
}

- (NSTextAlignment)alignmentAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(alignment);
}

- (NSLineBreakMode)lineBreakModeAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(lineBreakMode);
}

- (CGFloat)lineSpacingAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(lineSpacing);
}

- (CGFloat)paragraphSpacingAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(paragraphSpacing);
}

- (CGFloat)paragraphSpacingBeforeAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(paragraphSpacingBefore);
}

- (CGFloat)firstLineHeadIndentAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(firstLineHeadIndent);
}

- (CGFloat)headIndentAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(headIndent);
}

- (CGFloat)tailIndentAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(tailIndent);
}

- (CGFloat)minimumLineHeightAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(minimumLineHeight);
}

- (CGFloat)maximumLineHeightAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(maximumLineHeight);
}

- (CGFloat)lineHeightMultipleAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(lineHeightMultiple);
}

- (NSWritingDirection)baseWritingDirectionAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(baseWritingDirection);
}

- (float)hyphenationFactorAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(hyphenationFactor);
}

- (CGFloat)defaultTabIntervalAtIndex:(NSUInteger)index {
    if (!kTYSM_iOS7Later) return 0;
    ParagraphAttributeAtIndex(defaultTabInterval);
}

- (NSArray *)tabStopsAtIndex:(NSUInteger)index {
    if (!kTYSM_iOS7Later) return nil;
    ParagraphAttributeAtIndex(tabStops);
}

#undef ParagraphAttribute
#undef ParagraphAttributeAtIndex

- (TYSMTextShadow *)textShadow {
    return [self textShadowAtIndex:0];
}

- (TYSMTextShadow *)textShadowAtIndex:(NSUInteger)index {
    return [self tysm_attribute:TYSMTextShadowAttributeName atIndex:index];
}

- (TYSMTextShadow *)textInnerShadow {
    return [self textInnerShadowAtIndex:0];
}

- (TYSMTextShadow *)textInnerShadowAtIndex:(NSUInteger)index {
    return [self tysm_attribute:TYSMTextInnerShadowAttributeName atIndex:index];
}

- (TYSMTextDecoration *)textUnderline {
    return [self textUnderlineAtIndex:0];
}

- (TYSMTextDecoration *)textUnderlineAtIndex:(NSUInteger)index {
    return [self tysm_attribute:TYSMTextUnderlineAttributeName atIndex:index];
}

- (TYSMTextDecoration *)textStrikethrough {
    return [self textStrikethroughAtIndex:0];
}

- (TYSMTextDecoration *)textStrikethroughAtIndex:(NSUInteger)index {
    return [self tysm_attribute:TYSMTextStrikethroughAttributeName atIndex:index];
}

- (TYSMTextBorder *)textBorder {
    return [self textBorderAtIndex:0];
}

- (TYSMTextBorder *)textBorderAtIndex:(NSUInteger)index {
    return [self tysm_attribute:TYSMTextBorderAttributeName atIndex:index];
}

- (TYSMTextBorder *)textBackgroundBorder {
    return [self textBackgroundBorderAtIndex:0];
}

- (TYSMTextBorder *)textBackgroundBorderAtIndex:(NSUInteger)index {
    return [self tysm_attribute:TYSMTextBackedStringAttributeName atIndex:index];
}

- (CGAffineTransform)textGlyphTransform {
    return [self textGlyphTransformAtIndex:0];
}

- (CGAffineTransform)textGlyphTransformAtIndex:(NSUInteger)index {
    NSValue *value = [self tysm_attribute:TYSMTextGlyphTransformAttributeName atIndex:index];
    if (!value) return CGAffineTransformIdentity;
    return [value CGAffineTransformValue];
}

- (NSString *)plainTextForRange:(NSRange)range {
    if (range.location == NSNotFound ||range.length == NSNotFound) return nil;
    NSMutableString *result = [NSMutableString string];
    if (range.length == 0) return result;
    NSString *string = self.string;
    [self enumerateAttribute:TYSMTextBackedStringAttributeName inRange:range options:kNilOptions usingBlock:^(id value, NSRange range, BOOL *stop) {
        TYSMTextBackedString *backed = value;
        if (backed && backed.string) {
            [result appendString:backed.string];
        } else {
            [result appendString:[string substringWithRange:range]];
        }
    }];
    return result;
}

+ (NSMutableAttributedString *)attachmentStringWithContent:(id)content
                                               contentMode:(UIViewContentMode)contentMode
                                                     width:(CGFloat)width
                                                    ascent:(CGFloat)ascent
                                                   descent:(CGFloat)descent {
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:TYSMTextAttachmentToken];
    
    TYSMTextAttachment *attach = [TYSMTextAttachment new];
    attach.content = content;
    attach.contentMode = contentMode;
    [atr setTextAttachment:attach range:NSMakeRange(0, atr.length)];
    
    YYTextRunDelegate *delegate = [YYTextRunDelegate new];
    delegate.width = width;
    delegate.ascent = ascent;
    delegate.descent = descent;
    CTRunDelegateRef delegateRef = delegate.CTRunDelegate;
    [atr setRunDelegate:delegateRef range:NSMakeRange(0, atr.length)];
    if (delegate) CFRelease(delegateRef);
    
    return atr;
}

+ (NSMutableAttributedString *)attachmentStringWithContent:(id)content
                                               contentMode:(UIViewContentMode)contentMode
                                            attachmentSize:(CGSize)attachmentSize
                                               alignToFont:(UIFont *)font
                                                 alignment:(TYSMTextVerticalAlignment)alignment {
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:TYSMTextAttachmentToken];
    
    TYSMTextAttachment *attach = [TYSMTextAttachment new];
    attach.content = content;
    attach.contentMode = contentMode;
    [atr setTextAttachment:attach range:NSMakeRange(0, atr.length)];
    
    YYTextRunDelegate *delegate = [YYTextRunDelegate new];
    delegate.width = attachmentSize.width;
    switch (alignment) {
        case TYSMTextVerticalAlignmentTop: {
            delegate.ascent = font.ascender;
            delegate.descent = attachmentSize.height - font.ascender;
            if (delegate.descent < 0) {
                delegate.descent = 0;
                delegate.ascent = attachmentSize.height;
            }
        } break;
        case TYSMTextVerticalAlignmentCenter: {
            CGFloat fontHeight = font.ascender - font.descender;
            CGFloat yOffset = font.ascender - fontHeight * 0.5;
            delegate.ascent = attachmentSize.height * 0.5 + yOffset;
            delegate.descent = attachmentSize.height - delegate.ascent;
            if (delegate.descent < 0) {
                delegate.descent = 0;
                delegate.ascent = attachmentSize.height;
            }
        } break;
        case TYSMTextVerticalAlignmentBottom: {
            delegate.ascent = attachmentSize.height + font.descender;
            delegate.descent = -font.descender;
            if (delegate.ascent < 0) {
                delegate.ascent = 0;
                delegate.descent = attachmentSize.height;
            }
        } break;
        default: {
            delegate.ascent = attachmentSize.height;
            delegate.descent = 0;
        } break;
    }
    
    CTRunDelegateRef delegateRef = delegate.CTRunDelegate;
    [atr setRunDelegate:delegateRef range:NSMakeRange(0, atr.length)];
    if (delegate) CFRelease(delegateRef);
    
    return atr;
}

+ (NSMutableAttributedString *)attachmentStringWithEmojiImage:(UIImage *)image
                                                     fontSize:(CGFloat)fontSize {
    if (!image || fontSize <= 0) return nil;
    
    BOOL hasAnim = NO;
    if (image.images.count > 1) {
        hasAnim = YES;
    } else if ([image conformsToProtocol:@protocol(TYSMAnimatedImage)]) {
        id <TYSMAnimatedImage> ani = (id)image;
        if (ani.animatedImageFrameCount > 1) hasAnim = YES;
    }
    
    CGFloat ascent = TYSMEmojiGetAscentWithFontSize(fontSize);
    CGFloat descent = TYSMEmojiGetDescentWithFontSize(fontSize);
    CGRect bounding = TYSMEmojiGetGlyphBoundingRectWithFontSize(fontSize);
    
    YYTextRunDelegate *delegate = [YYTextRunDelegate new];
    delegate.ascent = ascent;
    delegate.descent = descent;
    delegate.width = bounding.size.width + 2 * bounding.origin.x;
    
    TYSMTextAttachment *attachment = [TYSMTextAttachment new];
    attachment.contentMode = UIViewContentModeScaleAspectFit;
    attachment.contentInsets = UIEdgeInsetsMake(ascent - (bounding.size.height + bounding.origin.y), bounding.origin.x, descent + bounding.origin.y, bounding.origin.x);
    if (hasAnim) {
        TYSM_AnimatedImageView *view = [TYSM_AnimatedImageView new];
        view.frame = bounding;
        view.image = image;
        view.contentMode = UIViewContentModeScaleAspectFit;
        attachment.content = view;
    } else {
        attachment.content = image;
    }
    
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:TYSMTextAttachmentToken];
    [atr setTextAttachment:attachment range:NSMakeRange(0, atr.length)];
    CTRunDelegateRef ctDelegate = delegate.CTRunDelegate;
    [atr setRunDelegate:ctDelegate range:NSMakeRange(0, atr.length)];
    if (ctDelegate) CFRelease(ctDelegate);
    
    return atr;
}

- (NSRange)rangeOfAll {
    return NSMakeRange(0, self.length);
}

- (BOOL)isSharedAttributesInAllRange {
    __block BOOL shared = YES;
    __block NSDictionary *firstAttrs = nil;
    [self enumerateAttributesInRange:self.rangeOfAll options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        if (range.location == 0) {
            firstAttrs = attrs;
        } else {
            if (firstAttrs.count != attrs.count) {
                shared = NO;
                *stop = YES;
            } else if (firstAttrs) {
                if (![firstAttrs isEqualToDictionary:attrs]) {
                    shared = NO;
                    *stop = YES;
                }
            }
        }
    }];
    return shared;
}

- (BOOL)canDrawWithUIKit {
    static NSMutableSet *failSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        failSet = [NSMutableSet new];
        [failSet addObject:(id)kCTGlyphInfoAttributeName];
        [failSet addObject:(id)kCTCharacterShapeAttributeName];
        if (kTYSM_iOS7Later) {
            [failSet addObject:(id)kCTLanguageAttributeName];
        }
        [failSet addObject:(id)kCTRunDelegateAttributeName];
        [failSet addObject:(id)kCTBaselineClassAttributeName];
        [failSet addObject:(id)kCTBaselineInfoAttributeName];
        [failSet addObject:(id)kCTBaselineReferenceInfoAttributeName];
        if (kTYSM_iOS8Later) {
            [failSet addObject:(id)kCTRubyAnnotationAttributeName];
        }
        [failSet addObject:TYSMTextShadowAttributeName];
        [failSet addObject:TYSMTextInnerShadowAttributeName];
        [failSet addObject:TYSMTextUnderlineAttributeName];
        [failSet addObject:TYSMTextStrikethroughAttributeName];
        [failSet addObject:TYSMTextBorderAttributeName];
        [failSet addObject:TYSMTextBackgroundBorderAttributeName];
        [failSet addObject:TYSMTextBlockBorderAttributeName];
        [failSet addObject:TYSMTextAttachmentAttributeName];
        [failSet addObject:TYSMTextHighlightAttributeName];
        [failSet addObject:TYSMTextGlyphTransformAttributeName];
    });
    
#define Fail { result = NO; *stop = YES; return; }
    __block BOOL result = YES;
    [self enumerateAttributesInRange:self.rangeOfAll options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        if (attrs.count == 0) return;
        for (NSString *str in attrs.allKeys) {
            if ([failSet containsObject:str]) Fail;
        }
        if (!kTYSM_iOS7Later) {
            UIFont *font = attrs[NSFontAttributeName];
            if (CFGetTypeID((__bridge CFTypeRef)(font)) == CTFontGetTypeID()) Fail;
        }
        if (attrs[(id)kCTForegroundColorAttributeName] && !attrs[NSForegroundColorAttributeName]) Fail;
        if (attrs[(id)kCTStrokeColorAttributeName] && !attrs[NSStrokeColorAttributeName]) Fail;
        if (attrs[(id)kCTUnderlineColorAttributeName]) {
            if (!kTYSM_iOS7Later) Fail;
            if (!attrs[NSUnderlineColorAttributeName]) Fail;
        }
        NSParagraphStyle *style = attrs[NSParagraphStyleAttributeName];
        if (style && CFGetTypeID((__bridge CFTypeRef)(style)) == CTParagraphStyleGetTypeID()) Fail;
    }];
    return result;
#undef Fail
}

@end

@implementation NSMutableAttributedString (YYText)

- (void)setTysm_attributes:(NSDictionary *)attributes {
    if (attributes == (id)[NSNull null]) attributes = nil;
    [self setAttributes:@{} range:NSMakeRange(0, self.length)];
    [attributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setTysm_attribute:key value:obj];
    }];
}

- (void)setTysm_attribute:(NSString *)name value:(id)value {
    [self setTysm_attribute:name value:value range:NSMakeRange(0, self.length)];
}

- (void)setTysm_attribute:(NSString *)name value:(id)value range:(NSRange)range {
    if (!name || [NSNull isEqual:name]) return;
    if (value && ![NSNull isEqual:value]) [self addAttribute:name value:value range:range];
    else [self removeAttribute:name range:range];
}

- (void)tysm_removeAttributesInRange:(NSRange)range {
    [self setAttributes:nil range:range];
}

#pragma mark - Property Setter

- (void)setTysm_font:(UIFont *)font {
    /*
     In iOS7 and later, UIFont is toll-free bridged to CTFontRef,
     although Apple does not mention it in documentation.
     
     In iOS6, UIFont is a wrapper for CTFontRef, so CoreText can alse use UIfont,
     but UILabel/UITextView cannot use CTFontRef.
     
     We use UIFont for both CoreText and UIKit.
     */
    [self tysm_setFont:font range:NSMakeRange(0, self.length)];
}

- (void)setTysm_kern:(NSNumber *)kern {
    [self tysm_setKern:kern range:NSMakeRange(0, self.length)];
}

- (void)setTysm_color:(UIColor *)color {
    [self tysm_setColor:color range:NSMakeRange(0, self.length)];
}

- (void)setTysm_backgroundColor:(UIColor *)backgroundColor {
    [self tysm_setBackgroundColor:backgroundColor range:NSMakeRange(0, self.length)];
}

- (void)setTysm_strokeWidth:(NSNumber *)strokeWidth {
    [self tysm_setStrokeWidth:strokeWidth range:NSMakeRange(0, self.length)];
}

- (void)setTysm_strokeColor:(UIColor *)strokeColor {
    [self tysm_setStrokeColor:strokeColor range:NSMakeRange(0, self.length)];
}

- (void)setTysm_shadow:(NSShadow *)shadow {
    [self tysm_setShadow:shadow range:NSMakeRange(0, self.length)];
}

- (void)setTysm_strikethroughStyle:(NSUnderlineStyle)strikethroughStyle {
    [self tysm_setStrikethroughStyle:strikethroughStyle range:NSMakeRange(0, self.length)];
}

- (void)setTysm_strikethroughColor:(UIColor *)strikethroughColor {
    [self setStrikethroughColor:strikethroughColor range:NSMakeRange(0, self.length)];
}

- (void)setUnderlineStyle:(NSUnderlineStyle)underlineStyle {
    [self setUnderlineStyle:underlineStyle range:NSMakeRange(0, self.length)];
}

- (void)setUnderlineColor:(UIColor *)underlineColor {
    [self setUnderlineColor:underlineColor range:NSMakeRange(0, self.length)];
}

- (void)setLigature:(NSNumber *)ligature {
    [self setLigature:ligature range:NSMakeRange(0, self.length)];
}

- (void)setTextEffect:(NSString *)textEffect {
    [self setTextEffect:textEffect range:NSMakeRange(0, self.length)];
}

- (void)setObliqueness:(NSNumber *)obliqueness {
    [self setObliqueness:obliqueness range:NSMakeRange(0, self.length)];
}

- (void)setExpansion:(NSNumber *)expansion {
    [self setExpansion:expansion range:NSMakeRange(0, self.length)];
}

- (void)setBaselineOffset:(NSNumber *)baselineOffset {
    [self setBaselineOffset:baselineOffset range:NSMakeRange(0, self.length)];
}

- (void)setVerticalGlyphForm:(BOOL)verticalGlyphForm {
    [self setVerticalGlyphForm:verticalGlyphForm range:NSMakeRange(0, self.length)];
}

- (void)setLanguage:(NSString *)language {
    [self setLanguage:language range:NSMakeRange(0, self.length)];
}

- (void)setWritingDirection:(NSArray *)writingDirection {
    [self setWritingDirection:writingDirection range:NSMakeRange(0, self.length)];
}

- (void)setParagraphStyle:(NSParagraphStyle *)paragraphStyle {
    /*
     NSParagraphStyle is NOT toll-free bridged to CTParagraphStyleRef.
     
     CoreText can use both NSParagraphStyle and CTParagraphStyleRef,
     but UILabel/UITextView can only use NSParagraphStyle.
     
     We use NSParagraphStyle in both CoreText and UIKit.
     */
    [self setParagraphStyle:paragraphStyle range:NSMakeRange(0, self.length)];
}

- (void)setAlignment:(NSTextAlignment)alignment {
    [self setAlignment:alignment range:NSMakeRange(0, self.length)];
}

- (void)setBaseWritingDirection:(NSWritingDirection)baseWritingDirection {
    [self setBaseWritingDirection:baseWritingDirection range:NSMakeRange(0, self.length)];
}

- (void)setLineSpacing:(CGFloat)lineSpacing {
    [self setLineSpacing:lineSpacing range:NSMakeRange(0, self.length)];
}

- (void)setParagraphSpacing:(CGFloat)paragraphSpacing {
    [self setParagraphSpacing:paragraphSpacing range:NSMakeRange(0, self.length)];
}

- (void)setParagraphSpacingBefore:(CGFloat)paragraphSpacingBefore {
    [self setParagraphSpacing:paragraphSpacingBefore range:NSMakeRange(0, self.length)];
}

- (void)setFirstLineHeadIndent:(CGFloat)firstLineHeadIndent {
    [self setFirstLineHeadIndent:firstLineHeadIndent range:NSMakeRange(0, self.length)];
}

- (void)setHeadIndent:(CGFloat)headIndent {
    [self setHeadIndent:headIndent range:NSMakeRange(0, self.length)];
}

- (void)setTailIndent:(CGFloat)tailIndent {
    [self setTailIndent:tailIndent range:NSMakeRange(0, self.length)];
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    [self setLineBreakMode:lineBreakMode range:NSMakeRange(0, self.length)];
}

- (void)setMinimumLineHeight:(CGFloat)minimumLineHeight {
    [self setMinimumLineHeight:minimumLineHeight range:NSMakeRange(0, self.length)];
}

- (void)setMaximumLineHeight:(CGFloat)maximumLineHeight {
    [self setMaximumLineHeight:maximumLineHeight range:NSMakeRange(0, self.length)];
}

- (void)setLineHeightMultiple:(CGFloat)lineHeightMultiple {
    [self setLineHeightMultiple:lineHeightMultiple range:NSMakeRange(0, self.length)];
}

- (void)setHyphenationFactor:(float)hyphenationFactor {
    [self setHyphenationFactor:hyphenationFactor range:NSMakeRange(0, self.length)];
}

- (void)setDefaultTabInterval:(CGFloat)defaultTabInterval {
    [self setDefaultTabInterval:defaultTabInterval range:NSMakeRange(0, self.length)];
}

- (void)setTabStops:(NSArray *)tabStops {
    [self setTabStops:tabStops range:NSMakeRange(0, self.length)];
}

- (void)setTextShadow:(TYSMTextShadow *)textShadow {
    [self setTextShadow:textShadow range:NSMakeRange(0, self.length)];
}

- (void)setTextInnerShadow:(TYSMTextShadow *)textInnerShadow {
    [self setTextInnerShadow:textInnerShadow range:NSMakeRange(0, self.length)];
}

- (void)setTextUnderline:(TYSMTextDecoration *)textUnderline {
    [self setTextUnderline:textUnderline range:NSMakeRange(0, self.length)];
}

- (void)setTextStrikethrough:(TYSMTextDecoration *)textStrikethrough {
    [self setTextStrikethrough:textStrikethrough range:NSMakeRange(0, self.length)];
}

- (void)setTextBorder:(TYSMTextBorder *)textBorder {
    [self setTextBorder:textBorder range:NSMakeRange(0, self.length)];
}

- (void)setTextBackgroundBorder:(TYSMTextBorder *)textBackgroundBorder {
    [self setTextBackgroundBorder:textBackgroundBorder range:NSMakeRange(0, self.length)];
}

- (void)setTysm_textGlyphTransform:(CGAffineTransform)textGlyphTransform {
    [self setTextGlyphTransform:textGlyphTransform range:NSMakeRange(0, self.length)];
}

#pragma mark - Range Setter

- (void)tysm_setFont:(UIFont *)font range:(NSRange)range {
    /*
     In iOS7 and later, UIFont is toll-free bridged to CTFontRef,
     although Apple does not mention it in documentation.
     
     In iOS6, UIFont is a wrapper for CTFontRef, so CoreText can alse use UIfont,
     but UILabel/UITextView cannot use CTFontRef.
     
     We use UIFont for both CoreText and UIKit.
     */
    [self setTysm_attribute:NSFontAttributeName value:font range:range];
}

- (void)tysm_setKern:(NSNumber *)kern range:(NSRange)range {
    [self setTysm_attribute:NSKernAttributeName value:kern range:range];
}

- (void)tysm_setColor:(UIColor *)color range:(NSRange)range {
    [self setTysm_attribute:(id)kCTForegroundColorAttributeName value:(id)color.CGColor range:range];
    [self setTysm_attribute:NSForegroundColorAttributeName value:color range:range];
}

- (void)tysm_setBackgroundColor:(UIColor *)backgroundColor range:(NSRange)range {
    [self setTysm_attribute:NSBackgroundColorAttributeName value:backgroundColor range:range];
}

- (void)tysm_setStrokeWidth:(NSNumber *)strokeWidth range:(NSRange)range {
    [self setTysm_attribute:NSStrokeWidthAttributeName value:strokeWidth range:range];
}

- (void)tysm_setStrokeColor:(UIColor *)strokeColor range:(NSRange)range {
    [self setTysm_attribute:(id)kCTStrokeColorAttributeName value:(id)strokeColor.CGColor range:range];
    [self setTysm_attribute:NSStrokeColorAttributeName value:strokeColor range:range];
}

- (void)tysm_setShadow:(NSShadow *)shadow range:(NSRange)range {
    [self setTysm_attribute:NSShadowAttributeName value:shadow range:range];
}

- (void)tysm_setStrikethroughStyle:(NSUnderlineStyle)strikethroughStyle range:(NSRange)range {
    NSNumber *style = strikethroughStyle == 0 ? nil : @(strikethroughStyle);
    [self setTysm_attribute:NSStrikethroughStyleAttributeName value:style range:range];
}

- (void)setStrikethroughColor:(UIColor *)strikethroughColor range:(NSRange)range {
    if (kTYSMSystemVersion >= 7) {
        [self setTysm_attribute:NSStrikethroughColorAttributeName value:strikethroughColor range:range];
    }
}

- (void)setUnderlineStyle:(NSUnderlineStyle)underlineStyle range:(NSRange)range {
    NSNumber *style = underlineStyle == 0 ? nil : @(underlineStyle);
    [self setTysm_attribute:NSUnderlineStyleAttributeName value:style range:range];
}

- (void)setUnderlineColor:(UIColor *)underlineColor range:(NSRange)range {
    [self setTysm_attribute:(id)kCTUnderlineColorAttributeName value:(id)underlineColor.CGColor range:range];
    if (kTYSMSystemVersion >= 7) {
        [self setTysm_attribute:NSUnderlineColorAttributeName value:underlineColor range:range];
    }
}

- (void)setLigature:(NSNumber *)ligature range:(NSRange)range {
    [self setTysm_attribute:NSLigatureAttributeName value:ligature range:range];
}

- (void)setTextEffect:(NSString *)textEffect range:(NSRange)range {
    if (kTYSMSystemVersion >= 7) {
        [self setTysm_attribute:NSTextEffectAttributeName value:textEffect range:range];
    }
}

- (void)setObliqueness:(NSNumber *)obliqueness range:(NSRange)range {
    if (kTYSMSystemVersion >= 7) {
        [self setTysm_attribute:NSObliquenessAttributeName value:obliqueness range:range];
    }
}

- (void)setExpansion:(NSNumber *)expansion range:(NSRange)range {
    if (kTYSMSystemVersion >= 7) {
        [self setTysm_attribute:NSExpansionAttributeName value:expansion range:range];
    }
}

- (void)setBaselineOffset:(NSNumber *)baselineOffset range:(NSRange)range {
    if (kTYSMSystemVersion >= 7) {
        [self setTysm_attribute:NSBaselineOffsetAttributeName value:baselineOffset range:range];
    }
}

- (void)setVerticalGlyphForm:(BOOL)verticalGlyphForm range:(NSRange)range {
    NSNumber *v = verticalGlyphForm ? @(YES) : nil;
    [self setTysm_attribute:NSVerticalGlyphFormAttributeName value:v range:range];
}

- (void)setLanguage:(NSString *)language range:(NSRange)range {
    if (kTYSMSystemVersion >= 7) {
        [self setTysm_attribute:(id)kCTLanguageAttributeName value:language range:range];
    }
}

- (void)setWritingDirection:(NSArray *)writingDirection range:(NSRange)range {
    [self setTysm_attribute:(id)kCTWritingDirectionAttributeName value:writingDirection range:range];
}

- (void)setParagraphStyle:(NSParagraphStyle *)paragraphStyle range:(NSRange)range {
    /*
     NSParagraphStyle is NOT toll-free bridged to CTParagraphStyleRef.
     
     CoreText can use both NSParagraphStyle and CTParagraphStyleRef,
     but UILabel/UITextView can only use NSParagraphStyle.
     
     We use NSParagraphStyle in both CoreText and UIKit.
     */
    [self setTysm_attribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
}

#define ParagraphStyleSet(_attr_) \
[self enumerateAttribute:NSParagraphStyleAttributeName \
                 inRange:range \
                 options:kNilOptions \
              usingBlock: ^(NSParagraphStyle *value, NSRange subRange, BOOL *stop) { \
                  NSMutableParagraphStyle *style = nil; \
                  if (value) { \
                      if (CFGetTypeID((__bridge CFTypeRef)(value)) == CTParagraphStyleGetTypeID()) { \
                          value = [NSParagraphStyle styleWithCTStyle:(__bridge CTParagraphStyleRef)(value)]; \
                      } \
                      if (value. _attr_ == _attr_) return; \
                      if ([value isKindOfClass:[NSMutableParagraphStyle class]]) { \
                          style = (id)value; \
                      } else { \
                          style = value.mutableCopy; \
                      } \
                  } else { \
                      if ([NSParagraphStyle defaultParagraphStyle]. _attr_ == _attr_) return; \
                      style = [NSParagraphStyle defaultParagraphStyle].mutableCopy; \
                  } \
                  style. _attr_ = _attr_; \
                  [self setParagraphStyle:style range:subRange]; \
              }];

- (void)setAlignment:(NSTextAlignment)alignment range:(NSRange)range {
    ParagraphStyleSet(alignment);
}

- (void)setBaseWritingDirection:(NSWritingDirection)baseWritingDirection range:(NSRange)range {
    ParagraphStyleSet(baseWritingDirection);
}

- (void)setLineSpacing:(CGFloat)lineSpacing range:(NSRange)range {
    ParagraphStyleSet(lineSpacing);
}

- (void)setParagraphSpacing:(CGFloat)paragraphSpacing range:(NSRange)range {
    ParagraphStyleSet(paragraphSpacing);
}

- (void)setParagraphSpacingBefore:(CGFloat)paragraphSpacingBefore range:(NSRange)range {
    ParagraphStyleSet(paragraphSpacingBefore);
}

- (void)setFirstLineHeadIndent:(CGFloat)firstLineHeadIndent range:(NSRange)range {
    ParagraphStyleSet(firstLineHeadIndent);
}

- (void)setHeadIndent:(CGFloat)headIndent range:(NSRange)range {
    ParagraphStyleSet(headIndent);
}

- (void)setTailIndent:(CGFloat)tailIndent range:(NSRange)range {
    ParagraphStyleSet(tailIndent);
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode range:(NSRange)range {
    ParagraphStyleSet(lineBreakMode);
}

- (void)setMinimumLineHeight:(CGFloat)minimumLineHeight range:(NSRange)range {
    ParagraphStyleSet(minimumLineHeight);
}

- (void)setMaximumLineHeight:(CGFloat)maximumLineHeight range:(NSRange)range {
    ParagraphStyleSet(maximumLineHeight);
}

- (void)setLineHeightMultiple:(CGFloat)lineHeightMultiple range:(NSRange)range {
    ParagraphStyleSet(lineHeightMultiple);
}

- (void)setHyphenationFactor:(float)hyphenationFactor range:(NSRange)range {
    ParagraphStyleSet(hyphenationFactor);
}

- (void)setDefaultTabInterval:(CGFloat)defaultTabInterval range:(NSRange)range {
    if (!kTYSM_iOS7Later) return;
    ParagraphStyleSet(defaultTabInterval);
}

- (void)setTabStops:(NSArray *)tabStops range:(NSRange)range {
    if (!kTYSM_iOS7Later) return;
    ParagraphStyleSet(tabStops);
}

#undef ParagraphStyleSet

- (void)setSuperscript:(NSNumber *)superscript range:(NSRange)range {
    if ([superscript isEqualToNumber:@(0)]) {
        superscript = nil;
    }
    [self setTysm_attribute:(id)kCTSuperscriptAttributeName value:superscript range:range];
}

- (void)setGlyphInfo:(CTGlyphInfoRef)glyphInfo range:(NSRange)range {
    [self setTysm_attribute:(id)kCTGlyphInfoAttributeName value:(__bridge id)glyphInfo range:range];
}

- (void)setCharacterShape:(NSNumber *)characterShape range:(NSRange)range {
    [self setTysm_attribute:(id)kCTCharacterShapeAttributeName value:characterShape range:range];
}

- (void)setRunDelegate:(CTRunDelegateRef)runDelegate range:(NSRange)range {
    [self setTysm_attribute:(id)kCTRunDelegateAttributeName value:(__bridge id)runDelegate range:range];
}

- (void)setBaselineClass:(CFStringRef)baselineClass range:(NSRange)range {
    [self setTysm_attribute:(id)kCTBaselineClassAttributeName value:(__bridge id)baselineClass range:range];
}

- (void)setBaselineInfo:(CFDictionaryRef)baselineInfo range:(NSRange)range {
    [self setTysm_attribute:(id)kCTBaselineInfoAttributeName value:(__bridge id)baselineInfo range:range];
}

- (void)setBaselineReferenceInfo:(CFDictionaryRef)referenceInfo range:(NSRange)range {
    [self setTysm_attribute:(id)kCTBaselineReferenceInfoAttributeName value:(__bridge id)referenceInfo range:range];
}

- (void)setRubyAnnotation:(CTRubyAnnotationRef)ruby range:(NSRange)range {
    if (kTYSMSystemVersion >= 8) {
        [self setTysm_attribute:(id)kCTRubyAnnotationAttributeName value:(__bridge id)ruby range:range];
    }
}

- (void)setAttachment:(NSTextAttachment *)attachment range:(NSRange)range {
    if (kTYSMSystemVersion >= 7) {
        [self setTysm_attribute:NSAttachmentAttributeName value:attachment range:range];
    }
}

- (void)setLink:(id)link range:(NSRange)range {
    if (kTYSMSystemVersion >= 7) {
        [self setTysm_attribute:NSLinkAttributeName value:link range:range];
    }
}

- (void)setTextBackedString:(TYSMTextBackedString *)textBackedString range:(NSRange)range {
    [self setTysm_attribute:TYSMTextBackedStringAttributeName value:textBackedString range:range];
}

- (void)setTextBinding:(TYSMTextBinding *)textBinding range:(NSRange)range {
    [self setTysm_attribute:TYSMTextBindingAttributeName value:textBinding range:range];
}

- (void)setTextShadow:(TYSMTextShadow *)textShadow range:(NSRange)range {
    [self setTysm_attribute:TYSMTextShadowAttributeName value:textShadow range:range];
}

- (void)setTextInnerShadow:(TYSMTextShadow *)textInnerShadow range:(NSRange)range {
    [self setTysm_attribute:TYSMTextInnerShadowAttributeName value:textInnerShadow range:range];
}

- (void)setTextUnderline:(TYSMTextDecoration *)textUnderline range:(NSRange)range {
    [self setTysm_attribute:TYSMTextUnderlineAttributeName value:textUnderline range:range];
}

- (void)setTextStrikethrough:(TYSMTextDecoration *)textStrikethrough range:(NSRange)range {
    [self setTysm_attribute:TYSMTextStrikethroughAttributeName value:textStrikethrough range:range];
}

- (void)setTextBorder:(TYSMTextBorder *)textBorder range:(NSRange)range {
    [self setTysm_attribute:TYSMTextBorderAttributeName value:textBorder range:range];
}

- (void)setTextBackgroundBorder:(TYSMTextBorder *)textBackgroundBorder range:(NSRange)range {
    [self setTysm_attribute:TYSMTextBackgroundBorderAttributeName value:textBackgroundBorder range:range];
}

- (void)setTextAttachment:(TYSMTextAttachment *)textAttachment range:(NSRange)range {
    [self setTysm_attribute:TYSMTextAttachmentAttributeName value:textAttachment range:range];
}

- (void)tysm_setTextHighlight:(TYSMTextHighlight *)textHighlight range:(NSRange)range {
    [self setTysm_attribute:TYSMTextHighlightAttributeName value:textHighlight range:range];
}

- (void)tysm_setTextBlockBorder:(TYSMTextBorder *)textBlockBorder range:(NSRange)range {
    [self setTysm_attribute:TYSMTextBlockBorderAttributeName value:textBlockBorder range:range];
}

- (void)tysm_setTextRubyAnnotation:(YYTextRubyAnnotation *)ruby range:(NSRange)range {
    if (kTYSM_iOS8Later) {
        CTRubyAnnotationRef rubyRef = [ruby CTRubyAnnotation];
        [self setRubyAnnotation:rubyRef range:range];
        if (rubyRef) CFRelease(rubyRef);
    }
}

- (void)setTextGlyphTransform:(CGAffineTransform)textGlyphTransform range:(NSRange)range {
    NSValue *value = CGAffineTransformIsIdentity(textGlyphTransform) ? nil : [NSValue valueWithCGAffineTransform:textGlyphTransform];
    [self setTysm_attribute:TYSMTextGlyphTransformAttributeName value:value range:range];
}

- (void)tysm_setTextHighlightRange:(NSRange)range
                        color:(UIColor *)color
              backgroundColor:(UIColor *)backgroundColor
                     userInfo:(NSDictionary *)userInfo
                    tapAction:(TYSMTextAction)tapAction
              longPressAction:(TYSMTextAction)longPressAction {
    TYSMTextHighlight *highlight = [TYSMTextHighlight highlightWithBackgroundColor:backgroundColor];
    highlight.userInfo = userInfo;
    highlight.tapAction = tapAction;
    highlight.longPressAction = longPressAction;
    if (color) [self tysm_setColor:color range:range];
    [self tysm_setTextHighlight:highlight range:range];
}

- (void)tysm_setTextHighlightRange:(NSRange)range
                        color:(UIColor *)color
              backgroundColor:(UIColor *)backgroundColor
                    tapAction:(TYSMTextAction)tapAction {
    [self tysm_setTextHighlightRange:range
                          color:color
                backgroundColor:backgroundColor
                       userInfo:nil
                      tapAction:tapAction
                longPressAction:nil];
}

- (void)tysm_setTextHighlightRange:(NSRange)range
                        color:(UIColor *)color
              backgroundColor:(UIColor *)backgroundColor
                     userInfo:(NSDictionary *)userInfo {
    [self tysm_setTextHighlightRange:range
                          color:color
                backgroundColor:backgroundColor
                       userInfo:userInfo
                      tapAction:nil
                longPressAction:nil];
}

- (void)tysm_insertString:(NSString *)string atIndex:(NSUInteger)location {
    [self replaceCharactersInRange:NSMakeRange(location, 0) withString:string];
    [self tysm_removeDiscontinuousAttributesInRange:NSMakeRange(location, string.length)];
}

- (void)tysm_appendString:(NSString *)string {
    NSUInteger length = self.length;
    [self replaceCharactersInRange:NSMakeRange(length, 0) withString:string];
    [self tysm_removeDiscontinuousAttributesInRange:NSMakeRange(length, string.length)];
}

- (void)tysm_setClearColorToJoinedEmoji {
    NSString *str = self.string;
    if (str.length < 8) return;
    
    // Most string do not contains the joined-emoji, test the joiner first.
    BOOL containsJoiner = NO;
    {
        CFStringRef cfStr = (__bridge CFStringRef)str;
        BOOL needFree = NO;
        UniChar *chars = NULL;
        chars = (void *)CFStringGetCharactersPtr(cfStr);
        if (!chars) {
            chars = malloc(str.length * sizeof(UniChar));
            if (chars) {
                needFree = YES;
                CFStringGetCharacters(cfStr, CFRangeMake(0, str.length), chars);
            }
        }
        if (!chars) { // fail to get unichar..
            containsJoiner = YES;
        } else {
            for (int i = 0, max = (int)str.length; i < max; i++) {
                if (chars[i] == 0x200D) { // 'ZERO WIDTH JOINER' (U+200D)
                    containsJoiner = YES;
                    break;
                }
            }
            if (needFree) free(chars);
        }
    }
    if (!containsJoiner) return;
    
    // NSRegularExpression is designed to be immutable and thread safe.
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"((👨‍👩‍👧‍👦|👨‍👩‍👦‍👦|👨‍👩‍👧‍👧|👩‍👩‍👧‍👦|👩‍👩‍👦‍👦|👩‍👩‍👧‍👧|👨‍👨‍👧‍👦|👨‍👨‍👦‍👦|👨‍👨‍👧‍👧)+|(👨‍👩‍👧|👩‍👩‍👦|👩‍👩‍👧|👨‍👨‍👦|👨‍👨‍👧))" options:kNilOptions error:nil];
    });
    
    UIColor *clear = [UIColor clearColor];
    [regex enumerateMatchesInString:str options:kNilOptions range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [self tysm_setColor:clear range:result.range];
    }];
}

- (void)tysm_removeDiscontinuousAttributesInRange:(NSRange)range {
    NSArray *keys = [NSMutableAttributedString tysm_allDiscontinuousAttributeKeys];
    for (NSString *key in keys) {
        [self removeAttribute:key range:range];
    }
}

+ (NSArray *)tysm_allDiscontinuousAttributeKeys {
    static NSMutableArray *keys;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keys = @[(id)kCTSuperscriptAttributeName,
                 (id)kCTRunDelegateAttributeName,
                 TYSMTextBackedStringAttributeName,
                 TYSMTextBindingAttributeName,
                 TYSMTextAttachmentAttributeName].mutableCopy;
        if (kTYSM_iOS8Later) {
            [keys addObject:(id)kCTRubyAnnotationAttributeName];
        }
        if (kTYSM_iOS7Later) {
            [keys addObject:NSAttachmentAttributeName];
        }
    });
    return keys;
}

@end
