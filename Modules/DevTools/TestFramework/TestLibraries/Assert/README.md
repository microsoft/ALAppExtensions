This module provides functionality for verifying the values when running a test.

Use this module to do the following:
- Verify the outcome of a test.
- Fail a test, if needed.
- Distinguish between product errors and test failures.

This module must be used in test. Avoid using TESTFIELD, ERROR and other keywords that can be used in production. 
By failing the tests by using Assert, the stack trace will indicate that the test has failed, and not the product.

In the test code, name the codeunit Assert instead of LibraryAssert.

This module must not be used outside the test code.

# Public Objects
## Library Assert (Codeunit 130002)

 This module provides functions for easy verification of expected values and error handling in test code.
 

### IsTrue (Method) <a name="IsTrue"></a> 

 Tests whether the specified condition is true and throws an exception if the condition is false.
 

#### Syntax
```
procedure IsTrue(Condition: Boolean; Msg: Text)
```
#### Parameters
*Condition ([Boolean](https://go.microsoft.com/fwlink/?linkid=2209954))* 

The condition the test expects to be true.

*Msg ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))* 

The message to include in the exception when condition is false. The message is shown in test results.

### IsFalse (Method) <a name="IsFalse"></a> 

 Tests whether the specified condition is false and throws an exception if the condition is true.
 

#### Syntax
```
procedure IsFalse(Condition: Boolean; Msg: Text)
```
#### Parameters
*Condition ([Boolean](https://go.microsoft.com/fwlink/?linkid=2209954))* 

The condition the test expects to be false.

*Msg ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))* 

The message to include in the exception when condition is true. The message is shown in test results.

### AreEqual (Method) <a name="AreEqual"></a> 

 Tests whether the specified values are equal and throws an exception if the two values are not equal.
 

#### Syntax
```
procedure AreEqual(Expected: Variant; Actual: Variant; Msg: Text)
```
#### Parameters
*Expected ([Variant](https://go.microsoft.com/fwlink/?linkid=2210243))* 

The first value to compare. This is the value the tests expects.

*Actual ([Variant](https://go.microsoft.com/fwlink/?linkid=2210243))* 

The second value to compare. This is the value produced by the code under test.

*Msg ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))* 

The message to include in the exception when actual is not equal to expected. The message is shown in test results.

### AreNotEqual (Method) <a name="AreNotEqual"></a> 

 Tests whether the specified values are unequal and throws an exception if they are equal.
 

#### Syntax
```
procedure AreNotEqual(Expected: Variant; Actual: Variant; Msg: Text)
```
#### Parameters
*Expected ([Variant](https://go.microsoft.com/fwlink/?linkid=2210243))* 

The first value to compare. This is the value the test expects not to match actual.

*Actual ([Variant](https://go.microsoft.com/fwlink/?linkid=2210243))* 

The second value to compare. This is the value produced by the code under test.

*Msg ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))* 

The message to include in the exception when actual is not equal to expected. The message is shown in test results.

### AreNearlyEqual (Method) <a name="AreNearlyEqual"></a> 

 Tests whether the specified decimals are equal and throws an exception if the they are not equal.
 

#### Syntax
```
procedure AreNearlyEqual(Expected: Decimal; Actual: Decimal; Delta: Decimal; Msg: Text)
```
#### Parameters
*Expected ([Decimal](https://go.microsoft.com/fwlink/?linkid=2210240))* 

The first value to compare. This is the value the tests expects.

*Actual ([Decimal](https://go.microsoft.com/fwlink/?linkid=2210240))* 

The second value to compare. This is the value produced by the code under test.

*Delta ([Decimal](https://go.microsoft.com/fwlink/?linkid=2210240))* 

The required accuracy. An exception will be thrown only if actual is different than expected by more than delta.

*Msg ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))* 

The message to include in the exception when actual is different than expected by more than delta. The message is shown in test results.

### AreNotNearlyEqual (Method) <a name="AreNotNearlyEqual"></a> 

 Tests whether the specified decimals are unequal and throws an exception if the they are equal.
 

#### Syntax
```
procedure AreNotNearlyEqual(Expected: Decimal; Actual: Decimal; Delta: Decimal; Msg: Text)
```
#### Parameters
*Expected ([Decimal](https://go.microsoft.com/fwlink/?linkid=2210240))* 

The first value to compare. This is the value the tests expects not to match actual.

*Actual ([Decimal](https://go.microsoft.com/fwlink/?linkid=2210240))* 

The second value to compare. This is the value produced by the code under test.

*Delta ([Decimal](https://go.microsoft.com/fwlink/?linkid=2210240))* 

The required accuracy. An exception will be thrown only if actual is different than Expected by at most delta.

*Msg ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))* 

The message to include in the exception when actual is equal to Expected or different by less than delta. The message is shown in test results.

### Fail (Method) <a name="Fail"></a> 

 Throws an exception.
 

#### Syntax
```
procedure Fail(Msg: Text)
```
#### Parameters
*Msg ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))* 

The message to include in the exception. The message is shown in test results.

### RecordIsEmpty (Method) <a name="RecordIsEmpty"></a> 

 Tests whether the specified record is non-empty and throws an exception if it is.
 

#### Syntax
```
procedure RecordIsEmpty(RecVariant: Variant)
```
#### Parameters
*RecVariant ([Variant](https://go.microsoft.com/fwlink/?linkid=2210243))* 

The record to be checked

### RecordIsNotEmpty (Method) <a name="RecordIsNotEmpty"></a> 

 Tests whether the specified record is empty and throws an exception if it is.
 

#### Syntax
```
procedure RecordIsNotEmpty(RecVariant: Variant)
```
#### Parameters
*RecVariant ([Variant](https://go.microsoft.com/fwlink/?linkid=2210243))* 

The record to be checked

### TableIsEmpty (Method) <a name="TableIsEmpty"></a> 

 Tests whether the specified table is non-empty and throws an exception if it is.
 

#### Syntax
```
procedure TableIsEmpty(TableNo: Integer)
```
#### Parameters
*TableNo ([Integer](https://go.microsoft.com/fwlink/?linkid=2209956))* 

The id of table the test expects to be empty

### TableIsNotEmpty (Method) <a name="TableIsNotEmpty"></a> 

 Tests whether the specified table is empty and throws an exception if it is.
 

#### Syntax
```
procedure TableIsNotEmpty(TableNo: Integer)
```
#### Parameters
*TableNo ([Integer](https://go.microsoft.com/fwlink/?linkid=2209956))* 

The id of table the test expects not to be empty

### RecordCount (Method) <a name="RecordCount"></a> 

 Tests whether the Table holds the expected number of Records and throws an exception when the count is different.
 

#### Syntax
```
procedure RecordCount(RecVariant: Variant; ExpectedCount: Integer)
```
#### Parameters
*RecVariant ([Variant](https://go.microsoft.com/fwlink/?linkid=2210243))* 

The table whos records will be counter

*ExpectedCount ([Integer](https://go.microsoft.com/fwlink/?linkid=2209956))* 

The expected number of records in the table

### KnownFailure (Method) <a name="KnownFailure"></a> 

 This function is used to indicate the test is known to fail with a certain error. If the last error thrown is the expected one, a known failure error is thrown. If the last error was a different error than an exception is thrown.
 

#### Syntax
```
procedure KnownFailure(Expected: Text; WorkItemNo: Integer)
```
#### Parameters
*Expected ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))* 

The expected error

*WorkItemNo ([Integer](https://go.microsoft.com/fwlink/?linkid=2209956))* 

The Id of the workitem to fix the know test defect

### ExpectedError (Method) <a name="ExpectedError"></a> 

 Verifies that the last error thrown is the expected error. If a different error was thrown, an exception is thrown.
 

#### Syntax
```
procedure ExpectedError(Expected: Text)
```
#### Parameters
*Expected ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))* 

The expected error

### ExpectedErrorCode (Method) <a name="ExpectedErrorCode"></a> 

 Verifies that the last error code thrown is the expected error code. If a different error code was thrown, an exception is thrown.
 

#### Syntax
```
procedure ExpectedErrorCode(Expected: Text)
```
#### Parameters
*Expected ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))* 

The expected error code

### ExpectedMessage (Method) <a name="ExpectedMessage"></a> 

 Tests that the Expected message matches the Actual message
 

#### Syntax
```
procedure ExpectedMessage(Expected: Text; Actual: Text)
```
#### Parameters
*Expected ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))* 

The first value to compare. This is the value the tests expects not to match actual.

*Actual ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))* 

The second value to compare. This is the value produced by the code under test.

### AssertRecordNotFound (Method) <a name="AssertRecordNotFound"></a> 

 Verifies that the last error code thrown was the Record Not Found error code.
 

#### Syntax
```
procedure AssertRecordNotFound()
```
### AssertRecordAlreadyExists (Method) <a name="AssertRecordAlreadyExists"></a> 

 Verifies that the last error code thrown was the Record Already Exists error code.
 

#### Syntax
```
procedure AssertRecordAlreadyExists()
```
### AssertNothingInsideFilter (Method) <a name="AssertNothingInsideFilter"></a> 

 Verifies that the last error code thrown was the Nothing Inside Filter error code.
 

#### Syntax
```
procedure AssertNothingInsideFilter()
```
### AssertNoFilter (Method) <a name="AssertNoFilter"></a> 

 Verifies that the last error code thrown was the No Filter error code.
 

#### Syntax
```
procedure AssertNoFilter()
```
### AssertPrimRecordNotFound (Method) <a name="AssertPrimRecordNotFound"></a> 

 Verifies that the last error code thrown was the Primary Record Not Found error code.
 

#### Syntax
```
procedure AssertPrimRecordNotFound()
```
