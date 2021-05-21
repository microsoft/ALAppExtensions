// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1484 "XmlWriter Impl."
{
    Access = Internal;

    var
        StringBuilder: DotNet StringBuilder;
        StringWriter: DotNet StringWriter;
        XmlTextWriter: DotNet XmlTextWriter;
        Initialized: Boolean;

    procedure WriteStartDocument();
    begin
        Initialize();
        XmlTextWriter.WriteStartDocument();
    end;

    procedure WriteProcessingInstruction(Name: Text; "Text": Text)
    begin
        Initialize();
        XmlTextWriter.WriteProcessingInstruction(Name, "Text");
    end;

    procedure WriteStartElement(LocalName: Text);
    begin
        if not Initialized then
            Initialize();

        XmlTextWriter.WriteStartElement(LocalName);
    end;

    procedure WriteStartElement(Prefix: Text; LocalName: Text; NameSpace: Text);
    begin
        if not Initialized then
            Initialize();

        XmlTextWriter.WriteStartElement(Prefix, LocalName, NameSpace);
    end;

    procedure WriteElementString(LocalName: Text; ElementValue: Text)
    begin
        if not Initialized then
            Initialize();

        XmlTextWriter.WriteElementString(LocalName, ElementValue);
    end;

    procedure WriteString(ElementText: Text)
    begin
        if not Initialized then
            Initialize();

        XmlTextWriter.WriteString(ElementText);
    end;

    procedure WriteEndElement()
    begin
        if not Initialized then
            Initialize();

        XmlTextWriter.WriteEndElement();
    end;

    procedure WriteAttributeString(LocalName: Text; ElementValue: Text)
    begin
        if not Initialized then
            Initialize();

        XmlTextWriter.WriteAttributeString(LocalName, ElementValue);
    end;

    procedure WriteAttributeString(Prefix: Text; LocalName: Text; Namespace: Text; ElementValue: Text)
    begin
        if not Initialized then
            Initialize();

        XmlTextWriter.WriteAttributeString(Prefix, LocalName, Namespace, ElementValue);
    end;

    procedure WriteEndDocument()
    begin
        if not Initialized then
            Initialize();

        XmlTextWriter.WriteEndDocument();
    end;

    procedure WriteComment(ParComment: Text)
    begin
        if not Initialized then
            Initialize();

        XmlTextWriter.WriteComment(ParComment);
    end;

    procedure ToBigText(var XmlBigText: BigText)
    begin
        if not Initialized then
            Initialize();

        Clear(XmlBigText);
        XmlBigText.AddText(StringBuilder.ToString());
    end;

    local procedure Initialize()
    begin
        StringBuilder := StringBuilder.StringBuilder();
        StringWriter := StringWriter.StringWriter(StringBuilder);
        XmlTextWriter := XmlTextWriter.XmlTextWriter(StringWriter);
        Initialized := true;
    end;
}