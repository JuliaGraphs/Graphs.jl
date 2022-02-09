"""
    sample!([rng, ]a, k)

Sample `k` element from array `a` without repetition and eventually excluding elements in `exclude`.

### Optional Arguments
- `exclude=()`: elements in `a` to exclude from sampling.

### Implementation Notes
Changes the order of the elements in `a`. For a non-mutating version, see [`sample`](@ref).
"""
function sample!(rng::AbstractRNG, a::AbstractVector, k::Integer; exclude=())
    minsize = k + length(exclude)
    length(a) < minsize && throw(ArgumentError("vector must be at least size $minsize"))
    res = Vector{eltype(a)}()
    sizehint!(res, k)
    n = length(a)
    i = 1
    while length(res) < k
        r = rand(rng, 1:(n - i + 1))
        if !(a[r] in exclude)
            push!(res, a[r])
            a[r], a[n - i + 1] = a[n - i + 1], a[r]
            i += 1
        end
    end
    res
end

sample!(a::AbstractVector, k::Integer; exclude=()) = sample!(getRNG(), a, k; exclude=exclude)

"""
    sample([rng,] r, k)

Sample `k` element from unit range `r` without repetition and eventually excluding elements in `exclude`.

### Optional Arguments
- `exclude=()`: elements in `a` to exclude from sampling.

### Implementation Notes
Unlike [`sample!`](@ref), does not produce side effects.
"""
sample(a::AbstractVector, k::Integer; exclude=()) = sample!(getRNG(), collect(a), k; exclude=exclude)

getRNG(seed::Integer=-1) = seed >= 0 ? MersenneTwister(seed) : GLOBAL_RNG

"""
    rng_from_rng_or_seed(rng, seed)

Helper function for randomized functions that can take a random generator as well as a seed argument.

Currently most randomized functions in this package take a seed integer as an argument.
As modern randomized Julia functions tend to take a random generator instead of a seed,
this function helps with the transition by taking `rng` and `seed` as an argument and
always returning a random number generator.
At least one of these arguments must be `nothing`.
"""
function rng_from_rng_or_seed(rng::Union{Nothing, AbstractRNG}, seed::Union{Nothing, Integer})

    # TODO at some point we might emit a deprecation warning if a seed is specified

    !(isnothing(seed) || isnothing(rng)) && throw(ArgumentError("Cannot specify both, seed and rng"))
    !isnothing(seed)                     && return getRNG(seed)
    isnothing(rng)                       && return GLOBAL_RNG
    return rng
end

"""
    insorted(item, collection)

Return true if `item` is in sorted collection `collection`.

### Implementation Notes
Does not verify that `collection` is sorted.
"""
function insorted(item, collection)
    index = searchsortedfirst(collection, item)
    @inbounds return (index <= length(collection) && collection[index] == item)
end

"""
    findall!(A, B)

Set the `B[1:|I|]` to `I` where `I` is the set of indices `A[I]` returns true. 

Assumes `length(B) >= |I|`.
"""
function findall!(A::Union{BitArray{1}, Vector{Bool}}, B::Vector{T}) where T<:Integer
    len = 0
    @inbounds for (i, a) in enumerate(A)
        if a
            len += 1
            B[len] = i
        end
    end
    return B
end

"""
    unweighted_contiguous_partition(num_items, required_partitions)

Partition `1:num_items` into `required_partitions` number of partitions such that the
difference in length of the largest and smallest partition is atmost 1.

### Performance
Time: O(required_partitions)
"""
function unweighted_contiguous_partition(
    num_items::Integer,
    required_partitions::Integer
    )

    left = 1
    part = Vector{UnitRange}(undef, required_partitions)
    for i in 1:required_partitions
        len = fld(num_items+i-1, required_partitions)
        part[i] = left:(left+len-1)
        left += len
    end
    return part
end

"""
    greedy_contiguous_partition(weight, required_partitions, num_items=length(weight))

Partition `1:num_items` into atmost `required_partitions` number of contiguous partitions with 
the objective of minimising the largest partition.
The size of a partition is equal to the num of the weight of its elements.
`weight[i] > 0`.

### Performance
Time: O(num_items+required_partitions)
Requires only one iteration over `weight` but may not output the optimal partition.

### Implementation Notes
`Balance(wt, left, right, n_items, n_part) = 
max(sum(wt[left:right])*(n_part-1), sum(wt[right+1:n_items]))`.
Find `right` that minimises `Balance(weight, 1, right, num_items, required_partitions)`.
Set the first partition as `1:right`.
Repeat on indices `right+1:num_items` and one less partition.
"""
function greedy_contiguous_partition(
    weight::Vector{<:Integer},
    required_partitions::Integer,
    num_items::U=length(weight)
    ) where U <: Integer

    suffix_sum = cumsum(reverse(weight))
    reverse!(suffix_sum) 
    push!(suffix_sum, 0) #Eg. [2, 3, 1] => [6, 4, 1, 0]

    partitions = Vector{UnitRange{U}}()
    sizehint!(partitions, required_partitions)

    left = one(U)
    for partitions_remain in reverse(1:(required_partitions-1))

        left >= num_items && break 

        partition_size = weight[left]*partitions_remain #At least one item in each partition
        right = left

        #Find right: sum(wt[left:right])*partitions_remain and sum(wt[(right+1):num_items]) is balanced
        while right+one(U) < num_items && partition_size < suffix_sum[right+one(U)] 
            right += one(U)
            partition_size += weight[right]*partitions_remain
        end
        #max( sum(wt[left:right]), sum(wt[(right+1):num_items]) ) = partition_size
        #max( sum(wt[left:(right-1)]), sum(wt[right:num_items]) ) = suffix_sum[right]
        if left != right && partition_size > suffix_sum[right]
            right -= one(U)
        end
        
        push!(partitions, left:right)
        left = right + one(U)
    end
    push!(partitions, left:num_items)

    return partitions
end

"""
    optimal_contiguous_partition(weight, required_partitions, num_items=length(weight))

Partition `1:num_items` into atmost `required_partitions` number of contiguous partitions such
that the largest partition is minimised.
The size of a partition is equal to the sum of the weight of its elements.
`weight[i] > 0`.

### Performance
Time: O(num_items*log(sum(weight)))

### Implementation Notes
Binary Search for the partitioning over `[fld(sum(weight)-1, required_partitions), sum(weight)]`. 
"""
function optimal_contiguous_partition(
    weight::Vector{<:Integer},
    required_partitions::Integer,
    num_items::U=length(weight)
    ) where U <: Integer

    item_it = Iterators.take(weight, num_items)

    up_bound = sum(item_it) # Smallest known possible value
    low_bound = fld(up_bound-1, required_partitions) # Largest known impossible value

    # Find optimal balance
    while up_bound > low_bound+1
        search_for = fld(up_bound+low_bound, 2) 

        sum_part = 0
        remain_part = required_partitions

        possible = true
        for w in item_it
            sum_part += w
            if sum_part > search_for
                sum_part = w
                remain_part -= 1
                if remain_part == 0
                    possible = false
                    break
                end
            end
        end
        if possible
            up_bound = search_for
        else
            low_bound = search_for
        end
    end
    best_balance = up_bound

    # Find the partition with optimal balance
    partitions = Vector{UnitRange{U}}()
    sizehint!(partitions, required_partitions)
    sum_part = 0
    left = 1
    for (i, w) in enumerate(item_it)
        sum_part += w
        if sum_part > best_balance
            push!(partitions, left:(i-1))
            sum_part = w
            left = i
        end
    end
    push!(partitions, left:num_items)

    return partitions
end

"""
    isbounded(n)

Returns true if `typemax(n)` of an integer `n` exists.
"""
isbounded(n::Integer) = true
isbounded(n::BigInt) = false

"""
    isbounded(T)

Returns true if `typemax(T)` of a type `T <: Integer` exists.
"""
isbounded(::Type{T}) where {T <: Integer} = isconcretetype(T)
isbounded(::Type{BigInt}) = false

"""
    deepcopy_adjlist(adjlist::Vector{Vector{T}})

Internal utility function for copying adjacency lists.
On adjacency lists this function is more efficient than `deepcopy` for two reasons:
-  As of Julia v1.0.2, `deepcopy` is not typestable.
- `deepcopy` needs to track all references when traversing a recursive data structure
    in order to ensure that references to the same location do need get assigned to
    different locations in the copy. Because we can assume that all lists in our
    adjacency list are different, we don't need to keep track of them.
If `T` is not a bitstype (e.g. `BigInt`), we use the standard `deepcopy`.
"""
function deepcopy_adjlist(adjlist::Vector{Vector{T}}) where {T}
    isbitstype(T) || return deepcopy(adjlist)

    result = Vector{Vector{T}}(undef, length(adjlist))
    @inbounds for (i, list) in enumerate(adjlist)
        result_list = Vector{T}(undef, length(list))
        for (j, item) in enumerate(list)
            result_list[j] = item
        end
        result[i] = result_list
    end

    return result
end
