// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to query Microsoft Graph Api
/// </summary>
codeunit 9150 "Microsoft Graph Client"
{
    Access = Public;

    var
        [NonDebuggable]
        MicrosoftGraphClientImpl: Codeunit "Microsoft Graph Client Impl.";
        IHttpClient: Interface IHttpClient;
        HttpClientSet: Boolean;

    /// <summary>
    /// Initializes Microsoft Graph client.
    /// </summary>
    /// <param name="ApiVersion">API Version to use.</param>
    /// <param name="Authorization">The authorization to use.</param>
    procedure Initialize(MicrosoftGraphAPIVersion: Enum "Microsoft Graph API Version"; MicrosoftGraphAuthorization: Interface "Microsoft Graph Authorization")
    var
        HttpClient: Codeunit HttpClient;
    begin
        if not HttpClientSet then
            IHttpClient := HttpClient;
        MicrosoftGraphClientImpl.Initialize(MicrosoftGraphAPIVersion, MicrosoftGraphAuthorization, IHttpClient);
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
    /// <param name="RelativeUriToResource">A relativ uri including the resource segments</param>
    /// <param name="ResponseInStream">The InStream that will be populated with the file content.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure Get(RelativeUriToResource: Text; var ResponseInStream: InStream): Boolean
    begin
        exit(MicrosoftGraphClientImpl.Get(RelativeUriToResource, ResponseInStream));
    end;

    /// <summary>
    /// Get any request to the microsoft graph API
    /// </summary>
    /// <param name="RelativeUriToResource">A relativ uri including the resource segment</param>
    /// <param name="MgOptionalParameters">A wrapper for optional header and query parameters</param>
    /// <param name="ResponseInStream">The InStream that will be populated with the file content.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure Get(RelativeUriToResource: Text; MgOptionalParameters: Codeunit "Mg Optional Parameters"; var ResponseInStream: InStream): Boolean
    begin
        exit(MicrosoftGraphClientImpl.Get(RelativeUriToResource, MgOptionalParameters, ResponseInStream));
    end;

    /// <summary>
    /// Post any request to the microsoft graph API
    /// </summary>
    /// <param name="RelativeUriToResource">A relativ uri including the resource segment</param>
    /// <param name="MgOptionalParameters">A wrapper for optional header and query parameters</param>
    /// <param name="RequestContentInStream">The InStream that will be populated with the response message content.</param>
    /// <param name="ResponseInStream">The InStream that will be populated with the response message content.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    procedure Post(RelativeUriToResource: Text; MgOptionalParameters: Codeunit "Mg Optional Parameters"; var RequestContentInStream: InStream; var ResponseInStream: InStream): Boolean
    begin
        exit(MicrosoftGraphClientImpl.Post(RelativeUriToResource, MgOptionalParameters, RequestContentInStream, ResponseInStream));
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

    /// <summary>
    /// Set a custom implementation of the HttpClient to mock the web communication in a test.
    /// </summary>
    /// <param name="NewHttpClient"></param>
    internal procedure SetHttpClient(NewHttpClient: Interface IHttpClient)
    begin
        IHttpClient := NewHttpClient;
        HttpClientSet := true;
    end;
}