//
//  BelongingsManagerApple.h
//

#import <Foundation/Foundation.h>
#include "BelongingsManagerCommonType.h"


#if defined(IOS)
@interface BelongingsRecordApple : NSObject <NSCoding>
#else
@interface BelongingsRecordApple : NSObject
#endif
{
#if !defined(_LP64) && !defined (IOS)
    void *_m_pBelongingsRecord;
#endif

}
@property bool m_bValid;
@property uint32_t m_DefaultFeature;
@property uint32_t m_SupportedFeatures;
@property uint32_t m_WantedFeature;
@property uint32_t m_FeatureOptions;
@property (copy) NSString*	m_Name;
@property (copy) NSString*	m_Password;
@property (copy) NSString*	m_Address;
@property (copy) NSString*	m_Options;
@property (copy) NSString*	m_OwnerID;
@property int	m_Port;
@property int m_DeviceType;
@property int m_DiscoveringState;

@property int m_CommWay;

@property uint8_t* m_UID;
@property int m_UIDLength;

@property uint8_t* m_MAC;
@property int m_MACLength;    
@property uint8_t m_Attr;


@property (copy)  NSString*	jid;
@property (copy) NSString* serverType;
@property bool		xmppSupport;
@property int32_t	xfOptions;
@property uint32_t	wanIP;
@property uint16_t	wanAuthPort;
@property uint16_t	wanVideoPort;
@property uint16_t	wanAudioPort;
@property void*	DomainHandle;
@property int m_Version;

- (void) Copy:(BelongingsRecordApple*) record;
- (BOOL)Validate;
#if defined (IOS)
- (id)initWithCoder:(NSKeyedUnarchiver *)coder;
- (void)encodeWithCoder:(NSKeyedArchiver *)coder;
#endif
@end

struct PMBelongingsScanReport
{
    void* DomainHandle;
    BelongingsRecordApple* BelongingsRecord;
};

@interface BelongingsManagerApple : NSObject
{
#if !defined(_LP64)
    void* _m_pManager;
    void* _m_pSignalReceiver;

#endif

}
- (void) StartScanBelongings;
- (void) StopScanBelongings;
- (void) StartProbeDomain:(void*)DomainHandle;
- (void) StopProbeDomain:(void*)DomainHandle;
// Add Belongings record manually and return index
- (int) AddBelongingsInfo:(BelongingsRecordApple*) record;
- (void) RemoveBelongingsInfo:(int) index;
- (BelongingsRecordApple*) GetBelongingsInfo:(int)index;
- (bool) ProbeBelonging:(BelongingsRecordApple*) record;

@end
