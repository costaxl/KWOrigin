//
//  PMFolderInfoCollectorApple.h
//

#import <Foundation/Foundation.h>
#import "PMGUIBridgeApple.h"

#if defined(IOS)
@interface PMFolderEntryInfoApple : NSObject <NSCoding>
#else
@interface PMFolderEntryInfoApple : NSObject
#endif
{
}
@property (copy) NSString*	Name;
@property (copy) NSString*	FullPath;
// kNone = 0, kFolder = 1, kFile = 2, kOther = 3
@property uint32_t Type;
@property uint32_t CreateTime;
@property uint32_t ModifyTime;
@property uint32_t AccessTime;
@property int32_t Size;
@property (copy) NSString*	FileType;

- (void) Copy:(PMFolderEntryInfoApple*) Source;
#if defined (IOS)
- (id)initWithCoder:(NSKeyedUnarchiver *)coder;
- (void)encodeWithCoder:(NSKeyedArchiver *)coder;
#endif
@end



@interface PMFolderInfoCollectorApple : PMGUIBridgeApple
{
#if !defined(_LP64) && !defined (IOS)
    void* _m_pCollector;
#endif
}
-(int32_t) First;
-(int32_t) Last;
-(int32_t) Next;
-(int32_t) Privous;
-(int32_t) Goto:(int) index;
-(int32_t) GetSize;

-(PMFolderEntryInfoApple*) GetInfo;

-(bool) StartGroupingByFileType;
-(void) StopGrouping;
-(int32_t) GetGroupCount;
-(PMFolderInfoCollectorApple*) GetGroup:(int) index;
-(NSString*) GetKeyValue;
-(void) SetAllowedType:(NSString*)allowedType;

- (bool) handleNotify:(NSDictionary*)Info;


@end
