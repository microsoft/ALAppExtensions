/// <summary>Implementation of the "Http Authentication" interface for a request that requires basic authentication</summary>
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.RestClient;

using System;

codeunit 2359 "Http Authentication Basic" implements "Http Authentication"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        GlobalUsername: Text;
        GlobalPassword: SecretText;
        UsernameDomainTxt: Label '%1\%2', Locked = true;

    /// <summary>Initializes the authentication object with the given username and password</summary>
    /// <param name="Username">The username to use for authentication</param>
    /// <param name="Password">The password to use for authentication</param>
    procedure Initialize(Username: Text; Password: SecretText)
    begin
        Initialize(Username, '', Password);
    end;

    /// <summary>Initializes the authentication object with the given username, domain and password</summary>
    /// <param name="Username">The username to use for authentication</param>
    /// <param name="Domain">The domain to use for authentication</param>
    /// <param name="Password">The password to use for authentication</param>
    procedure Initialize(Username: Text; Domain: Text; Password: SecretText)
    begin
        if Domain = '' then
            GlobalUsername := Username
        else
            GlobalUsername := StrSubstNo(UsernameDomainTxt, Username, Domain);

        GlobalPassword := Password;
    end;

    /// <summary>Checks if authentication is required for the request</summary>
    /// <returns>Returns true because authentication is required</returns>
    procedure IsAuthenticationRequired(): Boolean;
    begin
        exit(true);
    end;

    /// <summary>Gets the authorization headers for the request</summary>
    /// <returns>Returns a dictionary of headers that need to be added to the request</returns>
    procedure GetAuthorizationHeaders() Header: Dictionary of [Text, SecretText];
    begin
        Header.Add('Authorization', SecretStrSubstNo('Basic %1', ToBase64(SecretStrSubstNo('%1:%2', GlobalUsername, GlobalPassword))));
    end;

    local procedure ToBase64(String: SecretText) Base64String: SecretText
    var
        Convert: DotNet Convert;
        Encoding: DotNet Encoding;
    begin
#pragma warning disable AL0796
        Base64String := Convert.ToBase64String(Encoding.UTF8().GetBytes(String.Unwrap()));
#pragma warning restore AL0796
    end;
}