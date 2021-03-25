module SlicedArrays

export Slices
import Base: getindex, setindex!, axes, size, IteratorSize, parent

include("slicearray.jl")
end # module
