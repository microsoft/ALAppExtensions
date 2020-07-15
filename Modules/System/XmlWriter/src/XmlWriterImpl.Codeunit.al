// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1384 "XmlWriter Impl."
{
    Access = Internal;
    SingleInstance = true;

    var
        StringBuilder: DotNet StringBuilder;
        StringWriter: DotNet StringWriter;
        XmlTextWriter: DotNet XmlTextWriter;

    procedure XmlWriterCreateDocument();
    begin
        StringBuilder := StringBuilder.StringBuilder;
        StringWriter := StringWriter.StringWriter(StringBuilder);
        XmlTextWriter := XmlTextWriter.XmlTextWriter(StringWriter);
        XmlTextWriter.WriteStartDocument;
    end;

    procedure XmlWriterStartElement(Prefix: Text; LocalName: Text; NameSpace: Text);
    begin
        XmlTextWriter.WriteStartElement(Prefix, LocalName, NameSpace);
    end;

    procedure XmlWriterElementString(LocalName: Text; ElementValue: Text)
    begin
        XmlTextWriter.WriteElementString(LocalName, ElementValue);
    end;

    procedure XmlWriterEndElement()
    begin
        XmlTextWriter.WriteEndElement;
    end;

    procedure XmlWriterAddAttribute(ElementName: Text; ElementValue: Text; Prefix: Text)
    begin
        if Prefix <> '' then
            XmlTextWriter.WriteAttributeString(Prefix, ElementName, '', ElementValue)
        else
            XmlTextWriter.WriteAttributeString(ElementName, ElementValue);
    end;

    procedure XmlWriterEndDocument()
    begin
        XmlTextWriter.WriteEndDocument;
    end;

    procedure XmlWriterComment(ParComment: Text)
    begin
        XmlTextWriter.WriteComment(ParComment);
    end;

    procedure XmlWriterToBigText(VAR XmlBigText: BigText)
    begin
        XmlBigText.AddText(StringBuilder.ToString);
    end;
}