# Examples of JSUrl usage

## Encode Julia objects

### Scalar objects

```julia
julia> using JSUrl

julia> JSUrl.stringify(nothing)
"~null"

julia> JSUrl.stringify(123)
"~123"

julia> JSUrl.stringify(-1.23)
"~-1.23"

julia> JSUrl.stringify(-Inf)
"~-Inf"

julia> JSUrl.stringify("hello world\u203c")
"~'hello*20world**203c"
```


### Collections
```julia
julia> JSUrl.stringify(["hello world\u203c", 123, -Inf, missing])
"~(~'hello*20world**203c~123~-Inf~null)"

julia> JSUrl.stringify(Dict(:h => "hello world\u203c", :n => 123, :i => -Inf, :m => missing])
"~(h~'hello*20world**203c~i~-Inf~m~null~n~123)"
```

## Parsing

```julia
julia> JSUrl.parse("~null")
nothing

julia> JSUrl.parse("~123")
123

julia> JSUrl.parse("~-1.23")
-1.23

julia> JSUrl.parse("~-Inf")
-Inf

julia> JSUrl.parse("~'hello*20world**203c")
"hello world‼"

julia> JSUrl.parse("~(~'hello*20world**203c~123~-Inf~null)")
4-element Vector{Any}:
    "hello world‼"
 123
 -Inf
    nothing


julia> JSUrl.parse("~(h~'hello*20world**203c~i~-Inf~m~null~n~123)")
Dict{Any, Any} with 4 entries:
  "n" => 123
  "m" => nothing
  "h" => "hello world‼"
  "i" => -Inf
```

## Notes

* Symbols, Strings and Characters are all encoded as Strings. When decoded, they end up as Strings.
* `missing` and `nothing` are encoded as `"~null"`. When decoded, they will end up as `nothing`.
* Functions are encoded as `"~fn"` but when decoded will end up as `nothing` since functions cannot be serialized.
* Tuples, arrays and sets are all serialized as arrays. When decoded they come back as arrays.
* Dicts, NamedTuples and Pairs are encoded as objects. When decoded they come back as dicts with keys converted to strings.
* Numbers are encoded as-is, including NaN, Inf and -Inf. They decode back to either Int or Float64.
* Boolean values are encoded as `"~true"` and `"~false"`.
* Other types are serialized based on calling `repr()` on that type and storing the result as an object of `Type:val`. They decode to a Dict with
  the key being the typename as a string and the value being the `repr`ed value of the object.
