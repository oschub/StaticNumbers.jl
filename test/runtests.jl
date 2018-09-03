using FixedNumbers
using Test

@test Fixed(1) === FixedInteger{1}()
@test Fixed(1) == 1
@test sin(Fixed(1)) == sin(1)
@test Fixed(1+im) === FixedNumber{1+im}()

@test Fixed(1) + Fixed(1) == 2

@test promote_type(FixedInteger{1}, FixedInteger{1}) == Int
@test promote_type(FixedInteger{1}, FixedInteger{2}) == Int

@test zero(Fixed(1)) === 0
@test zero(Fixed(1.0)) === 0.0

@test Fixed(true) == true
@test Fixed(false) == false

for x in (-1.0, -1, 2, 3, 1.5, 2.0, 3.1, pi, 3//2, 3.0+im)
    for f in (:round, :ceil, :floor, :sign, :cos, :sin, :log, :exp, :isfinite, :isnan)
        r = try
            @eval $f($x)
        catch
            nothing
        end
        if r != nothing
            #println(f, (x,), " == ", r)
            @test @eval $f(Fixed($x)) == $r
        end
    end
    for y in (-1.0, -1, 2, 3, 1.5, 2.0, 3.1, pi, 3//2, 3.0+im)
        @test Fixed(x) + y === x + y
        @test x + Fixed(y) === x + y
        @test Fixed(x) + Fixed(y) === x + y
        for f in (:-, :*, :/, :^, :rem, :mod, :(<<), :(>>), :(==), :(<), :(<=), :(>), :(>=))
            r = try
                @eval $f($x,$y)
            catch
                nothing
            end
            if r != nothing
                #println(f, (x,y), " ≈ ", r)
                @test @eval $f(Fixed($x), $y) ≈ $r
                @test @eval $f($x, Fixed($y)) ≈ $r
                @test @eval $f(Fixed($x), Fixed($y)) ≈ $r
            end
        end
    end
end

@test Fixed(1.5) === FixedReal{1.5}()

@test Fixed{1}() === Fixed(1)

@test Float64(Fixed(1.5)) === 1.5

@test big(Fixed(1)) == big(1)
@test typeof(big(Fixed(1))) == BigInt

@test Complex{Float64}(Fixed(2)) === ComplexF64(2)

@test 2+Fixed(2) == 4
@test 1+Fixed(1//2) === 3//2
@test Fixed(1//2)+1 === 3//2

@test Fixed(Fixed(1)) == Fixed(1)
@test_throws ErrorException FixedInteger{FixedInteger{1}()}()
@test_throws InexactError convert(FixedInteger{1}, 2)

@test FixedInteger{0}() < 1
@test Fixed(1) isa Integer
@test +Fixed(1) === Fixed(1)
@test -Fixed(1) == -1
@test ~Fixed(1) == -2
@test isqrt(Fixed(1)) == 1
@test zero(Fixed(1)) == 0
@test one(Fixed(2)) == 1
@test oneunit(Fixed(2)) == 1

@test sprint(show, Fixed(1)) == "Fixed(1)"
@test sprint(show, Fixed(1//2)) == "Fixed(1//2)"
@test sprint(show, Fixed(0.5)) == "Fixed(0.5)"

@test tryfixed(0, Fixed(1)) === 0
@test tryfixed(1, Fixed(1)) === Fixed(1)
@test tryfixed(0, Fixed(0), Fixed(1)) === Fixed(0)
@test tryfixed(1, Fixed(0), Fixed(1)) === Fixed(1)
@test tryfixed(2, Fixed(0), Fixed(1)) === 2

@test tryfixed(0, 1) === 0
@test tryfixed(Fixed(0), 1) === Fixed(0)
@test tryfixed(1, 1) === Fixed(1)
@test tryfixed(0, 0, 1) === Fixed(0)
@test tryfixed(1, 0, 1) === Fixed(1)
@test tryfixed(2, 0, 1) === 2
@test tryfixed(2, (0, 1)) === 2
@test tryfixed(2, (0, 1, 2)) === Fixed(2)
@test 2 ⩢ (0, 1) === 2
@test 2 ⩢ (0, 1, 2) === Fixed(2)
@test 2 ⩢ 0 ⩢ 1 ⩢ 2 === Fixed(2)
@test 2 ⩢ 0 ⩢ 1 === 2

@test tryfixed(2, 1:3) == Fixed(2)
@test tryfixed(4, 1:3) == 4

#println(macroexpand(FixedNumbers, :(@fixednumbers (0, 1) (Base.Math.sinpi, Base.Math.cospi) (Base.:+, Base.:-) )))
@fixednumbers (0, 1) (Base.Math.sinpi, Base.Math.cospi) (Base.:+, Base.:-)
@test sinpi(FixedInteger{1}()) === FixedInteger{0}()
@test FixedInteger{1}() - FixedInteger{1}() === FixedInteger{0}()

# Test that sqrt(-1) doesn't cause problems with @fixednumbers
@fixednumbers (-1, 0, 1) (Base.sqrt,) (Base.rem,)
@test sqrt(Fixed(1)) === Fixed(1)
@test rem(Fixed(1), Fixed(1)) === Fixed(0)

@test ntuple(identity, Fixed(5)) === ntuple(identity, Val(5))

# Test FixedRanges

@test fixedlength(1:3) isa FixedRange
@test length(fixedlength(1:3)) === Fixed(3)

r = FixedStepRange(1, 2, Fixed(3))

@test r isa FixedRange
@test r isa FixedRange{Int, Int, Int, <:Fixed}
@test r isa FixedRange{Int, Int, Int, <:Fixed{3}}
@test r isa FixedRange{Int, Int, Int, FixedInteger{3}}
@test r isa FixedNumbers.FixedStepRange{Int, Int, Int, FixedInteger{3}}
@test all(r .== 3:2:7)
@test r[2] == 5
@test all(collect(r) .== [3, 5, 7])
@test all(2*r .== 2*(3:2:7))
@test all(r*5 .== (3:2:7)*5)
@test all(2 .* r .== 2 .* (3:2:7))
@test all(r .* 5 .== (3:2:7) .* 5)
@test all(7 .+ r .== 7 .+ (3:2:7))
@test all(r .+ 7 .== (3:2:7) .+ 7)
@test all(7 .- r .== 7 .- (3:2:7))
@test all(r .- 7 .== (3:2:7) .- 7)
@test all(-r .== -(3:2:7))
@test +r === r
@test .+r === r
@test .-(.-r) === r
@test -(-r) === r
@test typeof(7 .+ r) == typeof(r)
@test typeof(r .+ 7) == typeof(r)
@test typeof(7 .- r) == typeof(r)
@test typeof(r .- 7) == typeof(r)
@test typeof(7 .* r) == typeof(r)
@test typeof(r .* 7) == typeof(r)
@test typeof(7 .+ 5 .* r) == typeof(r)
@test typeof(r .* 5 .+ 7) == typeof(r)
@test all( (7:3:100)[r] .== (7:3:100)[3:2:7] )

@test !(Fixed(false)) === true
@test !(Fixed(true)) === false
@test true isa FixedOrBool
@test Fixed(true) isa FixedOrBool

@test 1 isa FixedOrInt
@test Fixed(1) isa FixedOrInt

@test offixedtype(Fixed(1), 2) === Fixed(2)
@test offixedtype(Fixed(1), 2) === Fixed(2)
@test offixedtype(1.0, 2) === 2.0

ur = FixedUnitRange(2, Fixed(3))
@test ur isa FixedRange
@test ur isa FixedRange{Int, Int, <:Fixed, <:Fixed}
@test ur isa FixedRange{Int, Int, <:Fixed{1}, <:Fixed{3}}
@test ur isa FixedRange{Int, Int, FixedInteger{1}, FixedInteger{3}}
@test ur isa FixedNumbers.FixedUnitRange{Int, Int, FixedInteger{3}}
@test all(ur .== 3:5)
@test ur[2] == 4
@test all(collect(ur) .== [3, 4, 5])
@test all(2*ur .== 2*(3:5))
@test all(ur*5 .== (3:5)*5)
@test all(2 .* ur .== 2 .* (3:5))
@test all(ur .* 5 .== (3:5) .* 5)
@test all(7 .+ ur .== 7 .+ (3:5))
@test all(ur .+ 7 .== (3:5) .+ 7)
@test all(-ur .== -(3:5))
@test +ur === ur
@test .+ur === ur
@test .-(.-ur) === ur
@test -(-ur) === ur
@test typeof(7 .+ ur) == typeof(ur)
@test typeof(ur .+ 7) == typeof(ur)
@test length(7 .- ur) == Fixed(3)
@test typeof(ur .- 7) == typeof(ur)
@test length(7 .* ur) === Fixed(3)
@test length(ur .* 7) === Fixed(3)
@test length(7 .+ 5 .* ur) === Fixed(3)
@test length(ur .* 5 .+ 7) === Fixed(3)
@test all( (7:3:100)[ur] .== (7:3:100)[3:5] )

# Test types
@test FixedRange(1:3) isa FixedUnitRange
@test FixedRange(1:2:4) isa FixedStepRange

# Test that type inferrence is working
@test Base.return_types(*, (Int, typeof(r)))[1] === typeof(r)
@test Base.return_types(*, (Int, typeof(ur)))[1] === typeof(r)

f1(x) = tryfixed(x, Fixed(3))
@test Base.return_types(f1, (Int64,))[1] == Union{FixedInteger{3}, Int64}

f2(x) = tryfixed(x, 3)
@test Base.return_types(f2, (Int64,))[1] == Union{FixedInteger{3}, Int64}

f3(x) = tryfixed(x, 3, 4)
@show Base.return_types(f3, (Int,))
g3() = f3(4)
@test Base.return_types(g3, ())[1] == FixedInteger{4}

f4(x) = tryfixed(x, Fixed(3), Fixed(4))
@show Base.return_types(f4, (Int,))
g4() = f4(4)
@test Base.return_types(g4, ())[1] == FixedInteger{4}

f5(x) = tryfixed(mod(x,4), FixedStepRange(Fixed(-1),Fixed(1),Fixed(4)))
@show Base.return_types(f5, (Int,))
g5() = f5(2)
@show Base.return_types(g5, ())

# Test array handling with fixed ranges
A = rand(16,16)
B = rand(Fixed(16),Fixed(16))
C = A[fixedlength(5:8),FixedOneTo(4)]
@test all(C .== A[fixedlength(5:8),FixedOneTo(4)])
A[FixedOneTo(4),FixedOneTo(4)] = C
@test all(A[FixedOneTo(4),FixedOneTo(4)] .== C)
@test all(fixedlength(3:4).^2 == (3:4).^2)
