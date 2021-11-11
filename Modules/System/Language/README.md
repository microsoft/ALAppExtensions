Changes the language for Windows and applications, and converts language codes to language IDs, and vice versa. The Language table is a subset of Windows languages. You can add languages, and edit translations and descriptions in the list.

# Public Objects
## Language (Table 8)

 Table that contains the available application languages.
 


## Language (Codeunit 43)

 Management codeunit that exposes various functions to work with languages.
 

### GetUserLanguageCode (Method) <a name="GetUserLanguageCode"></a> 

 Gets the current user's language code.
 The function emits the [OnGetUserLanguageCode](#OnGetUserLanguageCode) event.
 To change the language code returned from this function, subscribe for this event and change the passed language code.
 

#### Syntax
```
procedure GetUserLanguageCode(): Code[10]
```
#### Return Value
*[Code[10]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type)*

The language code of the user's language
### GetLanguageIdOrDefault (Method) <a name="GetLanguageIdOrDefault"></a> 

 Gets the language ID based on its code. Or defaults to the current user language.
 

#### Syntax
```
procedure GetLanguageIdOrDefault(LanguageCode: Code[10]): Integer
```
#### Parameters
*LanguageCode ([Code[10]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

The code of the language

#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The ID for the language code that was provided for this function. If no ID is found for the language code, then it returns the ID of the current user's language.
### GetLanguageId (Method) <a name="GetLanguageId"></a> 

 Gets the language ID based on its code.
 

#### Syntax
```
procedure GetLanguageId(LanguageCode: Code[10]): Integer
```
#### Parameters
*LanguageCode ([Code[10]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

The code of the language

#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The ID for the language code that was provided for this function. If no ID is found for the language code, then it returns 0.
### GetLanguageCode (Method) <a name="GetLanguageCode"></a> 

 Gets the code for a language based on its ID.
 

#### Syntax
```
procedure GetLanguageCode(LanguageId: Integer): Code[10]
```
#### Parameters
*LanguageId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the language.

#### Return Value
*[Code[10]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type)*

The code of the language that corresponds to the ID, or an empty code if the language with the specified ID does not exist.
### GetWindowsLanguageName (Method) <a name="GetWindowsLanguageName"></a> 

 Gets the name of a language based on the language code.
 

#### Syntax
```
procedure GetWindowsLanguageName(LanguageCode: Code[10]): Text
```
#### Parameters
*LanguageCode ([Code[10]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

The code of the language.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The name of the language corresponding to the code or empty string, if language with the specified code does not exist
### GetWindowsLanguageName (Method) <a name="GetWindowsLanguageName"></a> 

 Gets the name of a windows language based on its ID.
 

#### Syntax
```
procedure GetWindowsLanguageName(LanguageId: Integer): Text
```
#### Parameters
*LanguageId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the language.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The name of the language that corresponds to the ID, or an empty string if a language with the specified ID does not exist.
### GetApplicationLanguages (Method) <a name="GetApplicationLanguages"></a> 

 Gets all available languages in the application.
 

#### Syntax
```
procedure GetApplicationLanguages(var TempLanguage: Record "Windows Language" temporary)
```
#### Parameters
*TempLanguage ([Record "Windows Language" temporary]())* 

A temporary record to place the result in

### GetDefaultApplicationLanguageId (Method) <a name="GetDefaultApplicationLanguageId"></a> 

 Gets the default application language ID.
 

#### Syntax
```
procedure GetDefaultApplicationLanguageId(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The ID of the default language for the application.
### ValidateApplicationLanguageId (Method) <a name="ValidateApplicationLanguageId"></a> 

 Checks whether the provided language is a valid application language.
 If it isn't, the function displays an error.
 

#### Syntax
```
procedure ValidateApplicationLanguageId(LanguageId: Integer)
```
#### Parameters
*LanguageId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the language to validate.

### ValidateWindowsLanguageId (Method) <a name="ValidateWindowsLanguageId"></a> 

 Checks whether the provided language exists. If it doesn't, the function displays an error.
 

#### Syntax
```
procedure ValidateWindowsLanguageId(LanguageId: Integer)
```
#### Parameters
*LanguageId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the language to validate.

### LookupApplicationLanguageId (Method) <a name="LookupApplicationLanguageId"></a> 

 Opens a list of the languages that are available for the application so that the user can choose a language.
 

#### Syntax
```
procedure LookupApplicationLanguageId(var LanguageId: Integer)
```
#### Parameters
*LanguageId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Exit parameter that holds the chosen language ID.

### LookupWindowsLanguageId (Method) <a name="LookupWindowsLanguageId"></a> 

 Opens a list of languages that are available for the Windows version.
 

#### Syntax
```
procedure LookupWindowsLanguageId(var LanguageId: Integer)
```
#### Parameters
*LanguageId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Exit parameter that holds the chosen language ID.

### LookupLanguageCode (Method) <a name="LookupLanguageCode"></a> 

 Opens a list of the languages that are available for the application so that the user can choose a language.
 

#### Syntax
```
procedure LookupLanguageCode(var LanguageCode: Code[10])
```
#### Parameters
*LanguageCode ([Code[10]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Exit parameter that holds the chosen language code.

### GetParentLanguageId (Method) <a name="GetParentLanguageId"></a> 

 Gets the parent language ID based on Windows Culture Info.
 

#### Syntax
```
procedure GetParentLanguageId(LanguageId: Integer): Integer
```
#### Parameters
*LanguageId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Exit parameter that holds the chosen language ID.

#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The ID of the parent language
### SetPreferredLanguageID (Method) <a name="SetPreferredLanguageID"></a> 

 Sets the preferred language for the provided user.
 

#### Syntax
```
procedure SetPreferredLanguageID(UserSecID: Guid; NewLanguageID: Integer)
```
#### Parameters
*UserSecID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The user security ID for the user for whom the preferred language is changed.

*NewLanguageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The new preferred language for the user.

### OnGetUserLanguageCode (Event) <a name="OnGetUserLanguageCode"></a> 

 Integration event, emitted from [GetUserLanguageCode](#GetUserLanguageCode).
 Subscribe to this event to change the default behavior by changing the provided parameter(s).
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnGetUserLanguageCode(var UserLanguageCode: Code[10]; var Handled: Boolean)
```
#### Parameters
*UserLanguageCode ([Code[10]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Exit parameter that holds the user language code.

*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

To change the default behavior of the function that emits the event, set this parameter to true.


## Languages (Page 9)

 Page for displaying application languages.
 


## Windows Languages (Page 535)

 Page for displaying available windows languages.
 

