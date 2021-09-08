// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1462 "Xml DotNet Convert"
{
    Access = Internal;

    [TryFunction]
    procedure ToDotNet(InputXmlDocument: XmlDocument; var OutputXmlDocument: DotNet XmlDocument)
    var
        XmlWriteOptions: XmlWriteOptions;
        Xml: Text;
    begin
        XmlWriteOptions.PreserveWhitespace := true;
        InputXmlDocument.WriteTo(XmlWriteOptions, Xml);
        OutputXmlDocument := OutputXmlDocument.XmlDocument();
        OutputXmlDocument.PreserveWhitespace := true;
        OutputXmlDocument.LoadXml(Xml);
    end;

    [TryFunction]
    procedure ToDotNet(InputXmlElement: XmlElement; var OutputXmlElement: DotNet XmlElement)
    var
        OutputXmlDocument: DotNet XmlDocument;
        XmlWriteOptions: XmlWriteOptions;
        Xml: Text;
    begin
        XmlWriteOptions.PreserveWhitespace := true;
        InputXmlElement.WriteTo(XmlWriteOptions, Xml);
        OutputXmlDocument := OutputXmlDocument.XmlDocument();
        OutputXmlDocument.PreserveWhitespace := true;
        OutputXmlDocument.LoadXml(Xml);
        OutputXmlElement := OutputXmlDocument.FirstChild();
    end;


    [TryFunction]
    procedure FromDotNet(InputXmlDocument: DotNet XmlDocument; var OutputXmlDocument: XmlDocument)
    begin
        XmlDocument.ReadFrom(InputXmlDocument.InnerXml(), OutputXmlDocument);
    end;

    [TryFunction]
    procedure FromDotNet(InputXmlElement: DotNet XmlElement; var OutputXmlElement: XmlElement)
    var
        OutputXmlDocument: XmlDocument;
    begin
        XmlDocument.ReadFrom(InputXmlElement.OuterXml(), OutputXmlDocument);
        OutputXmlDocument.GetRoot(OutputXmlElement);
    end;
}