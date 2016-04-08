//
//  GUIPeerManager.h
//
//

#ifndef __GUIPeerManager__
#define __GUIPeerManager__
#import <Foundation/Foundation.h>
#import "BelongingsManagerApple.h"
#import "NSSServer.h"

@interface GUIPeerManager : NSObject<BelongingsRecordHolder>
{
}
@property (nonatomic) NSUInteger m_CurrentIndex;
@property (nonatomic,strong) NSMutableArray *m_ManualRecords;
@property (nonatomic,strong) NSMutableArray *m_DiscoverRecords;

- (void)addDiscoverBelongingRecord:(BelongingsRecordApple *)record;
- (void)delDiscoverBelongingRecord:(BelongingsRecordApple *)record;
- (void)addManualBelongingRecord:(BelongingsRecordApple *)record;
- (void)delManualBelongingRecord:(BelongingsRecordApple *)record;
- (void)saveManualRecords;
// RecordType - 0:Manual, 1:Discover
- (BelongingsRecordApple *)IsBelongingRecordExist:(BelongingsRecordApple *)record in:(int)RecordType;

@end

#endif 
