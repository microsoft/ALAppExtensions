// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to query Microsoft Graph Api
/// </summary>
codeunit 9350 "Microsoft Graph Client"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        [NonDebuggable]
        MicrosoftGraphClientImpl: Codeunit "Microsoft Graph Client Impl.";
        HttpClientSet: Boolean;
        IHttpClient: Interface IHttpClient;

    /// <summary>
    /// Initializes Microsoft Graph client.
    /// </summary>
    /// <remarks>Should be called before any GET,PATCH,POST,DELTE request</remarks>
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
    /// The base URL to use when constructing the final request URI.
    /// If not set, the base URL is https://graph.microsoft.com . 
    /// </summary>
    /// <remarks>It's optional to set the BaseUrl.</remarks>
    /// <param name="BaseUrl">A valid URL string</param>
    procedure SetBaseUrl(BaseUrl: Text)
    begin
        MicrosoftGraphClientImpl.SetBaseUrl(BaseUrl);
    end;


    /// <summary>
    /// Returns detailed information on last API call.
    /// </summary>
    /// <returns>Codeunit holding http resonse status, reason phrase, headers and possible error information for tha last API call</returns>
    /// <remarks>If any GET,PATCH,POST,DELTE request results in an error, then the HTTP Diagnostics is not initialized.</remarks>
    procedure GetDiagnostics(): Interface "HTTP Diagnostics"
    begin
        exit(MicrosoftGraphClientImpl.GetDiagnostics());
    end;


    /// <summary>
    /// Get any request to the microsoft graph API
    /// </summary>
    /// <remarks>Does not require UI interaction.</remarks>
    /// <param name="RelativeUriToResource">A relativ uri including the resource segments</param>
    /// <param name="ResponseInStream">The InStream that will be populated with the file content.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    /// <error>Authentication failed.</error>
    procedure Get(RelativeUriToResource: Text; var ResponseInStream: InStream): Boolean
    begin
        exit(MicrosoftGraphClientImpl.Get(RelativeUriToResource, ResponseInStream));
    end;

    /// <summary>
    /// Get any request to the microsoft graph API
    /// </summary>
    /// <remarks>Does not require UI interaction.</remarks>
    /// <param name="RelativeUriToResource">A relativ uri including the resource segment</param>
    /// <param name="MgOptionalParameters">A wrapper for optional header and query parameters</param>
    /// <param name="ResponseInStream">The InStream that will be populated with the file content.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    /// <error>Authentication failed.</error>
    procedure Get(RelativeUriToResource: Text; MgOptionalParameters: Codeunit "Mg Optional Parameters"; var ResponseInStream: InStream): Boolean
    begin
        exit(MicrosoftGraphClientImpl.Get(RelativeUriToResource, MgOptionalParameters, ResponseInStream));
    end;

    /// <summary>
    /// Post any request to the microsoft graph API
    /// </summary>
    /// <remarks>Does not require UI interaction.</remarks>
    /// <param name="RelativeUriToResource">A relativ uri including the resource segment</param>
    /// <param name="MgOptionalParameters">A wrapper for optional header and query parameters</param>
    /// <param name="RequestContentInStream">The InStream that will be populated with the response message content.</param>
    /// <param name="ResponseInStream">The InStream that will be populated with the response message content.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    /// <error>Authentication failed.</error>
    procedure Post(RelativeUriToResource: Text; MgOptionalParameters: Codeunit "Mg Optional Parameters"; var RequestContentInStream: InStream; var ResponseInStream: InStream): Boolean
    begin
        exit(MicrosoftGraphClientImpl.Post(RelativeUriToResource, MgOptionalParameters, RequestContentInStream, ResponseInStream));
    end;

    /// <summary>
    /// Patch any request to the microsoft graph API
    /// </summary>
    /// <remarks>Does not require UI interaction.</remarks>
    /// <param name="RelativeUriToResource">A relativ uri including the resource segment</param>
    /// <param name="MgOptionalParameters">A wrapper for optional header and query parameters</param>
    /// <param name="RequestContentInStream">The InStream that will be populated with the response message content.</param>
    /// <param name="ResponseInStream">The InStream that will be populated with the response message content.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    /// <error>Authentication failed.</error>
    procedure Patch(RelativeUriToResource: Text; MgOptionalParameters: Codeunit "Mg Optional Parameters"; var RequestContentInStream: InStream; var ResponseInStream: InStream): Boolean
    begin
        exit(MicrosoftGraphClientImpl.Patch(RelativeUriToResource, MgOptionalParameters, RequestContentInStream, ResponseInStream));
    end;

    /// <summary>
    /// Send a DELETE request to the microsoft graph API
    /// </summary>
    /// <remarks>Does not require UI interaction.</remarks>
    /// <param name="RelativeUriToResource">A relativ uri to the resource - e.g. /users/{id|userPrincipalName}.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    /// <error>Authentication failed.</error>
    procedure Delete(RelativeUriToResource: Text): Boolean
    begin
        exit(MicrosoftGraphClientImpl.Delete(RelativeUriToResource));
    end;

    /// <summary>
    /// Set a custom implementation of the HttpClient to mock the web communication in a test.
    /// </summary>
    /// <remarks>This method is only used for testing purpose.</remarks>
    /// <param name="NewHttpClient"></param>
    internal procedure SetHttpClient(NewHttpClient: Interface IHttpClient)
    begin
        IHttpClient := NewHttpClient;
        HttpClientSet := true;
    end;
}