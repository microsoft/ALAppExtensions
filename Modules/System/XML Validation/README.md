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
*Xml ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))* 

Xml string to validate.

*XmlSchema ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))* 

Xml schema string to validate against.

*Namespace ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))* 

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

*Namespace ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))* 

Namespace of the xml schema.


### TryValidateAgainstSchema (Method) <a name="TryValidateAgainstSchema"></a> 

 Performs validation of a XmlDocument against a schema in a stream.
 
#### Syntax
```
[TryFunction]
procedure TryValidateAgainstSchema(XmlDocStream: InStream; XmlSchemaStream: InStream; Namespace: Text)
```
#### Parameters
*XmlDocStream ([InStream](https://go.microsoft.com/fwlink/?linkid=2210033))* 

InStream holding the xml document to validate.

*XmlSchemaStream ([InStream](https://go.microsoft.com/fwlink/?linkid=2210033))* 

InStream holding the schema to validate against.

*Namespace ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))* 

Namespace of the xml schema.


### TrySetValidatedDocument (Method) <a name="TrySetValidatedDocument"></a> 

 Sets validated document from a string.
 
#### Syntax
```
[TryFunction]
procedure TrySetValidatedDocument(Xml: Text)
```
#### Parameters
*Xml ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))* 

Xml string to validate.


### TrySetValidatedDocument (Method) <a name="TrySetValidatedDocument"></a> 

 Sets validated document in a XmlDocument.
 
#### Syntax
```
[TryFunction]
procedure TrySetValidatedDocument(XmlDoc: XmlDocument)
```
#### Parameters
*XmlDoc ([XmlDocument]())* 

Xml document to validate.


### TrySetValidatedDocument (Method) <a name="TrySetValidatedDocument"></a> 

 Sets validated document from a stream.
 
#### Syntax
```
[TryFunction]
procedure TrySetValidatedDocument(XmlDocInStream: InStream)
```
#### Parameters
*XmlDocInStream ([InStream](https://go.microsoft.com/fwlink/?linkid=2210033))* 

InStream holding the XML document to validate.


### TryAddValidationSchema (Method) <a name="TryAddValidationSchema"></a> 

 Adds validation schema to validated document from a string.
 
#### Syntax
```
[TryFunction]
procedure TryAddValidationSchema(XmlSchema: Text; Namespace: Text)
```
#### Parameters

*XmlSchema ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))* 

Xml schema string to validate against.

*Namespace ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))* 

Namespace of the XML schema.


### TryAddValidationSchema (Method) <a name="TryAddValidationSchema"></a> 

 Adds validation schema to validated document XmlDocument.
 
#### Syntax
```
[TryFunction]
procedure TryAddValidationSchema(XmlSchemaDoc: XmlDocument; Namespace: Text)
```
#### Parameters

*XmlSchemaDoc ([XmlDocument]())* 

Xml document with the schema to validate against.

*Namespace ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))* 

Namespace of the XML schema.


### TryAddValidationSchema (Method) <a name="TryAddValidationSchema"></a> 

 Adds validation schema to validated document in a stream.
 
#### Syntax
```
[TryFunction]
procedure TryAddValidationSchema(XmlSchemaInStream: InStream; Namespace: Text)
```
#### Parameters

*XmlSchemaStream ([InStream](https://go.microsoft.com/fwlink/?linkid=2210033))* 

InStream holding the XSD schema to validate against.

*Namespace ([Text](https://go.microsoft.com/fwlink/?linkid=2210031))* 

Namespace of the XML schema.


### TryValidateAgainstSchema (Method) <a name="TryValidateAgainstSchema"></a> 

 Performs validation of a XmlDocument against one or more XSD schemas.

#### Syntax
```
[TryFunction]
procedure TryValidateAgainstSchema()
```
