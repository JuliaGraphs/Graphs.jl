# Helpers for iteration

immutable VecProxy{A, I}
    vec::A
    len::Int
    inds::I
end

vec_proxy{A,I}(vec::A, inds::I) = VecProxy(vec, length(inds), inds)

length(proxy::VecProxy) = proxy.len
isempty(proxy::VecProxy) = isempty(proxy.inds)
getindex(proxy::VecProxy, i::Integer) = proxy.vec[proxy.inds[i]]

start(proxy::VecProxy) = 1
next(proxy::VecProxy, s::Int) = (proxy.vec[proxy.inds[s]], s+1)
done(proxy::VecProxy, s::Int) =  s > proxy.len
