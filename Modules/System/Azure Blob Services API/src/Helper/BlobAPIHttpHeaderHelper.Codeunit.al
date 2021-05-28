// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9048 "Blob API HttpHeader Helper"
{
    Access = Internal;

    procedure HandleHeaders(HttpRequestType: Enum "Http Request Type"; var Client: HttpClient; var OperationObject: Codeunit "Blob API Operation Object")
    var
        FormatHelper: Codeunit "Blob API Format Helper";
        UsedDateTimeText: Text;
        Headers: HttpHeaders;
        HeadersDictionary: Dictionary of [Text, Text];
        HeaderKey: Text;
        AuthType: Enum "Storage Service Authorization Type";
    begin
        Headers := Client.DefaultRequestHeaders;
        // Add to all requests >>
        UsedDateTimeText := FormatHelper.GetRfc1123DateTime();
        OperationObject.AddHeader('x-ms-date', UsedDateTimeText);
        OperationObject.AddHeader('x-ms-version', Format(OperationObject.GetApiVersion()));
        // Add to all requests <<
        HeadersDictionary := OperationObject.GetSortedHeadersDictionary();
        OperationObject.SetHeaderValues(HeadersDictionary);
        foreach HeaderKey in HeadersDictionary.Keys do
            if not IsContentHeader(HeaderKey) then
                OperationObject.AddHeader(Headers, HeaderKey, HeadersDictionary.Get(HeaderKey));
        case OperationObject.GetAuthorizationType() of
            AuthType::AccessKey:
                OperationObject.AddHeader(Headers, 'Authorization', OperationObject.GetSharedKeySignature(HttpRequestType));
        //AuthType::"AAD (Client Credentials)":
        //    OperationObject.AddHeader(Headers, 'Authorization', OperationObject.GetAADBearerToken(HttpRequestType));
        end;
    end;

    procedure HandleContentHeaders(var Content: HttpContent; var OperationObject: Codeunit "Blob API Operation Object"): Boolean
    var
        Headers: HttpHeaders;
        HeadersDictionary: Dictionary of [Text, Text];
        HeaderKey: Text;
        ContainsContentHeader: Boolean;
    begin
        Content.GetHeaders(Headers);
        HeadersDictionary := OperationObject.GetSortedHeadersDictionary();
        foreach HeaderKey in HeadersDictionary.Keys do
            if IsContentHeader(HeaderKey) then begin
                OperationObject.AddHeader(Headers, HeaderKey, HeadersDictionary.Get(HeaderKey));
                ContainsContentHeader := true;
            end;
        exit(ContainsContentHeader);
    end;

    local procedure IsContentHeader(HeaderKey: Text): Boolean
    begin
        if HeaderKey in ['Content-Type', 'Content-Length', 'x-ms-blob-content-length', 'x-ms-blob-type', 'Content-Language', 'x-ms-blob-content-language'] then // TODO: Check if these are all relevant headers
            exit(true);
        exit(false);
    end;
}