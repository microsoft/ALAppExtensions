Provides constants and static methods for trigonometric, logarithmic, and other common mathematical functions.


# Public Objects
## Math (Codeunit 710)

 Provides constants and static methods for trigonometric, logarithmic, and other common mathematical functions.
 

### Pi (Method) <a name="Pi"></a> 

 Returns the value of pi.
 

#### Syntax
```
procedure Pi(): Decimal
```
#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

Value of pi.
### E (Method) <a name="E"></a> 

 Returns the value of E.
 

#### Syntax
```
procedure E(): Decimal
```
#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

Value of E.
### Abs (Method) <a name="Abs"></a> 

 Returns the absolute value of a Decimal number.
 

#### Syntax
```
procedure Abs(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

A decimal.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

A decimal number, x, such that 0 ≤ x ≤MaxValue
### Acos (Method) <a name="Acos"></a> 

 Returns the angle whose cosine is the specified number.
 

#### Syntax
```
procedure Acos(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

A number representing a cosine.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

An angle, θ, measured in radians, such that 0 ≤θ≤π
### Asin (Method) <a name="Asin"></a> 

 Returns the angle whose sine is the specified number.
 

#### Syntax
```
procedure Asin(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

A number representing a sine, where decimalValue must be greater than or equal to -1, but less than or equal to 1.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

An angle, θ, measured in radians, such that -π/2 ≤θ≤π/2
### Atan (Method) <a name="Atan"></a> 

 Returns the angle whose tangent is the specified number.
 

#### Syntax
```
procedure Atan(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

A number representing a tangent.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

An angle, θ, measured in radians, such that -π/2 ≤θ≤π/2.
### Atan2 (Method) <a name="Atan2"></a> 

 Returns the angle whose tangent is the quotient of two specified numbers.
 

#### Syntax
```
procedure Atan2(y: Decimal; x: Decimal): Decimal
```
#### Parameters
*y ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

The y coordinate of a point.

*x ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

The x coordinate of a point.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

An angle, θ, measured in radians, such that -π≤θ≤π, and tan(θ) = y / x, where (x, y) is a point in the Cartesian plane. 
### BigMul (Method) <a name="BigMul"></a> 

 Produces the full product of two 32-bit numbers.
 

#### Syntax
```
procedure BigMul(a: Integer; b: Integer): BigInteger
```
#### Parameters
*a ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The first number to multiply.

*b ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The second number to multiply.

#### Return Value
*[BigInteger](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/biginteger/biginteger-data-type)*

The number containing the product of the specified numbers.
### Ceiling (Method) <a name="Ceiling"></a> 

 Returns the smallest integral value that is greater than or equal to the specified decimal number.
 

#### Syntax
```
procedure Ceiling(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

A decimal number.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

The smallest integral value that is greater than or equal to decimalValue.
### Cos (Method) <a name="Cos"></a> 

 Returns the cosine of the specified angle.
 

#### Syntax
```
procedure Cos(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

An angle, measured in radians.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

The cosine of decimalValue. 
### Cosh (Method) <a name="Cosh"></a> 

 Returns the hyperbolic cosine of the specified angle.
 

#### Syntax
```
procedure Cosh(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

An angle, measured in radians.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

The hyperbolic cosine of value.
### Exp (Method) <a name="Exp"></a> 

 Returns e raised to the specified power.
 

#### Syntax
```
procedure Exp(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

A number specifying a power.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

The number e raised to the power decimalValue.
### Floor (Method) <a name="Floor"></a> 

 Returns the largest integral value less than or equal to the specified decimal number.
 

#### Syntax
```
procedure Floor(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

A decimal number.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

The largest integral value less than or equal to decimalValue.
### IEEERemainder (Method) <a name="IEEERemainder"></a> 

 Returns the remainder resulting from the division of a specified number by another specified number.
 

#### Syntax
```
procedure IEEERemainder(x: Decimal; y: Decimal): Decimal
```
#### Parameters
*x ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

A dividend.

*y ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

A divisor.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

A number equal to x - (y Q), where Q is the quotient of x / y rounded to the nearest integer (if x / y falls halfway between two integers, the even integer is returned).
### Log (Method) <a name="Log"></a> 

 Returns the natural (base e) logarithm of a specified number.
 

#### Syntax
```
procedure Log(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

The number whose logarithm is to be found.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

The natural logarithm of decimalValue; that is, ln decimalValue, or log e decimalValue
### Log (Method) <a name="Log"></a> 

 Returns the logarithm of a specified number in a specified base.
 

#### Syntax
```
procedure Log(a: Decimal; newBase: Decimal): Decimal
```
#### Parameters
*a ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

The number whose logarithm is to be found.

*newBase ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

The base of the logarithm.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

The logarithm of a specified number in a specified base.
### Log10 (Method) <a name="Log10"></a> 

 Returns the base 10 logarithm of a specified number.
 

#### Syntax
```
procedure Log10(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

A number whose logarithm is to be found.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

The base 10 logarithm of the specified number
### Max (Method) <a name="Max"></a> 

 Returns the larger of two decimal numbers.
 

#### Syntax
```
procedure Max(decimalValue1: Decimal; decimalValue2: Decimal): Decimal
```
#### Parameters
*decimalValue1 ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

The first of two decimal numbers to compare.

*decimalValue2 ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

The second of two decimal numbers to compare.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

Parameter decimalValue1 or decimalValue2, whichever is larger.
### Min (Method) <a name="Min"></a> 

 Returns the smaller of two decimal numbers.
 

#### Syntax
```
procedure Min(decimalValue1: Decimal; decimalValue2: Decimal): Decimal
```
#### Parameters
*decimalValue1 ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

The first of two decimal numbers to compare.

*decimalValue2 ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

The second of two decimal numbers to compare.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

Parameter decimalValue1 or decimalValue2, whichever is smaller.
### Pow (Method) <a name="Pow"></a> 

 Returns a specified number raised to the specified power.
 

#### Syntax
```
procedure Pow(x: Decimal; y: Decimal): Decimal
```
#### Parameters
*x ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

A double-precision floating-point number to be raised to a power.

*y ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

A double-precision floating-point number that specifies a power.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

The number x raised to the power y.
### Sign (Method) <a name="Sign"></a> 

 Returns an integer that indicates the sign of a decimal number.
 

#### Syntax
```
procedure Sign(decimalValue: Decimal): Integer
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

A signed decimal number.

#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

A number that indicates the sign of value.
### Sinh (Method) <a name="Sinh"></a> 

 Returns the hyperbolic sine of the specified angle.
 

#### Syntax
```
procedure Sinh(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

An angle, measured in radians.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

The hyperbolic sine of value.
### Sin (Method) <a name="Sin"></a> 

 Returns the sine of the specified angle.
 

#### Syntax
```
procedure Sin(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

An angle, measured in radians.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

The sine of a.
### Sqrt (Method) <a name="Sqrt"></a> 

 Returns the square root of a specified number.
 

#### Syntax
```
procedure Sqrt(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

The number whose square root is to be found.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

The positive square root of decimalValue.
### Tan (Method) <a name="Tan"></a> 

 Returns the tangent of the specified angle.
 

#### Syntax
```
procedure Tan(a: Decimal): Decimal
```
#### Parameters
*a ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

An angle, measured in radians.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

The tangent of a.
### Tanh (Method) <a name="Tanh"></a> 

 Returns the hyperbolic tangent of the specified angle.
 

#### Syntax
```
procedure Tanh(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

An angle, measured in radians.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

The hyperbolic tangent of value.
### Truncate (Method) <a name="Truncate"></a> 

 Calculates the integral part of a specified decimal number.
 

#### Syntax
```
procedure Truncate(decimalValue: Decimal): Decimal
```
#### Parameters
*decimalValue ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

A number to truncate.

#### Return Value
*[Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type)*

The integral part of decimalValue.
