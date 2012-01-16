#! /usr/bin/env python
# avahi-alias.py
# Source: http://www.avahi.org/wiki/Examples/PythonPublishAlias

import avahi, dbus
from encodings.idna import ToASCII

# Got these from /usr/include/avahi-common/defs.h
CLASS_IN = 0x01
TYPE_CNAME = 0x05

TTL = 60

def publish_cname(cname):
    bus = dbus.SystemBus()
    server = dbus.Interface(bus.get_object(avahi.DBUS_NAME, avahi.DBUS_PATH_SERVER),
            avahi.DBUS_INTERFACE_SERVER)
    group = dbus.Interface(bus.get_object(avahi.DBUS_NAME, server.EntryGroupNew()),
            avahi.DBUS_INTERFACE_ENTRY_GROUP)

    rdata = createRR(server.GetHostNameFqdn())
    cname = encode_dns(cname)

    group.AddRecord(avahi.IF_UNSPEC, avahi.PROTO_UNSPEC, dbus.UInt32(0),
        cname, CLASS_IN, TYPE_CNAME, TTL, rdata)
    group.Commit()


def encode_dns(name):
    out = []
    for part in name.split('.'):
        if len(part) == 0: continue
        out.append(ToASCII(part))
    return '.'.join(out)

def createRR(name):
    out = []
    for part in name.split('.'):
        if len(part) == 0: continue
        out.append(chr(len(part)))
        out.append(ToASCII(part))
    out.append('\0')
    return ''.join(out)

if __name__ == '__main__':
    import time, sys, locale
    for each in sys.argv[1:]:
        name = unicode(each, locale.getpreferredencoding())
        publish_cname(name)
    try:
        # Just loop forever
        while 1: time.sleep(60)
    except KeyboardInterrupt:
        print "Exiting"
