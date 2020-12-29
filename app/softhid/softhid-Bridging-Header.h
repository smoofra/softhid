//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#include <IOKit/Serial/ioss.h>
#include <IOKit/hidsystem/IOLLEvent.h>

const unsigned long kIOSSIOSPEED = IOSSIOSPEED;

const unsigned long kLEFT_CONTROL  = NX_DEVICELCTLKEYMASK;
const unsigned long kRIGHT_CONTROL = NX_DEVICERCTLKEYMASK;

const unsigned long kLEFT_OPTION  = NX_DEVICELALTKEYMASK;
const unsigned long kRIGHT_OPTION = NX_DEVICERALTKEYMASK;

const unsigned long kLEFT_SHIFT  = NX_DEVICELSHIFTKEYMASK;
const unsigned long kRIGHT_SHIFT = NX_DEVICERSHIFTKEYMASK;

const unsigned long kLEFT_COMMAND = NX_DEVICELCMDKEYMASK;
const unsigned long kRIGHT_COMMAND = NX_DEVICERCMDKEYMASK;
