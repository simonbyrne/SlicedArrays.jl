module SlicedArrays

export Slices, Rows, Columns
import Base: getindex, setindex!, axes, size, IteratorSize, parent

include("slicearray.jl")
end # module
