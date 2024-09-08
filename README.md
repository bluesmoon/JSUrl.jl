# JSUrl

## Julia Implementation of [JSUrl](https://github.com/Sage/jsurl)

[![Build Status](https://github.com/bluesmoon/JSUrl.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/bluesmoon/JSUrl.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage Status](https://coveralls.io/repos/github/bluesmoon/JSUrl.jl/badge.svg?branch=main)](https://coveralls.io/github/bluesmoon/JSUrl.jl?branch=main)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://bluesmoon.github.io/JSUrl.jl/)

## Quick Usage
```julia
julia> Pkg.add("JSUrl")

julia> using JSUrl

julia> JSUrl.stringify(Dict("foo" => "bar", "bar" => 3, "baz" => [1, 2, 3]))
"~(bar~3~baz~(~1~2~3)~foo~'bar)"

julia> JSUrl.parse("~(bar~3~baz~(~1~2~3)~foo~'bar)")
Dict{Any, Any} with 3 entries:
  "bar" => 3
  "baz" => Any[1, 2, 3]
  "foo" => "bar"
```

See the [docs](https://bluesmoon.github.io/JSUrl.jl/) for more details on usage.

You'll also find more examples in the [tests/](tests/).
