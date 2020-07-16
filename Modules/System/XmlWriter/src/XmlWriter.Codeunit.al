// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
// Provides helper functions for System.Xml.XmlWriter
/// </summary>

codeunit 1385 "XmlWriter"
{
    Access = Public;

    var
        XmlWriterImpl: Codeunit "XmlWriter Impl.";

    /// <summary>
    /// Creates the XmlWriter Document
    /// </summary>
    procedure XmlWriterCreateDocument()
    begin
        XmlWriterImpl.XmlWriterCreateDocument();
    end;

    /// <summary>
    /// When overridden in a derived class, writes the specified start tag.
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
    /// When overridden in a derived class, closes one element and pops the corresponding namespace scope.
    /// </summary>
    procedure WriteEndElement()
    begin
        XmlWriterImpl.WriteEndElement();
    end;

    /// <summary>
    /// When overridden in a derived class, writes an attribute with the specified value.
    /// </summary>
    /// <param name="LocalName">The local name of the attribute.</param>
    /// <param name="ElementValue">The value of the attribute.</param>
    /// <param name="Prefix">The namespace prefix of the attribute.</param>
    /// <param name="Ns">The namespace URI of the attribute.</param>
    procedure WriteAttributeString(Prefix: Text; LocalName: Text; Ns: Text; ElementValue: Text)
    begin
        XmlWriterImpl.WriteAttributeString(Prefix, LocalName, Ns, ElementValue);
    end;

    /// <summary>
    /// When overridden in a derived class, writes an attribute with the specified value.
    /// </summary>
    /// <param name="LocalName">The local name of the attribute.</param>
    /// <param name="ElementValue">The value of the attribute.</param>
    procedure WriteAttributeString(LocalName: Text; ElementValue: Text)
    begin
        XmlWriterImpl.WriteAttributeString(LocalName, ElementValue);
    end;

    /// <summary>
    /// When overridden in a derived class, writes out a comment <!--...--> containing the specified text.
    /// </summary>
    /// <param name="Comment">Text to place inside the comment.</param>
    procedure WriteComment(Comment: Text)
    begin
        XmlWriterImpl.WriteComment(Comment);
    end;

    /// <summary>
    /// When overridden in a derived class, closes any open elements or attributes and puts the writer back in the Start state.
    /// </summary>
    procedure WriteEndDocument()
    begin
        XmlWriterImpl.WriteEndDocument();
    end;

    /// <summary>
    /// Writes the text within Xml Writer to the BigText variable. 
    /// </summary>
    /// <param name="XmlBigText">The BigText the Xml Writer has to be write to. </param>
    procedure XmlWriterToBigText(VAR XmlBigText: BigText)
    begin
        XmlWriterImpl.XmlWriterToBigText(XmlBigText);
    end;
}