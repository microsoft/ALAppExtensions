// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides constants and static methods for trigonometric, logarithmic, and other common mathematical functions.
/// </summary>
codeunit 710 Math
{
    Access = Public;

    var
        DotNetMath: DotNet Math;

    /// <summary>
    /// Returns the value of pi.
    /// </summary>
    /// <returns>Value of pi.</returns>
    procedure Pi(): Decimal
    begin
        exit(3.1415926535897931);
    end;

    /// <summary>
    /// Returns the value of E.
    /// </summary>
    /// <returns>Value of E.</returns>
    procedure E(): Decimal
    begin
        exit(2.7182818284590451);
    end;

    /// <summary>
    /// Returns the absolute value of a Decimal number.
    /// </summary>
    /// <param name="decimalValue">A decimal.</param>
    /// <returns>A decimal number, x, such that 0 ≤ x ≤MaxValue</returns>
    procedure Abs(decimalValue: Decimal): Decimal
    begin
        exit(DotNetMath.Abs(decimalValue));
    end;

    /// <summary>
    /// Returns the angle whose cosine is the specified number.
    /// </summary>
    /// <param name="decimalValue">A number representing a cosine.</param>
    /// <returns>An angle, θ, measured in radians, such that 0 ≤θ≤π</returns>
    procedure Acos(decimalValue: Decimal): Decimal
    begin
        exit(DotNetMath.Acos(decimalValue));
    end;

    /// <summary>
    /// Returns the angle whose sine is the specified number.
    /// </summary>
    /// <param name="decimalValue">A number representing a sine, where decimalValue must be greater than or equal to -1, but less than or equal to 1.</param>
    /// <returns>An angle, θ, measured in radians, such that -π/2 ≤θ≤π/2</returns>
    procedure Asin(decimalValue: Decimal): Decimal
    begin
        exit(DotNetMath.Asin(decimalValue));
    end;

    /// <summary>
    /// Returns the angle whose tangent is the specified number.
    /// </summary>
    /// <param name="decimalValue">A number representing a tangent.</param>
    /// <returns>An angle, θ, measured in radians, such that -π/2 ≤θ≤π/2.</returns>
    procedure Atan(decimalValue: Decimal): Decimal
    begin
        exit(DotNetMath.Atan(decimalValue));
    end;

    /// <summary>
    /// Returns the angle whose tangent is the quotient of two specified numbers.
    /// </summary>
    /// <param name="y">The y coordinate of a point.</param>
    /// <param name="x">The x coordinate of a point.</param>
    /// <returns>An angle, θ, measured in radians, such that -π≤θ≤π, and tan(θ) = y / x, where (x, y) is a point in the Cartesian plane. </returns>
    procedure Atan2(y: Decimal; x: Decimal): Decimal
    begin
        exit(DotNetMath.Atan2(y, x));
    end;

    /// <summary>
    /// Produces the full product of two 32-bit numbers.
    /// </summary>
    /// <param name="a">The first number to multiply.</param>
    /// <param name="b">The second number to multiply.</param>
    /// <returns>The number containing the product of the specified numbers.</returns>
    procedure BigMul(a: Integer; b: Integer): BigInteger
    begin
        exit(DotNetMath.BigMul(a, b));
    end;

    /// <summary>
    /// Returns the smallest integral value that is greater than or equal to the specified decimal number.
    /// </summary>
    /// <param name="decimalValue">A decimal number.</param>
    /// <returns>The smallest integral value that is greater than or equal to decimalValue.</returns>
    procedure Ceiling(decimalValue: Decimal): Decimal
    begin
        exit(DotNetMath.Ceiling(decimalValue));
    end;

    /// <summary>
    /// Returns the cosine of the specified angle.
    /// </summary>
    /// <param name="decimalValue">An angle, measured in radians.</param>
    /// <returns>The cosine of decimalValue. </returns>
    procedure Cos(decimalValue: Decimal): Decimal
    begin
        exit(DotNetMath.Cos(decimalValue));
    end;

    /// <summary>
    /// Returns the hyperbolic cosine of the specified angle.
    /// </summary>
    /// <param name="decimalValue">An angle, measured in radians.</param>
    /// <returns>The hyperbolic cosine of value.</returns>
    procedure Cosh(decimalValue: Decimal): Decimal
    begin
        exit(DotNetMath.Cosh(decimalValue));
    end;

    /// <summary>
    /// Returns e raised to the specified power.
    /// </summary>
    /// <param name="decimalValue">A number specifying a power.</param>
    /// <returns>The number e raised to the power decimalValue.</returns>
    procedure Exp(decimalValue: Decimal): Decimal
    begin
        exit(DotNetMath.Exp(decimalValue));
    end;

    /// <summary>
    /// Returns the largest integral value less than or equal to the specified decimal number.
    /// </summary>
    /// <param name="decimalValue">A decimal number.</param>
    /// <returns>The largest integral value less than or equal to decimalValue.</returns>
    procedure Floor(decimalValue: Decimal): Decimal
    begin
        exit(DotNetMath.Floor(decimalValue));
    end;

    /// <summary>
    /// Returns the remainder resulting from the division of a specified number by another specified number.
    /// </summary>
    /// <param name="x">A dividend.</param>
    /// <param name="y">A divisor.</param>
    /// <returns>A number equal to x - (y Q), where Q is the quotient of x / y rounded to the nearest integer (if x / y falls halfway between two integers, the even integer is returned).</returns>
    procedure IEEERemainder(x: Decimal; y: Decimal): Decimal
    begin
        exit(DotNetMath.IEEERemainder(x, y));
    end;

    /// <summary>
    /// Returns the natural (base e) logarithm of a specified number.
    /// </summary>
    /// <param name="decimalValue">The number whose logarithm is to be found.</param>
    /// <returns>The natural logarithm of decimalValue; that is, ln decimalValue, or log e decimalValue</returns>
    procedure Log(decimalValue: Decimal): Decimal
    begin
        exit(DotNetMath.Log(decimalValue));
    end;

    /// <summary>
    /// Returns the logarithm of a specified number in a specified base.
    /// </summary>
    /// <param name="a">The number whose logarithm is to be found.</param>
    /// <param name="newBase">The base of the logarithm.</param>
    /// <returns>The logarithm of a specified number in a specified base.</returns>
    procedure Log(a: Decimal; newBase: Decimal): Decimal
    begin
        exit(DotNetMath.Log(a, newBase));
    end;


    /// <summary>
    /// Returns the base 10 logarithm of a specified number.
    /// </summary>
    /// <param name="decimalValue">A number whose logarithm is to be found.</param>
    /// <returns>The base 10 logarithm of the specified number</returns>
    procedure Log10(decimalValue: Decimal): Decimal
    begin
        exit(DotNetMath.Log10(decimalValue));
    end;

    /// <summary>
    /// Returns the larger of two decimal numbers.
    /// </summary>
    /// <param name="decimalValue1">The first of two decimal numbers to compare.</param>
    /// <param name="decimalValue2">The second of two decimal numbers to compare.</param>
    /// <returns>Parameter decimalValue1 or decimalValue2, whichever is larger.</returns>
    procedure "Max"(decimalValue1: Decimal; decimalValue2: Decimal): Decimal
    begin
        exit(DotNetMath.Max(decimalValue1, decimalValue2));
    end;

    /// <summary>
    /// Returns the smaller of two decimal numbers.
    /// </summary>
    /// <param name="decimalValue1">The first of two decimal numbers to compare.</param>
    /// <param name="decimalValue2">The second of two decimal numbers to compare.</param>
    /// <returns>Parameter decimalValue1 or decimalValue2, whichever is smaller.</returns>
    procedure "Min"(decimalValue1: Decimal; decimalValue2: Decimal): Decimal
    begin
        exit(DotNetMath.Min(decimalValue1, decimalValue2));
    end;

    /// <summary>
    /// Returns a specified number raised to the specified power.
    /// </summary>
    /// <param name="x">A double-precision floating-point number to be raised to a power.</param>
    /// <param name="y">A double-precision floating-point number that specifies a power.</param>
    /// <returns>The number x raised to the power y.</returns>
    procedure Pow(x: Decimal; y: Decimal): Decimal
    begin
        exit(DotNetMath.Pow(x, y));
    end;

    /// <summary>
    /// Returns an integer that indicates the sign of a decimal number.
    /// </summary>
    /// <param name="decimalValue">A signed decimal number.</param>
    /// <returns>A number that indicates the sign of value.</returns>
    procedure Sign(decimalValue: Decimal): Integer
    begin
        exit(DotNetMath.Sign(decimalValue));
    end;

    /// <summary>
    /// Returns the hyperbolic sine of the specified angle.
    /// </summary>
    /// <param name="decimalValue">An angle, measured in radians.</param>
    /// <returns>The hyperbolic sine of value.</returns>
    procedure Sinh(decimalValue: Decimal): Decimal
    begin
        exit(DotNetMath.Sinh(decimalValue));
    end;

    /// <summary>
    /// Returns the sine of the specified angle.
    /// </summary>
    /// <param name="decimalValue">An angle, measured in radians.</param>
    /// <returns>The sine of a.</returns>
    procedure Sin(decimalValue: Decimal): Decimal
    begin
        exit(DotNetMath.Sin(decimalValue));
    end;

    /// <summary>
    /// Returns the square root of a specified number.
    /// </summary>
    /// <param name="decimalValue">The number whose square root is to be found.</param>
    /// <returns>The positive square root of decimalValue.</returns>
    procedure Sqrt(decimalValue: Decimal): Decimal
    begin
        exit(DotNetMath.Sqrt(decimalValue));
    end;

    /// <summary>
    /// Returns the tangent of the specified angle.
    /// </summary>
    /// <param name="a">An angle, measured in radians.</param>
    /// <returns>The tangent of a.</returns>
    procedure Tan(a: Decimal): Decimal
    begin
        exit(DotNetMath.Tan(a));
    end;

    /// <summary>
    /// Returns the hyperbolic tangent of the specified angle.
    /// </summary>
    /// <param name="decimalValue">An angle, measured in radians.</param>
    /// <returns>The hyperbolic tangent of value.</returns>
    procedure Tanh(decimalValue: Decimal): Decimal
    begin
        exit(DotNetMath.Tanh(decimalValue));
    end;

    /// <summary>
    /// Calculates the integral part of a specified decimal number.
    /// </summary>
    /// <param name="decimalValue">A number to truncate.</param>
    /// <returns>The integral part of decimalValue.</returns>
    procedure Truncate(decimalValue: Decimal): Decimal
    begin
        exit(DotNetMath.Truncate(decimalValue));
    end;
}

