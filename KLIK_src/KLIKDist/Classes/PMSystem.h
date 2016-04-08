//
//  PMSystem.h
//  iDocShare
//

#import <Foundation/Foundation.h>
#import "PMPlayerAppleTranslator.h"
#import "NotificationTranslatorApple.h"

@protocol BelongingsRecordHolder <NSObject>
- (void)addDiscoverBelongingRecord:(BelongingsRecordApple *)record;
- (void)delDiscoverBelongingRecord:(BelongingsRecordApple *)record;
@end


@interface PMSystem : NSObject
{
    PMPlayerAppleTranslator* m_pPMPlayer;
    PMLiveDomainApple* m_pJingleDomain;
    PMLiveDomainApple* m_pLanDomain;
    BelongingsManagerApple* m_pBelongingsManager;

}
@property (nonatomic, readonly) PMPlayerAppleTranslator* m_pPMPlayer;
@property (nonatomic, retain) id<BelongingsRecordHolder> m_BelongingsRecordHolder;
@property (nonatomic, readonly) void* m_DomainHandle;

+ (PMSystem*) defaultPMSystem;
+ (void) releaseDefaultPMSystem;


@end
