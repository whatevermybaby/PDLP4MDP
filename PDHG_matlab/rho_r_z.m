% rng(5)
% A=rand(2,5);
% l=zeros(2+5,1);
% r=5;
% b=rand(2,1);
% c=rand(5,1);
% z=rand(2+5,1);
function [z_hat,favl]=rho_r_z(l,z,r,A,b,c)
%   rho_r(z)=1/r*max(L(x,y_hat)-L(x_hat,y))
%   s.t. z_hat \in R^n+m
%        l<=z_hat
%        ||z_hat-z||_2<=r
% using dichotomy
[m,n]=size(A);
g=[c;-b]+[zeros(n,n) -A';A zeros(m,m)]*z;

z1=z;g1=g;l1=l;
gieq=find(g~=0);
g=g(gieq);
z=z(gieq);
l=l(gieq);

l(find(g<0))=-inf;
g=max(g,-g);
lambda_hat=(z-l)./g;

if norm(l-z)<=r
    z_hat=l;
else
    lambda_lo=0;
    lambda_hi=inf;
    lo_n=find(lambda_hat<=lambda_lo);
    up_n=find(lambda_hat>=lambda_hi);
    f_lo=norm(l(lo_n)-z(lo_n),2)^2;
    f_hi=norm(g(up_n),2)^2;
    I=find(lambda_lo<lambda_hat & lambda_hat<lambda_hi);
    
    while isempty(I)==0 
        lambda_hat=lambda_hat(I);
        z=z(I);l=l(I);g=g(I);
        I=find(lambda_lo<lambda_hat & lambda_hat<lambda_hi);
        
        lambda_mid=median(lambda_hat);
        z_hat=max(z-lambda_mid*g,l);
        f_mid=f_lo+norm(z_hat-z,2)^2+f_hi*lambda_mid^2;
        
        lo_n=find(lambda_hat<=lambda_mid);
        up_n=find(lambda_hat>=lambda_mid);
        if f_mid<r^2
            lambda_lo=lambda_mid;
            lo_n=find(lambda_hat<=lambda_mid);
            f_lo=f_lo+norm(l(lo_n)-z(lo_n))^2;
            I=I(find(lambda_hat>lambda_mid));
        else
            lambda_hi=lambda_mid;
            up_n=find(lambda_hat>=lambda_mid);
            f_hi=f_hi+norm(g(up_n))^2;
            I=I(find(lambda_hat<lambda_mid));
        end
    end
    lambda_mid=sqrt((r^2-f_lo)/f_hi);
    z_hat=max(z1-lambda_mid*g1,l1);
end
favl=-1/r*(g1'*z_hat-[c;-b]'*z1);
end
