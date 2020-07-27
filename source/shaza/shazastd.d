module shaza.std;

import std.variant;
import std.conv;
import std.typecons;

alias SzInt = Algebraic!(byte, short, int, long);
alias SzUInt = Algebraic!(ubyte, ushort, uint, ulong);
alias SzFloat = Algebraic!(float, double);
alias SzNum = Algebraic!(byte, short, int, long, ubyte, ushort, uint, ulong, float, double);

TypeInfo_Class[ClassKeyword] globalTypeMap;

class Namespace {
    __gshared static Namespace globalNs = new Namespace("user");

    const string name;
    Scope nsScope;

    static this() {
    }

    this(string name) {
        this.name = name;
        nsScope = new Scope(null);
    }

    void put(string sym, Variable var) {
        nsScope.putGlobal(sym, var);
    }

    Variable find(string sym) {
        return nsScope.find(sym);
    }

    SzFunction findFn(string sym) {
        return nsScope.find(sym).get!(SzFunction);
    }
}

class Scope {
    Variable[string] variables;
    Scope parent;

    this(Scope _parent) {
        parent = _parent;
    }

    Variable find(string sym) {
        Variable NOTFOUND = variable(0);
        Variable res;
        Scope current = this;
        while (current !is null) {
            res = current.find(sym);
            if (res is NOTFOUND) {
                return res;
            }
            current = current.parent;
        }
        throw new ShazaError("Name not found: ", sym);
    }

    void put(string sym, Variable var) {
        variables[sym] = var;
    }

    void putGlobal(string sym, Variable var) {
        if (parent is null) {
            variables[sym] = var;
            return;
        }
        parent.putGlobal(sym, var);
    }
}

struct Symbol {
    const string name;
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
        return ":" ~ text;
    }
}

struct ClassKeyword {
    const string text;

    this(string text) {
        this.text = text;
    }

    string toString() {
        return "::" ~ text;
    }
}

/*
union Value {
    SzNum numValue;
    string stringValue;
    void* voidPtrValue;
    SzVector vectorValue;
    SzMap mapValue;
    SzFunction funcValue;
    bool boolValue;
}
*/

class SzVector {
    Variable[] val;

    this(Variable[] val) {
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

    public SzVector append(Variable v) {
        return new SzVector(val ~ v);
    }

    public SzVector appendAll(SzVector sv) {
        return new SzVector(val ~ sv.val);
    }

    public size_t size() {
        return val.length;
    }

    public Variable get(int v) {
        return val[v];
    }
}

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

class SzMap {
    Variable[Variable] val;

    this(Variable[Variable] val) {
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

    public SzMap assoc(Variable key, Variable value) {
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

union SzFunctionInner {
    Variable delegate() p0;
    Variable delegate(Variable v) p1;
    Variable delegate(Variable v0, Variable v1) p2;
    Variable delegate(Variable v0, Variable v1, Variable v2) p3;
    Variable delegate(Variable[] vs) pn;
}

class SzFunction {
    SzFunctionInner val;
    int numParams;

    this(SzFunctionInner val, int numParams) {
        this.val = val;
        this.numParams = numParams;
    }

    this(Variable delegate() val) {
        this.val = SzFunctionInner(val);
        this.numParams = 0;
    }

    this(Variable delegate(Variable) val) {
        SzFunctionInner f = {p1: val};
        this(f, 1);
    }

    this(Variable delegate(Variable, Variable) val) {
        SzFunctionInner f = {p2: val};
        this(f, 2);
    }

    this(Variable delegate(Variable, Variable, Variable) val) {
        SzFunctionInner f = {p3: val};
        this(f, 3);
    }

    this(Variable delegate(Variable[]) val) {
        SzFunctionInner f = {pn: val};
        this(f, -1);
    }

    public Variable opCall(Variable[] args) {
        if (numParams != -1 && (args.length != numParams)) {
            throw new ShazaError(toString(), ": Wrong number of parameters (",
                    to!string(args.length), ")");
        }
        switch (numParams) {
        case 0:
            return val.p0();
        case 1:
            return val.p1(args[0]);
        case 2:
            return val.p2(args[0], args[1]);
        case 3:
            return val.p3(args[0], args[1], args[2]);
        default:
            return val.pn(args);
        }
    }

    public Variable opCall() {
        if (numParams > 0) {
            throw new ShazaError(toString(), ": Wrong number of parameters (0)");
        }
        switch (numParams) {
        case 0:
            return val.p0();
        default:
            return val.pn([]);
        }
    }

    public override string toString() {
        return "<Function " ~ to!string(val) ~ "(" ~ to!string(numParams) ~ ")>";
    }
}

class Cell {
    Variable v;
    Cell next;

    this(Variable v) {
        this.v = v;
    }

    this(Variable v, Cell c) {
        this.v = v;
        this.next = c;
    }

    Variable car() {
        return v;
    }

    Cell cdr() {
        return next;
    }

    Cell withCdr(Cell c) {
        return new Cell(v, c);
    }
}

// TODO Finish the class!
alias SzList = SzVector;

/*
class SzList {
    Cell cell;

    this() {
    }

    this(Cell _head) {
        cell = _head;
    }

    public override string toString() {
        string res = "(";
        SzList n = this;
        while (!(n.next is null)) {
            res ~= n.val.toString();
            res ~= ", ";
        }
        res = res[0 .. $-2];
        res ~= ")";
        return to!string(val);
    }

    private Cell copyCells(Cell c) {
        Cell res = new Cell(c.car());
        Cell n;
        while (res.cdr() !is null) {

        }return res;
    }

    public SzList append(Variable v) {
        if (cell is null) {
            return new SzList(new Cell(v));
        }

    }

    public int size() {
        int n;
        Cell curr = cell;

        while (curr !is null) {
            n++;
        }

        return n;
    }

    public Variable first() {
        return cell is null ? SzNull.get : cell.v;
    }

    public Variable next() {
        return variable(next);
    }

    public Variable rest() {
        return variable(next);
    }
}
*/

alias Variable = Algebraic!(SzNull, long, double, ulong, string, void*,
        Symbol, ClassKeyword, Keyword, bool, SzVector, SzMap, SzFunction);

Variable variable(T)(T val) {
    return Variable(val);
}

Variable variable(bool val) {
    return Variable(val);
}

Variable variable(byte val) {
    return Variable(to!long(val));
}

Variable variable(short val) {
    return Variable(to!long(val));
}

Variable variable(int val) {
    return Variable(to!long(val));
}

Variable variable(uint val) {
    return Variable(to!ulong(val));
}

Variable variable(float val) {
    return Variable(to!double(val));
}

Variable fnToVariable(Variable delegate() val) {
    return Variable(new SzFunction(val));
}

Variable fnToVariable(Variable delegate(Variable) val) {
    return Variable(new SzFunction(val));
}

Variable fnToVariable(Variable delegate(Variable, Variable) val) {
    return Variable(new SzFunction(val));
}

Variable fnToVariable(Variable delegate(Variable, Variable, Variable) val) {
    return Variable(new SzFunction(val));
}

Variable fnToVariable(Variable delegate(Variable[]) val) {
    return Variable(new SzFunction(val));
}

/*
class Variable {
    ClassKeyword type;
    Value val;

    this(T)(T val) {
        this.type = getKeywordForTypeOf(val);
        this.val = szValue(val);
    }

    this(T)(T val, ClassKeyword type) {
        this.type = type;
        this.val = szValue(val);
    }

    override string toString() {
        switch(type.text) {
            case "any":
            return to!string(val.voidPtrValue);
            case "number":
            return to!string(val.numValue);
            case "int":
            return to!string(val.numValue);
            case "int8":
            return to!string(val.numValue);
            case "int16":
            return to!string(val.numValue);
            case "int32":
            return to!string(val.numValue);
            case "int64":
            return to!string(val.numValue);
            case "float":
            return to!string(val.numValue);
            case "float32":
            return to!string(val.numValue);
            case "float64":
            return to!string(val.numValue);
            case "string":
            return to!string(val.stringValue);
            case "vector":
            return to!string(val.vectorValue);
            case "list":
            return to!string(val.vectorValue);
            case "map":
            return to!string(val.mapValue);
            case "boolean":
            return to!string(val.boolValue);
            case "function":
            return to!string(val.funcValue);
            default:
            return to!string(val);
        }
    }
}
*/

/*
void shazaInit() {
    globalTypeMap = [
    ClassKeyword("any") : Variable.classinfo,
    ClassKeyword("number"): Boxed!SzNum.classinfo,
    ClassKeyword("int"): Boxed!SzInt.classinfo,
    ClassKeyword("int8"): Boxed!byte.classinfo,
    ClassKeyword("int16"): Boxed!short.classinfo,
    ClassKeyword("int32"): Boxed!int.classinfo,
    ClassKeyword("int64"): Boxed!long.classinfo,
    ClassKeyword("float"): Boxed!SzFloat.classinfo,
    ClassKeyword("float32"): Boxed!float.classinfo,
    ClassKeyword("float64"): Boxed!double.classinfo,
    ClassKeyword("string"): Boxed!string.classinfo,
    ClassKeyword("vector"): SzVector.classinfo,
    ClassKeyword("list"): SzList.classinfo,
    ClassKeyword("map"): SzMap.classinfo,
    ClassKeyword("boolean"): Boxed!bool.classinfo,
    ClassKeyword("function"): SzFunction.classinfo,
    ];
}
*/

static Namespace get_current_ns() {
    return Namespace.globalNs;
}

/*
// TODO
ClassKeyword getKeywordForTypeOf(T)(T value) {
    return ClassKeyword("int");
}
*/

Namespace define_ns(string name) {
    return new Namespace(name);
}

T* shaza_define(T)(string name, T* value) {
    Namespace ns = get_current_ns();
    ns.variables ~= new Variable(value, T);
    return value;
}

/*
// TODO
Value szValue(T)(T v) {
    Value res;
    res.stringValue = v;
    return res;
}
*/
