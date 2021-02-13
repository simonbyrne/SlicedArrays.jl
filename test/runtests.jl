using Test
using SlicedArrays

X = reshape(collect(1:12),(3,4))

S = SlicedArray(X,(1,))
@test S isa AbstractVector
@test size(S) == (3,)
@test eltype(S) <: AbstractVector{Int}
@test S[1] == [1,4,7,10]

R = SlicedArray(X,(2,))
@test R isa AbstractVector
@test size(R) == (4,)
@test eltype(R) <: AbstractVector{Int}
@test R[1] == [1,2,3]

S[2] = [21,22,23,24]
@test X[2,:] == [21,22,23,24]

R[4] = [31,32,33]
@test X[:,4] == [31,32,33]


_eachrow(X) = SlicedArray(X,(1,))
@inferred _eachrow(X)

_eachcol(X) = SlicedArray(X,(2,))
@inferred _eachcol(X)


