This module provides functionality for creating and running Businss Central Performance Toolkit test suites. 

Use this module to do the following:
- Create a Businss Central Performance Toolkit tests suites.
- Run the Businss Central Performance Toolkit test suites and analyze results.

Additional Notes:
This module can only be installed on a sandbox.

# Public Objects
## "BCPT Test Context" (Codeunit 149003)

 ### StartScenario (Method) <a name="StartScenario"></a> 

 This method starts the scope of a test session where the performance numbers are collected.
 
#### Syntax
```
procedure StartScenario(ScenarioOperation: Text)
```
#### Parameters
*ScenarioOperation ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Scenario name or label.

 ### EndScenario (Method) <a name="EndScenario"></a> 

 This method ends the scope of a test session where the performance numbers are collected.
 
#### Syntax
```
procedure EndScenario(ScenarioOperation: Text)
```
#### Parameters
*ScenarioOperation ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Scenario name or label.

 ### EndScenario (Method) <a name="EndScenario"></a> 

 This method ends the scope of a test session where the performance numbers are collected.
 
#### Syntax
```
procedure EndScenario(ScenarioOperation: Text; ExecutionSuccess: Boolean)
```
#### Parameters
*ScenarioOperation ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Scenario name or label.

*ExecutionSuccess ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

true if the BCPT finished without any errors, else false.

 ### GetParameters (Method) <a name="GetParameters"></a> 

 This method returns the parameters associated with the test as text.
 
#### Syntax
```
procedure GetParameters()
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Parameters as text.

 ### GetParameter (Method) <a name="GetParameter"></a> 

 This method returns the parameter value associated with the passed parameter name on the session.
 
#### Syntax
```
procedure GetParameter(ParameterName: Text): Text
```
#### Parameters
*ParameterName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Parameter name or label.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Parameter value for the parameter passed.

## "BCPT Test Suite" (Codeunit 149006)

 ### CreateTestSuiteHeader (Method) <a name="CreateTestSuiteHeader"></a> 

 This method create a new test suite.
 
#### Syntax
```
procedure CreateTestSuiteHeader(SuiteCode: Code[10]; SuiteDescription: Text[50]; DurationInMinutes: Integer; DefaultMinUserDelayInMs: Integer; DefaultMaxUserDelayInMs: Integer;  OneDayCorrespondsToMinutes: Integer; Tag: Text[20])
```
#### Parameters
*SuiteCode ([Code](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Test suite code.

*SuiteDescription ([Text]([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Test suite description.

*DurationInMinutes ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Test suite run duration in minutes.

*DefaultMinUserDelayInMs ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Default minimum user delays in milliseconds.

*DefaultMaxUserDelayInMs ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Default maximum user delays in milliseconds.

*OneDayCorrespondsToMinutes ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

*Tag ([Text]([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Test suite tag.

 ### CreateTestSuiteHeader (Method) <a name="CreateTestSuiteHeader"></a> 

 This method create a new test suite.
 
#### Syntax
```
procedure CreateTestSuiteHeader(SuiteCode: Code[10]; SuiteDescription: Text[50])
```
#### Parameters
*SuiteCode ([Code](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Test suite code.

*SuiteDescription ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Test suite description.

 ### SetTestSuiteDuration (Method) <a name="SetTestSuiteDuration"></a> 

 This method create a new test suite.
 
#### Syntax
```
procedure SetTestSuiteDuration(SuiteCode: Code[10]; DurationInMinutes: Integer)
```
#### Parameters
*SuiteCode ([Code](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Test suite code.

*DurationInMinutes ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Test suite run duration in minutes.

 ### SetTestSuiteDefaultMinUserDelay (Method) <a name="SetTestSuiteDefaultMinUserDelay"></a> 

 This method create a new test suite.
 
#### Syntax
```
procedure SetTestSuiteDefaultMinUserDelay(SuiteCode: Code[10]; DelayInMs: Integer)
```
#### Parameters
*SuiteCode ([Code](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Test suite code.

*DelayInMs ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Test suite run duration in minutes.

 ### SetTestSuiteDefaultMinUserDelay (Method) <a name="SetTestSuiteDefaultMinUserDelay"></a> 

 This method create a new test suite.
 
#### Syntax
```
procedure SetTestSuiteDefaultMinUserDelay(SuiteCode: Code[10]; DelayInMs: Integer)
```
#### Parameters
*SuiteCode ([Code](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Test suite code.

*DelayInMs ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Test suite run duration in minutes.

 ### SetTestSuiteDefaultMaxUserDelay (Method) <a name="SetTestSuiteDefaultMaxUserDelay"></a> 

 This method create a new test suite.
 
#### Syntax
```
procedure SetTestSuiteDefaultMaxUserDelay(SuiteCode: Code[10]; DelayInMs: Integer)
```
#### Parameters
*SuiteCode ([Code](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Test suite code.

*DelayInMs ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Test suite run duration in minutes.

 ### SetTestSuite1DayCorresponds (Method) <a name="SetTestSuite1DayCorresponds"></a> 

 This method create a new test suite.
 
#### Syntax
```
procedure SetTestSuite1DayCorresponds(SuiteCode: Code[10]; DurationInMinutes: Integer)
```
#### Parameters
*SuiteCode ([Code](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Test suite code.

*DurationInMinutes ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Test suite run duration in minutes.

 ### SetTestSuiteTag (Method) <a name="SetTestSuiteTag"></a> 

 This method create a new test suite.
 
#### Syntax
```
procedure SetTestSuiteTag(SuiteCode: Code[10]; Tag: Text[20])
```
#### Parameters
*SuiteCode ([Code](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Test suite code.

*Tag ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Test suite tag.

 ### AddLineToTestSuiteHeader (Method) <a name="AddLineToTestSuiteHeader"></a> 

 This method creates and adds a line to the test suite.
 
#### Syntax
```
procedure AddLineToTestSuiteHeader(SuiteCode: Code[10]; CodeunitId: Integer; NoOfSessions: Integer; Description: Text[50]; MinUserDelayInMs: Integer; MaxUserDelayInMs: Integer; DelayBtwnIterInSecs: Integer; RunInForeground: Boolean; Parameters: Text[1000]): Integer
```
#### Parameters
*SuiteCode ([Code](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Test suite code.

*CodeunitId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Test codeunit id.

*NoOfSessions ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Number of sessions that runs the specified codeunit.

*Description ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Optional field to store additional description.

*MinUserDelayInMs ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Minimum delay between user actions in milliseconds.

*MaxUserDelayInMs ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Maximum delay between user actions in milliseconds.

*DelayBtwnIterInSecs ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Delay between iterations in seconds.

*RunInForeground ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Run in foreground session.

*Parameters ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Input parameter for the codeunit.

#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

Line number of the newly created line.

 ### AddLineToTestSuiteHeader (Method) <a name="AddLineToTestSuiteHeader"></a> 

 This method creates and adds a line to the test suite.
 
#### Syntax
```
procedure AddLineToTestSuiteHeader(SuiteCode: Code[10]; CodeunitId: Integer): Integer
```
#### Parameters
*SuiteCode ([Code](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Test suite code.

*CodeunitId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Test codeunit id.

#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

Line number of the newly created line.

 ### AddLineToTestSuiteHeader (Method) <a name="AddLineToTestSuiteHeader"></a> 

 This method creates and adds a line to the test suite.
 
#### Syntax
```
procedure AddLineToTestSuiteHeader(SuiteCode: Code[10]; CodeunitId: Integer; NoOfSessions: Integer; Description: Text[50]; MinUserDelayInMs: Integer; MaxUserDelayInMs: Integer; DelayBtwnIterInSecs: Integer; RunInForeground: Boolean; Parameters: Text[1000]; DelayType: Enum "BCPT Line Delay Type"): Integer
```
#### Parameters
*SuiteCode ([Code](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Test suite code.

*CodeunitId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Test codeunit id.

*NoOfSessions ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Number of sessions that runs the specified codeunit.

*Description ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Optional field to store additional description.

*MinUserDelayInMs ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Minimum delay between user actions in milliseconds.

*MaxUserDelayInMs ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Maximum delay between user actions in milliseconds.

*DelayBtwnIterInSecs ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Delay between iterations in seconds.

*RunInForeground ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Run in foreground session.

*Parameters ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Input parameter for the codeunit.

*DelayType ([Enum](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/enum/enum-data-type))*

Type of Delay between user actions.

#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

Line number of the newly created line.

 ### SetTestSuiteLineNoOfSessions (Method) <a name="SetTestSuiteLineNoOfSessions"></a> 

 This method sets No. of Sessions field on the test suite line.
 
#### Syntax
```
procedure SetTestSuiteLineNoOfSessions(SuiteCode: Code[10]; LineNo: Integer; NoOfSessions: Integer)
```
#### Parameters
*SuiteCode ([Code](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Test suite code.

*LineNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Line no. of the test suite line.

*NoOfSessions ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Number of sessions that runs the specified codeunit.

 ### SetTestSuiteLineDescription (Method) <a name="SetTestSuiteLineDescription"></a> 

 This method sets description field on the test suite line.
 
#### Syntax
```
procedure SetTestSuiteLineDescription(SuiteCode: Code[10]; LineNo: Integer; Description: Text[50])
```
#### Parameters
*SuiteCode ([Code](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Test suite code.

*LineNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Line no. of the test suite line.

*Description ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Field to store additional description.

 ### SetTestSuiteLineMinUserDelay (Method) <a name="SetTestSuiteLineMinUserDelay"></a> 

 This method sets minimum user delay on the test suite line.
 
#### Syntax
```
procedure SetTestSuiteLineMinUserDelay(SuiteCode: Code[10]; LineNo: Integer; DelayInMs: Integer)
```
#### Parameters
*SuiteCode ([Code](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Test suite code.

*LineNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Line no. of the test suite line.

*DelayInMs ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Minimum delay between user actions in milliseconds.

 ### SetTestSuiteLineMaxUserDelay (Method) <a name="SetTestSuiteLineMaxUserDelay"></a> 

 This method sets maximum use delay on the test suite line.
 
#### Syntax
```
procedure SetTestSuiteLineMaxUserDelay(SuiteCode: Code[10]; LineNo: Integer; DelayInMs: Integer)
```
#### Parameters
*SuiteCode ([Code](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Test suite code.

*LineNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Line no. of the test suite line.

*DelayInMs ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Maximum delay between user actions in milliseconds.

 ### SetTestSuiteLineDelayBtwnIter (Method) <a name="SetTestSuiteLineDelayBtwnIter"></a> 

 This method sets belay between iterations on the test suite line.
 
#### Syntax
```
procedure SetTestSuiteLineDelayBtwnIter(SuiteCode: Code[10]; LineNo: Integer; DelayInSecs: Integer)
```
#### Parameters
*SuiteCode ([Code](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Test suite code.

*LineNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Line no. of the test suite line.

*DelayInSecs ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Delay between iterations in seconds.

 ### SetTestSuiteLineRunInForeground (Method) <a name="SetTestSuiteLineRunInForeground"></a> 

 This method sets Run In Foreground field on the test suite line.
 
#### Syntax
```
procedure SetTestSuiteLineRunInForeground(SuiteCode: Code[10]; LineNo: Integer; RunInForeground: Boolean)
```
#### Parameters
*SuiteCode ([Code](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Test suite code.

*LineNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Line no. of the test suite line.

*RunInForeground ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Run in foreground session.

 ### SetTestSuiteLineParameters (Method) <a name="SetTestSuiteLineParameters"></a> 

 This method creates and adds a line to the test suite.
 
#### Syntax
```
procedure SetTestSuiteLineParameters(SuiteCode: Code[10]; LineNo: Integer; Parameters: Text[1000])
```
#### Parameters
*SuiteCode ([Code](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Test suite code.

*LineNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Line no. of the test suite line.

*Parameters ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Input parameter for the codeunit.


 ### IsAnyTestRunInProgress (Method) <a name="IsAnyTestRunInProgress"></a> 

 This method checks if any test run is in progress.
 
#### Syntax
```
procedure IsAnyTestRunInProgress(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

Returns if a test run is in progress or not.

 ### IsTestRunInProgress (Method) <a name="IsTestRunInProgress"></a> 

 This method checks if a particular test suite run is in progress or not.
 
#### Syntax
```
procedure IsTestRunInProgress(SuiteCode: Code[10]): Boolean
```
#### Parameters
*SuiteCode ([Code](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Test suite code.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

Returns if a test run is in progress or not for a passed test suite code.




