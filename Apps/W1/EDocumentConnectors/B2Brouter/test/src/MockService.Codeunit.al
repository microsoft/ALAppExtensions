// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.B2BRouter;

codeunit 50100 "Mock Service"
{
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"B2Brouter Api Management", OnBeforeCreateHttpRequest, '', false, false)]
    local procedure "ApiManagement_OnBeforeCreateHttpRequest"(var Url: Text; var Method: Text)
    var
        Regex: Codeunit System.Utilities.Regex;
        NewUrl: Text;
    begin
        case true of
            Regex.IsMatch(Url, 'https?://.+/projects/.*/invoices/import\.json'):
                NewUrl := ImportUrl;

            Regex.IsMatch(Url, 'https?://.+/invoices/[0-9]+\.json$'):
                NewUrl := GetDocumentUrl;

            Regex.IsMatch(Url, 'https?://.+/invoices/[0-9]+/as/'):
                NewUrl := DownloadDocumentURl;

            Regex.IsMatch(Url, 'https?://.+/projects/.*/received\.json$'):
                NewUrl := ReceiveUrl;

            Regex.IsMatch(Url, 'https?://.+/invoices/send_invoice/[0-9]+\.json$'):
                NewUrl := SendUrl;

            Regex.IsMatch(Url, 'https?://.+/invoices/[0-9]+/ack\.json$'):
                NewUrl := FetchUrl;
        end;

        if NewUrl <> '' then
            Url := NewUrl;
    end;

    internal procedure SetImportUrl(NewUrl: Text)
    begin
        ImportUrl := NewUrl;
    end;

    internal procedure SetGetDocumentUrl(NewUrl: Text)
    begin
        GetDocumentUrl := NewUrl;
    end;

    internal procedure SetDownloadDocumentUrl(NewUrl: Text)
    begin
        DownloadDocumentURl := NewUrl;
    end;

    internal procedure SetReceiveUrl(NewUrl: Text)
    begin
        ReceiveUrl := NewUrl;
    end;

    internal procedure SetSendUrl(NewUrl: Text)
    begin
        SendUrl := NewUrl;
    end;

    internal procedure SetFetchUrl(NewUrl: Text)
    begin
        FetchUrl := NewUrl;
    end;

    var
        ImportUrl: Text;
        GetDocumentUrl: Text;
        DownloadDocumentURl: Text;
        ReceiveUrl: Text;
        SendUrl: Text;
        FetchUrl: Text;

}