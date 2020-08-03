module multipersist;

import std.bigint;
import std.datetime.stopwatch;
import std.stdio;

int multiplicationPersistance(BigInt n) {
    int score = 1;
    BigInt temp;

    while(true) {
        if (n < 10)
            return score;
        score++;
        temp = 1;
        while (n >= 10) {
            temp *= n % 10;
            n /= 10;
        }
        n = temp * n;
    }
}

BigInt version1(int stopat) {
    BigInt record = 0;
    int persistance = 0;
    while (persistance < stopat) {
        persistance = multiplicationPersistance( record);
        record++;
    }
    return record;
}

BigInt version2(int stopat) {
    BigInt record = 0;
    int persistance = 0;
    while (persistance < stopat) {
        if (record & 1) {
            persistance = multiplicationPersistance( record);
        }
        record++;
    }
    return record;
}

BigInt version3(int stopat) {
    BigInt record = 0;
    BigInt expo = 10;
    int persistance = 0;
    while (persistance < stopat) {
        if (record & 1 && record > expo) {
            persistance = multiplicationPersistance( record);
        }
        record++;
        if (record > (expo * 10)){
            expo *= 10;
        }
    }
    return record;
}

BigInt version4(int stopat) {
    BigInt record = 0;
    BigInt expo = 10;
    BigInt expo1 = 100;
    int persistance = 0;
    while (persistance < stopat) {
        if (record & 1 && record > expo) {
            persistance = multiplicationPersistance( record);
        }
        record++;
        if (record > expo1){
            expo *= 10;
            expo1 *= 10;
        }
    }
    return record;
}

BigInt version5(int stopat) {
    BigInt record = 0;
    BigInt expo = 20;
    BigInt expo1 = 100;
    int persistance = 0;
    while (persistance < stopat) {
        if (record & 1 && record > expo) {
            persistance = multiplicationPersistance( record);
        }
        record++;
        if (record > expo1){
            expo *= 10;
            expo1 *= 10;
        }
    }
    return record;
}

BigInt version6(int stopat) {
    BigInt record = 0;
    BigInt expo = 20;
    BigInt expo1 = 100;
    int persistance = 0;
    while (persistance < stopat) {
        if (record & 1 && record > expo) {
            persistance = multiplicationPersistance( record);
        }
        record++;
        if (record > expo1){
            expo *= 10;
            expo1 *= 10;
            record = expo + 1;
        }
    }
    return record;
}

int multiplicationPersistance2(BigInt n) {
    int score = 1;
    BigInt temp;

    start:

    if (n < 10)
        return score;
    score++;
    temp = 1;
    while (n >= 10) {
        temp *= n % 10;
        n /= 10;
    }
    n = temp * n;

    goto start;
}

BigInt version7(int stopat) {
    BigInt record = 0;
    BigInt expo = 20;
    BigInt expo1 = 100;
    int persistance = 0;
    while (persistance < stopat) {
        if (record & 1 && record > expo) {
            persistance = multiplicationPersistance2( record);
        }
        record++;
        if (record > expo1){
            expo *= 10;
            expo1 *= 10;
            record = expo + 1;
        }
    }
    return record;
}

BigInt version8(int stopat) {
    BigInt record = 0;
    BigInt expo = 20;
    int persistance = 0;
    while (persistance < stopat) {
        if (record & 1 && record > expo) {
            persistance = multiplicationPersistance2( record);
        }
        record++;
        if (record > (expo * 10)){
            expo *= 10;
            record = expo + 1;
        }
    }
    return record;
}

void main() {
    ulong total;
    const uint targetPersist = 10;

    //for (int i = 0; i < 5; i++){
    StopWatch sw;
    sw.reset();
    sw.start();
    version1( targetPersist);
    total = sw.peek().total!"msecs"();
    writefln( "V1 %s", total);

    sw.reset();
    sw.start();
    version2( targetPersist);
    total = sw.peek().total!"msecs"();
    writefln( "V2 %s", total);

    sw.reset();
    sw.start();
    version3( targetPersist);
    total = sw.peek().total!"msecs"();
    writefln( "V3 %s", total);

    sw.reset();
    sw.start();
    version4( targetPersist);
    total = sw.peek().total!"msecs"();
    writefln( "V4 %s", total);

    sw.reset();
    sw.start();
    version5( targetPersist);
    total = sw.peek().total!"msecs"();
    writefln( "V5 %s", total);

    sw.reset();
    sw.start();
    version6( targetPersist);
    total = sw.peek().total!"msecs"();
    writefln( "V6 %s", total);

    sw.reset();
    sw.start();
    version7( targetPersist);
    total = sw.peek().total!"msecs"();
    writefln( "V7 %s", total);

    sw.reset();
    sw.start();
    version8( targetPersist);
    total = sw.peek().total!"msecs"();
    writefln( "V8 %s", total);
    //}
}
