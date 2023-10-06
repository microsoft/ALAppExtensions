// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8952 "AFS Operation Payload"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        [NonDebuggable]
        ContentHeaders: Dictionary of [Text, Text];
        [NonDebuggable]
        RequestHeaders: Dictionary of [Text, Text];
        [NonDebuggable]
        UriParameters: Dictionary of [Text, Text];

        Authorization: Interface "Storage Service Authorization";
        ApiVersion: Enum "Storage Service API Version";
        [NonDebuggable]
        StorageBaseUrl: Text;
        [NonDebuggable]
        StorageAccountName: Text;
        [NonDebuggable]
        FileShareName: Text;
        [NonDebuggable]
        Path: Text;

        AFSOperation: Enum "AFS Operation";

    procedure GetAuthorization(): Interface "Storage Service Authorization"
    begin
        exit(Authorization);
    end;

    procedure SetAuthorization(StorageServiceAuthorization: Interface "Storage Service Authorization")
    begin
        Authorization := StorageServiceAuthorization;
    end;

    [NonDebuggable]
    procedure SetOperation(NewOperation: Enum "AFS Operation")
    begin
        AFSOperation := NewOperation;

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

    [NonDebuggable]
    procedure GetStorageAccountName(): Text
    begin
        exit(StorageAccountName);
    end;

    [NonDebuggable]
    procedure SetStorageAccountName(StorageAccount: Text);
    begin
        StorageAccountName := StorageAccount;
    end;

    [NonDebuggable]
    procedure GetFileShareName(): Text
    begin
        exit(FileShareName);
    end;

    [NonDebuggable]
    procedure SetFileShareName(FileShare: Text);
    begin
        FileShareName := FileShare;
    end;

    [NonDebuggable]
    procedure GetPath(): Text
    begin
        exit(Path);
    end;

    [NonDebuggable]
    procedure SetPath(NewPath: Text);
    begin
        Path := NewPath;
    end;

    [NonDebuggable]
    procedure SetBaseUrl(BaseUrl: Text)
    begin
        StorageBaseUrl := BaseUrl;
    end;

    procedure GetOperation(): Enum "AFS Operation"
    begin
        exit(AFSOperation);
    end;

    [NonDebuggable]
    procedure GetRequestHeaders(): Dictionary of [Text, Text]
    begin
        exit(RequestHeaders);
    end;

    [NonDebuggable]
    procedure GetContentHeaders(): Dictionary of [Text, Text]
    begin
        exit(ContentHeaders);
    end;

    [NonDebuggable]
    procedure Initialize(StorageAccount: Text; FileShare: Text; PathText: Text; StorageServiceAuthorization: Interface "Storage Service Authorization"; StorageServiceAPIVersion: Enum "Storage Service API Version")
    begin
        StorageAccountName := StorageAccount;
        ApiVersion := StorageServiceAPIVersion;
        Authorization := StorageServiceAuthorization;
        FileShareName := FileShare;
        Path := PathText;

        Clear(StorageBaseUrl);
        Clear(UriParameters);
        Clear(RequestHeaders);
        Clear(ContentHeaders);
        Clear(AFSOperation);
    end;

    /// <summary>
    /// Creates the Uri for this object, based on given values
    /// </summary>
    /// <returns>An Uri (as Text) for this API Operation</returns>
    [NonDebuggable]
    internal procedure ConstructUri(): Text
    var
        AFSURIHelper: Codeunit "AFS URI Helper";
    begin
        AFSURIHelper.SetOptionalUriParameter(UriParameters);
        exit(AFSURIHelper.ConstructUri(StorageBaseUrl, StorageAccountName, FileShareName, Path, AFSOperation));
    end;

    [NonDebuggable]
    procedure AddRequestHeader(HeaderKey: Text; HeaderValue: Text)
    begin
        if RequestHeaders.Remove(HeaderKey) then;
        RequestHeaders.Add(HeaderKey, HeaderValue);
    end;

    [NonDebuggable]
    procedure AddContentHeader(HeaderKey: Text; HeaderValue: Text)
    begin
        if ContentHeaders.Remove(HeaderKey) then;
        ContentHeaders.Add(HeaderKey, HeaderValue);
    end;

    [NonDebuggable]
    procedure AddUriParameter(ParameterKey: Text; ParameterValue: Text)
    begin
        UriParameters.Remove(ParameterKey);
        UriParameters.Add(ParameterKey, ParameterValue);
    end;

    [NonDebuggable]
    procedure SetOptionalParameters(AFSOptionalParameters: Codeunit "AFS Optional Parameters")
    var
        Optionals: Dictionary of [Text, Text];
        OptionalParameterKey: Text;
    begin
        // Add request headers
        Optionals := AFSOptionalParameters.GetRequestHeaders();
        foreach OptionalParameterKey in Optionals.Keys() do
            AddRequestHeader(OptionalParameterKey, Optionals.Get(OptionalParameterKey));

        // Add URI parameters
        Optionals := AFSOptionalParameters.GetParameters();
        foreach OptionalParameterKey in Optionals.Keys() do
            AddUriParameter(OptionalParameterKey, Optionals.Get(OptionalParameterKey));
    end;
}