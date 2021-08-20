// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9042 "ABS Operation Payload"
{
    Access = Internal;

    var
        ContentHeaders, RequestHeaders, UriParameters : Dictionary of [Text, Text];

        Authorization: Interface "Storage Service Authorization";
        ApiVersion: Enum "Storage Service API Version";
        StorageBaseUrl, StorageAccountName, ContainerName, BlobName : Text;
        Operation: Enum "ABS Operation";

    procedure GetAuthorization(): Interface "Storage Service Authorization"
    begin
        exit(Authorization);
    end;

    procedure SetAuthorization(StorageServiceAuthorization: Interface "Storage Service Authorization")
    begin
        Authorization := StorageServiceAuthorization;
    end;

    procedure SetOperation(NewOperation: Enum "ABS Operation")
    begin
        Operation := NewOperation;

        // Clear state
        Clear(ContentHeaders);
        Clear(RequestHeaders);
        Clear(UriParameters);
    end;

    procedure GetApiVersion(): Enum "Storage Service API Version"
    begin
        exit(ApiVersion);
    end;

    procedure SetApiVersion(StorageServiceApiVersion: Enum "Storage Service API Version");
    begin
        ApiVersion := StorageServiceApiVersion;
    end;

    procedure GetStorageAccountName(): Text
    begin
        exit(StorageAccountName);
    end;

    procedure SetStorageAccountName(StorageAccount: Text);
    begin
        StorageAccountName := StorageAccount;
    end;

    procedure GetContainerName(): Text
    begin
        exit(ContainerName);
    end;

    procedure SetContainerName(Container: Text);
    begin
        ContainerName := Container;
    end;

    procedure GetBlobName(): Text
    begin
        exit(BlobName);
    end;

    procedure SetBlobName("Blob": Text);
    begin
        BlobName := "Blob";
    end;

    procedure SetBaseUrl(BaseUrl: Text)
    begin
        StorageBaseUrl := BaseUrl;
    end;

    procedure GetOperation(): Enum "ABS Operation"
    begin
        exit(Operation);
    end;

    procedure GetRequestHeaders(): Dictionary of [Text, Text]
    begin
        SortHeaders(RequestHeaders);

        exit(RequestHeaders);
    end;

    procedure GetContentHeaders(): Dictionary of [Text, Text]
    begin
        SortHeaders(ContentHeaders);

        exit(ContentHeaders);
    end;

    procedure Initialize(StorageAccount: Text; Container: Text; BlobName: Text; StorageServiceAuthorization: Interface "Storage Service Authorization"; StorageServiceAPIVersion: Enum "Storage Service API Version")
    begin
        StorageAccountName := StorageAccount;
        ApiVersion := StorageServiceAPIVersion;
        Authorization := StorageServiceAuthorization;
        ContainerName := Container;
        BlobName := BlobName;

        Clear(StorageBaseUrl);
        Clear(UriParameters);
        Clear(RequestHeaders);
        Clear(ContentHeaders);
    end;

    /// <summary>
    /// Creates the Uri for this object, based on given values
    /// </summary>
    /// <returns>An Uri (as Text) for this API Operation</returns>
    internal procedure ConstructUri(): Text
    var
        URIHelper: Codeunit "ABS URI Helper";
    begin
        URIHelper.SetOptionalUriParameter(UriParameters);
        exit(URIHelper.ConstructUri(StorageBaseUrl, StorageAccountName, ContainerName, BlobName, Operation));
    end;

    local procedure SortHeaders(var Headers: Dictionary of [Text, Text])
    var
        SortedDictionary: DotNet GenericSortedDictionary2;
        SortedDictionaryEntry: DotNet GenericKeyValuePair2;
        HeaderKey: Text;
    begin
        SortedDictionary := SortedDictionary.SortedDictionary();

        foreach HeaderKey in Headers.Keys() do
            SortedDictionary.Add(HeaderKey, Headers.Get(HeaderKey));

        Clear(Headers);

        foreach SortedDictionaryEntry in SortedDictionary do
            Headers.Add(SortedDictionaryEntry."Key"(), SortedDictionaryEntry.Value());
    end;

    procedure AddRequestHeader(HeaderKey: Text; HeaderValue: Text)
    begin
        if RequestHeaders.Remove(HeaderKey) then;
        RequestHeaders.Add(HeaderKey, HeaderValue);
    end;

    procedure AddContentHeader(HeaderKey: Text; HeaderValue: Text)
    begin
        if ContentHeaders.Remove(HeaderKey) then;
        ContentHeaders.Add(HeaderKey, HeaderValue);
    end;

    procedure AddUriParameter(ParameterKey: Text; ParameterValue: Text)
    begin
        UriParameters.Remove(ParameterKey);
        UriParameters.Add(ParameterKey, ParameterValue);
    end;

    procedure SetOptionalParameters(OptionalParameters: Codeunit "ABS Optional Parameters")
    var
        Optionals: Dictionary of [Text, Text];
        OptionalParameterKey: Text;
    begin
        // TODO Consider filtering out parameters and header based on the operation

        // Add request headers
        Optionals := OptionalParameters.GetRequestHeaders();
        foreach OptionalParameterKey in Optionals.Keys() do
            AddRequestHeader(OptionalParameterKey, Optionals.Get(OptionalParameterKey));

        // Add URI parameters
        Optionals := OptionalParameters.GetParameters();
        foreach OptionalParameterKey in Optionals.Keys() do
            AddUriParameter(OptionalParameterKey, Optionals.Get(OptionalParameterKey));
    end;
}