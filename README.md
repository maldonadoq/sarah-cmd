Sarah-Cmd
======================

[sarah]: https://github.com/percy00010/sarah-cmd

  - [Introduction](#introduction)
  - [Sarah](#sarah)
  - [Examples](#examples)

## Introduction ##

## Sarah ##

### Type Variable
    - Function
    	* f(x)= sin(x)
    - Base
    	* B= [(1,5):(2,4):(3,2):(4,9)]
    - Matrix
      * M= [1,2:2,3]
    - Real 
    	* p= 10    

### Functions!!
    * plot(Function;a;b)
    * plotear(Method Function) I
    * select(Method Click)     II
    * integrate(Function;A;B;ns;Method Integrate)
    * raiz(Function;A;B;Error;Method Raiz;Newton[Derivada])
    * interpolation(Base;Method Interpolation)
    * edo(Function;A;B;xin;f(xin);Method Edo;Frame)	
    * intersection(Function;Function;A;B;Error)
    * extrapolation(Data,Method Extrapolation)
    * matrix(Matrix;Matrix;Esc-Pow;Operation)
    
### ABC
    -Method Integrate
        * 'Trapecio'
        * 'Simpson1/3'
        * 'Simpson3/8'
        * 'Cuadratura'
    - Method Raiz
        * 'Bisect'
        * 'FalPos'
        * 'Secant'
        * 'Newton' ->[Derivada!]''
    - Method Interpolation
        * 'Lagrange'
        * 'Newton'
    - Data
        * 'Name Data.txt'
    - Method Extrapolation
        * 'Lineal'
        * 'Exponencial'
        * 'Logaritmo'
    - Method Edo
        * 'Euler'
        * 'Heun'
        * 'RungeKutta'
        * 'Dormand'
    - Frame
        * 'Table'   [Tabla de Datos]
        * 'Graphic' [Grafica!!!]
    - Error
        * E-4[0.0001]
    - Method Click
        * area [area entre las dos funciones seleccionadas]
        * intersection [raiz entre las dos funciones seleccionadas]
    - Method Function
        * clear [limpiar todas las funciones]
        * view [volver a la grafica de funciones]
        * Function         
## Examples
    - Variables
		  * f(x)= sin(x)
      * g(x)= cos(x)
      * h(x)= power(x,2)-2
      * B= [(1,5):(2,4):(3,2):(4,9)]
      * M= [1,2:2,3]
      * N= [-6,2:4,3]
      * s(x)= sin(exp(x*y))/((2*y)-(x*cos(exp(x*y))))

    - Functions
      * plot(f(x);-10;10)      
      * integrate(h(x);1;2;100;'Simpson1/3')
      * areaI(h(x);1;2;100)
      * areaII(f(x);g(x))
      * raiz(h(x);1;2;0.001;'Bisect';'')
      * interpolation(B;'Lagrange')
      * edo(s(x);-0.7;2;-0.7;0.49;'RungeKutta';'Graphic')
      * intersection(f(x);g(x);-10;10;0.001)
      * extrapolation('data.txt','Lineal')
      * matrix(M;N;2;'inv')
    - Click Op
      * plotear(x*0.1) | plotear(sin(x)) [many]
      * choose function!! click [seleccionar 2 funciones!]
      * select(area)

<!--:sparkles: :camel: :boom:-->

* * *
[Percy Maldonado Quispe UCSP](https://github.com/percy00010)
