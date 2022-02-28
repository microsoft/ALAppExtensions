// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes methods to create different kinds of authorizations for HTTP Request made to Azure Storage Services.
/// </summary>
codeunit 9062 "Storage Service Authorization"
{
    Access = Public;

    /// <summary>
    /// Creates an account SAS (Shared Access Signature) for authorizing HTTP request to Azure Storage Services.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/create-account-sas
    /// </summary>
    /// <param name="SigningKey">The signing key to use.</param>
    /// <param name="SignedVersion">Specifies the signed storage service version to use to authorize requests made with this account SAS. Must be set to version 2015-04-05 or later.</param>
    /// <param name="SignedServices">Specifies the signed services accessible with the account SAS.</param>
    /// <param name="SignedPermissions">Specifies the signed permissions for the account SAS. Permissions are only valid if they match the specified signed resource type; otherwise they are ignored.</param>
    /// <param name="SignedExpiry">The time at which the shared access signature becomes invalid.</param>
    /// <returns>An account SAS authorization.</returns>
    [NonDebuggable]
    procedure CreateAccountSAS(SigningKey: Text; SignedVersion: Enum "Storage Service API Version"; SignedServices: List of [Enum "SAS Service Type"]; SignedResources: List of [Enum "SAS Resource Type"]; SignedPermissions: List of [Enum "SAS Permission"]; SignedExpiry: DateTime): Interface "Storage Service Authorization"
    var
        StorServAuthImpl: Codeunit "Stor. Serv. Auth. Impl.";
    begin
        exit(StorServAuthImpl.CreateSAS(SigningKey, SignedVersion, SignedServices, SignedResources, SignedPermissions, SignedExpiry));
    end;

    /// <summary>
    /// Creates an account SAS (Shared Access Signature) for authorizing HTTP request to Azure Storage Services.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/create-account-sas
    /// </summary>
    /// <param name="SigningKey">The signing key to use.</param>
    /// <param name="SignedVersion">Specifies the signed storage service version to use to authorize requests made with this account SAS. Must be set to version 2015-04-05 or later.</param>
    /// <param name="SignedServices">Specifies the signed services accessible with the account SAS.</param>
    /// <param name="SignedPermissions">Specifies the signed permissions for the account SAS. Permissions are only valid if they match the specified signed resource type; otherwise they are ignored.</param>
    /// <param name="SignedExpiry">The time at which the shared access signature becomes invalid.</param>
    /// <param name="OptionalParams">See table "Stor. Serv. SAS Parameters".</param>
    /// <returns>An account SAS authorization.</returns>
    [NonDebuggable]
    procedure CreateAccountSAS(SigningKey: Text; SignedVersion: Enum "Storage Service API Version"; SignedServices: List of [Enum "SAS Service Type"];
                                                                    SignedResources: List of [Enum "SAS Resource Type"];
                                                                    SignedPermissions: List of [Enum "SAS Permission"];
                                                                    SignedExpiry: DateTime;
                                                                    OptionalSASParameters: Record "SAS Parameters"): Interface "Storage Service Authorization"
    var
        StorServAuthImpl: Codeunit "Stor. Serv. Auth. Impl.";
    begin
        exit(StorServAuthImpl.CreateSAS(SigningKey, SignedVersion, SignedServices, SignedResources, SignedPermissions, SignedExpiry, OptionalSASParameters));
    end;

    /// <summary>
    /// Creates a Shared Key authorization mechanism for HTTP requests to Azure Storage Services.
    /// See: https://docs.microsoft.com/en-us/rest/api/storageservices/authorize-with-shared-key
    /// </summary>
    /// <param name="SharedKey">The shared key to use.</param>
    /// <returns>A Shared Key authorization.</returns>
    [NonDebuggable]
    procedure CreateSharedKey(SharedKey: Text): Interface "Storage Service Authorization"
    var
        StorServAuthImpl: Codeunit "Stor. Serv. Auth. Impl.";
    begin
        exit(StorServAuthImpl.SharedKey(SharedKey, GetDefaultAPIVersion()));
    end;

    /// <summary>
    /// Creates a Shared Key authorization mechanism for HTTP requests to Azure Storage Services.
    /// See: https://docs.microsoft.com/en-us/rest/api/storageservices/authorize-with-shared-key
    /// </summary>
    /// <param name="SharedKey">The shared key to use.</param>
    /// <param name="ApiVersion">The API version to use.</param>
    /// <returns>A Shared Key authorization.</returns>
    [NonDebuggable]
    procedure CreateSharedKey(SharedKey: Text; ApiVersion: Enum "Storage Service API Version"): Interface "Storage Service Authorization"
    var
        StorServAuthImpl: Codeunit "Stor. Serv. Auth. Impl.";
    begin
        exit(StorServAuthImpl.SharedKey(SharedKey, ApiVersion));
    end;

    /// <summary>
    /// Get the default Storage Service API Version.
    /// </summary>
    /// <returns>The default Storage Service API Version</returns>
    procedure GetDefaultAPIVersion(): Enum "Storage Service API Version"
    var
        StorServAuthImpl: Codeunit "Stor. Serv. Auth. Impl.";
    begin
        exit(StorServAuthImpl.GetDefaultAPIVersion());
    end;
}
