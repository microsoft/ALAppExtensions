// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9044 "ABS Format Helper"
{
    Access = Internal;

    [NonDebuggable]
    procedure AppendToUri(var Uri: Text; ParameterIdentifier: Text; ParameterValue: Text)
    var
        ConcatChar: Text;
        AppendType1Lbl: Label '%1%2=%3', Comment = '%1 = Concatenation character, %2 = Parameter Identifer, %3 = Parameter Value', Locked = true;
        AppendType2Lbl: Label '%1%2', Comment = '%1 = Concatenation character, %2 = Parameter Value', Locked = true;
    begin
        ConcatChar := '?';
        if Uri.Contains('?') then
            ConcatChar := '&';
        if ParameterIdentifier <> '' then
            Uri += StrSubstNo(AppendType1Lbl, ConcatChar, ParameterIdentifier, ParameterValue)
        else
            Uri += StrSubstNo(AppendType2Lbl, ConcatChar, ParameterValue)
    end;

    [NonDebuggable]
    procedure RemoveCurlyBracketsFromString("Value": Text): Text
    begin
        exit(DelChr("Value", '=', '{}'));
    end;

    [NonDebuggable]
    procedure GetBase64BlockId(): Text
    begin
        exit(GetBase64BlockId(RemoveCurlyBracketsFromString(Format(CreateGuid()))));
    end;

    [NonDebuggable]
    procedure GetBase64BlockId(BlockId: Text): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        Uri: Codeunit Uri;
    begin
        exit(Uri.EscapeDataString(Base64Convert.ToBase64(BlockId)));
    end;

    [NonDebuggable]
    procedure BlockDictionariesToBlockListDictionary(CommitedBlocks: Dictionary of [Text, Integer]; UncommitedBlocks: Dictionary of [Text, Integer]; var BlockList: Dictionary of [Text, Text]; OverwriteValueToLatest: Boolean)
    var
        Keys: List of [Text];
        "Key": Text;
        "Value": Text;
    begin
        "Value" := 'Committed';
        If OverwriteValueToLatest then
            "Value" := 'Latest';
        Keys := CommitedBlocks.Keys;
        foreach "Key" in Keys do
            BlockList.Add("Key", "Value");

        "Value" := 'Uncommitted';
        If OverwriteValueToLatest then
            "Value" := 'Latest';
        Keys := UncommitedBlocks.Keys;
        foreach "Key" in Keys do
            BlockList.Add("Key", "Value");
    end;

    [NonDebuggable]
    procedure BlockListDictionaryToXmlDocument(BlockList: Dictionary of [Text, Text]): XmlDocument
    var
        Document: XmlDocument;
        BlockListNode: XmlNode;
        BlockNode: XmlNode;
        Keys: List of [Text];
        "Key": Text;
    begin
        XmlDocument.ReadFrom('<?xml version="1.0" encoding="utf-8"?><BlockList></BlockList>', Document);
        Document.SelectSingleNode('/BlockList', BlockListNode);
        Keys := BlockList.Keys;
        foreach "Key" in Keys do begin
            BlockNode := XmlElement.Create(BlockList.Get("Key"), '', "Key").AsXmlNode(); // Dictionary value contains "Latest", "Committed" or "Uncommitted"
            BlockListNode.AsXmlElement().Add(BlockNode);
        end;
        exit(Document);
    end;

    [NonDebuggable]
    procedure TagsDictionaryToXmlDocument(Tags: Dictionary of [Text, Text]): XmlDocument
    var
        Document: XmlDocument;
        TagSetNode: XmlNode;
        TagNode: XmlNode;
        KeyNode: XmlNode;
        ValueNode: XmlNode;
        Keys: List of [Text];
        "Key": Text;
    begin
        XmlDocument.ReadFrom('<?xml version="1.0" encoding="utf-8"?><Tags><TagSet></TagSet></Tags>', Document);
        Document.SelectSingleNode('/Tags/TagSet', TagSetNode);
        Keys := Tags.Keys;
        foreach "Key" in Keys do begin
            TagNode := XmlElement.Create('Tag').AsXmlNode();
            KeyNode := XmlElement.Create('Key', '', "Key").AsXmlNode();
            ValueNode := XmlElement.Create('Value', '', Tags.Get("Key")).AsXmlNode();
            TagSetNode.AsXmlElement().Add(TagNode);

            TagNode.AsXmlElement().Add(KeyNode);
            TagNode.AsXmlElement().Add(ValueNode);
        end;
        exit(Document);
    end;

    [NonDebuggable]
    procedure XmlDocumentToTagsDictionary(Document: XmlDocument): Dictionary of [Text, Text]
    var
        Tags: Dictionary of [Text, Text];
        TagNodesList: XmlNodeList;
        TagNode: XmlNode;
        KeyValue: Text;
        Value: Text;
    begin
        if not Document.SelectNodes('/Tags/TagSet/Tag', TagNodesList) then
            exit;

        foreach TagNode in TagNodesList do begin
            KeyValue := GetSingleNodeInnerText(TagNode, 'Key');
            Value := GetSingleNodeInnerText(TagNode, 'Value');
            if KeyValue = '' then begin
                Clear(Tags);
                exit;
            end;
            Tags.Add(KeyValue, Value);
        end;
        exit(Tags);
    end;

    [NonDebuggable]
    local procedure GetSingleNodeInnerText(Node: XmlNode; XPath: Text): Text
    var
        ChildNode: XmlNode;
        XmlElement: XmlElement;
    begin
        if not Node.SelectSingleNode(XPath, ChildNode) then
            exit;
        XmlElement := ChildNode.AsXmlElement();
        exit(XmlElement.InnerText());
    end;

    [NonDebuggable]
    procedure TagsDictionaryToSearchExpression(Tags: Dictionary of [Text, Text]): Text
    var
        Helper: Codeunit "Uri";
        Keys: List of [Text];
        "Key": Text;
        SingleQuoteChar: Char;
        Expression: Text;
        ExpressionPartLbl: Label '"%1" %2 %3%4%5', Comment = '%1 = Tag, %2 = Operator, %3 = Single Quote, %4 = Value, %5 = Single Quote';
    begin
        SingleQuoteChar := 39;
        Keys := Tags.Keys;
        foreach "Key" in Keys do begin
            if Expression <> '' then
                Expression += ' AND ';
            Expression += StrSubstNo(ExpressionPartLbl, "Key".Trim(), GetOperatorFromValue(Tags.Get("Key")).Trim(), SingleQuoteChar, GetValueWithoutOperator(Tags.Get("Key")).Trim(), SingleQuoteChar);
        end;
        Expression := Helper.EscapeDataString(Expression);
        exit(Expression);
    end;

    [NonDebuggable]
    procedure QueryExpressionToQueryBlobContent(QueryExpression: Text): XmlDocument
    var
        Document: XmlDocument;
        QueryRequestNode: XmlNode;
        QueryTypeNode: XmlNode;
        ExpressionNode: XmlNode;
    begin
        XmlDocument.ReadFrom('<?xml version="1.0" encoding="utf-8"?><QueryRequest></QueryRequest>', Document);
        Document.SelectSingleNode('/QueryRequest', QueryRequestNode);
        QueryTypeNode := XmlElement.Create('QueryType', '', 'SQL').AsXmlNode();
        QueryRequestNode.AsXmlElement().Add(QueryTypeNode);
        ExpressionNode := XmlElement.Create('Expression', '', QueryExpression).AsXmlNode();
        QueryRequestNode.AsXmlElement().Add(ExpressionNode);
        exit(Document);
    end;

    [NonDebuggable]
    local procedure GetOperatorFromValue("Value": Text): Text
    var
        NewValue: Text;
    begin
        NewValue := "Value".Substring(1, "Value".IndexOf(' '));
        exit(NewValue.Trim());
    end;

    [NonDebuggable]
    local procedure GetValueWithoutOperator("Value": Text): Text
    var
        NewValue: Text;
    begin
        NewValue := "Value".Substring("Value".IndexOf(' ') + 1);
        exit(NewValue.Trim());
    end;

    [NonDebuggable]
    procedure TextToXmlDocument(SourceText: Text): XmlDocument
    var
        Document: XmlDocument;
    begin
        XmlDocument.ReadFrom(SourceText, Document);
        exit(Document);
    end;

    procedure ConvertToDateTime(PropertyValue: Text): DateTime
    var
        NewDateTime: DateTime;
    begin
        NewDateTime := 0DT;
        // PropertyValue is something like the following: 'Mon, 24 May 2021 12:25:27 GMT'
        // 'Evaluate' converts these correctly
        Evaluate(NewDateTime, PropertyValue);
        exit(NewDateTime);
    end;

    procedure ConvertToInteger(PropertyValue: Text): Integer
    var
        NewInteger: Integer;
    begin
        if Evaluate(NewInteger, PropertyValue) then
            exit(NewInteger);
    end;

    procedure ConvertToBoolean(PropertyValue: Text): Boolean
    var
        NewBoolean: Boolean;
    begin
        if Evaluate(NewBoolean, PropertyValue) then
            exit(NewBoolean);
    end;

    procedure GetNewLineCharacter(): Text
    var
        LF: Char;
    begin
        LF := 10;
        exit(Format(LF));
    end;

    procedure GetIso8601DateTime(MyDateTime: DateTime): Text
    begin
        exit(FormatDateTime(MyDateTime, 's')); // https://docs.microsoft.com/en-us/dotnet/standard/base-types/standard-date-and-time-format-strings
    end;

    procedure GetRfc1123DateTime(MyDateTime: DateTime): Text
    begin
        exit(FormatDateTime(MyDateTime, 'R')); // https://docs.microsoft.com/en-us/dotnet/standard/base-types/standard-date-and-time-format-strings
    end;

    local procedure FormatDateTime(MyDateTime: DateTime; FormatSpecifier: Text): Text
    var
        DateTimeAsXmlString: Text;
        DateTimeDotNet: DotNet DateTime;
    begin
        DateTimeAsXmlString := Format(MyDateTime, 0, 9); // Format as XML, e.g.: 2020-11-11T08:50:07.553Z
        exit(DateTimeDotNet.Parse(DateTimeAsXmlString).ToUniversalTime().ToString(FormatSpecifier));
    end;
}