// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1462 "Xml DotNet Convert"
{
    Access = Internal;

    [TryFunction]
    procedure ToDotNet(InputXmlDocument: XmlDocument; var OutputXmlDocument: DotNet XmlDocument)
    begin
        ToDotNet(InputXmlDocument, OutputXmlDocument, false);
    end;

    [TryFunction]
    procedure ToDotNet(InputXmlDocument: XmlDocument; var OutputXmlDocument: DotNet XmlDocument; PreserveWhitespace: Boolean)
    var
        XmlWriteOptions: XmlWriteOptions;
        Xml: Text;
    begin
        XmlWriteOptions.PreserveWhitespace := PreserveWhitespace;
        InputXmlDocument.WriteTo(XmlWriteOptions, Xml);
        OutputXmlDocument := OutputXmlDocument.XmlDocument();
        OutputXmlDocument.PreserveWhitespace := PreserveWhitespace;
        OutputXmlDocument.LoadXml(Xml);
    end;

    [TryFunction]
    procedure ToDotNet(InputXmlElement: XmlElement; var OutputXmlElement: DotNet XmlElement)
    begin
        ToDotNet(InputXmlElement, OutputXmlElement, false);
    end;

    [TryFunction]
    procedure ToDotNet(InputXmlElement: XmlElement; var OutputXmlElement: DotNet XmlElement; PreserveWhitespace: Boolean)
    var
        OutputXmlDocument: DotNet XmlDocument;
        XmlWriteOptions: XmlWriteOptions;
        Xml: Text;
    begin
        XmlWriteOptions.PreserveWhitespace := PreserveWhitespace;
        InputXmlElement.WriteTo(XmlWriteOptions, Xml);
        OutputXmlDocument := OutputXmlDocument.XmlDocument();
        OutputXmlDocument.PreserveWhitespace := PreserveWhitespace;
        OutputXmlDocument.LoadXml(Xml);
        OutputXmlElement := OutputXmlDocument.FirstChild();
    end;

    [TryFunction]
    procedure FromDotNet(InputXmlDocument: DotNet XmlDocument; var OutputXmlDocument: XmlDocument)
    begin
        FromDotNet(InputXmlDocument, OutputXmlDocument, false);
    end;

    [TryFunction]
    procedure FromDotNet(InputXmlDocument: DotNet XmlDocument; var OutputXmlDocument: XmlDocument; PreserveWhitespace: Boolean)
    var
        XmlReadOptions: XmlReadOptions;
    begin
        InputXmlDocument.PreserveWhitespace := PreserveWhitespace;
        XmlReadOptions.PreserveWhitespace := PreserveWhitespace;
        XmlDocument.ReadFrom(InputXmlDocument.InnerXml(), XmlReadOptions, OutputXmlDocument);
    end;

    [TryFunction]
    procedure FromDotNet(InputXmlElement: DotNet XmlElement; var OutputXmlElement: XmlElement)
    begin
        FromDotNet(InputXmlElement, OutputXmlElement, false);
    end;

    [TryFunction]
    procedure FromDotNet(InputXmlElement: DotNet XmlElement; var OutputXmlElement: XmlElement; PreserveWhitespace: Boolean)
    var
        OutputXmlDocument: XmlDocument;
        XmlReadOptions: XmlReadOptions;
    begin
        InputXmlElement.OwnerDocument().PreserveWhitespace := PreserveWhitespace;
        XmlReadOptions.PreserveWhitespace := PreserveWhitespace;
        XmlDocument.ReadFrom(InputXmlElement.OuterXml(), XmlReadOptions, OutputXmlDocument);
        OutputXmlDocument.GetRoot(OutputXmlElement);
    end;
}