#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "LZStorageHelper.h"
#import "LZFileHelper.h"
#import "LZDefaultsHelper.h"

FOUNDATION_EXPORT double LZStorageHelperVersionNumber;
FOUNDATION_EXPORT const unsigned char LZStorageHelperVersionString[];

