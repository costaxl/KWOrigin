//
//  GUIPeerManager.cpp
//  iDocShare
//
//  Created by tywang on 14/10/1.
//
//

#include "GUIPeerManager.h"

@interface GUIPeerManager ()
{
}
- (NSMutableArray *)loadRecords;

@end

@implementation GUIPeerManager
@synthesize m_ManualRecords;
@synthesize m_DiscoverRecords;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.m_ManualRecords = [self loadRecords];
        self.m_DiscoverRecords = [[NSMutableArray alloc] init];

    }
    return self;
}
-(void)dealloc
{
    [self.m_ManualRecords dealloc];
    [self.m_DiscoverRecords dealloc];
    [super dealloc];
    
}

- (void)addDiscoverBelongingRecord:(BelongingsRecordApple *)record;
{
    assert(record.m_CommWay != DC_MANUAL);
    if ([self IsBelongingRecordExist:record in:1] != nil)
    {
        return;
    }

    BelongingsRecordApple *newRecord = [[BelongingsRecordApple alloc] init];
    [newRecord Copy:record];
    [self.m_DiscoverRecords addObject:newRecord];
    
}

- (void)delDiscoverBelongingRecord:(BelongingsRecordApple *)record
{
    assert(record.m_CommWay != DC_MANUAL);

    BelongingsRecordApple* existRecord;
    existRecord = [self IsBelongingRecordExist:record in:1];
    if (existRecord == nil)
    {
        return;
    }
    
    NSInteger indexOfRecord = [self.m_DiscoverRecords indexOfObject:existRecord];
    
    [self.m_DiscoverRecords removeObjectAtIndex:indexOfRecord];

}
- (void)addManualBelongingRecord:(BelongingsRecordApple *)record
{
    assert(record.m_CommWay == DC_MANUAL);
    if ([self IsBelongingRecordExist:record in:0] != nil)
    {
        return;
    }
    
    BelongingsRecordApple *newRecord = [[BelongingsRecordApple alloc] init];
    [newRecord Copy:record];
    [self.m_ManualRecords addObject:newRecord];

}
- (void)delManualBelongingRecord:(BelongingsRecordApple *)record
{
    assert(record.m_CommWay == DC_MANUAL);
    
    BelongingsRecordApple* existRecord;
    existRecord = [self IsBelongingRecordExist:record in:0];
    if (existRecord == nil)
    {
        return;
    }
    
    NSInteger indexOfRecord = [self.m_ManualRecords indexOfObject:existRecord];
    
    [self.m_ManualRecords removeObjectAtIndex:indexOfRecord];
}

- (BelongingsRecordApple *)IsBelongingRecordExist:(BelongingsRecordApple *)record  in:(int)RecordType
{
    BelongingsRecordApple* comRecord;
    
    if (RecordType == 0)
    {
        for (NSUInteger i = 0; i < [self.m_ManualRecords count]; i++)
        {
            comRecord = [self.m_ManualRecords objectAtIndex:i];
            if ([record.m_Address compare:comRecord.m_Address] == 0)
                return comRecord;
        }

    }
    else if (RecordType ==1)
    {
        for (NSUInteger i = 0; i < [self.m_DiscoverRecords count]; i++)
        {
            comRecord = [self.m_DiscoverRecords objectAtIndex:i];
            if (record.m_CommWay == DC_Jingle)
            {
                if ([record.jid compare:comRecord.jid] == 0)
                    return comRecord;
            }
            else if (record.m_CommWay == DC_Lan)
            {
                if ([record.m_Address compare:comRecord.m_Address] == 0)
                    return comRecord;
                
            }
        }

    }
    else
    {
        assert(false);
    }
    
    return nil;
    
}


- (void)saveManualRecords
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/PMPlayer.dat", directory];
    
    [NSKeyedArchiver archiveRootObject:self.m_ManualRecords toFile:fileName];
}

- (NSMutableArray *)loadRecords
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/PMPlayer.dat", directory];
    
    NSMutableArray *records = [[NSKeyedUnarchiver unarchiveObjectWithFile:fileName] retain];
    //NSMutableArray *records = nil;
    if (records == nil) {
        records = [[NSMutableArray alloc] init];
    }
    
    return records;
}


@end
