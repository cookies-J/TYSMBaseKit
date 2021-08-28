//
//  UIPasteboard+YYText.m
//  YYKit <https://github.com/ibireme/YYKit>
//
//  Created by ibireme on 15/4/2.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "UIPasteboard+YYText.h"
#import "YYKitMacro.h"
#import "TYSMImage.h"
#import "NSAttributedString+YYText.h"
#import <MobileCoreServices/MobileCoreServices.h>

YYSYNTH_DUMMY_CLASS(UIPasteboard_YYText)

NSString *const YYPasteboardTypeAttributedString = @"com.ibireme.NSAttributedString";
NSString *const YYUTTypeWEBP = @"com.google.webp";

@implementation UIPasteboard (YYText)


- (void)setPNGData:(NSData *)PNGData {
    [self setData:PNGData forPasteboardType:(id)kUTTypePNG];
}

- (NSData *)PNGData {
    return [self dataForPasteboardType:(id)kUTTypePNG];
}

- (void)setJPEGData:(NSData *)JPEGData {
    [self setData:JPEGData forPasteboardType:(id)kUTTypeJPEG];
}

- (NSData *)JPEGData {
    return [self dataForPasteboardType:(id)kUTTypeJPEG];
}

- (void)setGIFData:(NSData *)GIFData {
    [self setData:GIFData forPasteboardType:(id)kUTTypeGIF];
}

- (NSData *)GIFData {
    return [self dataForPasteboardType:(id)kUTTypeGIF];
}

- (void)setWEBPData:(NSData *)WEBPData {
    [self setData:WEBPData forPasteboardType:YYUTTypeWEBP];
}

- (NSData *)WEBPData {
    return [self dataForPasteboardType:YYUTTypeWEBP];
}

- (void)setImageData:(NSData *)imageData {
    [self setData:imageData forPasteboardType:(id)kUTTypeImage];
}

- (NSData *)imageData {
    return [self dataForPasteboardType:(id)kUTTypeImage];
}

- (void)setAttributedString:(NSAttributedString *)attributedString {
    self.string = [attributedString plainTextForRange:NSMakeRange(0, attributedString.length)];
    NSData *data = [attributedString tysm_archiveToData];
    if (data) {
        NSDictionary *item = @{YYPasteboardTypeAttributedString : data};
        [self addItems:@[item]];
    }
    [attributedString enumerateAttribute:TYSMTextAttachmentAttributeName inRange:NSMakeRange(0, attributedString.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(TYSMTextAttachment *attachment, NSRange range, BOOL *stop) {
        UIImage *img = attachment.content;
        if ([img isKindOfClass:[UIImage class]]) {
            NSDictionary *item = @{@"com.apple.uikit.image" : img};
            [self addItems:@[item]];
            
            
            if ([img isKindOfClass:[TYSMImage class]] && ((TYSMImage *)img).animatedImageData) {
                if (((TYSMImage *)img).animatedImageType == TYSMImageTypeGIF) {
                    NSDictionary *item = @{(id)kUTTypeGIF : ((TYSMImage *)img).animatedImageData};
                    [self addItems:@[item]];
                } else if (((TYSMImage *)img).animatedImageType == TYSMImageTypePNG) {
                    NSDictionary *item = @{(id)kUTTypePNG : ((TYSMImage *)img).animatedImageData};
                    [self addItems:@[item]];
                } else if (((TYSMImage *)img).animatedImageType == TYSMImageTypeWebP) {
                    NSDictionary *item = @{(id)YYUTTypeWEBP : ((TYSMImage *)img).animatedImageData};
                    [self addItems:@[item]];
                }
            }
            
            
            // save image
            UIImage *simpleImage = nil;
            if ([attachment.content isKindOfClass:[UIImage class]]) {
                simpleImage = attachment.content;
            } else if ([attachment.content isKindOfClass:[UIImageView class]]) {
                simpleImage = ((UIImageView *)attachment.content).image;
            }
            if (simpleImage) {
                NSDictionary *item = @{@"com.apple.uikit.image" : simpleImage};
                [self addItems:@[item]];
            }
            
            // save animated image
            if ([attachment.content isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView = attachment.content;
                TYSMImage *image = (id)imageView.image;
                if ([image isKindOfClass:[TYSMImage class]]) {
                    NSData *data = image.animatedImageData;
                    TYSMImageType type = image.animatedImageType;
                    if (data) {
                        switch (type) {
                            case TYSMImageTypeGIF: {
                                NSDictionary *item = @{(id)kUTTypeGIF : data};
                                [self addItems:@[item]];
                            } break;
                            case TYSMImageTypePNG: { // APNG
                                NSDictionary *item = @{(id)kUTTypePNG : data};
                                [self addItems:@[item]];
                            } break;
                            case TYSMImageTypeWebP: {
                                NSDictionary *item = @{(id)YYUTTypeWEBP : data};
                                [self addItems:@[item]];
                            } break;
                            default: break;
                        }
                    }
                }
            }
            
        }
    }];
}

- (NSAttributedString *)attributedString {
    for (NSDictionary *items in self.items) {
        NSData *data = items[YYPasteboardTypeAttributedString];
        if (data) {
            return [NSAttributedString tysm_unarchiveFromData:data];
        }
    }
    return nil;
}

@end
