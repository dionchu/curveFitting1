function[x] = laGrange(c, A, b, B)

  D = A*inv(B)*A';

v = (inv(B)-inv(B)*A'*inv(D)*A*inv(B))*c;
w = inv(B)*A'*inv(D)*b;

gamma = ((v'*B*v)*(w'*B*w)-(v'*B*w)^2)/(v'*B*v);
 gamma = gamma*1;
mu1   = (-v'*B*w+sqrt((v'*B*w)^2-(v'*B*v)*(w'*B*w-gamma)))/(v'*B*v);
		      mu2   = (-v'*B*w-sqrt((v'*B*w)^2-(v'*B*v)*(w'*B*w-gamma)))/(v'*B*v);

%%%% alternatively, normalize v to improve machine precision

u = (v./sqrt(v'*B*v));
gamma2 = (w'-(u'*B*w)*u')*B*w;
r1     = -u'*B*w+sqrt(gamma2 + ((u'*B*w)*u'-w')*B*w);
r2     = -u'*B*w-sqrt(gamma2 + ((u'*B*w)*u'-w')*B*w);

x1 = r1*v+w;
x2 = r2*v+w;

if(c'*x1 > c'*x2)
x = x1;
else
x = x2;
end
