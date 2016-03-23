//
//  GUIModelService.m
//

#import "GUIModelService.h"
NSString * const NSSPresentStateDidChangeNotification = @"NSSPresentStateDidChangeNotification";

@implementation GUIModelService


static GUIModelService* defaultModelService=nil;
+(GUIModelService*) defaultModelService
{
    return defaultModelService;
}

-(id)init
{
    self =[super init];
    if(!self)
        return nil;
    
    self.m_PeerManager = [[GUIPeerManager alloc] init];
    self.m_NSSserver = [[NSSServer alloc] init];
    self.m_FSServer = [[FSServer alloc] init];
    
    [PMSystem defaultPMSystem].m_BelongingsRecordHolder = self.m_PeerManager;
    [self LoadSetting];
    defaultModelService = self;

    return self;
}
-(void) dealloc
{
    if (self.m_FSServer)
        [self.m_FSServer dealloc];

    if (self.m_NSSserver)
        [self.m_NSSserver dealloc];

    if (self.m_PeerManager)
        [self.m_PeerManager dealloc];
    
    if (self.m_AppSetting)
        [self.m_AppSetting dealloc];
    
    if ([PMSystem defaultPMSystem])
        [PMSystem releaseDefaultPMSystem];
    [super dealloc];

}
- (void)SaveSetting
{
    [self SaveSetting:self.m_AppSetting];
}
- (void)SaveSetting:(AppSetting*)Setting
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/iDocShareSetting", directory];
    
    NSMutableArray *array = [[NSMutableArray alloc]initWithObjects:Setting, nil];
    
    [NSKeyedArchiver archiveRootObject:array toFile:fileName];
}
- (BOOL)LoadSetting
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/iDocShareSetting", directory];
    
    NSMutableArray *records = [[NSKeyedUnarchiver unarchiveObjectWithFile:fileName] retain];
    //NSMutableArray *records = nil;
    if (self.m_AppSetting)
        [self.m_AppSetting dealloc];
    
    if (records == nil)
    {
        self.m_AppSetting = [[AppSetting alloc] init];
    }
    else
    {
        self.m_AppSetting = [records objectAtIndex:0];
    }
    if (self.m_AppSetting.m_ScreenShareServerRecord)
        self.m_AppSetting.m_ScreenShareServerRecord.m_bValid = true;
    if (self.m_AppSetting.m_FileServerRecord)
        self.m_AppSetting.m_FileServerRecord.m_bValid = true;
    return true;

}

@end


