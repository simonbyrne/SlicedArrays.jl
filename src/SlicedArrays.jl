module SlicedArrays

export SlicedArray

import Base: IteratorSize, size, length, ndims,
    IteratorEltype, eltype,
    iterate, getindex, setindex!, parent


"""

- `N` is the dimension of the "outer" array
- `L` is a tuple of length `M=ndims(parent)`, each element denoting how the corresponding dimension is handled:
  - an integer if it is an outer dimension, being the index of the SlicedArray
  - `nothing` if it is an "inner" dimension

- `P` is the type of the parent array
- `CI` is the type of the Cartesian iterator
- `S` is the element type
"""
struct SlicedArray{N,L,P,CI,S} <: AbstractArray{S,N}
    """
    Parent array
    """
    parent::P
    """
    `CartesianIndices` iterator used to index each slice
    """
    cartiter::CI
end

unitaxis(::AbstractArray) = Base.OneTo(1)

function SlicedArray{N,L}(A::P, iter::CI) where {N,L,P,CI}
    S = Base._return_type(view, Tuple{P, map((a,l) -> l === nothing ? Colon : eltype(a), axes(A), L)...})
    SlicedArray{N,L,P,CI,S}(A, iter)
end


# L is a tuple of length `ndims(parent)`, each element denoting how the corresponding dimension is handled:
#  - an integer if it is an outer dimensions
#  - nothing if an inner d


_sliced_check_dims(N) = nothing
function _sliced_check_dims(N, dim, dims...)
    1 <= dim <= N || throw(DimensionMismatch("Invalid dimension $dim"))
    dim in dims && throw(DimensionMismatch("Dimensions $dims are not unique"))
    _sliced_check_dims(N,dims...)
end

@inline function _eachslice(A::AbstractArray{T,N}, dims::NTuple{M,Integer}, drop::Bool) where {T,N,M}
    _sliced_check_dims(N,dims...)
    if drop
        iter = CartesianIndices(map(dim -> axes(A,dim), dims))
        L = ntuple(dim -> findfirst(isequal(dim), dims), N)
        return SlicedArray{M,L}(A, iter)
    else
        iter = ntuple(dim -> dim in dims ? axes(A,dim) : unitaxis(A), N)
        L = ntuple(dim -> dim in dims ? dim : nothing, N)
        return SlicedArray{N,L}(A, iter)
    end
end
@inline function _eachslice(A::AbstractArray{T,N}, dim::Integer, drop::Bool) where {T,N}
    _eachslice(A, (dim,), drop)
end

@inline function eachslice(A; dims, drop=true)
    Base.@_inline_meta
    _eachslice(A, dims, drop)
end


eachrow(A; drop=true) = _eachslice(A, (1,), drop)
eachcol(A; drop=true) = _eachslice(A, (2,), drop)

const RowSlicedMatrix = SlicedArray{1,(1,nothing),P,CI,S} where {S<:AbstractVector,P<:AbstractMatrix,CI}
const ColSlicedMatrix = SlicedArray{1,(nothing,1),P,CI,S} where {S<:AbstractVector,P<:AbstractMatrix,CI}


IteratorSize(::Type{SlicedArray{N,L,P,CI,S}}) where {N,L,P,CI,S} = IteratorSize(CI)
size(s::SlicedArray) = size(s.cartiter)
size(s::SlicedArray, dim) = size(s.cartiter, dim)
length(s::SlicedArray) = length(s.cartiter)

@inline function _slice_index(s::SlicedArray{N,L,P,CI,S}, I...) where {N,L,P,CI,S}
    c = s.cartiter[I...]    
    return map(l -> l === nothing ? (:) : c[l], L)
end

function getindex(s::SlicedArray, I...)
    view(s.parent, _slice_index(s, I...)...)
end

function setindex!(s::SlicedArray, val, I...)
    s.parent[_slice_index(s, I...)...] = val
end

parent(s::SlicedArray) = s.arr


end # module
