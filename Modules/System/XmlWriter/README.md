Provides helper functions to create XML as Big Text with System.Xml.XmlTextWriter

Use this module to do the following:
- Create an Xml Document with System.Xml.XmlTextWriter
- Add elements to the Xml Document
- Add attributes to the elements
- Add comments to the Xml Document
- Transforms the Xml Document to Big Text
# Public Objects
## XmlWriter (Codeunit 1483)

 Provides helper functions for System.Xml.XmlWriter
 

### WriteStartDocument (Method) <a name="WriteStartDocument"></a> 

 Initializes the XmlWriter and creates the XmlWriter Document
 

#### Syntax
```
procedure WriteStartDocument()
```
### WriteProcessingInstruction (Method) <a name="WriteProcessingInstruction"></a> 

 Writes the Processing Instruction.
 

This function reinitializes the XML Writer.

#### Syntax
```
procedure WriteProcessingInstruction(Name: Text; "Text": Text)
```
#### Parameters
*Name ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the processing instruction.

*Text ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The text to include in the processing instruction.

### WriteStartElement (Method) <a name="WriteStartElement"></a> 

 Writes the specified start tag.
 

#### Syntax
```
procedure WriteStartElement(LocalName: Text)
```
#### Parameters
*LocalName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The local name of the element.

### WriteStartElement (Method) <a name="WriteStartElement"></a> 

 Writes the specified start tag and associates it with the given namespace and prefix.
 

#### Syntax
```
procedure WriteStartElement(Prefix: Text; LocalName: Text; NameSpace: Text)
```
#### Parameters
*Prefix ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The namespace prefix of the element.

*LocalName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The local name of the element.

*NameSpace ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The namespace URI to associate with the element. If this namespace is already in scope and has an associated prefix, the writer automatically writes that prefix also.

### WriteElementString (Method) <a name="WriteElementString"></a> 

 Writes an element with the specified local name and value.
 

#### Syntax
```
procedure WriteElementString(LocalName: Text; ElementValue: Text)
```
#### Parameters
*LocalName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The local name of the element.

*ElementValue ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The value of the element.

### WriteString (Method) <a name="WriteString"></a> 

 Writes the given text content.
 

#### Syntax
```
procedure WriteString(ElementText: Text)
```
#### Parameters
*ElementText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Text to write.

### WriteEndElement (Method) <a name="WriteEndElement"></a> 

 Closes one element and pops the corresponding namespace scope.
 

#### Syntax
```
procedure WriteEndElement()
```
### WriteAttributeString (Method) <a name="WriteAttributeString"></a> 

 Writes an attribute with the specified local name, namespace URI, and value.
 

#### Syntax
```
procedure WriteAttributeString(Prefix: Text; LocalName: Text; Namespace: Text; ElementValue: Text)
```
#### Parameters
*Prefix ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The namespace prefix of the attribute.

*LocalName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The local name of the attribute.

*Namespace ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The namespace URI of the attribute.

*ElementValue ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The value of the attribute.

### WriteAttributeString (Method) <a name="WriteAttributeString"></a> 

 Writes out the attribute with the specified local name and value.
 

#### Syntax
```
procedure WriteAttributeString(LocalName: Text; ElementValue: Text)
```
#### Parameters
*LocalName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The local name of the attribute.

*ElementValue ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The value of the attribute.

### WriteComment (Method) <a name="WriteComment"></a> 

 Writes out a comment <!-- ... --> containing the specified text.
 

#### Syntax
```
procedure WriteComment(Comment: Text)
```
#### Parameters
*Comment ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Text to place inside the comment.

### WriteEndDocument (Method) <a name="WriteEndDocument"></a> 

 Closes any open elements or attributes and puts the writer back in the Start state.
 

#### Syntax
```
procedure WriteEndDocument()
```
### ToBigText (Method) <a name="ToBigText"></a> 

 Writes the text within Xml Writer to the BigText variable.
 

#### Syntax
```
procedure ToBigText(Var XmlBigText: BigText)
```
#### Parameters
*XmlBigText ([BigText]())* 

The BigText the Xml Writer has to be write to.

