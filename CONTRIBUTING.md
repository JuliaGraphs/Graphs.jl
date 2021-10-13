# Contributor Guide

We welcome all possible contributors and ask that you read these guidelines before starting to work on this project.
Following these guidelines will reduce friction and improve the speed at which your code gets merged.

## Bug reports

If you notice code that crashes, is incorrect, or is too slow, please file a bug report. The report should be raised as a github issue with a minimal working example that reproduces the condition.
The example should include any data needed. If the problem is incorrectness, then please post the correct result along with an incorrect result.

Please include version numbers of all relevant libraries and Julia itself.

## Development guidelines

- Correctness is a necessary requirement; efficiency is desirable. Once you have a correct implementation, make a Pull Request (PR) so we can help improve performance.
- PRs should contain one logical enhancement to the codebase.
- Squash commits in a PR.
- If you want to introduce a new feature, open an issue can to discuss a feature before you start coding (this maximizes the likelihood of patch acceptance).
- Minimize dependencies on external packages, and avoid introducing new dependencies that would increase the compilation time by a lot.
- Put type assertions on all function arguments where conflict may arise (use abstract types, `Union`, or `Any` if necessary).
- If the algorithm was presented in a paper, include a reference to the paper (_e.g._, a proper academic citation along with an eprint link).
- Take steps to ensure that code works correctly and efficiently on edge cases (disconnected graphs, empty graphs, ...).
- We can accept code that does not work for directed graphs as long as it comes with an explanation of what it would take to make it work for directed graphs.
- Prefer the short circuiting conditional over `if`/`else` when convenient, and where state is not explicitly being mutated (*e.g.*, `condition && error("message")` is good; `condition && i += 1` is not).
- Write code to reuse memory wherever possible. For example:

```julia
function f(g, v)
    storage = Vector{Int}(undef, nv(g))
    # some code operating on storage, g, and v.
    for i in 1:nv(g)
        storage[i] = v-i
    end
    return sum(storage)
end
```
should be rewritten as two functions
```julia
function f(g::AbstractGraph, v::Integer)
    storage = Vector{Int}(undef, nv(g))
    return f!(g, v, storage)
end

function f!(g::AbstractGraph, v::Integer, storage::AbstractVector{Int})
    # some code operating on storage, g, and v.
    for i in 1:nv(g)
        storage[i] = v-i
    end
    return sum(storage)
end
```
This gives users the option of reusing memory and improving performance.

### Minimizing use of internal struct fields

Since Graphs supports multiple implementations of the graph data structure using the `AbstractGraph` [type](https://juliagraphs.github.io/Graphs.jl/latest/types.html#AbstractGraph-Type-1), you should refrain from using the internal fields of structs such as `fadjlist`. Instead, you should use the functions provided in the API.
Code that is instrumental to defining a concrete graph type can use the internal structure of that type.

## Git usage

### Getting started on a package contribution

In order to make it easier for you to contribute and review Pull Requests (PRs),
it would be better to be familiar with git fundamentals.

Most importantly:
- clone the repository from JuliaGraphs/Graphs.jl
- fork the repository on your own github account
- make the modification to the repository, test and document all your changes
- push to the fork you created
- open a PR.

See the [JuMP documentation](https://jump.dev/JuMP.jl/dev/developers/contributing/) for a more detailed guide.

### Advanced: visualize opened PRs locally:

In order to make it easier for you to review Pull Requests (PRs), you can add this to your git config file, which should be located at `PACKAGE_LOCATION/.git/config`, where `PACKAGE_LOCATION` is where the Graphs.jl was cloned.
If you added the package with the `] dev` command, it is likely at `$HOME/.julia/dev/Graphs`.

These instructions were taken from [this gist](https://gist.github.com/piscisaureus/3342247).

Locate the section for your github remote in the `.git/config` file. It looks like this:

```
[remote "origin"]
    fetch = +refs/heads/*:refs/remotes/origin/*
    url = git@github.com:JuliaGraphs/Graphs.jl.git
```

Now add the line `fetch = +refs/pull/*/head:refs/remotes/origin/pr/*` to this section. Obviously, change the github url to match your project's URL. It ends up looking like this:

```
[remote "origin"]
    fetch = +refs/heads/*:refs/remotes/origin/*
    url = git@github.com:JuliaGraphs/Graphs.jl.git
    fetch = +refs/pull/*/head:refs/remotes/origin/pr/*
```

Now fetch all the pull requests:

```
$ git fetch origin
From github.com:JuliaGraphs/Graphs.jl
 * [new ref]         refs/pull/1000/head -> origin/pr/1000
 * [new ref]         refs/pull/1002/head -> origin/pr/1002
 * [new ref]         refs/pull/1004/head -> origin/pr/1004
 * [new ref]         refs/pull/1009/head -> origin/pr/1009
...
```

To check out a particular pull request:

```
$ git checkout pr/999
Branch pr/999 set up to track remote branch pr/999 from origin.
Switched to a new branch 'pr/999'
```

Now you can test a PR by running `git fetch && git checkout pr/PRNUMBER && julia -e 'using Pkg; Pkg.test("Graphs")'`
