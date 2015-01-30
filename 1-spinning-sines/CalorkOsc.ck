// CalorkOsc.ck
// Eric Heep

public class CalorkOsc {
    // sets max number of OscOut objects
    10 => int NUM_ADDRS;
    OscOut out[NUM_ADDRS];
    OscMsg out_msg[NUM_ADDRS];

    // OscIn objects 
    OscIn in;
    OscMsg in_msg;

    // int for counting number of Osc objects
    int idx;
    57120 => int listening_port;
    57120 => int sending_port;

    // address variables
    string my_addr;
    string addrs[0];

    // parameter arrays
    float params[0][NUM_ADDRS];
    string param_list[0];

    // sets your name for outgoing messages, defaults port to 57120
    public void myAddr(string id) {
        init(id, listening_port);    
    }

    // overloaded myAddr, in case you'd want to change the port
    public void myAddr(string id, int lp) {
        id => my_addr;
        // sets in.port to lp
        lp => listening_port => in.port;
        // sets port to listen for all messages
        in.listenAll();
    }
 
    // searches for the index location of an array
    private int arg(string str, string arr[]) {
        for (int i; i < arr.cap(); i++) {
            if (str == arr[i]) {
                return i; 
            }
        }
    }

    // ensures proper parameter names are given
    private int check(string val, string arr[]) {
        for (int i; i < arr.cap(); i++) {
            if (val == arr[i]) {
                return 1;
            }
        }
        return 0;
    }

    // retrieves parameter using address and parameter type
    public float getParam(string addr, string param) {
        for (int i; i < addrs.cap(); i++) {
            if (addr == addrs[i]) {
                return params[param][i]; 
            }
        }
    }

    // setup up which params you'll want to listen for in a script
    public void setParams(string arr[]) {
        float add[NUM_ADDRS];
        for (int i; i < arr.cap(); i++) {
            params << add;
            param_list << arr[i];
            params[i] @=> params[param_list[i]];
        }
    }

    // overloaded addIp, sets ip and name association, defaults port to 57120
    public void addIp (string ip, string addr) {
        addIp(ip, addr, sending_port);
    }

    //  addIp, sets ip, name association, and port number
    public void addIp (string ip, string addr, int p) {
        out[idx].dest(ip, p);
        addrs << addr; 
        idx++;
    }

    // spork to begin recieving, set addrs/ips/params before receiving
    public void recv() {
        // params
        int pos;
        string addr, param;

        // recieves Osc from whatever
        while (true) {
            in => now;
            while (in.recv(in_msg)) {
                if (in_msg.numArgs() == 1) {
                    in_msg.address.rfind("/") => pos;
                    in_msg.address.substring(0, pos) => addr;
                    in_msg.address.substring(pos) => param;

                    // ensures a valid message 
                    if (check(addr, addrs) && check(param, param_list)) {
                        in_msg.getFloat(0) => params[param][arg(addr, addrs)];
                    }
                }
                if (in_msg.numArgs() == 2) {
                    in_msg.address => addr;
                    in_msg.getString(0) => param;

                    // ensures a valid message 
                    if (check(addr, addrs) && check(param, param_list)) {
                        in_msg.getFloat(1) => params[param][arg(addr, addrs)];
                    }
                }
            }
        }
    }

    // sends Osc message using standard Osc params 
    public void send(string addr, string param, float val) {
        int idx;
        if (addr != "/all" || addr != "/random") {
            for (int i; i < addrs.cap(); i++) {
                if (addrs[i] == addr) {
                    i => idx;
                }
            }
            out[idx].start(my_addr); 
            out[idx].add(param);
            out[idx].add(val); 
            out[idx].send();
        }
        if (addr == "/random") {
            Math.random2(0, addrs.cap() - 1) => idx;
            out[idx].start(my_addr); 
            out[idx].add(param);
            out[idx].add(val); 
            out[idx].send();
        }
        if (addr == "/all") {
            for (int i; i < addrs.cap(); i++) {
                out[i].start(my_addr); 
                out[i].add(param);
                out[i].add(val); 
                out[i].send();
            }
        }
    }
}

/*
// some example code
// shows how to set up and get params

CalorkOsc c;

// set your sending address
c.myAddr("/eric");

// add one IP and address at a time, two string arguments
c.addIp("169.254.87.91", "/justin");
c.addIp("169.254.223.167", "/danny");
c.addIp("169.254.207.86", "/mike");
c.addIp("169.254.74.231", "/shaurjya");
c.addIp("169.254.24.203", "/ed");

// notice the brackets
// you'll have to setup your parameters as an array of strings
c.setParams(["/freq", "/vol", "/chaos"]);

spork ~ c.recv();

while (true) {
    // c.send("/all", "/vol", 0.1);
    // c.send("/random", "/vol", 0.1);
    // c.send("/ed", "/freq", 0.518);
    <<< c.getParam("/ed", "/freq") >>>;
    100::ms => now;
}
*/
