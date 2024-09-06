"""
Julia implementation of [JSUrl](https://github.com/Sage/jsurl). See the JSURL docs for more details on the format.
"""
module JSUrl

"""
Encode a string type with JSUrl safe characters
"""
encode(ch::AbstractChar) = ch === '$' ? '!' : (ch = codepoint(ch); string(ch >= 0x100 ? "*" : "", "*", string(ch; base=16, pad=ch >= 0x100 ? 4 : 2)))
encode(s::AbstractString) = replace(s, r"[^\w.-]"a => ch -> encode(ch[1]))
encode(s::Symbol) = encode(string(s))


"""
Serialize a Julia object into a JSUrl string. This serialization is lossy as not all type information can be recovered.

To implement it for your own type, implement `show(::YourType)`.
"""
stringify(v::Number) = isfinite(v) ? "~$(v)" : "~null"
stringify(v::AbstractString) = "~'" * encode(v)
stringify(v::AbstractChar)   = "~'" * encode(v)
stringify(v::Nothing) = "~null"
stringify(v::Missing) = "~null"
stringify(v::AbstractArray) = "~(" * (isempty(v) ? "~" : join(map(stringify, v), "")) * ")"
stringify(v::Tuple) = stringify(collect(v))
stringify(v::AbstractDict)  = "~(" * join(filter(!isempty, map(k -> (val = stringify(v[k]); isnothing(val) ? "" : encode(k) * val), sort(collect(keys(v))))), "~") * ")"
stringify(v::Pair) = stringify(Dict(v))
stringify(v::NamedTuple) = stringify(Dict(pairs(v)))
stringify(v::Function) = "~fn"
stringify(v::Any) = stringify(Symbol(typeof(v)) => repr(v))

#JSUrl reserved terms
const reserved = Dict(
    "true"  => true,
    "false" => false,
    "null"  => nothing,
    "fn"    => nothing,
)

"""
Parse a JSUrl serialized string into a Julia object.

To deserialize your own type, look for a `Dict` with a single string key matching your typename.
The value will be the output of `repr(::YourType)`
"""
function parse(s::AbstractString)
    isempty(s) && return s

    s = replace(s, r"%(25)*27" => "'")

    i = 1
    len = length(s)

    function eat(expected::AbstractChar)
        i > len && throw(BoundsError(s, i))
        (s[i] !== expected) && throw(InvalidStateException("bad JSUrl syntax: expected " * expected * ", got " * s[i], Symbol(s[i])))
        i+=1
    end

    function decode()
        beg = i
        ch = s[i]
        r = ""

        while i <= len && (ch=s[i]) !== '~' && ch !== ')'
            if ch == '*'
                if beg < i
                    r *= s[beg:i-1]
                end
                if s[i + 1] === '*'
                    r *= Char(Base.parse(Int, s[i+2:i+5]; base=16))
                    i += 6
                    beg = i
                else
                    r *= Char(Base.parse(Int, s[i+1:i+2]; base=16))
                    i += 3
                    beg = i
                end
            elseif ch == '!'
                if beg < i
                    r *= s[beg:i-1]
                end
                r *= '$'
                i += 1
                beg = i
            else
                i += 1
            end
        end
        return r * s[beg:i-1]
    end

    function parseOne()
        eat('~')
        ch = s[i]
        if ch === '\''       # String or char
            i += 1
            return decode()
        elseif ch === '('        # Array or object
            i += 1
            if s[i] === '~'  #   Array
                result = []
                if s[i + 1] === ')'  # end
                    i += 1
                else
                    while s[i] === '~'
                        push!(result, parseOne())
                    end
                end
                eat(')')
                return result
            else            #   Object
                result = Dict()
                while i < len && s[i] !== ')'
                    key = decode()
                    result[key] = parseOne()
                    if s[i] === '~'
                        i+=1
                    end
                end
                eat(')');
                return result
            end
        else
            beg = i
            i += 1
            i = something(findnext(c -> c === '~' || c === ')', s, i), len+1)
            sub = s[beg:i-1]
            if 0x2d <= codepoint(ch) <= 0x39   # digit or -
                return Base.parse(occursin('.', sub) ? Float64 : Int, sub)
            elseif haskey(reserved, sub)
                return reserved[sub]
            else
                throw(KeyError(sub))
            end
        end
    end

    return parseOne()
end

end
