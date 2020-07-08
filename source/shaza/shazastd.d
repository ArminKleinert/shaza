module shaza.shaza.std;

import std.variant;
import std.conv;
import std.typecons;

alias SzInt = Algebraic!(byte, short, int, long);
alias SzUInt = Algebraic!(ubyte, ushort, uint, ulong);
alias SzFloat = Algebraic!(float, double);
alias SzNum = Algebraic!(byte, short, int, long, ubyte, ushort, uint, ulong, float, double);

TypeInfo_Class[ClassKeyword] globalTypeMap;

class Namespace {
    string name;
    Variable*[] variables;

    this (string name) {
        this.name = name;
        variables = [];
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

union Value {
    long intValue;
    double doubleValue;
    string stringValue;
    void* voidPtrValue;
    Value[] vectorValue;
    Value[Value] mapValue;
    Value delegate(Value[] x) funcValue;
}

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
        res = res[0 .. $-2];
        res ~= "]";
        return to!string( val);
    }
}

class SzMap {
    Variable[Variable] val;

    this(Variable[Variable] val) {
        this.val = val;
    }

    public override string toString() {
        string res = "{";
        foreach (k, v; val) {
            res ~= to!string(k);
            res ~= " ";
            res ~= to!string(v);
            res ~= ", ";
        }
        res = res[0 .. $-2];
        res ~= "}";
        return to!string( val);
    }
}

union SzFunctionInner {
    Variable delegate(Variable v) singleParam;
    Variable delegate(Variable v0, Variable v1) pairParam;
    Variable delegate(Variable v0, Variable v1, Variable v2) tripleParam;
    Variable delegate(Variable[] vs) multiParam;
}

class SzFunction {
    SzFunctionInner val;
    int numParams;

    this(SzFunctionInner val, int numParams) {
        this.val = val;
        this.numParams = numParams;
    }

    public override string toString() {
        return "<Function " ~ to!string(val) ~ "(" ~ to!string(numParams) ~ ")>";
    }
}

class SzList {
    Variable val;
    SzList next;

    this(Variable val, SzList next) {
        this.val = val;
        this.next = next;
    }

    public override string toString() {
        string res = "(";
        SzList n = this;
        while (n.next is null) {
            res ~= n.val.toString();
            res ~= ", ";
        }
        res = res[0 .. $-2];
        res ~= ")";
        return to!string( val);
    }
}

class Variable {
    ClassKeyword type;
    Object val;

    this(T)(T val) {
        this.type = getKeywordForTypeOf( val);
        this.val = val;
    }

    this(T)(T val, ClassKeyword type) {
        this.type = type;
        this.val = val;
    }
}

void shazaInit() {
    globalTypeMap = [
    ClassKeyword( "any") : Variable.classinfo,
    ClassKeyword( "number"): Boxed!SzNum.classinfo,
    ClassKeyword( "int"): Boxed!SzInt.classinfo,
    ClassKeyword( "int8"): Boxed!byte.classinfo,
    ClassKeyword( "int16"): Boxed!short.classinfo,
    ClassKeyword( "int32"): Boxed!int.classinfo,
    ClassKeyword( "int64"): Boxed!long.classinfo,
    ClassKeyword( "float"): Boxed!SzFloat.classinfo,
    ClassKeyword( "float32"): Boxed!float.classinfo,
    ClassKeyword( "float64"): Boxed!double.classinfo,
    ClassKeyword( "string"): Boxed!string.classinfo,
    ClassKeyword( "vector"): SzVector.classinfo,
    ClassKeyword( "list"): SzList.classinfo,
    ClassKeyword( "Map"): SzMap.classinfo,
    ClassKeyword( "boolean"): Boxed!bool.classinfo,
    ClassKeyword( "function"): SzFunction.classinfo,
    ];
}

Namespace get_current_ns() {
    return null;
}

Keyword getKeywordForTypeOf(T)(T value) {

}

Namespace define_ns(string name) {
    return new Namespace( name);
}

T* shaza_define(T)(string name, T* value) {
    Namespace ns = get_current_ns();
    ns.variables ~= new Variable( value, T);
    return value;
}



