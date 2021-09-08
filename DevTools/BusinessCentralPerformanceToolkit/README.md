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

Parameter value for the parameter pased.
