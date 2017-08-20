function [price] = FEMLogPriceAmerican1( S0,K,r,T,N,M,sigma,NumMethod,theta,...
	maxiter,tol,omega)
%UNTITLED22 Summary of this function goes here
%   Detailed explanation goes here
%% grid
dt = T / M;
t = 0:dt:T;
xmin = log(S0 * exp((r - sigma^2/2) * T -6 * sigma * sqrt(T)));
xmax = log(S0 * exp((r - sigma^2/2) * T +6 * sigma * sqrt(T)));
dx = (xmax - xmin) / N;
x = (xmin:dx:xmax)';
%% matrix definition
e = ones([N-1 1]);
DD = e * [-1/dx 2/dx -1/dx];
DD = spdiags(DD,-1:1,N-1,N-1);
FF = e * [dx/6 2/3*dx dx/6];
FF =  spdiags(FF,-1:1,N-1,N-1);
FD = e * [0.5 0 -0.5];
FD = spdiags(FD,-1:1,N-1,N-1);
switch NumMethod
	case 'explicit'
		diff_tilde = -sigma^2/2;
		reaz_tilde = 1/dt - r;
		tr_tilde = -(r - sigma^2/2);
		M2 = diff_tilde * DD + reaz_tilde * FF + tr_tilde * FD;
		M1 = FF / dt;
	case 'implicit'
		diff = sigma^2/2;
		reaz = 1/dt + r;
		tr = r - sigma^2/2;
		M1 = diff * DD + reaz * FF + tr * FD;
		M2 = FF / dt;
	case 'CN'
		diff = theta * sigma^2/2;
		reaz = 1/dt + theta * r;
		tr = theta * (r - sigma^2/2);
		diff_tilde = -(1 - theta) * sigma^2/2;
		reaz_tilde = 1/dt - (1 - theta) * r;
		tr_tilde = -(1 - theta) * (r - sigma^2/2);
		M1 = diff * DD + reaz * FF + tr * FD;
		M2 = diff_tilde * DD + reaz_tilde * FF + tr_tilde * FD;
	otherwise
		error('NumMethod invalid')
end
%% backward in time
BC = zeros([N-1 1]);
V = subplus(K - exp(x(2:end-1)));
h = waitbar(0,'Please wait...');
for j = M : -1 : 1
	BC(1) = -M1(2,1) * (exp(-r*(T - t(j)))*K - exp(xmin)) + ...
		M2(2,1) * (exp(-r*(T - t(j+1)))*K - exp(xmin));
% 	 	V = M1 \(M2 * V + BC);
	b = M2 * V + BC;
	V = PSORalgorithm1(M1,b,V,maxiter,tol,omega,K,N,x);
	waitbar((M - j)/M, h);
end
close(h);
price = interp1(exp(x(2:end-1)),V,S0,'spline');
end

