#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "m3" asset catalog image resource.
static NSString * const ACImageNameM3 AC_SWIFT_PRIVATE = @"m3";

#undef AC_SWIFT_PRIVATE
