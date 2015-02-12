// tail_sort.ck
// Eric Heep

HeapSend h;
Patterns p;

Hid hi;
HidMsg msg;
0 => int device;
if (!hi.openKeyboard(device)) me.exit();
<<< hi.name() + " is fully operational.", "">>>;

int lead_off[6];

fun void top() {
    500::ms => dur beat;
    int top_ref_prv[];
    h.arraySort("/top", beat, lead_off, p.patternA) @=> top_ref_prv;
    while (true) {
        h.arraySort("/top", beat, top_ref_prv, p.patternB) @=> top_ref_prv;
        h.arraySort("/top", beat, top_ref_prv, p.patternC) @=> top_ref_prv;
        h.arraySort("/top", beat, top_ref_prv, p.patternD) @=> top_ref_prv;
        h.arraySort("/top", beat, top_ref_prv, p.patternE) @=> top_ref_prv;
        h.arraySort("/top", beat, top_ref_prv, p.patternF) @=> top_ref_prv;
        h.arraySort("/top", beat, top_ref_prv, p.patternG) @=> top_ref_prv;
        h.arraySort("/top", beat, top_ref_prv, p.patternH) @=> top_ref_prv;
    }
}

fun void bot() {
    500::ms => dur beat;
    int bot_ref_prv[];
    h.arraySort("/bot", beat, lead_off, p.patternA) @=> bot_ref_prv;
    while (true) {
        h.arraySort("/bot", beat, bot_ref_prv, p.patternB) @=> bot_ref_prv;
        h.arraySort("/bot", beat, bot_ref_prv, p.patternC) @=> bot_ref_prv;
        h.arraySort("/bot", beat, bot_ref_prv, p.patternD) @=> bot_ref_prv;
        h.arraySort("/bot", beat, bot_ref_prv, p.patternE) @=> bot_ref_prv;
        h.arraySort("/bot", beat, bot_ref_prv, p.patternF) @=> bot_ref_prv;
        h.arraySort("/bot", beat, bot_ref_prv, p.patternG) @=> bot_ref_prv;
        h.arraySort("/bot", beat, bot_ref_prv, p.patternH) @=> bot_ref_prv;
    }
}

fun void go() {
    <<< "~ here we go ~", "" >>>;
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

while (1::second => now);
