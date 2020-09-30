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
        StringBuilder := StringBuilder.StringBuilder();
        StringWriter := StringWriter.StringWriter(StringBuilder);
        XmlTextWriter := XmlTextWriter.XmlTextWriter(StringWriter);
        XmlTextWriter.WriteStartDocument();
    end;

    procedure WriteStartElement(Prefix: Text; LocalName: Text; NameSpace: Text);
    begin
        XmlTextWriter.WriteStartElement(Prefix, LocalName, NameSpace);
    end;

    procedure WriteElementString(LocalName: Text; ElementValue: Text)
    begin
        XmlTextWriter.WriteElementString(LocalName, ElementValue);
    end;

    procedure WriteEndElement()
    begin
        XmlTextWriter.WriteEndElement();
    end;

    procedure WriteAttributeString(LocalName: Text; ElementValue: Text)
    begin
        XmlTextWriter.WriteAttributeString(LocalName, ElementValue);
    end;

    procedure WriteAttributeString(Prefix: Text; LocalName: Text; Ns: Text; ElementValue: Text)
    begin
        XmlTextWriter.WriteAttributeString(Prefix, LocalName, Ns, ElementValue);
    end;

    procedure WriteEndDocument()
    begin
        XmlTextWriter.WriteEndDocument();
    end;

    procedure WriteComment(ParComment: Text)
    begin
        XmlTextWriter.WriteComment(ParComment);
    end;

    procedure XmlWriterToBigText(VAR XmlBigText: BigText)
    begin
        XmlBigText.AddText(StringBuilder.ToString());
    end;
}