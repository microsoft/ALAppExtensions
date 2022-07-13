The purpose of this module is to provide ability to calculate the given expression and return the result.


# Public Objects
## Data Table (Codeunit 50000)

 Exposes functionality to provide ability to calculate the given epression and return the result.
 

### Calculate (Method) <a name="Calculate"></a> 

 Calculates an expression.
 

#### Syntax
```
procedure Calculate(Expression: Text) Result: Variant
```
#### Parameters
*Expression ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Text that contains the expression to calculate.

#### Return Value
*[Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type)*

Returns the result of the calculation. This is a variant that can contain any numeric value: [Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type), [Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type), [BigInteger](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/biginteger/biginteger-data-type) or [Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type).

### Remarks
*This method will return 0 (zero) in case an error occurs during the calcuation. Use method `Calculate(Expression: Text; var Result: Variant): Boolean` to get a boolean return value indicating success or failure.*

### Calculate (Method) <a name="CalculateTryFunction"></a> 
 
  Calculates an expression and returns a boolean indicating success or failure.

#### Syntax
```
procedure Calculate(Expression: Text; var Result: Variant): Boolean
```
#### Parameters
*Expression ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Text that contains the expression to calculate.

*Result ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))*

Returns the result of the calculation. This is a variant that can contain any numeric value: [Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type), [Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type), [BigInteger](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/biginteger/biginteger-data-type) or [Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type).

This parameter is passed by var and must be of type Variant.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

Indicating success or failure. In case of failure use `GetLastErrorText()` to get the error that occurred.

### Remarks
*The parameter Result will only be initialized in case of a successful call. In case of a failure, the parameter Result will have its original value or remain uninitialized.*
