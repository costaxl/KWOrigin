//
//  main.m
//  MobileVLC
//
//  Created by Pierre d'Herbemont on 6/27/10.
//  Copyright Applidium 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GUIAPPDelegate.h"

int main(int argc, char *argv[])
{
    // Install signal hander
	struct sigaction sigact;
	sigact.sa_flags = 0;
	sigact.sa_flags = sigact.sa_flags | SA_NODEFER | SA_RESETHAND;
	//sigact.sa_handler = TerminalHandler;
	sigaction( SIGUSR1, &sigact, NULL );
    
    
    int err;
	err = sigaction(SIGPIPE, NULL, &sigact);
	if(err == 0 && sigact.sa_handler != SIG_IGN) {
		sigact.sa_handler = SIG_IGN;
		sigaction(SIGPIPE, &sigact, NULL);
	}

    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([GUIAPPDelegate class]));
    }
}
