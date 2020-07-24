module shaza.buildins;

import std.variant;
import std.conv;
import std.typecons;

import shaza.std;

Nullable!long toIntOrNull(string text) {
    Nullable!long result;

    if (text == null || text.size == 0) {
        return result;
    }

    int base = 10;

    if (text.size > 1) {
        if (text[0] == '+' || text[0] == '-') {
            text = text[1..$]; // Cut prefix
        }

        if (text[0] == '0') {
            import std.stdio;
            bool hasBasePrefix = true;
            switch (text[1]) {
                case 'x':
                base = 16;
                break ;
                case 'b':
                base = 2;
                break ;
                case 'o':
                base = 8;
                break ;
                case 'd':
                base = 10;
                break ;
                default:
                base = 10;
                hasBasePrefix = false;
                break ;
            }
            if (hasBasePrefix) {
                text = text[2..$];
            }
        }
    }

    try {
        result = to!long( text, base);
    } catch(ConvException ce) {
    }

    return result;
}

Nullable!ulong toUIntOrNull(string text) {
    Nullable!ulong result;

    if (text == null || text.size == 0) {
        return result;
    }
    if (text[$-1] == 'u') {
        text = text[0..$-1];
    }

    Nullable!long temp = toIntOrNull( text);
    if (!temp.isNull()) {
        result = cast(ulong) temp.get();
    }

    return result;
}

Nullable!double toFloatOrNull(string text) {
    Nullable!double result;

    if (text == null || text.size == 0) {
        return result;
    }
    if (text[$-1] == 'f') {
        text = text[0..$-1];
    }

    try {
        result = to!double( text);
    } catch(ConvException ce) {
    }
    return result;
}

size_t size(T)(T[] lst) {
    return lst.length;
}

bool contains(T)(T[] list, T o) {
    return indexof( list, o) == -1;
}

int indexof(T)(T[] list, T o) {
    for (int i = 0; i < list.size; i++) {
        if (list[i] == 0) return i;
    }
    return -1;
}

// SECTION lib

bool isIntegral(Variable v) {
    return v.peek!(long) !is null;
}
bool isNonIntNum(Variable v) {
    return v.peek!(double) !is null;
}
bool isNum(Variable v) {
    return v.peek!(long) !is null || v.peek!(double) !is null;
}

string stringCat(string s0, string s1) {
    return s0 ~ s1;
}

string stringCat(string s0, string[] ss...) {
    string res = s0;
    foreach (string t; ss) {
        res ~= t;
    }
    return res;
}

Variable toVector(Variable v) {
    Variable res = v.visit!(
    (SzVector sv) => sv,
    //(SzList sl) => sl,
    // (SzMap sm) => // TODO
    other => null)();

    if (!res.hasValue()) {
        throw new ShazaError( to!string( v), " not convertable to vector.");
    }

    return res;
}

Variable toList(Variable v) {
    Variable res = v.visit!(
    (SzVector sv) => sv,
    //(SzList sl) => sl,
    // (SzMap sm) => // TODO
    other => null)();

    if (!res.hasValue()) {
        throw new ShazaError( to!string( v), " not convertable to vector.");
    }

    return res;
}

Variable toMap(Variable v) {
    Variable res = v.visit!(
    // (SzVector sv) => , // TODO
    // (SzList sl) => , // TODO
    (SzMap sm) => sm,
    other => null)();

    if (!res.hasValue()) {
        throw new ShazaError( to!string( v), " not convertable to vector.");
    }

    return res;
}

bool isTruthy(Variable v) {
    if (*(v.peek!(bool)) is false || *(v.peek!(SzNull)) !is null) {
        return false;
    }
    return true;
}

Variable convert(ClassKeyword ck, Variable v) {
    return v;
    /*
    switch (ck.text) {
        case "any" : return v;
        case "number" : return (isNum( v)) ? v : variable( to!long( v));
        case "int" : return variable( to!long( v));
        case "int8" : return variable( to!byte( v)); // TODO
        case "int16" : return variable( to!short( v));// TODO
        case "int32" : return variable( to!long( v));// TODO
        case "int64" : return variable( to!long( v));
        case "float" : return variable( to!double( v));
        case "float32" : return variable( to!float( v));
        case "float64" : return variable( to!double( v));
        case "string" : return variable( to!string( v));
        case "vector" : return toVector( v);
        case "list" : return toList( v);
        case "map" : return toMap( v);
        case "boolean" : return isTruthy( v);
        case "function" : if (v.peek!(SzFunction) !is null) return v.peek!(SzFunction);
        default : throw new ShazaError( stringCat( v, " cannot be converted to ", ck));
    }
    */
}

Variable add(Variable v0, Variable v1) {
    if (isIntegral( v0)) {
        if (isIntegral( v1)) return variable( v0.get!(long) + v1.get!(long));
        else if (isNonIntNum( v1)) return variable( v0.get!(long) + v1.get!(double));
    } else if (isNonIntNum( v0)) {
        if (isIntegral( v1)) return variable( v0.get!(double) + v1.get!(long));
        else if (isNonIntNum( v1)) return variable( v0.get!(double) + v1.get!(double));
    }
    string errormsg = "Addition only allowed for numeric types. (Given: ";
    throw new ShazaError( errormsg, v0.toString(), ", ", v1.toString(), ")");
}

Variable sub(Variable v0, Variable v1) {
    if (isIntegral( v0)) {
        if (isIntegral( v1)) return variable( v0.get!(long) - v1.get!(long));
        else if (isNonIntNum( v1)) return variable( v0.get!(long) - v1.get!(double));
    } else if (isNonIntNum( v0)) {
        if (isIntegral( v1)) return variable( v0.get!(double) - v1.get!(long));
        else if (isNonIntNum( v1)) return variable( v0.get!(double) - v1.get!(double));
    }
    string errormsg = "Subtraction only allowed for numeric types. (Given: ";
    throw new ShazaError( errormsg, v0.toString(), ", ", v1.toString(), ")");
}

Variable mul(Variable v0, Variable v1) {
    if (isIntegral( v0)) {
        if (isIntegral( v1)) return variable( v0.get!(long) * v1.get!(long));
        else if (isNonIntNum( v1)) return variable( v0.get!(long) * v1.get!(double));
    } else if (isNonIntNum( v0)) {
        if (isIntegral( v1)) return variable( v0.get!(double) * v1.get!(long));
        else if (isNonIntNum( v1)) return variable( v0.get!(double) * v1.get!(double));
    }
    string errormsg = "Multiplication only allowed for numeric types. (Given: ";
    throw new ShazaError( errormsg, v0.toString(), ", ", v1.toString(), ")");
}

Variable div(Variable v0, Variable v1) {
    if (isIntegral( v0)) {
        if (isIntegral( v1)) return variable( v0.get!(long) / v1.get!(long));
        else if (isNonIntNum( v1)) return variable( v0.get!(long) / v1.get!(double));
    } else if (isNonIntNum( v0)) {
        if (isIntegral( v1)) return variable( v0.get!(double) / v1.get!(long));
        else if (isNonIntNum( v1)) return variable( v0.get!(double) / v1.get!(double));
    }
    string errormsg = "Multiplication only allowed for numeric types. (Given: ";
    throw new ShazaError( errormsg, v0.toString(), ", ", v1.toString(), ")");
}

Variable mod(Variable v0, Variable v1) {
    if (isIntegral( v0)) {
        if (isIntegral( v1)) return variable( v0.get!(long) % v1.get!(long));
        else if (isNonIntNum( v1)) return variable( v0.get!(long) % v1.get!(double));
    } else if (isNonIntNum( v0)) {
        if (isIntegral( v1)) return variable( v0.get!(double) % v1.get!(long));
        else if (isNonIntNum( v1)) return variable( v0.get!(double) % v1.get!(double));
    }
    string errormsg = "Multiplication only allowed for numeric types. (Given: ";
    throw new ShazaError( errormsg, v0.toString(), ", ", v1.toString(), ")");
}

Variable et_add(Variable outType, Variable v0, Variable v1) {
    return convert( outType.get!(ClassKeyword), add( v0, v1));
}
Variable et_sub(Variable outType, Variable v0, Variable v1) {
    return convert( outType.get!(ClassKeyword), sub( v0, v1));
}
Variable et_mul(Variable outType, Variable v0, Variable v1) {
    return convert( outType.get!(ClassKeyword), mul( v0, v1));
}
Variable et_div(Variable outType, Variable v0, Variable v1) {
    return convert( outType.get!(ClassKeyword), div( v0, v1));
}
Variable et_mod(Variable outType, Variable v0, Variable v1) {
    return convert( outType.get!(ClassKeyword), mod( v0, v1));
}

Variable cr_list(Variable[] vars) {
    return variable( new SzVector( vars)); // FIXME
}
Variable cr_vector(Variable[] vars) {
    return variable( new SzVector( vars));
}
Variable cr_map(Variable[] vars) {
    // TODO Error handling for odd length

    Variable[Variable] val;
    for (int i = 0; i < vars.size(); i+=2) {
        val[vars[i]] = vars[i+1];
    }
    return variable( new SzMap( val));
}

static void setup() {
    Namespace.globalNs.put( "+", variable( &add));
    Namespace.globalNs.put( "-", variable( &sub));
    Namespace.globalNs.put( "*", variable( &mul));
    Namespace.globalNs.put( "/", variable( &div));
    Namespace.globalNs.put( "%", variable( &mod));
    Namespace.globalNs.put( "+'", variable( &et_add));
    Namespace.globalNs.put( "-'", variable( &et_sub));
    Namespace.globalNs.put( "*'", variable( &et_mul));
    Namespace.globalNs.put( "/'", variable( &et_div));
    Namespace.globalNs.put( "%'", variable( &et_mod));

    Namespace.globalNs.put( "list", variable( &cr_list));
    Namespace.globalNs.put( "vector", variable( &cr_vector));
    Namespace.globalNs.put( "cr_map", variable( &cr_map));
}
