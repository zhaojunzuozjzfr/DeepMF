function [  W, H, F_obj ] = GsnMF( V, r,maxiter, err_rat, Lp,LpC)
 % code by Haonan Huang, 2020
 H = rand(r, size(V, 2)); 
 W = V * pinv(H);

 HVt=H*V'; HHt=H*H';
 WtV=W'*V; WtW=W'*W; 

 F_obj(1,1)=norm(V - W * H, 'fro') + trace(H * Lp * H');

for iter = 1:maxiter
    [H]=NNLS_MR(H,WtW,WtV,Lp,LpC);    %Optimize H with W fixed
    HHt=H*H';   HVt=H*V';
    [W]=Ne_NNLS(W,HHt,HVt);           %Optimize W with H fixed
     WtW=W'*W; WtV=W'*V;       
    F_obj(1,iter+1)=norm(V - W * H, 'fro') + trace(H * Lp * H');
%     if F_obj(iter+1)<err_rat
%        break;
%     end
end
return;

function [H,Grad]=Ne_NNLS(Z,WtW,WtV)

if ~issparse(WtW)
    L=norm(WtW);	% Lipschitz constant
else
    L=norm(full(WtW));
end

% Grad=WtW*Z-WtV;    % orginal Gradient
Grad=Z*WtW-WtV';     
H=Z-Grad/L;          
denom=max(1,sqrt(sum(H.^2)));
ind=find(denom>0);
H(:,ind)=H(:,ind)./(ones(size(H,1),1)*denom(ind));        
% Grad=WtW*H-WtV;
return;

function [H,Grad]=NNLS_MR(Z,WtW,WtV,Lp,LpC)

if ~issparse(WtW)
    L=norm(WtW)+LpC;	% Lipschitz constant
else
    L=norm(full(WtW))+LpC;
end
%H=Z;    % Initialization
Grad=WtW*Z-WtV+Z*Lp;     % Gradient
H=max(Z-Grad/L,0);    % Calculate sequence 'Y'

return;