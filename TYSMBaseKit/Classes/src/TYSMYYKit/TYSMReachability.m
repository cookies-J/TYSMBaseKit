//
//  TYSMReachability.m
//  TYSMKit <https://github.com/ibireme/TYSMKit>
//
//  Created by ibireme on 15/2/6.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "TYSMReachability.h"
#import <objc/message.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

static TYSMReachabilityStatus TYSMReachabilityStatusFromFlags(SCNetworkReachabilityFlags flags, BOOL allowWWAN) {
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
        return TYSMReachabilityStatusNone;
    }
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) &&
        (flags & kSCNetworkReachabilityFlagsTransientConnection)) {
        return TYSMReachabilityStatusNone;
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) && allowWWAN) {
        return TYSMReachabilityStatusWWAN;
    }
    
    return TYSMReachabilityStatusWiFi;
}

static void TYSMReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    TYSMReachability *self = ((__bridge TYSMReachability *)info);
    if (self.notifyBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.notifyBlock(self);
        });
    }
}

@interface TYSMReachability ()
@property (nonatomic, assign) SCNetworkReachabilityRef ref;
@property (nonatomic, assign) BOOL scheduled;
@property (nonatomic, assign) BOOL allowWWAN;
@property (nonatomic, strong) CTTelephonyNetworkInfo *networkInfo;
@end

@implementation TYSMReachability

+ (dispatch_queue_t)sharedQueue {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.ibireme.TYSMkit.reachability", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

- (instancetype)init {
    /*
     See Apple's Reachability implementation and readme:
     The address 0.0.0.0, which reachability treats as a special token that 
     causes it to actually monitor the general routing status of the device, 
     both IPv4 and IPv6.
     https://developer.apple.com/library/ios/samplecode/Reachability/Listings/ReadMe_md.html#//apple_ref/doc/uid/DTS40007324-ReadMe_md-DontLinkElementID_11
     */
    struct sockaddr_in zero_addr;
    bzero(&zero_addr, sizeof(zero_addr));
    zero_addr.sin_len = sizeof(zero_addr);
    zero_addr.sin_family = AF_INET;
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&zero_addr);
    return [self initWithRef:ref];
}

- (instancetype)initWithRef:(SCNetworkReachabilityRef)ref {
    if (!ref) return nil;
    self = super.init;
    if (!self) return nil;
    _ref = ref;
    _allowWWAN = YES;
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
        _networkInfo = [CTTelephonyNetworkInfo new];
    }
    return self;
}

- (void)dealloc {
    self.notifyBlock = nil;
    self.scheduled = NO;
    CFRelease(self.ref);
}

- (void)tysm_setScheduled:(BOOL)scheduled {
    if (_scheduled == scheduled) return;
    _scheduled = scheduled;
    if (scheduled) {
        SCNetworkReachabilityContext context = { 0, (__bridge void *)self, NULL, NULL, NULL };
        SCNetworkReachabilitySetCallback(self.ref, TYSMReachabilityCallback, &context);
        SCNetworkReachabilitySetDispatchQueue(self.ref, [self.class sharedQueue]);
    } else {
        SCNetworkReachabilitySetDispatchQueue(self.ref, NULL);
    }
}

- (SCNetworkReachabilityFlags)tysm_flags {
    SCNetworkReachabilityFlags flags = 0;
    SCNetworkReachabilityGetFlags(self.ref, &flags);
    return flags;
}

- (TYSMReachabilityStatus)tysm_status {
    return TYSMReachabilityStatusFromFlags(self.flags, self.allowWWAN);
}

- (TYSMReachabilityWWANStatus)tysm_wwanStatus {
    if (!self.networkInfo) return TYSMReachabilityWWANStatusNone;
    NSString *status = self.networkInfo.currentRadioAccessTechnology;
    if (!status) return TYSMReachabilityWWANStatusNone;
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dic = @{CTRadioAccessTechnologyGPRS : @(TYSMReachabilityWWANStatus2G),  // 2.5G   171Kbps
                CTRadioAccessTechnologyEdge : @(TYSMReachabilityWWANStatus2G),  // 2.75G  384Kbps
                CTRadioAccessTechnologyWCDMA : @(TYSMReachabilityWWANStatus3G), // 3G     3.6Mbps/384Kbps
                CTRadioAccessTechnologyHSDPA : @(TYSMReachabilityWWANStatus3G), // 3.5G   14.4Mbps/384Kbps
                CTRadioAccessTechnologyHSUPA : @(TYSMReachabilityWWANStatus3G), // 3.75G  14.4Mbps/5.76Mbps
                CTRadioAccessTechnologyCDMA1x : @(TYSMReachabilityWWANStatus3G), // 2.5G
                CTRadioAccessTechnologyCDMAEVDORev0 : @(TYSMReachabilityWWANStatus3G),
                CTRadioAccessTechnologyCDMAEVDORevA : @(TYSMReachabilityWWANStatus3G),
                CTRadioAccessTechnologyCDMAEVDORevB : @(TYSMReachabilityWWANStatus3G),
                CTRadioAccessTechnologyeHRPD : @(TYSMReachabilityWWANStatus3G),
                CTRadioAccessTechnologyLTE : @(TYSMReachabilityWWANStatus4G)}; // LTE:3.9G 150M/75M  LTE-Advanced:4G 300M/150M
    });
    NSNumber *num = dic[status];
    if (num) return num.unsignedIntegerValue;
    else return TYSMReachabilityWWANStatusNone;
}

- (BOOL)tysm_isReachable {
    return self.status != TYSMReachabilityStatusNone;
}

+ (instancetype)reachability {
    return self.new;
}

+ (instancetype)reachabilityForLocalWifi {
    struct sockaddr_in localWifiAddress;
    bzero(&localWifiAddress, sizeof(localWifiAddress));
    localWifiAddress.sin_len = sizeof(localWifiAddress);
    localWifiAddress.sin_family = AF_INET;
    localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
    TYSMReachability *one = [self reachabilityWithAddress:(const struct sockaddr *)&localWifiAddress];
    one.allowWWAN = NO;
    return one;
}

+ (instancetype)reachabilityWithHostname:(NSString *)hostname {
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithName(NULL, [hostname UTF8String]);
    return [[self alloc] initWithRef:ref];
}

+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress {
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)hostAddress);
    return [[self alloc] initWithRef:ref];
}

- (void)tysm_setNotifyBlock:(void (^)(TYSMReachability *reachability))notifyBlock {
    _notifyBlock = [notifyBlock copy];
    self.scheduled = (self.notifyBlock != nil);
}

@end
