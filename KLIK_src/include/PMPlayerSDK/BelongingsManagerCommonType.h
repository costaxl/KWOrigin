//
//  BelongingsManagerCommonType.h
//

#ifndef _BelongingsManagerCommonType_h
#define _BelongingsManagerCommonType_h

#include "PMConstants.h"

typedef enum {BS_NotExist=0, BS_Discovered, BS_Self} BelongingsState;
typedef enum {DC_MANUAL=0, DC_Lan, DC_Jingle} DiscoveryWay;
typedef enum {SA_NONE=0, SA_EmptyPassword=(0x00000001 << 0)} BMServerAttribute;

#define PM_NOTIFICATION_BELONGINGS_SCAN_STATUS "PM_Notification_Belongings_Scan_Status"


#endif
