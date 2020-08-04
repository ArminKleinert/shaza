module multipersist;

import std.bigint;
import std.datetime.stopwatch;
import std.stdio;

// SECTION Multiplication persistance calculator 1

int multiplicationPersistance(BigInt n) {
    int score = 1;
    BigInt temp;

    while (true) {
        if (n < 10)
            return score;
        score++;
        temp = 1;
        while (n >= 10) {
            temp *= n % 10;
            n /= 10;
        }
        n *= temp;
    }
}

// SECTION Version 1

BigInt version1(int stopat) {
    BigInt record = 0;
    int persistance = 0;
    while (persistance < stopat) {
        persistance = multiplicationPersistance( record);
        record++;
    }
    return record;
}

// SECTION Version 2

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

// SECTION Version 3

BigInt version3(int stopat) {
    BigInt record = 0;
    BigInt expo = 10;
    int persistance = 0;
    while (persistance < stopat) {
        if (record & 1 && record > expo) {
            persistance = multiplicationPersistance( record);
        }
        record++;
        if (record > (expo * 10)) {
            expo *= 10;
        }
    }
    return record;
}

// SECTION Version 4

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
        if (record > expo1) {
            expo *= 10;
            expo1 *= 10;
        }
    }
    return record;
}

// SECTION Version 5

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
        if (record > expo1) {
            expo *= 10;
            expo1 *= 10;
        }
    }
    return record;
}

// SECTION Version 6

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
        if (record > expo1) {
            expo *= 10;
            expo1 *= 10;
            record = expo + 1;
        }
    }
    return record;
}

// SECTION Multiplication persistance calculator 2

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
    n *= temp;

    goto start;
}

// SECTION Version 7

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
        if (record > expo1) {
            expo *= 10;
            expo1 *= 10;
            record = expo + 1;
        }
    }
    return record;
}

//////// Using multiplicationPersistance instead of version 2 again!

// SECTION Version 8

BigInt version8(int stopat) {
    BigInt record = 0;
    BigInt expo = 20;
    BigInt expo1 = 100;
    int persistance = 0;

    while (true) {
        if (record & 1 && record > expo) {
            persistance = multiplicationPersistance( record);
            if (persistance >= stopat)
                break ;
        }

        record++;
        if (record > expo1) {
            expo *= 10;
            expo1 *= 10;
            record = expo + 1;
        }
    }

    return record;
}

// SECTION Version 9

BigInt version9(int stopat) {
    BigInt record = 0;
    BigInt expo = 20;
    BigInt expo1 = 100;
    int persistance = 0;

    while (true) {
        if (record & 1 && record > expo) {
            persistance = multiplicationPersistance( record);
            if (persistance >= stopat)
                return record;
        }

        record++;
        if (record > expo1) {
            expo *= 10;
            expo1 *= 10;
            record = expo + 1;
        }
    }
}

// SECTION Multiplication persistance calculator 3

int multiplicationPersistance3(BigInt n) {
    int score = 1;
    BigInt temp;

    while (true) {
        if (n < 10)
            return score;
        score++;
        temp = 1;
        while (n >= 10 && temp > 0) {
            temp *= n % 10;
            n /= 10;
        }
        n *= temp;
    }
}

// SECTION Version 10

BigInt version10(int stopat) {
    BigInt record = 0;
    BigInt expo = 20;
    BigInt expo1 = 100;
    int persistance = 0;

    while (true) {
        if (record & 1 && record > expo) {
            persistance = multiplicationPersistance3( record);
            if (persistance >= stopat) {
                break ;
            }
        }

        record++;
        if (record > expo1) {
            expo *= 10;
            expo1 *= 10;
            record = expo + 1;
        }
    }
    return record;
}

// SECTION Version 11

BigInt[BigInt] nextNumLookup;

void v11prepareLookup() {
    BigInt record = 21;
    BigInt expo = 20;
    BigInt expo1 = 100;

    while (nextNumLookup.length < 5000) {
        if (record & 1 && record > expo) {
            BigInt n = record;
            BigInt key = record;
            BigInt value = 1;

            while (n >= 10 && value > 0) {
                value *= n % 10;
                n /= 10;
            }
            n *= value;
            nextNumLookup[key] = value;
        }

        record++;
        if (record > expo1) {
            //expo *= 10;
            expo = expo1 << 1;
            expo1 *= 10;
            record = expo + 1;
        }
    }
}

// SECTION Multiplication persistance calculator 4

int multiplicationPersistance4(ref BigInt n) {
    int score = 1;
    BigInt temp;

    while (true) {
        if (n < 10)
            return score;
        if (n in nextNumLookup){
            n = nextNumLookup[n];
            continue ;
        }
        score++;
        temp = 1;
        while (n >= 10 && temp > 0) {
            temp *= n % 10;
            n /= 10;
        }
        n *= temp;
    }
}

BigInt version11(int stopat) {
    BigInt record = 21;
    BigInt expo = 20;
    BigInt expo1 = 100;
    int persistance = 0;

    while (true) {
        if (record & 1 && record > expo) {
            persistance = multiplicationPersistance4( record);
            if (persistance >= stopat) {
                break ;
            }
        }

        record++;
        if (record > expo1) {
            expo *= 10;
            expo1 *= 10;
            record = expo + 1;
        }
    }
    return record;
}

void main() {
    ulong total;
    const int targetPersist = 10;

    StopWatch sw;
    /*
    sw.reset();
    sw.start();
    version1(targetPersist);
    total = sw.peek().total!"msecs"();
    writefln("V1 %s", total);

    sw.reset();
    sw.start();
    version2(targetPersist);
    total = sw.peek().total!"msecs"();
    writefln("V2 %s", total);

    sw.reset();
    sw.start();
    version3(targetPersist);
    total = sw.peek().total!"msecs"();
    writefln("V3 %s", total);

    sw.reset();
    sw.start();
    version4(targetPersist);
    total = sw.peek().total!"msecs"();
    writefln("V4 %s", total);

    sw.reset();
    sw.start();
    version5(targetPersist);
    total = sw.peek().total!"msecs"();
    writefln("V5 %s", total);

    sw.reset();
    sw.start();
    version6(targetPersist);
    total = sw.peek().total!"msecs"();
    writefln("V6 %s", total);

    sw.reset();
    sw.start();
    version7(targetPersist);
    total = sw.peek().total!"msecs"();
    writefln("V7 %s", total);

    sw.reset();
    sw.start();
    version8(targetPersist);
    total = sw.peek().total!"msecs"();
    writefln("V8 %s", total);
    */

    sw.reset();
    sw.start();
    version9(targetPersist);
    total = sw.peek().total!"msecs"();
    writefln("V9 %s", total);

    sw.reset();
    sw.start();
    version10( targetPersist);
    total = sw.peek().total!"msecs"();
    writefln( "V10 %s", total);

    sw.reset();
    sw.start();
    v11prepareLookup();
    total = sw.peek().total!"msecs"();
    writefln( "Lookup: %s", total);
    version11( targetPersist);
    total = sw.peek().total!"msecs"();
    writefln( "V11 %s", total);

    sw.reset();
    sw.start();
    version11( targetPersist);
    total = sw.peek().total!"msecs"();
    writefln( "V11 %s", total);
}

/*
void main() {
    ulong total;
    const int targetPersist = 10;
    BigInt result = 0;

    writeln("Lets go.");

    StopWatch sw;
    sw.reset();
    sw.start();
    result = findPersistance12(result);
    total = sw.peek().total!"msecs"();
    writefln("Num: %s\nTime: %s", result, total);
}
*/

/*
With default build option:
V1 111315
V2 68158
V3 74255
V4 68587
V5 45282
V6 39699
V7 39344
V8 40238
V9 40133

With release option:
V1 88910
V2 52766
V3 56306
V4 53071
V5 34012
V6 30773
V7 30696
V8 30800
V9 30735
V10 25367
*/
