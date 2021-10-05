Contains functionality that retrieves data about the geographical location of a client device.
# Public Objects
## Geolocation (Codeunit 7568)

 Provides functionality for getting geographical location information from the client device.
 `
 Geolocation.SetHighAccuracy(true);
 if Geolocation.RequestGeolocation() then
    Geolocation.GetGeolocation(Latitude, Longitude);
 `

### RequestGeolocation (Method) <a name="RequestGeolocation"></a> 

 Requests a geographical location from the client device and returns whether the request was succesful.
 

#### Syntax
```
procedure RequestGeolocation(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the geographical location data was retrieved and is available, and the user agreed to share it, otherwise false.
### GetGeolocation (Method) <a name="GetGeolocation"></a> 

 Gets a geographical location from the client device and returns it in the the longitude and latitude parameters.
 

#### Syntax
```
procedure GetGeolocation(var Latitude: Decimal; var Longitude: Decimal)
```
#### Parameters
*Latitude ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

The latitude value of the geographical location.

*Longitude ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

The longitude value of the geographical location.

### IsAvailable (Method) <a name="IsAvailable"></a> 

 Checks whether geographical location data is available on the client device.
 

#### Syntax
```
procedure IsAvailable(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the location is available; false otherwise.
### HasGeolocation (Method) <a name="HasGeolocation"></a> 

 Checks whether geographical location data has been retrieved from the client device and is available.
 

#### Syntax
```
procedure HasGeolocation(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if geographical location data is retrieved and is available, otherwise false.
### GetGeolocationStatus (Method) <a name="GetGeolocationStatus"></a> 

 Gets the status of the geographical location data of the client device.
 

#### Syntax
```
procedure GetGeolocationStatus(): Enum "Geolocation Status"
```
#### Return Value
*[Enum "Geolocation Status"]()*

The status of the geographical location data.
### SetHighAccuracy (Method) <a name="SetHighAccuracy"></a> 

 Sets whether the geographical location data for the device should have the highest level of accuracy.
 

#### Syntax
```
procedure SetHighAccuracy(Enable: Boolean)
```
#### Parameters
*Enable ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Instructs the device that the geographical location data for this request must have the highest level of accuracy.

### SetTimeout (Method) <a name="SetTimeout"></a> 

 Sets a timeout for the geographical location data request.
 

#### Syntax
```
procedure SetTimeout(Timeout: Integer)
```
#### Parameters
*Timeout ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The maximum length of time (milliseconds) that is allowed to pass to a location request.

### SetMaximumAge (Method) <a name="SetMaximumAge"></a> 

 Sets a maximum age for the geographical location data request.
 

#### Syntax
```
procedure SetMaximumAge(Age: Integer)
```
#### Parameters
*Age ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The maximum length of time (milliseconds) of cached geographical location data.

### GetHighAccuracy (Method) <a name="GetHighAccuracy"></a> 

 Gets whether the device should have the highest level of accuracy for geographical location data.
 

#### Syntax
```
procedure GetHighAccuracy(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

Whether high accuracy is set. A value to provide a hint to the device that this request must have the best possible location accuracy.
### GetTimeout (Method) <a name="GetTimeout"></a> 

 Gets the timeout for the geographical location data request.
 

#### Syntax
```
procedure GetTimeout(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The maximum length of time (milliseconds) that is allowed to pass to a location request.
### GetMaximumAge (Method) <a name="GetMaximumAge"></a> 

 Gets the maximum age for the geographical location data request.
 

#### Syntax
```
procedure GetMaximumAge(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The maximum length of time (milliseconds) of geographical location data.

## Geolocation (Page 7568)

 This page shows instructional text for the user and is opened when the geographical location of the client device is requested.
 


## Geolocation Status (Enum 7568)

 Specifies the status of the geographical location data.
 

### Available (value: 0)


 Available
 

### No Data (value: 1)


 No data (no data could be obtained).
 

### Timed Out (value: 2)


 Timed out (location information not obtained in due time).
 

### Not Available (value: 3)


 Not available (for example user denied app access to location).
 

