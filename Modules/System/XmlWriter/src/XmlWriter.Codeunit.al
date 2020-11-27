// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides helper functions for System.Xml.XmlWriter
/// </summary>
codeunit 1483 "XmlWriter"
{
    Access = Public;

    var
        XmlWriterImpl: Codeunit "XmlWriter Impl.";

    /// <summary>
    /// Initializes the XmlWriter and creates the XmlWriter Document
    /// </summary>
    procedure WriteStartDocument()
    begin
        XmlWriterImpl.WriteStartDocument();
    end;

    /// <summary>
    /// Writes the Processing Instruction.
    /// </summary>
    /// <remarks>This function reinitializes the XML Writer.</remarks>
    /// <param name="Name">The name of the processing instruction.</param>
    /// <param name="Text">The text to include in the processing instruction.</param>
    procedure WriteProcessingInstruction(Name: Text; "Text": Text)
    begin
        XmlWriterImpl.WriteProcessingInstruction(Name, "Text");
    end;

    /// <summary>
    /// Writes the specified start tag.
    /// </summary>
    /// <param name="LocalName">The local name of the element.</param>
    procedure WriteStartElement(LocalName: Text)
    begin
        XmlWriterImpl.WriteStartElement(LocalName);
    end;

    /// <summary>
    /// Writes the specified start tag and associates it with the given namespace and prefix.
    /// </summary>
    /// <param name="Prefix">The namespace prefix of the element.</param>
    /// <param name="LocalName">The local name of the element.</param>
    /// <param name="NameSpace">The namespace URI to associate with the element. If this namespace is already in scope and has an associated prefix, the writer automatically writes that prefix also.</param>
    procedure WriteStartElement(Prefix: Text; LocalName: Text; NameSpace: Text)
    begin
        XmlWriterImpl.WriteStartElement(Prefix, LocalName, NameSpace);
    end;

    /// <summary>
    /// Writes an element with the specified local name and value.
    /// </summary>
    /// <param name="LocalName">The local name of the element.</param>
    /// <param name="ElementValue">The value of the element.</param>
    procedure WriteElementString(LocalName: Text; ElementValue: Text)
    begin
        XmlWriterImpl.WriteElementString(LocalName, ElementValue);
    end;

    /// <summary>
    /// Writes the given text content.
    /// </summary>
    /// <param name="ElementText">Text to write.</param>
    procedure WriteString(ElementText: Text)
    begin
        XmlWriterImpl.WriteString(ElementText);
    end;

    /// <summary>
    /// Closes one element and pops the corresponding namespace scope.
    /// </summary>
    procedure WriteEndElement()
    begin
        XmlWriterImpl.WriteEndElement();
    end;

    /// <summary>
    /// Writes an attribute with the specified local name, namespace URI, and value.
    /// </summary>
    /// <param name="Prefix">The namespace prefix of the attribute.</param>
    /// <param name="LocalName">The local name of the attribute.</param>
    /// <param name="Namespace">The namespace URI of the attribute.</param>
    /// <param name="ElementValue">The value of the attribute.</param>
    procedure WriteAttributeString(Prefix: Text; LocalName: Text; Namespace: Text; ElementValue: Text)
    begin
        XmlWriterImpl.WriteAttributeString(Prefix, LocalName, Namespace, ElementValue);
    end;

    /// <summary>
    /// Writes out the attribute with the specified local name and value.
    /// </summary>
    /// <param name="LocalName">The local name of the attribute.</param>
    /// <param name="ElementValue">The value of the attribute.</param>
    procedure WriteAttributeString(LocalName: Text; ElementValue: Text)
    begin
        XmlWriterImpl.WriteAttributeString(LocalName, ElementValue);
    end;

    /// <summary>
    /// Writes out a comment <!--...--> containing the specified text.
    /// </summary>
    /// <param name="Comment">Text to place inside the comment.</param>
    procedure WriteComment(Comment: Text)
    begin
        XmlWriterImpl.WriteComment(Comment);
    end;

    /// <summary>
    /// Closes any open elements or attributes and puts the writer back in the Start state.
    /// </summary>
    procedure WriteEndDocument()
    begin
        XmlWriterImpl.WriteEndDocument();
    end;

    /// <summary>
    /// Writes the text within Xml Writer to the BigText variable. 
    /// </summary>
    /// <param name="XmlBigText">The BigText the Xml Writer has to be write to.</param>
    procedure ToBigText(Var XmlBigText: BigText)
    begin
        XmlWriterImpl.ToBigText(XmlBigText);
    end;
}