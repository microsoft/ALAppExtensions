// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 3801 "App Key Vault Secret Pr. Impl."
{
    Access = Internal;

    var
        [NonDebuggable]
        NavAzureKeyVaultAppSecretProvider: dotnet AzureKeyVaultAppSecretProvider;
        IsInitialized: Boolean;
        CannotInitializeErr: Label 'Couldn''t initialize the App Key Vault Secret Provider.\\Common reasons include:\- The extension doesn''t specify a key vault in its app.json file.\- The extension wasn''t published with a PublisherAzureActiveDirectoryTenantId and the server requires it\- The server''s Azure Key Vault settings are incorrect\- The server lacks permission to the private key of Azure Key Vault client certificate\\Please check the Event Log or Application Insights for more details.';
        NotInitializedErr: Label 'Cannot get secrets because the App Key Vault Secret Provider has not been initialized.';

    [NonDebuggable]
    procedure InitializeFromCurrentApp()
    var
        InitializeErrorInfo: ErrorInfo;
    begin
        // Initialize the .NET object
        if InitializeFromCurrentAppInternal() then
            IsInitialized := true
        else begin
            InitializeErrorInfo.DataClassification := DataClassification::SystemMetadata;
            InitializeErrorInfo.ErrorType := ErrorType::Client;
            InitializeErrorInfo.Verbosity := Verbosity::Error;
            InitializeErrorInfo.Message := CannotInitializeErr;
            Error(InitializeErrorInfo);
        end;
    end;

    [TryFunction]
    [NonDebuggable]
    procedure InitializeFromCurrentAppInternal()
    begin
        // Initialize the .NET helper object.
        //   The InitializeFromCallingAppExceptSystemApplication method in the .NET code will identify the app that directly called it
        //   and will then initialize itself with the key vaults for that app.
        //
        //   If an app calls through the System app, such as through this very codeunit, the InitializeFromCallingAppExceptSystemApplication
        //   method will choose that app rather than the System app. This will be the normal case.
        NavAzureKeyVaultAppSecretProvider := NavAzureKeyVaultAppSecretProvider.AzureKeyVaultAppSecretProvider();
        NavAzureKeyVaultAppSecretProvider.InitializeFromCallingAppExceptSystemApplication();
    end;

    [NonDebuggable]
    procedure GetSecret(SecretName: Text; var SecretValue: Text): Boolean
    var
        InitializeErrorInfo: ErrorInfo;
    begin
        if not IsInitialized then begin
            InitializeErrorInfo.DataClassification := DataClassification::SystemMetadata;
            InitializeErrorInfo.ErrorType := ErrorType::Client;
            InitializeErrorInfo.Verbosity := Verbosity::Error;
            InitializeErrorInfo.Message := NotInitializedErr;
            Error(InitializeErrorInfo);
        end;

        // The .NET class will catch all user errors, e.g., secret not found, key vault not found, no access to key vault.
        // It will return false in these cases, and set SecretValue=''.
        exit(NavAzureKeyVaultAppSecretProvider.TryGetAzureKeyVaultSecret(SecretName, SecretValue));
    end;
}
