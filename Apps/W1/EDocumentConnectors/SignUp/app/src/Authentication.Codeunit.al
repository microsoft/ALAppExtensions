// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

codeunit 6381 Authentication
{
    Access = Internal;

    var
        AuthenticationImpl: Codeunit AuthenticationImpl;

    /// <summary>
    /// The method initializes the connection setup.
    /// </summary>
    procedure InitConnectionSetup()
    begin
        this.AuthenticationImpl.InitConnectionSetup();
    end;

    /// <summary>
    /// The method returns the onboarding URL.
    /// </summary>
    /// <returns>Onboarding URL</returns>
    procedure GetRootOnboardingUrl(): Text
    begin
        exit(this.AuthenticationImpl.GetRootOnboardingUrl());
    end;

    /// <summary>
    /// The method creates the client credentials.
    /// </summary>
    [NonDebuggable]
    procedure CreateClientCredentials()
    begin
        this.AuthenticationImpl.CreateClientCredentials();
    end;

    /// <summary>
    /// The method returns the bearer authentication text.
    /// </summary>
    /// <returns>Bearer authentication token</returns>
    procedure GetBearerAuthToken(): SecretText;
    begin
        exit(this.AuthenticationImpl.GetBearerAuthToken());
    end;

    /// <summary>
    /// The method returns the root bearer authentication token.
    /// </summary>
    /// <returns>Root bearer authentication token</returns>
    procedure GetRootBearerAuthToken(): SecretText;
    begin
        exit(this.AuthenticationImpl.GetRootBearerAuthToken());
    end;

    /// <summary>
    /// The mehod saves the token to the storage.
    /// </summary>
    /// <param name="TokenKey">Token Key</param>
    /// <param name="Value">Token</param>
    [NonDebuggable]
    procedure StorageSet(var TokenKey: Guid; Value: Text)
    begin
        this.AuthenticationImpl.StorageSet(TokenKey, Value);
    end;

    /// <summary>
    /// The mehod saves the token to the storage.
    /// </summary>
    /// <param name="TokenKey">Token Key</param>
    /// <param name="Value">Token</param>
    [NonDebuggable]
    procedure StorageSet(var TokenKey: Guid; Value: SecretText)
    begin
        this.AuthenticationImpl.StorageSet(TokenKey, Value);
    end;

    /// <summary>
    /// The method returns BC instance identifier.
    /// </summary>
    /// <returns>Identifier</returns>
    procedure GetBCInstanceIdentifier() Identifier: Text
    begin
        exit(this.AuthenticationImpl.GetBCInstanceIdentifier());
    end;

    /// <summary>
    /// The method returns the root URL.
    /// </summary>
    /// <returns></returns>
    [NonDebuggable]
    procedure GetRootUrl() ReturnValue: Text
    begin
        exit(this.AuthenticationImpl.GetRootUrl());
    end;
}