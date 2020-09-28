// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1484 "XmlWriter Impl"
{
    Access = Internal;

    procedure WriteStartDocument()
    begin
        StringBuilder := StringBuilder.StringBuilder();
        StringWriter := StringWriter.StringWriter(StringBuilder);
        XmlTextWriter := XmlTextWriter.XmlTextWriter(StringWriter);
        XmlTextWriter.WriteStartDocument();
    end;

    procedure WriteEndDocument()
    begin
        XmlTextWriter.WriteEndDocument();
    end;

    procedure ToBigText(var XmlBigText: BigText)
    begin
        XmlTextWriter.WriteString(XmlBigText);
    end;

    var
        StringBuilder: DotNet StringBuilder;
        StringWriter: DotNet StringWriter;
        XmlTextWriter: DotNet XmlTextWriter;
}