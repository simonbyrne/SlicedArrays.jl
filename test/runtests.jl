using Test
using SlicedArrays

X = reshape(collect(1:12),(3,4))

f(x::AbstractVector{<:AbstractVector}) = 1
f(x::SlicedArrays.RowSlicedMatrix) = 2
f(x::SlicedArrays.ColSlicedMatrix) = 3


S = SlicedArrays.eachslice(X,dims=1)
@test S === SlicedArrays.eachrow(X)
@test S isa AbstractVector
@test size(S) == (3,)
@test eltype(S) <: AbstractVector{Int}
@test S[1] isa eltype(S)
@test S[1] == [1,4,7,10]

@test S isa SlicedArrays.RowSlicedMatrix
@test SlicedArrays.RowSlicedMatrix <: AbstractVector{<:AbstractVector}
@test f(S) == 2

R = SlicedArrays.eachslice(X,dims=2)
@test R === SlicedArrays.eachcol(X)
@test R isa AbstractVector
@test size(R) == (4,)
@test eltype(R) <: AbstractVector{Int}
@test R[1] isa eltype(R)
@test R[1] == [1,2,3]

@test R isa SlicedArrays.ColSlicedMatrix
@test SlicedArrays.ColSlicedMatrix <: AbstractVector{<:AbstractVector}
@test f(R) == 3


S[2] = [21,22,23,24]
@test X[2,:] == [21,22,23,24]

R[4] = [31,32,33]
@test X[:,4] == [31,32,33]


@inferred SlicedArrays.eachrow(X)
@inferred SlicedArrays.eachcol(X)

kw_eachrow(X) = SlicedArrays.eachslice(X,dims=(1,))
#@inferred kw_eachrow(X)


