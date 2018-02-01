# sarah-cmd
Análisis Numérico!

>Type Variable!
  -Function 
    f(x)= sin(x)
  -Real
    p= 10
  -Base
    B= [(1,5):(2,4):(3,2):(4,9)]
  -Matrix
    M[]= [1,2:2,3]

>Functions!
	- plot(Function;a;b)
	- integrate(Function;A;B;ns;Method Integrate)
	- raiz(Function;A;B;Error;Method Raiz;Newton[Derivada])
	- interpolation(Base;Method Interpolation)
	- edo(Function;A;B;xin;f(xin);Method Edo;Frame)	
	- intersection(Function;Function;A;B;Error)
	- extrapolation(Data,Method Extrapolation)
	- matrix(Matrix;Matrix;Esc-Pow;Operation)

>ABC
	-Method Integrate
  	.'Trapecio'
  	.'Simpson1/3'
  	.'Simpson3/8'
  	.'Cuadratura'
  -Method Raiz
  	.'Bisect'
  	.'FalPos'
  	.'Secant'
  	.'Newton' ->[Derivada!]''
  -Method Interpolation
    .'Lagrange'
    .'Newton'
  -Data
    .'Name Data.txt'
  -Method Extrapolation
  	.'Lineal'
  	.'Exponencial'
  	.'Logaritmo'
  -Method Edo
    .'Euler'
    .'Heun'
    .'RungeKutta'
    .'Dormand'
  -Frame
  	.'Table'
  	.'Graphic'  
  -Error
    . E-4[0.0001]

>Examples
	-Variables
		.f(x)= 'sin(x)'
		.g(x)= 'cos(x)'
		.h(x)= 'power(x,2)-2'
		.B= '[(1,5):(2,4):(3,2):(4,9)]'
		.M[]= [1,2:2,3]
		.M[]= [-6,2:4,3]
		.s(x)= 'sin(exp(x*y))/((2*y)-(x*cos(exp(x*y))))'

	Functions
  	.plot(f(x);-10;10)
    .integrate(h(x);1;2;100;'Simpson1/3')
	  .raiz(h(x);1;2;0.001;'Bisect';'')
	  .interpolation(B;'Lagrange')
		.edo(s(x);-0.7;2;-0.7;0.49;'RungeKutta';'Graphic')
	  .intersection(f(x);g(x);-10;10;0.001)
		.extrapolation('data.txt','Lineal')