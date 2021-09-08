This module provides functionality to work with URIs.

It exposes .Net classes [Uri](https://docs.microsoft.com/en-us/dotnet/api/system.uri?view=netcore-3.1) and [UriBuilder](https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder?view=netcore-3.1) for AL development. 
# Public Objects
## Uri (Codeunit 3060)

 Provides an object representation of a uniform resource identifier (URI) and easy access to the parts of the URI.
 

Visit https://docs.microsoft.com/en-us/dotnet/api/system.uri for more information.

### Init (Method) <a name="Init"></a> 

 Initializes a new instance of the Uri class with the specified URI.
 

Visit https://docs.microsoft.com/en-us/dotnet/api/system.uri.-ctor#System_Uri__ctor_System_String_ for more information.

#### Syntax
```
procedure Init(UriString: Text)
```
#### Parameters
*UriString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A string that identifies the resource to be represented by the Uri instance. Note that an IPv6 address in string form must be enclosed within brackets. For example, "http://[2607:f8b0:400d:c06::69]".

### GetAbsoluteUri (Method) <a name="GetAbsoluteUri"></a> 

 Gets the absolute URI.
 

#### Syntax
```
procedure GetAbsoluteUri(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

A string containing the entire URI.
### GetScheme (Method) <a name="GetScheme"></a> 

 Gets the scheme name for the URI.
 

Visit https://docs.microsoft.com/en-us/dotnet/api/system.uri.scheme for more information.

#### Syntax
```
procedure GetScheme(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

A text that contains the scheme for this URI, converted to lowercase.
### GetSegments (Method) <a name="GetSegments"></a> 

 Gets a list containing the path segments that make up the specified URI.
 

Visit https://docs.microsoft.com/en-us/dotnet/api/system.uri.segments for more information.

#### Syntax
```
procedure GetSegments(var Segments: List of [Text])
```
#### Parameters
*Segments ([List of [Text]]())* 

An out variable that contains the path segments that make up the specified URI.

### EscapeDataString (Method) <a name="EscapeDataString"></a> 

 Converts a string to its escaped representation.
 

Visit https://docs.microsoft.com/en-us/dotnet/api/system.uri.escapedatastring for more information.

#### Syntax
```
procedure EscapeDataString(TextToEscape: Text): Text
```
#### Parameters
*TextToEscape ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 



#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

A string that contains the escaped representation of .
### UnescapeDataString (Method) <a name="UnescapeDataString"></a> 

 Converts a string to its unescaped representation.
 

Visit https://docs.microsoft.com/en-us/dotnet/api/system.uri.unescapedatastring for more information.

#### Syntax
```
procedure UnescapeDataString(TextToUnescape: Text): Text
```
#### Parameters
*TextToUnescape ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 



#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

A string that contains the unescaped representation of .
### IsValidUri (Method) <a name="IsValidUri"></a> 

 Checks if the provded string is a valid URI.
 

#### Syntax
```
[TryFunction]
procedure IsValidUri(UriString: Text)
```
#### Parameters
*UriString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to check.

### GetUri (Method) <a name="GetUri"></a> 

 Gets the underlying .Net Uri variable.
 

#### Syntax
```
[Scope('OnPrem')]
procedure GetUri(var OutUri: DotNet Uri)
```
#### Parameters
*OutUri ([DotNet Uri]())* 

A .Net object of class Uri that holds the underlying .Net Uri variable.

### SetUri (Method) <a name="SetUri"></a> 

 Sets the underlying .Net Uri variable.
 

#### Syntax
```
[Scope('OnPrem')]
procedure SetUri(NewUri: DotNet Uri)
```
#### Parameters
*NewUri ([DotNet Uri]())* 

A .Net object of class Uri to set to the underlying .Net Uri variable.


## Uri Builder (Codeunit 3061)

 Provides a custom constructor for uniform resource identifiers (URIs) and modifies URIs for the Uri codeunit.
 

Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder for more information.

### Init (Method) <a name="Init"></a> 

 Initializes a new instance of the UriBuilder class with the specified URI.
 

Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.-ctor#System_UriBuilder__ctor_System_String_ for more information.

#### Syntax
```
procedure Init(Uri: Text)
```
#### Parameters
*Uri ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A URI string.

### SetQuery (Method) <a name="SetQuery"></a> 

 Sets any query information included in the URI.
 

Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.query for more information.

#### Syntax
```
procedure SetQuery(Query: Text)
```
#### Parameters
*Query ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A string that represents the query information to set.

### GetQuery (Method) <a name="GetQuery"></a> 

 Gets the query information included in the URI.
 

Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.query for more information.

#### Syntax
```
procedure GetQuery(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The query information included in the URI.
### GetUri (Method) <a name="GetUri"></a> 

 Gets the Uri instance constructed by the specified "Uri Builder" instance.
 

Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.uri for more information.

#### Syntax
```
procedure GetUri(var Uri: Codeunit Uri)
```
#### Parameters
*Uri ([Codeunit Uri]())* 

A Uri that contains the URI constructed by the Uri Builder.

