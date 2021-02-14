module SlicedArrays

export SlicedArray

import Base: IteratorSize, size, length, ndims,
    IteratorEltype, eltype,
    iterate, getindex, setindex!, parent

struct SlicedArray{S,N,P,CI,L} <: AbstractArray{S,N}
    """
    Parent array
    """
    parent::P
    """
    `CartesianIndices` iterator used to index each slice
    """
    cartiter::CI
end

_sliced_check_dims(N) = nothing
function _sliced_check_dims(N, dim, dims...)
    1 <= dim <= N || throw(DimensionMismatch("Invalid dimension $dim"))
    dim in dims && throw(DimensionMismatch("Dimensions $dims are not unique"))
    _sliced_check_dims(N,dims...)
end


const _SlicedArray{N,P,CI,L} = SlicedArray{S,N,P,CI,L} where {S}
function _SlicedArray{N,P,CI,L}(A::P, iter) where {N,P,CI,L}
    # determine element type
    S = Base._return_type(view, Tuple{P, map((a,l) -> l === nothing ? Colon : eltype(a), axes(A), L)...})
    SlicedArray{S,N,P,CI,L}(A,iter)
end


@inline function _eachslice(A::AbstractArray{T,N}, dims::NTuple{M,Integer}) where {T,N,M}
    _sliced_check_dims(N,dims...)
    iter = CartesianIndices(map(dim -> axes(A,dim), dims))
    L = ntuple(dim -> findfirst(isequal(dim), dims), N)
    _SlicedArray{M,typeof(A),typeof(iter),L}(A,iter)
end
@inline function _eachslice(A::AbstractArray{T,N}, dim::Integer) where {T,N}
    _eachslice(A, (dim,))
end

@inline eachslice(A; dims) = _eachslice(A, dims)


const RowSlicedMatrix = SlicedArray{S,1,P,CI,(1,nothing)} where {S<:AbstractVector,P<:AbstractMatrix,CI}
const ColSlicedMatrix = SlicedArray{S,1,P,CI,(nothing,1)} where {S<:AbstractVector,P<:AbstractMatrix,CI}


IteratorSize(::Type{SlicedArray{S,N,P,CI,L}}) where {S,N,P,CI,L} = IteratorSize(CI)
size(s::SlicedArray) = size(s.cartiter)
size(s::SlicedArray, dim) = size(s.cartiter, dim)
length(s::SlicedArray) = length(s.cartiter)

@inline function _slice_index(s::SlicedArray{S,N,P,CI,L}, I...) where {S,N,P,CI,L}
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
