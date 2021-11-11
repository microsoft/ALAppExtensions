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
### GetHost (Method) <a name="GetHost"></a> 

 Gets the host name of the URI.
 

Visit https://docs.microsoft.com/en-us/dotnet/api/system.uri.host for more information.

#### Syntax
```
procedure GetHost(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

A text that contains the host name for this URI.
### GetPort (Method) <a name="GetPort"></a> 

 Gets the port number of the URI.
 

Visit https://docs.microsoft.com/en-us/dotnet/api/system.uri.port for more information.

#### Syntax
```
procedure GetPort(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

An integer that contains the port number for this URI.
### GetAbsolutePath (Method) <a name="GetAbsolutePath"></a> 

 Gets the absolute path of the URI.
 

Visit https://docs.microsoft.com/en-us/dotnet/api/system.uri.absolutepath for more information.

#### Syntax
```
procedure GetAbsolutePath(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

A text that contains the absolute path for this URI.
### GetQuery (Method) <a name="GetQuery"></a> 

 Gets any query information included in the specified URI.
 

Visit https://docs.microsoft.com/en-us/dotnet/api/system.uri.query for more information.

#### Syntax
```
procedure GetQuery(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

A text that contains the query information for this URI.
### GetFragment (Method) <a name="GetFragment"></a> 

 Gets the escaped URI fragment.
 

Visit https://docs.microsoft.com/en-us/dotnet/api/system.uri.fragment for more information.

#### Syntax
```
procedure GetFragment(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

A text that contains the fragment portion for this URI.
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

### SetScheme (Method) <a name="SetScheme"></a> 

 Sets the scheme name of the URI.
 

Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.scheme for more information.

#### Syntax
```
procedure SetScheme(Scheme: Text)
```
#### Parameters
*Scheme ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A string that represents the scheme name to set.

### GetScheme (Method) <a name="GetScheme"></a> 

 Gets the scheme name of the URI.
 

Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.scheme for more information.

#### Syntax
```
procedure GetScheme(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The scheme name of the URI.
### SetHost (Method) <a name="SetHost"></a> 

 Sets the host name of the URI.
 

Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.host for more information.

#### Syntax
```
procedure SetHost(Host: Text)
```
#### Parameters
*Host ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A string that represents the host name to set.

### GetHost (Method) <a name="GetHost"></a> 

 Gets the host name of the URI.
 

Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.host for more information.

#### Syntax
```
procedure GetHost(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The host name of the URI.
### SetPort (Method) <a name="SetPort"></a> 

 Sets the port number of the URI.
 

Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.port for more information.

#### Syntax
```
procedure SetPort(Port: Integer)
```
#### Parameters
*Port ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

An integer that represents the port number to set.

### GetPort (Method) <a name="GetPort"></a> 

 Gets the port number of the URI.
 

Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.port for more information.

#### Syntax
```
procedure GetPort(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The port number of the URI.
### SetPath (Method) <a name="SetPath"></a> 

 Sets the path to the resource referenced by the URI.
 

Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.path for more information.

#### Syntax
```
procedure SetPath(Path: Text)
```
#### Parameters
*Path ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A string that represents the path to set.

### GetPath (Method) <a name="GetPath"></a> 

 Gets the path to the resource referenced by the URI.
 

Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.path for more information.

#### Syntax
```
procedure GetPath(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The path to the resource referenced by the URI.
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
### SetFragment (Method) <a name="SetFragment"></a> 

 Sets the fragment portion of the URI.
 

Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.fragment for more information.

#### Syntax
```
procedure SetFragment(Fragment: Text)
```
#### Parameters
*Fragment ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A string that represents the fragment portion to set.

### GetFragment (Method) <a name="GetFragment"></a> 

 Gets the fragment portion of the URI.
 

Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.fragment for more information.

#### Syntax
```
procedure GetFragment(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The fragment portion of the URI.
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

### AddQueryFlag (Method) <a name="AddQueryFlag"></a> 
If the provided  is empty.


 Adds a flag to the query string of this UriBuilder. In case the same query flag exists already, the action in  is taken.
 

This function could alter the order of the existing query string parts. For example, if the previous URL was "https://microsoft.com?foo=bar&john=doe" and the new flag is "contoso", the result could be "https://microsoft.com?john=doe&foo=bar&contoso".

#### Syntax
```
procedure AddQueryFlag(Flag: Text; DuplicateAction: Enum "Uri Query Duplicate Behaviour")
```
#### Parameters
*Flag ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A flag to add to the query string of this UriBuilder. This value will be encoded before being added to the URI query string. Cannot be empty.

*DuplicateAction ([Enum "Uri Query Duplicate Behaviour"]())* 

Specifies which action to take if the flag already exist.

### AddQueryFlag (Method) <a name="AddQueryFlag"></a> 
If the provided  is empty.


 Adds a flag to the query string of this UriBuilder. In case the same query flag exists already, only one occurrence is kept.
 

This function could alter the order of the existing query string parts. For example, if the previous URL was "https://microsoft.com?foo=bar&john=doe" and the new flag is "contoso", the result could be "https://microsoft.com?john=doe&foo=bar&contoso".

#### Syntax
```
procedure AddQueryFlag(Flag: Text)
```
#### Parameters
*Flag ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A flag to add to the query string of this UriBuilder. This value will be encoded before being added to the URI query string. Cannot be empty.

### AddQueryParameter (Method) <a name="AddQueryParameter"></a> 
If the provided  is empty.


 Adds a parameter key-value pair to the query string of this UriBuilder (in the form `ParameterKey=ParameterValue`). In case the same query key exists already, the action in  is taken.
 

This function could alter the order of the existing query string parts. For example, if the previous URL was "https://microsoft.com?foo=bar&john=doe" and the new flag is "contoso=42", the result could be "https://microsoft.com?john=doe&foo=bar&contoso=42".

#### Syntax
```
procedure AddQueryParameter(ParameterKey: Text; ParameterValue: Text; DuplicateAction: Enum "Uri Query Duplicate Behaviour")
```
#### Parameters
*ParameterKey ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The key for the new query parameter. This value will be encoded before being added to the URI query string. Cannot be empty.

*ParameterValue ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The value for the new query parameter. This value will be encoded before being added to the URI query string. Can be empty.

*DuplicateAction ([Enum "Uri Query Duplicate Behaviour"]())* 

Specifies which action to take if the ParameterKey specified already exist.

### AddQueryParameter (Method) <a name="AddQueryParameter"></a> 
If the provided  is empty.


 Adds a parameter key-value pair to the query string of this UriBuilder (in the form `ParameterKey=ParameterValue`). In case the same query key exists already, its value is overwritten.
 

This function could alter the order of the existing query string parts. For example, if the previous URL was "https://microsoft.com?foo=bar&john=doe" and the new flag is "contoso=42", the result could be "https://microsoft.com?john=doe&foo=bar&contoso=42".

#### Syntax
```
procedure AddQueryParameter(ParameterKey: Text; ParameterValue: Text)
```
#### Parameters
*ParameterKey ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The key for the new query parameter. This value will be encoded before being added to the URI query string. Cannot be empty.

*ParameterValue ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The value for the new query parameter. This value will be encoded before being added to the URI query string. Can be empty.


## Uri Query Duplicate Behaviour (Enum 3062)

 Specifies the behaviour when adding a new query parameter or flag to a URI.
 

### Skip (value: 1)


 Skips adding the value if the same flag or parameter already exists.
 

### Overwrite All Matching (value: 2)


 Keeps the new value (overwrites all existing matching flags or parameters).
 

### Keep All (value: 3)


 Keeps both the existing values and the new value.
 

### Throw Error (value: 4)


 Throws an error if the flag or parameter already exists.
 

