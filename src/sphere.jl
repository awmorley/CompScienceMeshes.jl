
# U: the dimension of the universe
# D: the dimension of the manifold
# N: the number of vertices
# T: the type of the coordinates
# C: the complimentary dimension (should always be U-D)
immutable SphereChart{P,T}
    center::P
    radius::T
end

volume(p::SphereChart) = 4π * p.radius^2

coordtype{P,T}(ch::Type{SphereChart{P,T}}) = T
coordtype(p::SphereChart) = coordtype(typeof(p))

dimension{P,T}(p::SphereChart{P,T}) = 2
dimension(p::SphereChart) = dimension(typeof(p))

universedimension{P,T}(::Type{SphereChart{P,T}}) = 3
universedimension(p::SphereChart) = universedimension(typeof(p))

immutable ThetaPhiPlane{T} end
domain{P,T}(ch::SphereChart{P,T}) = ThetaPhiPlane{T}()

immutable SphereNeighborhood{P,Q,T}
    sphere::SphereChart{P,T}
    paramters::Q
    cartesian::P
    tangents::Tuple{P,P}
end

function neighborhood(ch::SphereChart, uv)
    ϕ, Θ = uv

    cosϕ, sinϕ = cos(ϕ), sin(ϕ)
    cosΘ, sinΘ = cos(Θ), sin(Θ)

    p = @SVector [cosϕ*sinΘ, sinϕ*sinΘ, cosΘ]

    tΘ = @SVector [cosϕ*cosΘ, sinϕ*cosΘ, -sinΘ]
    tϕ = @SVector [-sinϕ*sinΘ/abs(sinΘ), cosϕ*sinΘ/abs(sinΘ), 0]

    SphereNeighborhood(ch, uv, p, (tΘ, tϕ))
end

cartesian(nbd::SphereNeighborhood) = nbd.cartesian

function quadpoints(ch::SphereChart, L)
    UW = zip(legendre(L+1, -1.0, 1.0)...)
    dp = 2π / (2L+1); P = linspace(0, 2π-dp, 2L+1)
    [(neighborhood(ch, (p,acos(u))), dp*w) for (u,w) in UW for p in P]
end
