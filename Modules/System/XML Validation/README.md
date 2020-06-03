Use the module to validate XML-formatted strings against XML schemas.
# Public Objects
## Xml Validation (Codeunit 6240)

 Provides helper functions for xml validation against a schema.
 

### TryValidateAgainstSchema (Method) <a name="TryValidateAgainstSchema"></a> 
If xml definition is not well-formed


 Performs validation of an XML from a string against a schema from a string.
 

#### Syntax
```
[TryFunction]
procedure TryValidateAgainstSchema(Xml: Text; XmlSchema: Text; Namespace: Text)
```
#### Parameters
*Xml ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Xml string to validate.

*XmlSchema ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Xml schema string to validate against.

*Namespace ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Namespace of the xml schema.

### TryValidateAgainstSchema (Method) <a name="TryValidateAgainstSchema"></a> 

 Performs validation of a XmlDocument against a schema in a XmlDocument.
 

#### Syntax
```
[TryFunction]
procedure TryValidateAgainstSchema(XmlDoc: XmlDocument; XmlSchemaDoc: XmlDocument; Namespace: Text)
```
#### Parameters
*XmlDoc ([XmlDocument]())* 

Xml document to validate.

*XmlSchemaDoc ([XmlDocument]())* 

Xml document with the schema to validate against.

*Namespace ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Namespace of the xml schema.

### TryValidateAgainstSchema (Method) <a name="TryValidateAgainstSchema"></a> 

 Performs validation of a XmlDocument against a schema in a stream.
 

#### Syntax
```
[TryFunction]
procedure TryValidateAgainstSchema(XmlDocStream: InStream; XmlSchemaStream: InStream; Namespace: Text)
```
#### Parameters
*XmlDocStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

InStream holding the xml document to validate.

*XmlSchemaStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

InStream holding the schema to validate against.

*Namespace ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Namespace of the xml schema.

