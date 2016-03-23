//
//  DataManagerApple.h
//  Created by tywang on 2015/5/7.
//
//

#ifndef __DataManagerApple__
#define __DataManagerApple__
#import <Foundation/Foundation.h>

#define DS_SUCCESS 0
#define DS_ERROR -1
#define DS_BLOCK -2
#define DS_EOS -3

#define DSEvent_None 0,
#define DSEvent_OpenComplete  (1UL << 0)
#define DSEvent_DataAvailable  (1UL << 1)
#define DSEvent_SpaceAvailable (1UL << 2)
#define DSEvent_ErrorOccurred (1UL << 3)
#define DSEvent_EndEncountered (1UL << 4)


@interface DataServiceApple : NSObject
{
#if !defined(_LP64) && !defined (IOS)
    void* _m_pService;
    void* _m_DataHandlerMap;
#endif
}

- (uint32_t) GetTransportAdmission:(id)anObserver selector:(SEL)aSelector;
- (uint32_t) GetTransportAdmission:(uint32_t) ReceiverTicket Observer:(id)anObserver selector:(SEL)aSelector ExchangeID:(uint32_t)aExchange;
- (bool) SetReceiverTicket:(uint32_t) TransportTicket ReceiverTicket:(uint32_t) aReceiverTicket;
- (void) ReturnTransportAdmission:(uint32_t) ticket;
- (uint32_t) RegisterDataReceiver:(uint32_t) ticket Observer:(id)anObserver selector:(SEL)aSelector;
- (void) UnregisterDataReceiver:(uint32_t) ticket;

- (bool) CanSendData;
- (bool) CanReceiveData;

@end



#endif

