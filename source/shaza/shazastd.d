module shaza.std;

import std.variant;
import std.conv;
import std.typecons;
import std.traits;
import std.stdio;

class Cell {
    private Object _car;
    private Cell _cdr;

    public this(Object value) {
        this._car = value;
        _cdr = null;
    }

    static Cell create(T)(T val)
            if (!isBasicType!T && !isArray!T && !isSomeFunction!T) {
        return new Cell(val);
    }

    static Cell create(T)(T val) if (isBasicType!T) {
        return new Cell(box(val));
    }

    static Cell create(T)(T val) if (isArray!(T)) {
        return new Cell(box(val));
    }

    static Cell create(T)(T val) if (isSomeFunction!(T)) {
        return new Cell(box(val));
    }

    public Object car() {
        return _car;
    }

    public void setCar(Object val) {
        this._car = val;
    }

    public Cell cdr() {
        return _cdr;
    }

    public void setCdr(Cell cdr) {
        this._cdr = cdr;
    }

    public Object cdar() {
        return _cdr.car;
    }

    public Cell cddr() {
        return _cdr.cdr;
    }

    public Object caar() {
        return (cast(Cell) _car).car;
    }

    Object opIndex(size_t index) {
        auto current = this;
        while (index > 0) {
            current = current.cdr;
            index--;
        }
        return current.car;
    }

    override string toString() {
        import std.array;

        Cell current = this;
        auto result = appender("(");

        while (current !is null) {
            result ~= to!string(current.car);
            if (current.cdr !is null)
                result ~= ", ";
            current = current.cdr;
        }
        result ~= ')';

        return result[];
    }
}

/*
Cell cons(Object[] vars...) {
    if (vars.length == 0)
        return null;

    Cell head = Cell.create(vars[0]);
    Cell tail = head;
    for (auto i = 1; i < vars.length; i++)
        head.setCdr(tail = tail._cdr = Cell.create(vars[i]));

    return head;
}
*/

Cell cons(T)(T[] vars...) {
    if (vars.length == 0)
        return null;
    writeln(vars);

    Cell head = Cell.create(vars[0]);

    Cell tail;
    if (vars.length >= 2) {
        tail = Cell.create(vars[1]);
        head.setCdr(tail);
    }

    for (auto i = 2; i < vars.length; i++) {
        Cell ncell = Cell.create(vars[i]);
        tail.setCdr(ncell);
        tail = tail.cdr;
    }

    return head;
}

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
    const T _v;
    alias _v this;

    this(in T v) {
        _v = v;
    }

    T get() {
        return _v;
    }

    override string toString() {
        return to!string(_v);
    }
}

Boxed!T box(T)(T val) {
    return new Boxed!T(val);
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
