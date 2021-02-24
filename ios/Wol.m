
#import "Wol.h"

@implementation Wol

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(
  send:(NSString *)ipAddress 
  macParamater:(nonnull NSString *)macAddress 
  callback:(RCTResponseSenderBlock)callback)
{
      //construct mac address
    unsigned char magicPacket[102];
    unsigned char mac[6];
    for(int i = 0; i < 6; i++)
    {
        magicPacket[i] = 0xff;
    }

    NSArray *splitMacStrArr = [macAddress componentsSeperatedByString:@":"];

    for (NSUInteger i = 0; i < 6; i++) {
      unsigned char result = 0;
      NSScanner *scanner = [NSScanner scannerWithString:[splitMacStrArr objectAtIndex;i]];
      [scanner scanHexInt:&result];
      mac[i] = result;
    }
    
    for(int i = 1; i <= 16; i++)
    {
        memcpy(&magicPacket[i * 6], &mac, 6 * sizeof(unsigned char));
    }
    
    //construct ip address and port number
    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_len = sizeof(addr);
    addr.sin_family = AF_INET;
    addr.sin_port = htons(9);
    //substitute the ip address of your device here
    inet_aton(ipAddress, &addr.sin_addr);
    
    //create socket using CFSocket
    //sending magic packet through UDP protocol
    CFSocketRef WOLSocket;
    WOLSocket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_DGRAM, IPPROTO_UDP, 0, NULL, NULL);
    if ( WOLSocket == NULL) {
      callback(@[[false , "Wake-On-LAN packet has not been sent."]]);
    } else if( WOLSocket ) {
            NSLog(@"Socket created :)");
            CFDataRef sendAddr = CFDataCreate(NULL, (unsigned char *)&addr, sizeof(addr));
            CFDataRef Data = CFDataCreate(NULL, (const UInt8*)magicPacket, sizeof(magicPacket));
            CFSocketSendData(WOLSocket, sendAddr, Data, -1);
            callback(@[[true , "Wake-On-LAN packet has been sent."]]);
    }


}

@end