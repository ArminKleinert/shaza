module shaza.std;

import std.variant;
import std.conv;
import std.typecons;

struct Symbol {
    const string name;
    alias name this;
    public this(string _name) {
        name = _name;
    }
}

class ShazaError : Error {
    public this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }

    public this(string[] ss...) {
        string msg = "";
        foreach (string t; ss) {
            msg ~= t;
        }
        super(msg, __FILE__, __LINE__);
    }
}

class Boxed(T) {
    T _v;
    alias _v this;

    this(in T v) {
        _v = v;
    }
}

struct Keyword {
    const string text;

    this(string text) {
        this.text = text;
    }

    string toString() {
        return text;
    }
}

struct ClassKeyword {
    const string text;

    this(string text) {
        this.text = text;
    }

    string toString() {
        return text;
    }
}

alias SzVector(T) = T[];

class SzNull {
    private this() {
    }

    // Cache instantiation flag in thread-local bool
    // Thread local
    private static bool instantiated_;

    // Thread global
    private __gshared SzNull instance_;

    static SzNull get() {
        if (!instantiated_) {
            synchronized (SzNull.classinfo) {
                if (!instance_)
                    instance_ = new SzNull();
                instantiated_ = true;
            }
        }

        return instance_;
    }

    static SzNull nil() {
        return get();
    }

    override string toString() {
        return "nil";
    }
}

alias SzMap(K, V) = V[K];

/*
class SzVector(T) {
    T[] val;

    this(T[] val) {
        this.val = val;
    }

    public override string toString() {
        string res = "[";
        foreach (v; val) {
            res ~= to!string(v);
            res ~= ", ";
        }
        res = res[0 .. $ - 2];
        res ~= "]";
        return to!string(val);
    }

    public SzVector append(T v) {
        return new SzVector(val ~ v);
    }

    public SzVector appendAll(SzVector sv) {
        return new SzVector(val ~ sv.val);
    }

    public size_t size() {
        return val.length;
    }

    public T get(int v) {
        return val[v];
    }
}

class SzMap(K, V) {
    V[K] val;

    this(V[K] val) {
        this.val = val;
    }

    this() {
    }

    public override string toString() {
        string res = "{";
        foreach (k, v; val) {
            res ~= to!string(k);
            res ~= " ";
            res ~= to!string(v);
            res ~= ", ";
        }
        res = res[0 .. $ - 2];
        res ~= "}";
        return to!string(val);
    }

    public SzMap assoc(K key, V value) {
        Variable[Variable] newVal = val.dup;
        newVal[key] = value;
        return new SzMap(newVal);
    }

    public size_t size() {
        return val.length;
    }

    public Variable get(Variable key) {
        return val[key];
    }

    public Variable[] keys(Variable key) {
        return val.keys;
    }
}
*/
