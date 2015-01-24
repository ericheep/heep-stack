HeapSend h;
Patterns p;

Hid hi;
HidMsg msg;
0 => int device;
if (!hi.openKeyboard(device)) me.exit();
<<< hi.name() + " is fully operational.", "">>>;

dur beat;
int lead_off[12];

fun void top() {
    int top_ref_prv[];
    h.arraySort("/top", beat, lead_off, p.patternD(inc)) @=> top_ref_prv;
    h.arraySort("/top", beat, top_ref_prv, p.patternC(inc)) @=> top_ref_prv;
    h.arraySort("/top", beat, top_ref_prv, p.patternE(inc)) @=> top_ref_prv;
    h.arraySort("/top", beat, top_ref_prv, p.patternD(inc)) @=> top_ref_prv;
}

fun void bot() {
    int bot_ref_prv[];
    h.arraySort("/bot", beat, lead_off, p.patternC(inc)) @=> bot_ref_prv;
    h.arraySort("/bot", beat, bot_ref_prv, p.patternB(inc)) @=> bot_ref_prv;
    h.arraySort("/bot", beat, bot_ref_prv, p.patternD(inc)) @=> bot_ref_prv;
    h.arraySort("/bot", beat, bot_ref_prv, p.patternC(inc)) @=> bot_ref_prv;
}

fun void go() {
    spork ~ top();
    spork ~ bot();
}

while (true) {
    hi => now;
    while (hi.recv(msg)) {
        if (msg.isButtonDown()) {
            if (msg.ascii == 96) {
                go();
            }
        }
    }
}


