// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Integration.Microsoft.Graph;
using System.Integration.Microsoft.Graph.Authorization;
using System.RestClient;

/// <summary>
/// Exposes functionality to query Microsoft Graph Api
/// </summary>
codeunit 9350 "Mg Client"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        [NonDebuggable]
        MgClientImpl: Codeunit "Mg Client Impl.";

    /// <summary>
    /// Initializes Microsoft Graph client.
    /// </summary>
    /// <remarks>Should be called before any GET,PATCH,POST,DELTE request</remarks>
    /// <param name="MgAPIVersion">API Version to use.</param>
    /// <param name="MgAuthorizationInstance">The authorization to use.</param>
    procedure Initialize(MgAPIVersion: Enum "Mg API Version"; MgAuthorizationInstance: Interface "Mg Authorization")
    begin
        MgClientImpl.Initialize(MgAPIVersion, MgAuthorizationInstance);
    end;

    /// <summary>
    /// Initializes Microsoft Graph client.
    /// </summary>
    /// <remarks>Should be called before any GET,PATCH,POST,DELTE request</remarks>
    /// <param name="MgAPIVersion">API Version to use.</param>
    /// <param name="MgAuthorizationInstance">The authorization to use.</param>
    /// <param name="HttpClientHandlerInstance">The authorization to use.</param>
    procedure Initialize(MgAPIVersion: Enum "Mg API Version"; MgAuthorizationInstance: Interface "Mg Authorization"; HttpClientHandlerInstance: Interface "Http Client Handler")
    begin
        MgClientImpl.Initialize(MgAPIVersion, MgAuthorizationInstance, HttpClientHandlerInstance);
    end;

    /// <summary>
    /// The base URL to use when constructing the final request URI.
    /// If not set, the base URL is https://graph.microsoft.com . 
    /// </summary>
    /// <remarks>It's optional to set the BaseUrl.</remarks>
    /// <param name="BaseUrl">A valid URL string</param>
    procedure SetBaseUrl(BaseUrl: Text)
    begin
        MgClientImpl.SetBaseUrl(BaseUrl);
    end;


    /// <summary>
    /// Get any request to the microsoft graph API
    /// </summary>
    /// <remarks>Does not require UI interaction.</remarks>
    /// <param name="RelativeUriToResource">A relativ uri including the resource segments</param>
    /// <param name="HttpResponseMessage">The response message object.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    /// <error>Authentication failed.</error>
    procedure Get(RelativeUriToResource: Text; var HttpResponseMessage: Codeunit "Http Response Message"): Boolean
    begin
        exit(MgClientImpl.Get(RelativeUriToResource, HttpResponseMessage));
    end;

    /// <summary>
    /// Get any request to the microsoft graph API
    /// </summary>
    /// <remarks>Does not require UI interaction.</remarks>
    /// <param name="RelativeUriToResource">A relativ uri including the resource segment</param>
    /// <param name="MgOptionalParameters">A wrapper for optional header and query parameters</param>
    /// <param name="HttpResponseMessage">The response message object.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    /// <error>Authentication failed.</error>
    procedure Get(RelativeUriToResource: Text; MgOptionalParameters: Codeunit "Mg Optional Parameters"; var HttpResponseMessage: Codeunit "Http Response Message"): Boolean
    begin
        exit(MgClientImpl.Get(RelativeUriToResource, MgOptionalParameters, HttpResponseMessage));
    end;

    /// <summary>
    /// Post any request to the microsoft graph API
    /// </summary>
    /// <remarks>Does not require UI interaction.</remarks>
    /// <param name="RelativeUriToResource">A relativ uri including the resource segment</param>
    /// <param name="MgOptionalParameters">A wrapper for optional header and query parameters</param>
    /// <param name="RequestHttpContent">The HttpContent object for the request.</param>
    /// <param name="HttpResponseMessage">The response message object.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    /// <error>Authentication failed.</error>
    procedure Post(RelativeUriToResource: Text; MgOptionalParameters: Codeunit "Mg Optional Parameters"; RequestHttpContent: Codeunit "Http Content"; var HttpResponseMessage: Codeunit "Http Response Message"): Boolean
    begin
        exit(MgClientImpl.Post(RelativeUriToResource, MgOptionalParameters, RequestHttpContent, HttpResponseMessage));
    end;

    /// <summary>
    /// Patch any request to the microsoft graph API
    /// </summary>
    /// <remarks>Does not require UI interaction.</remarks>
    /// <param name="RelativeUriToResource">A relativ uri including the resource segment</param>
    /// <param name="MgOptionalParameters">A wrapper for optional header and query parameters</param>
    /// <param name="RequestHttpContent">The HttpContent object for the request.</param>
    /// <param name="HttpResponseMessage">The response message object.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    /// <error>Authentication failed.</error>
    procedure Patch(RelativeUriToResource: Text; MgOptionalParameters: Codeunit "Mg Optional Parameters"; RequestHttpContent: Codeunit "Http Content"; var HttpResponseMessage: Codeunit "Http Response Message"): Boolean
    begin
        exit(MgClientImpl.Patch(RelativeUriToResource, MgOptionalParameters, RequestHttpContent, HttpResponseMessage));
    end;

    /// <summary>
    /// Send a DELETE request to the microsoft graph API
    /// </summary>
    /// <remarks>Does not require UI interaction.</remarks>
    /// <param name="RelativeUriToResource">A relativ uri to the resource - e.g. /users/{id|userPrincipalName}.</param>
    /// <param name="MgOptionalParameters">A wrapper for optional header and query parameters</param>
    /// <param name="HttpResponseMessage">The response message object.</param>
    /// <returns>True if the operation was successful; otherwise - false.</returns>
    /// <error>Authentication failed.</error>
    procedure Delete(RelativeUriToResource: Text; MgOptionalParameters: Codeunit "Mg Optional Parameters"; var HttpResponseMessage: Codeunit "Http Response Message"): Boolean
    begin
        exit(MgClientImpl.Delete(RelativeUriToResource, MgOptionalParameters, HttpResponseMessage));
    end;
}