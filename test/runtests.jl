using JSUrl, Test

pt(v::NamedTuple, p) = pt(Dict(pairs(v)), p)
pt(v::Pair, p) = pt(Dict(v), p)
function pt(v::AbstractDict, p)
    for kv in v
        @test haskey(p, string(kv[1]))
        pt(v[kv[1]], p[string(kv[1])])
    end
end

pt(v::Tuple, p) = pt(collect(v), p)
function pt(v::AbstractArray, p)
    @test length(v) == length(p)
    for i in 1:length(v)
        pt(v[i], p[i])
    end
end

function pt(v, p)
    v = (ismissing(v) || isa(v, Function) || (isa(v, Number) && (isnan(v) || !isfinite(v)))) ? nothing : v

    @test v == p
end

function t(v, r)
    @test r === JSUrl.stringify(v)
    pt(v, JSUrl.parse(JSUrl.stringify(v)))
#    @test r === JSUrl.stringify(JSUrl.parse(JSUrl.stringify(v)))
end

@testset "JSUrl" begin
@testset "basic values" begin
    t(nothing, "~null")
    t(sum, "~fn")
    t(missing, "~null")
    t(false, "~false")
    t(true, "~true")
    t(0, "~0")
    t(1, "~1")
    t(-1.5, "~-1.5")
    t("hello world\u203c", "~'hello*20world**203c")
    t(" !\"#abc\$%&'()*+,-./09:;<=>?@AZ[\\]^_`az{|}~", "~'*20*21*22*23abc!*25*26*27*28*29*2a*2b*2c-.*2f09*3a*3b*3c*3d*3e*3f*40AZ*5b*5c*5d*5e_*60az*7b*7c*7d*7e")
    t(NaN, "~null")
    t(Inf, "~null")
    t(-Inf, "~null")
end
@testset "arrays" begin
    t([], "~(~)")
    t([missing, sum, nothing, false, 0, "hello world\u203c"], "~(~null~fn~null~false~0~'hello*20world**203c)")
    t((missing, sum, nothing, false, 0, "hello world\u203c"), "~(~null~fn~null~false~0~'hello*20world**203c)")
end
@testset "objects" begin
    t(Dict(), "~()")
    t(Dict(
        :a => missing,
        :b => sum,
        :c => nothing,
        :d => false,
        :e => 0,
        :f => "hello world\u203c"
    ), "~(a~null~b~fn~c~null~d~false~e~0~f~'hello*20world**203c)")
    t(:f => "hello world\u203c", "~(f~'hello*20world**203c)")
    t((f = "hello world\u203c", a = 0.1), "~(a~0.1~f~'hello*20world**203c)")

end
@testset "mix" begin
    t(Dict(
        :a => [
            [1, 2],
            [], Dict()],
        :b => [],
        :c => Dict(
            :d => "hello",
            :e => Dict(),
            :f => []
        )
    ), "~(a~(~(~1~2)~(~)~())~b~(~)~c~(d~'hello~e~()~f~(~)))")
end

@testset "percent-escaped single quotes" begin
    @test Dict("a" => "hello", "b" => "world") == JSUrl.parse("~(a~%27hello~b~%27world)")
end

@testset "percent-escaped percent-escaped single quotes" begin
    @test Dict("a" => "hello", "b" => "world") == JSUrl.parse("~(a~%2527hello~b~%2525252527world)")
end

@testset "misc" begin
    @test JSUrl.stringify('å') == JSUrl.stringify("å")
    @test JSUrl.stringify('π') == JSUrl.stringify("π")
    @test "~(DataType~'Any)"   == JSUrl.stringify(Any)

    @test_throws KeyError JSUrl.parse("~foo")
end


end
