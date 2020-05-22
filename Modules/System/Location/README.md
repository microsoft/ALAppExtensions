Contains functionality that enables getting the location of a client device.
# Public Objects
## Location (Page 50105)

 Provides an interface for accessing the location on the client device.
 

### IsAvailable (Method) <a name="IsAvailable"></a> 

 Checks whether location information is available on the client device.
 

#### Syntax
```
procedure IsAvailable(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if location information is available, false otherwise.

### HasLocation (Method) <a name="HasLocation"></a> 

 Checks if a location has been retrieved from the client device and and is available.
 

#### Syntax
```
procedure HasLocation(): Boolean
```
#### Return Value
*([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

True if a location is retrieved and is available; false otherwise.

### GetLocation (Method) <a name="GetLocation"></a> 

 Gets the location that was retrieved when opening the page.
 An error is displayed if the function is called without opening the page first or if the location is not available.
 

#### Syntax
```
procedure GetLocation(var Latitude: Decimal; var Longitude: Decimal)
```
#### Parameters
*Latitude ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 
*Longitude ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

The latitude and longitude value of the location.


### GetLocationStatus (Method) <a name="GetLocationStatus"></a> 

 Gets the status of the client device location.
 

#### Syntax
```
procedure GetLocationStatus(): Enum "Location Status"
```
#### Return Value
*([Enum "Location Status"]())* 

The status of the location.

### SetHighAccuracy (Method) <a name="SetHighAccuracy"></a> 

 Sets whether the device should have the best possible location accuracy.

#### Syntax
```
procedure SetQuality(Enable: Boolean)
```
#### Parameters
*Enable ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))*  

A value to provide a hint to the device that this request must have the best possible location accuracy.

### SetTimeout (Method) <a name="SetTimeout"></a> 

 Sets a timeout for the location request.
 

#### Syntax
```
procedure SetTimeout(Timeout: Integer)
```
#### Parameters
*Timeout ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The maximum length of time (milliseconds) that is allowed to pass to a location request.

### SetMaximumAge (Method) <a name="SetMaximumAge"></a> 

 Sets a maximum age for the location request.
 

#### Syntax
```
procedure SetMaximumAge(Age: Integer)
```
#### Parameters
*Age ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The maximum length of time (milliseconds) of a cached location.

### GetHighAccuracy (Method) <a name="GetHighAccuracy"></a> 

 Gets whether the device should have the best possible location accuracy.

#### Syntax
```
procedure GetHighQuality(): Boolean
```
#### Return Value
*([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Whether high accuracy is set. A value to provide a hint to the device that this request must have the best possible location accuracy.

### GetTimeout (Method) <a name="GetTimeout"></a> 

 Gets the timeout for the location request.
 

#### Syntax
```
procedure SetTimeout(): Integer
```
#### Return Value
*([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The maximum length of time (milliseconds) that is allowed to pass to a location request.

### GetMaximumAge (Method) <a name="GetMaximumAge"></a> 

 Gets the maximum age for the location request.
 

#### Syntax
```
procedure GetMaximumAge(): Integer
```
#### Return Value
*([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The maximum length of time (milliseconds) of a cached location.




## Location Status (Enum 50107)

Specifies the location status of the returned location from the Location page.
 

### Available (value: 0)


 Available.
 

### NoData (value: 1)


 No data (no data could be obtained).
 

### TimedOut (value: 2)


 Timed out (location information not obtained in due time).s.
 

### NotAvailable (value: 3)


 Not available (for example user denied app access to location).
 
