// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.RestClient;

codeunit 31175 "EPO API Submission CZL"
{
    Access = Internal;

    var
        HttpResponseMessage: Codeunit "Http Response Message";
        FormUrl: Text;
        BaseUrlTok: Label 'https://adisspr.mfcr.cz/dpr/', Locked = true;
        SubmitUriTok: Label 'epo_podani?otevriFormular=1', Locked = true;
        UrlXPathTok: Label 'URL', Locked = true;

    [TryFunction]
    procedure TrySend(Content: XmlDocument)
    var
        HttpContent: Codeunit "Http Content";
        RestClient: Codeunit "Rest Client";
        ResponseXmlDocument: XmlDocument;
        UrlXmlNode: XmlNode;
    begin
        HttpContent := HttpContent.Create(Content);
        RestClient.Initialize();
        RestClient.SetBaseAddress(BaseUrlTok);
        HttpResponseMessage := RestClient.Post(SubmitUriTok, HttpContent);
        if not HttpResponseMessage.GetIsSuccessStatusCode() then
            Error(HttpResponseMessage.GetErrorMessage());

        ResponseXmlDocument := HttpResponseMessage.GetContent().AsXmlDocument();
        ResponseXmlDocument.SelectSingleNode(UrlXPathTok, UrlXmlNode);
        FormUrl := UrlXmlNode.AsXmlElement().InnerText;
    end;

    procedure GetFormUrl(): Text
    begin
        exit(FormUrl);
    end;

    procedure GetHttpResonse(): Codeunit "Http Response Message"
    begin
        exit(HttpResponseMessage);
    end;
}