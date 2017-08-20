function [alpha,lambda_num,sigma2_eps,Bl,Br] = LevyIntegral1AI(k,N,epsilon)
%UNTITLED33 Summary of this function goes here
%   Detailed explanation goes here
tol = 1e-10;
Br = 0.001;Bl = -0.001;
% while (k(Bl)>tol)
%     Bl=Bl-0.2;
% end
% while (k(Br)>tol)
%     Br=Br+0.2;
% end
Bl = fsolve(@(y) k(y) - tol, Bl);
Br = fsolve(@(y) k(y) - tol, Br);
qnodes = linspace(-epsilon,epsilon, 2*N);
sigma2_eps = trapz(qnodes,qnodes.^2 .* k(qnodes).* (qnodes>0)) + ...
	trapz(qnodes,qnodes.^2 .* k(qnodes).* (qnodes<0));
qnodes1 = linspace(Bl,-epsilon,N);
qnodes2 = linspace(epsilon,Br,N);
lambda_num = trapz(qnodes1,k(qnodes1)) + trapz(qnodes2,k(qnodes2));
alpha = trapz(qnodes1, (exp(qnodes1) - 1) .* k(qnodes1)) + ...
	trapz(qnodes2, (exp(qnodes2) - 1) .* k(qnodes2));
end % end function

