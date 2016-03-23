//
//  AppSetting.m
//  PMPlayer
//
//  Created by James_hsieh on 12/8/13.
//
//

#import "AppSetting.h"

#include <string>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>


#define CRYPTO_AES128_KEY @"PhilMedia0970618"

static NSData *AES128Encrypt(NSString *string)
{
    CCCryptorStatus ccStatus;
    NSString *key;
    const char *input;
    size_t inputSize;
    uint8_t *output;
    size_t outputSize;
    size_t movedBytes;
    
    input = [string UTF8String];
    if (!input) return [NSData data];
    inputSize = strlen(input) + 1;
    
    outputSize = inputSize + kCCBlockSizeAES128;
    output = (uint8_t *)malloc(outputSize);
    
    key = CRYPTO_AES128_KEY;
    
    ccStatus = CCCrypt(kCCEncrypt,
                       kCCAlgorithmAES128,
                       kCCOptionPKCS7Padding,
                       [key UTF8String],
                       kCCKeySizeAES128,
                       NULL,
                       input,
                       inputSize,
                       output,
                       outputSize,
                       &movedBytes);
	
    if (ccStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:output length:movedBytes freeWhenDone:YES];
    } else {
        return nil;
    }
}

static NSString *AES128Decrypt(NSData *data)
{
	CCCryptorStatus ccStatus;
	NSString *key;
	const char *input;
	size_t inputSize;
	uint8_t *output;
	size_t outputSize;
	size_t movedBytes;
	
	input = (const char *)[data bytes];
	inputSize = [data length];
	
	outputSize = inputSize + kCCBlockSizeAES128;
	output = (uint8_t*)malloc(outputSize);
	
	key = CRYPTO_AES128_KEY;
	
	ccStatus = CCCrypt(kCCDecrypt,
					   kCCAlgorithmAES128,
					   kCCOptionPKCS7Padding,
					   [key UTF8String],
					   kCCKeySizeAES128,
					   NULL,
					   input,
					   inputSize,
					   output,
					   outputSize,
					   &movedBytes);
	
	if (ccStatus == kCCSuccess) {
		NSString *decryptStr = [[NSString alloc] initWithUTF8String:(const char *)output];
		free(output);
		return [decryptStr autorelease];
	} else {
		free(output);
		return nil;
	}
}


@implementation AppSetting
@synthesize m_ScreenShareServerRecord, m_FileServerRecord;
#if defined (IOS)
- (id)initWithCoder:(NSKeyedUnarchiver *)coder
{
    BelongingsRecordApple *_peerRecord;
    BelongingsRecordApple *_fileServerRecord;
	
	if ([coder containsValueForKey:@"FileServerRecord"])
    {
        _fileServerRecord	= [coder decodeObjectForKey:@"FileServerRecord"];
        _peerRecord	= [coder decodeObjectForKey:@"ScreenShareServerRecord"];
        
	}
    else
    {

		_fileServerRecord		= [coder decodeObject];
		_peerRecord		= [coder decodeObject];

	}
    
    [self init];
    if (self)
    {
        self.m_FileServerRecord = _fileServerRecord;
        self.m_ScreenShareServerRecord = nil;
    }
    return self;
	
}

- (void)encodeWithCoder:(NSKeyedArchiver *)coder
{
	[coder encodeObject:self.m_FileServerRecord forKey:@"FileServerRecord"];
	[coder encodeObject:self.m_ScreenShareServerRecord forKey:@"ScreenShareServerRecord"];
}
#endif

@end

