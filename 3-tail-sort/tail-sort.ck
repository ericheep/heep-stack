HeapSend h;
Patterns p;

/*
Hid hi;
HidMsg msg;
0 => int device;
if (!hi.openKeyboard(device)) me.exit();
<<< hi.name() + " is fully operational.", "">>>;
*/

250::ms => dur beat;
int lead_off[8];

fun void top() {
    int top_ref_prv[];
    h.arraySort("/top", beat, lead_off, p.patternA(0)) @=> top_ref_prv;
    while (true) {
        h.arraySort("/top", beat, top_ref_prv, p.patternA(0)) @=> top_ref_prv;
        h.arraySort("/top", beat, top_ref_prv, p.patternB(0)) @=> top_ref_prv;
    }
}

fun void bot() {
    int bot_ref_prv[];
    while (true) {
        h.arraySort("/bot", beat, lead_off, p.patternC(2)) @=> bot_ref_prv;
    }
}

fun void go() {
    <<< "~ here we go", "" >>>;
    spork ~ top();
    spork ~ bot();
}

go();

/*
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
*/

while (1::second => now);


