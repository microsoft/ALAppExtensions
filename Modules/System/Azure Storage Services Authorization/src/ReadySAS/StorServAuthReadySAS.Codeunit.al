// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Azure.Storage;

using System.Utilities;

codeunit 9088 "Stor. Serv. Auth. Ready SAS" implements "Storage Service Authorization"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [NonDebuggable]
    procedure Authorize(var HttpRequestMessage: HttpRequestMessage; StorageAccount: Text)
    var
        Uri: Codeunit Uri;
        UriBuilder: Codeunit "Uri Builder";
        UriText, QueryText : Text;
    begin
        UriText := HttpRequestMessage.GetRequestUri();

        UriBuilder.Init(UriText);
        QueryText := UriBuilder.GetQuery();

        QueryText := DelChr(QueryText, '<', '?'); // remove ? from the query

        if QueryText <> '' then
            QueryText += '&';
        QueryText += GetSharedAccessSignature();
        UriBuilder.SetQuery(QueryText);

        UriBuilder.GetUri(Uri);

        HttpRequestMessage.SetRequestUri(Uri.GetAbsoluteUri());
    end;

    [NonDebuggable]
    procedure GetSharedAccessSignature(): Text
    begin
        exit(SharedAccessSignature);
    end;

    [NonDebuggable]
    procedure SetSharedAccessSignature(NewSharedAccessSignature: Text)
    begin
        SharedAccessSignature := NewSharedAccessSignature;
        if SharedAccessSignature.StartsWith('?') then
            SharedAccessSignature := DelChr(SharedAccessSignature, '<', '?');
    end;

    var
        SharedAccessSignature: Text;
}