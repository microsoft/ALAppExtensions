// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to handle the creation of a signature to sign requests to the Storage Services REST API
/// More Information: https://docs.microsoft.com/en-us/rest/api/storageservices/authorize-with-shared-key
/// </summary>
codeunit 9064 "Stor. Serv. Auth. Shared Key" implements "Storage Service Authorization"
{
    Access = Internal;

    procedure Authorize(var HttpRequest: HttpRequestMessage; StorageAccount: Text)
    var
        Headers: HttpHeaders;
    begin
        HttpRequest.GetHeaders(Headers);

        Headers.Remove('Authorization');
        Headers.Add('Authorization', GetSharedKeySignature(HttpRequest, StorageAccount));
    end;

    [NonDebuggable]
    procedure SetSharedKey(SharedKey: Text)
    begin
        Secret := SharedKey;
    end;

    procedure SetApiVersion(NewApiVersion: Enum "Storage service API Version")
    begin
        ApiVersion := NewApiVersion;
    end;

    [NonDebuggable]
    local procedure GetSharedKeySignature(HttpRequestMessage: HttpRequestMessage; StorageAccount: Text): Text
    var
        StringToSign: Text;
        Signature: Text;
        SignaturePlaceHolderLbl: Label 'SharedKey %1:%2', Comment = '%1 = Account Name; %2 = Calculated Signature', Locked = true;
        SecretCanNotBeEmptyErr: Label 'Secret (Access Key) must be provided';
    begin
        if Secret = '' then
            Error(SecretCanNotBeEmptyErr);

        StringToSign := CreateSharedKeyStringToSign(HttpRequestMessage, StorageAccount);
        Signature := AuthFormatHelper.GetAccessKeyHashCode(StringToSign, Secret);
        exit(StrSubstNo(SignaturePlaceHolderLbl, StorageAccount, Signature));
    end;

    local procedure CreateSharedKeyStringToSign(HttpRequestMessage: HttpRequestMessage; StorageAccount: Text): Text
    var
        RequestHeaders, ContentHeaders : HttpHeaders;
        StringToSign: Text;
    begin
        HttpRequestMessage.GetHeaders(RequestHeaders);
        if TryGetContentHeaders(HttpRequestMessage, ContentHeaders) then;

        StringToSign += HttpRequestMessage.Method() + NewLine();
        StringToSign += GetHeaderValueOrEmpty(ContentHeaders, 'Content-Encoding') + NewLine();
        StringToSign += GetHeaderValueOrEmpty(ContentHeaders, 'Content-Language') + NewLine();
        StringToSign += GetHeaderValueOrEmpty(ContentHeaders, 'Content-Length') + NewLine();
        StringToSign += GetHeaderValueOrEmpty(ContentHeaders, 'Content-MD5') + NewLine();
        StringToSign += GetHeaderValueOrEmpty(ContentHeaders, 'Content-Type') + NewLine();
        StringToSign += GetHeaderValueOrEmpty(RequestHeaders, 'Date') + NewLine();
        StringToSign += GetHeaderValueOrEmpty(RequestHeaders, 'If-Modified-Since') + NewLine();
        StringToSign += GetHeaderValueOrEmpty(RequestHeaders, 'If-Match') + NewLine();
        StringToSign += GetHeaderValueOrEmpty(RequestHeaders, 'If-None-Match') + NewLine();
        StringToSign += GetHeaderValueOrEmpty(RequestHeaders, 'If-Unmodified-Since') + NewLine();
        StringToSign += GetHeaderValueOrEmpty(RequestHeaders, 'Range') + NewLine();
        StringToSign += GetCanonicalizedHeaders(RequestHeaders) + NewLine();
        StringToSign += GetCanonicalizedResource(StorageAccount, HttpRequestMessage.GetRequestUri());

        exit(StringToSign);
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure TryGetContentHeaders(var HttpRequestMessage: HttpRequestMessage; var RequestHttpHeaders: HttpHeaders)
    begin
        HttpRequestMessage.Content.GetHeaders(RequestHttpHeaders);
    end;

    local procedure GetHeaderValueOrEmpty(Headers: HttpHeaders; HeaderKey: Text): Text
    var
        ReturnValue: array[1] of Text;
    begin
        if not Headers.GetValues(HeaderKey, ReturnValue) then
            exit('');

        if HeaderKey = 'Content-Length' then
            if ReturnValue[1] = '0' then
                exit('');

        exit(ReturnValue[1]);
    end;

    // see https://docs.microsoft.com/en-us/rest/api/storageservices/authorize-with-shared-key#constructing-the-canonicalized-headers-string
    local procedure GetCanonicalizedHeaders(Headers: HttpHeaders): Text
    var
        HeaderKey: Text;
        HeaderValue: array[1] of Text;
        CanonicalizedHeaders: Text;
        KeyValuePairLbl: Label '%1:%2', Comment = '%1 = Key; %2 = Value', Locked = true;
    begin
        foreach HeaderKey in Headers.Keys() do
            if HeaderKey.StartsWith('x-ms-') then
                if Headers.GetValues(HeaderKey, HeaderValue) then begin
                    if CanonicalizedHeaders <> '' then
                        CanonicalizedHeaders += NewLine();
                    CanonicalizedHeaders += StrSubstNo(KeyValuePairLbl, HeaderKey.ToLower(), HeaderValue[1])
                end;

        exit(CanonicalizedHeaders);
    end;

    local procedure GetCanonicalizedResource(StorageAccount: Text; UriString: Text): Text
    var
        Uri: Codeunit Uri;
        UriBuider: Codeunit "Uri Builder";
        SortedDictionaryQuery: DotNet GenericSortedDictionary2;
        SortedDictionaryEntry: DotNet GenericKeyValuePair2;
        QueryString: Text;
        Segments: List of [Text];
        Segment: Text;
        StringBuilderResource: TextBuilder;
        StringBuilderQuery: TextBuilder;
        StringBuilderCanonicalizedResource: TextBuilder;
        KeyValuePairLbl: Label '%1:%2', Comment = '%1 = Key; %2 = Value';
    begin
        Uri.Init(UriString);
        Uri.GetSegments(Segments);

        UriBuider.Init(UriString);
        QueryString := UriBuider.GetQuery();

        StringBuilderResource.Append('/');
        StringBuilderResource.Append(StorageAccount);
        foreach Segment in Segments do
            StringBuilderResource.Append(Segment);

        if QueryString <> '' then begin
            // According to documentation it should be lexicographically, but I didn't find a better way than SortedDictionary
            // see: https://docs.microsoft.com/en-us/rest/api/storageservices/authorize-with-shared-key#constructing-the-canonicalized-headers-string
            SplitQueryStringIntoSortedDictionary(QueryString, SortedDictionaryQuery);
            foreach SortedDictionaryEntry in SortedDictionaryQuery do begin
                StringBuilderQuery.Append(NewLine());
                StringBuilderQuery.Append(StrSubstNo(KeyValuePairLbl, SortedDictionaryEntry."Key", Uri.UnescapeDataString(SortedDictionaryEntry.Value)));
            end;
        end;
        StringBuilderCanonicalizedResource.Append(StringBuilderResource.ToText());
        StringBuilderCanonicalizedResource.Append(StringBuilderQuery.ToText());
        exit(StringBuilderCanonicalizedResource.ToText());
    end;

    local procedure SplitQueryStringIntoSortedDictionary(QueryString: Text; var NewSortedDictionary: DotNet GenericSortedDictionary2)
    var
        Segments: List of [Text];
        Segment: Text;
        CurrIdentifier: Text;
        CurrValue: Text;
    begin
        if QueryString.StartsWith('?') then
            QueryString := CopyStr(QueryString, 2);
        Segments := QueryString.Split('&');

        NewSortedDictionary := NewSortedDictionary.SortedDictionary();

        foreach Segment in Segments do
            if GetKeyValueFromQueryParameter(Segment, CurrIdentifier, CurrValue) then
                NewSortedDictionary.Add(CurrIdentifier, CurrValue);
    end;

    local procedure GetKeyValueFromQueryParameter(QueryString: Text; var CurrIdentifier: Text; var CurrValue: Text): Boolean
    var
        Split: List of [Text];
    begin
        Split := QueryString.Split('=');

        if Split.Count() <> 2 then
            exit(false); // This should not happen

        CurrIdentifier := Split.Get(1);
        CurrValue := Split.Get(2);

        exit(true);
    end;

    local procedure NewLine(): Text
    begin
        exit(AuthFormatHelper.NewLine());
    end;

    var
        AuthFormatHelper: Codeunit "Auth. Format Helper";
        ApiVersion: Enum "Storage service API Version";
        [NonDebuggable]
        Secret: Text;
}