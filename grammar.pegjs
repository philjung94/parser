{
    var data = [{'hello': 1}, {'hello':2}];
    var store = {};
    Array.prototype.unroll = function (x) {
        for (var i = 0; i < this.length; i++) {
            this[i] = this[i][x];
        }
    }
    function _isFunction(x) {
        return Object.prototype.toString.call(x) == '[object Function]';
    }
    function _unnest (keys) {
        return function (target) {
            var y = Object.assign({}, target);
            for (var i = 0; i < keys.length; i++) {
                y = y[keys[i]];
            }
            return y;
        }
    }
    function _map (target) {
        return function (callback) {
            return ( Array.isArray(target)
                && target.length > 0 ) ? 
                    target.map(callback)
                        : null;
        }
    }
    function _reduce (target) {
        return function (callback) {
            return ( Array.isArray(target) 
                && target.length > 1 ) ? 
                    target.slice(1).reduce(callback, target[0]) 
                        : target[0] || null;
        }
    }
    function _eval (x, y) {
        if (x.length === 0) {
            return x();
        } else {
            if (Array.isArray(y) &&
                y.length > 0 &&
                y.every(cv => cv !== undefined)) {
                var z = x(y[0]);
                if (y.length > 1) {
                    for (var i = 1; i < y.length; i++) {
                        if (_isFunction(z)) {
                            z = z(y[i]);
                        }
                    }
                }
                console.log('eval', z);
                return z;
            } else {
                console.log('no eval, returning fn', x);
                return x;
            }
        }
    }
}

start = _ src _ (assign)* _ x:end _ {
    return x;
}

end = _ "return" ws rhs:val {
    return rhs[1];
}

assign = _ lhs:name _ eq _ rhs:val _ {
    store[lhs] = rhs[1];
}

val = _ (arg / fn ) _ 

arg = _ op _ x:fn _ y:val* _ cl _ {
    y.unroll(1);
    console.log('fn', x);
    console.log('val', y);
    return _eval(x, y)
}

fn = map 
    / reduce 
    / unnest 
    / binaryoperator 
    / num
    / get

    map = _ "map" ws {
        return _map;
    }
    
    reduce = _ "reduce" ws {
        return _reduce;
    }
    
    unnest = _ keys:key+ _ {
        keys.unroll(3);
        return _unnest(keys);
    }
    
    src = _ "from" ws label: name {
        store[label] = data;
    }

    get = label:name {
        return store[label];
    }

binaryoperator = add / multiply / subtract / divide

    add = _"+"_ {
        return function (a, b) {
            return a + b;
        };
    }
    
    subtract = _"-"_ {
        return function (a, b) {
            return a - b;
        }
    }

    multiply = _"*"_ {
        return function (a, b) {
            return a * b;
        };   
    }

    divide = _"%"_ {
        return function (a, b) {
            return a / b;
        }
    }
            
key = _ "." _ name _ 

name = label:[a-zA-Z_]+ {
    return label.join("");
}

_ = [ \t\n\r]*

ws = [ \t\n\r]+

eq = _ "=" _

op = _ "(" _

cl = _ ")" _ 

num = num:[0-9]+ {
    return Number(num);
}
