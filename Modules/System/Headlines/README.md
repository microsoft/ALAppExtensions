This module provides methods for constructing headlines on Role Centers.

Use this module to do the following:

Get the maximum text length displayed on a headline.
Truncate and emphasize text.
Manage the standard greeting headline.


# Public Objects
## Headlines (Codeunit 1439)

 Various functions related to headlines functionality.

 Payload - the main text of the headline.
 Qualifier - smaller text, hint to the payload.
 Expression property - value for the field on the page with type HeadlinePart.
 

### Truncate (Method) <a name="Truncate"></a> 

 Truncate the text from the end for its length to be no more than MaxLength.
 If the text has to be shortened, "..." is be added at the end.
 

#### Syntax
```
procedure Truncate(TextToTruncate: Text; MaxLength: Integer): Text
```
#### Parameters
*TextToTruncate ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Text that be shortened in order to fit on the headline.

*MaxLength ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The maximal length of the string. Usually obtained through
 [GetMaxQualifierLength](#GetMaxQualifierLength) or [GetMaxPayloadLength](#GetMaxPayloadLength) function.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The truncated text
### Emphasize (Method) <a name="Emphasize"></a> 

 Emphasize a string of text in the headline. Applies the style to the text.
 

#### Syntax
```
procedure Emphasize(TextToEmphasize: Text): Text
```
#### Parameters
*TextToEmphasize ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The text that the style will be applied on.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Emphasized text (special tags are added to the input).
### GetHeadlineText (Method) <a name="GetHeadlineText"></a> 

 Combine the text from Qualifier and Payload in order to get a single string with headline
 text. This text is usually assigned to Expression property on the HeadlinePart page.
 

#### Syntax
```
procedure GetHeadlineText(Qualifier: Text; Payload: Text; var ResultText: Text): Boolean
```
#### Parameters
*Qualifier ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The text to be displayed on the qualifier (smaller text above the main one)
 of the headline (parts of it can be emphasized, see [Emphasize](#Emphasize)).

*Payload ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The text to be displayed on the payload (the main text of the headline)
 of the headline (parts of it can be emphasized, see [Emphasize](#Emphasize)).

*ResultText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Output parameter. Contains the combined text, ready to be assigned to
 the Expression property, if the function returns 'true', the unchanged value otherwise.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

'false' if payload is empty, or payload is too long, or qualifier is too long,
 'true' otherwise.
### GetUserGreetingText (Method) <a name="GetUserGreetingText"></a> 

 Get a greeting text for the current user relevant to the time of the day.
 Timespans and correspondant greetings:
 00:00-10:59     Good morning, John Doe!
 11:00-13:59     Hi, John Doe!
 14:00-18:59     Good afternoon, John Doe!
 19:00-23:59     Good evening, John Doe!
 if the user name is blank for the current user, simplified version
 is used (for example, "Good afternoon!").
 

#### Syntax
```
procedure GetUserGreetingText(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The greeting text.
### ShouldUserGreetingBeVisible (Method) <a name="ShouldUserGreetingBeVisible"></a> 

 Determines if a greeting text should be visible.
 

#### Syntax
```
procedure ShouldUserGreetingBeVisible(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the user logged in less than 10 minutes ago, false otherwise.
### GetMaxQualifierLength (Method) <a name="GetMaxQualifierLength"></a> 

 The accepted maximum length of a qualifier.
 

#### Syntax
```
procedure GetMaxQualifierLength(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The number of characters, 50.
### GetMaxPayloadLength (Method) <a name="GetMaxPayloadLength"></a> 

 The accepted maximum length of a payload.
 

#### Syntax
```
procedure GetMaxPayloadLength(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The number of characters, 75.
