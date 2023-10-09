// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to query Microsoft Graph Api
/// </summary>
codeunit 9130 "Microsoft Graph Client"
{
    Access = Public;

    var
        [NonDebuggable]
        MicrosoftGraphClientImpl: Codeunit "Microsoft Graph Client Impl.";

    /// <summary>
    /// Initializes Microsoft Graph client.
    /// </summary>
    /// <param name="ApiVersion">API Version to use.</param>
    /// <param name="Authorization">The authorization to use.</param>
    procedure Initialize(MicrosoftGraphAPIVersion: Enum "Microsoft Graph API Version"; MicrosoftGraphAuthorization: Interface "Microsoft Graph Authorization")
    begin
        MicrosoftGraphClientImpl.Initialize(MicrosoftGraphAPIVersion, MicrosoftGraphAuthorization);
    end;

    /// <summary>
    /// Returns detailed information on last API call.
    /// </summary>
    /// <returns>Codeunit holding http resonse status, reason phrase, headers and possible error information for tha last API call</returns>
    procedure GetDiagnostics(): Interface "HTTP Diagnostics"
    begin
        exit(MicrosoftGraphClientImpl.GetDiagnostics());
    end;


    /// <summary>
    /// Get any request to the microsoft graph API
    /// </summary>
    /// <param name="RelativeUriToResource">A relativ uri including the resource segment and query parameters</param>
    /// <param name="FileInStream">The InStream that will be populated with the file content.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure Get(RelativeUriToResource: Text; var FileInStream: InStream): Boolean
    begin
        exit(MicrosoftGraphClientImpl.Get(RelativeUriToResource, FileInStream));
    end;

    /// <summary>
    /// Send a DELETE request to the microsoft graph API
    /// </summary>
    /// <param name="RelativeUriToResource">A relativ uri to the resource - e.g. /users/{id|userPrincipalName}.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure Delete(RelativeUriToResource: Text): Boolean
    begin
        exit(MicrosoftGraphClientImpl.Delete(RelativeUriToResource));
    end;
}