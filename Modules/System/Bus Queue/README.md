This module provides a way for handling bus queues. A bus queue is a stack of HTTP calls where they are sent by FIFO pattern.

# Public Objects

## Bus Queue (Codeunit 51754)

### Init (Method)
Initializes a bus queue with the specified URL and HTTP request type.

#### Syntax
```
procedure Init(URL: Text[2048]; HttpRequestType: Enum "Http Request Type")
```

#### Parameters
*URL ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))*

The URL where the request will be sent

*HttpRequestType (Enum "Http Request Type")* 

The HTTP verb of the request.

### AddHeader (Method)
Adds a header to the request.

#### Syntax
```
procedure AddHeader(Name: Text[250]; Value: Text)
```

#### Parameters
*Name ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))* 

Name of the header.

*Value ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))* 

Value of the header.

### SetBody (Method)
Sets the body of the request using a Text parameter.

#### Syntax
```
procedure SetBody(Body: Text)
```

#### Parameters
*Body ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))*

Body of the request.

### SetBody (Method)
Sets the body of the request using a Text parameter and a specific codepage.

#### Syntax
```
procedure SetBody(Body: Text; Codepage: Integer)
```

#### Parameters
*Body ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))*

Body of the request.

*Codepage ([Integer](https://go.microsoft.com/fwlink/?linkid=2209956))*

Codepage for the body of the request.

### SetBody (Method)
Sets the body of the request using an InStream.

#### Syntax
```
procedure SetBody(InStreamBody: InStream)
```

#### Parameters
*InStreamBody ([InStream](https://go.microsoft.com/fwlink/?linkid=2210033))*

InStream with the data.

### SetMaximumNumberOfTries (Method)
Sets the maximum number of retries if a bus queue is in retry status.

#### Syntax
```
procedure SetMaximumNumberOfTries(MaximumNumberOfTries: Integer)
```

#### Parameters
*MaximumNumberOfTries ([Integer](https://go.microsoft.com/fwlink/?linkid=2209956))*

Maximum number of tries.

### SetSecondsBetweenRetries (Method)
Sets the seconds between retries if a bus queue is in retry status.

#### Syntax
```
procedure SetSecondsBetweenRetries(SecondsBetweenTries: Integer)
```

#### Parameters
*SecondsBetweenTries ([Integer](https://go.microsoft.com/fwlink/?linkid=2209956))*

Seconds between retries.

### SetCategory (Method)
Sets the category code of the bus queue.

#### Syntax
```
procedure SetCategory(CategoryCode: Code[10])
```

#### Parameters
*CategoryCode ([Code](https://learn.microsoft.com/es-es/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))*

The category code of the bus queue.

### SetRecordId (Method)
Sets the RecordId of the record to link to the bus queue.

#### Syntax
```
procedure SetRecordId("RecordId": RecordId)
```

#### Parameters
*RecordId ([RecordId](https://learn.microsoft.com/es-es/dynamics365/business-central/dev-itpro/developer/methods-auto/recordid/recordid-data-type))*

The RecordId of the record to link.

### SetSystemId (Method)
Sets the SystemId of the record to link to the bus queue.

#### Syntax
```
procedure SetSystemId(TableNo: Integer; SystemId: Guid)
```

#### Parameters
*TableNo ([Integer](https://go.microsoft.com/fwlink/?linkid=2209956))*

The table number of the record to link.

*SystemId ([Guid](https://learn.microsoft.com/es-es/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))*

The SystemId of the record to link.

### Enqueue (Method)
Creates a Bus Queue record and runs the Bus Queues Handler.

#### Syntax
```
procedure Enqueue(): Integer
```

#### Return Value
*[Boolean](https://go.microsoft.com/fwlink/?linkid=2209954)*

Entry No. of the Bus Queue.

## Bus Queue Response (Codeunit 51758)

### GetHeaders (Method)
Gets the headers

#### Syntax
```
procedure GetHeaders(): InStream
```

#### Return Value
[InStream](https://go.microsoft.com/fwlink/?linkid=2210033)

Response headers

### GetBody (Method)
Gets the body

#### Syntax
```
procedure GetBody(): InStream
```

#### Return Value
[InStream](https://go.microsoft.com/fwlink/?linkid=2210033)

Response body in InStream format

### GetHTTPCode (Method)
Gets the HTTP code

#### Syntax
```
procedure GetHTTPCode(): Integer
```

#### Return Value
[Integer](https://go.microsoft.com/fwlink/?linkid=2209956)

The HTTP code of the response

### GetReasonPhrase (Method)
Gets the reason phrase

#### Syntax
```
procedure GetReasonPhrase(): Text
```

#### Return Value
[Text](https://go.microsoft.com/fwlink/?linkid=2210031)

The reason phrase code of the response

### GetRecordId (Method)
Gets the RecordId

#### Syntax
```
procedure GetRecordId(): RecordId
```

#### Return Value
[RecordId](https://learn.microsoft.com/es-es/dynamics365/business-central/dev-itpro/developer/methods-auto/recordid/recordid-data-type)

The RecordId saved in the Bus Queue

### GetSystemId (Method)
Gets the SystemId

#### Syntax
```
procedure GetSystemId(): Guid
```

#### Return Value
[Guid](https://learn.microsoft.com/es-es/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)

The SystemId saved in the Bus Queue

## Bus Queue Response Raise Event (Codeunit 51753)

### OnAfterInsertBusQueueResponse (Method)
Allows to read the response of a Bus Queue Response

#### Syntax
```
internal procedure OnAfterInsertBusQueueResponse(BusQueueResponse: Codeunit "Bus Queue Response")
```