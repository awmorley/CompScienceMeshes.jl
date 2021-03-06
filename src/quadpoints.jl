immutable WeightPointValue{W,P,V}
  weight::W
  point::P
  value::V
end


function quadpoints(chart::ReferenceSimplex{1}, rule)
    u, w = legendre(rule, 0.0, 1.0)
    [(neighborhood(chart, u[:,i]), w[i]) for i in eachindex(w)]
    #[neighborhood(chart, u[:,i]) for i in eachindex(w)], w
end

function quadpoints(chart::ReferenceSimplex{2}, rule)
    u, w = trgauss(rule)
    [(neighborhood(chart, u[:,i]), w[i]) for i in eachindex(w)]
    #[neighborhood(chart, u[:,i]) for i in eachindex(w)], w
end


"""
    pw = quadpoints(chart, rule)

Returns a collection of (point, weight) tuples corresponding to the numerical quadrature `rule`
defined on the domain of `chart`. The weights returned take into account the Jacobian determinant
resulting from mapping from the reference domain to the configuration space.

Functions can be integrated like:

```julia
PW = quadpoints(chart, rule)
I = sum(pw[2]*f(pw[1]) for pw in PW)
```
"""
function quadpoints(chart::Simplex, rule)
    #P, V = quadpoints(domain(chart), rule)
    #Q = [neighborhood(chart,p) for p in P]
    #W = [jacobian(q)*v for (q,v) in zip(Q,V)]
    #return collect(zip(Q, W))
    PV = quadpoints(domain(chart), rule)
    map(PV) do pv
        q = neighborhood(chart, pv[1])
        w = jacobian(q)*pv[2]
        (q,w)
    end
end


"""
    quadpoints(refspace, charts, rules)

Computed a matrix of vectors containing (weight, point, value) triples that can
be used in numerical integration over the elements described by the charts. Internally,
this method used `quadpoints(chart, rule)` to retrieve the points and weights for
a certain quadrature rule over `chart`.
"""
function quadpoints(f, charts, rules)

    pw = quadpoints(charts[1], rules[1])
    P = typeof(pw[1][1])
    W = typeof(pw[1][2])
    V = typeof(f(pw[1][1]))

    WPV = WeightPointValue{W,P,V}

    qd = Array{Vector{WPV}}(length(rules), length(charts))
    for j in eachindex(charts)
        for i in eachindex(rules)
            pw = quadpoints(charts[j], rules[i])
            qd[i,j] = Vector{WPV}(length(pw))
            for k in eachindex(pw)
                qd[i,j][k] = WeightPointValue(pw[k][2],pw[k][1],f(pw[k][1]))
            end
        end
    end

  qd
end
