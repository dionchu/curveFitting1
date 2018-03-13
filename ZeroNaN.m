function[A] = ZeroNaN(A)

  b=isnan(A);
A(b)=0;
