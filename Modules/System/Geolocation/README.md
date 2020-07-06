Contains functionality that retrieves data about the geographical location of a client device.
# Public Objects
## Geolocation (Page 50100)

 Provides an interface for accessing data about the geographical location of a client device.
 

### IsAvailable (Method) <a name="IsAvailable"></a> 

 Checks whether geographical location information is available on the client device.
 

#### Syntax
```
procedure IsAvailable(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if geographical location information is available, false otherwise.

### HasGeolocation (Method) <a name="HasGeolocation"></a> 

 Checks whether data about the geographical location of a client device has been retrieved and is available.
 

#### Syntax
```
procedure HasGeolocation(): Boolean
```
#### Return Value
*([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

True if geographical location data has been retrieved and is available.

### GetGeolocation (Method) <a name="GetGeolocation"></a> 

 Gets the geographical location data that was retrieved when opening the page.
 An error is displayed if the function is called without opening the page first or if the location is not available.
 

#### Syntax
```
procedure GetGeolocation(var Latitude: Decimal; var Longitude: Decimal)
```
#### Parameters
*Latitude ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 
*Longitude ([Decimal](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/decimal/decimal-data-type))* 

The latitude and longitude value of the Geolocation.


### GetGeolocationStatus (Method) <a name="GetGeolocationStatus"></a> 

 Gets the status of the geographical location data of the client device.
 

#### Syntax
```
procedure GetGeolocationStatus(): Enum "Geolocation Status"
```
#### Return Value
*([Enum "Geolocation Status"]())* 

The status of the geographical location data.

### SetHighAccuracy (Method) <a name="SetHighAccuracy"></a> 

 Sets whether the geographical location data for the device should have the highest level of accuracy.

#### Syntax
```
procedure SetQuality(Enable: Boolean)
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
*([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Whether high accuracy is set. A value to provide a hint to the device that this request must have the best possible location accuracy.

### GetTimeout (Method) <a name="GetTimeout"></a> 

 Gets the timeout for the geographical location data request.
 

#### Syntax
```
procedure SetTimeout(): Integer
```
#### Return Value
*([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The maximum length of time (milliseconds) that is allowed to pass to a location request.

### GetMaximumAge (Method) <a name="GetMaximumAge"></a> 

 Gets the maximum age for the geographical location data request.
 

#### Syntax
```
procedure GetMaximumAge(): Integer
```
#### Return Value
*([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The maximum length of time (milliseconds) of geographical location data.




## Geolocation Status (Enum 50100)

Specifies status of the returned geographical location data from the Geolocation page.
 

### Available (value: 0)


 Available.
 

### NoData (value: 1)


 No data (no data could be obtained).
 

### TimedOut (value: 2)


 Timed out (location information not obtained in due time).s.
 

### NotAvailable (value: 3)


 Not available (for example user denied app access to location).
 
