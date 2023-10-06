// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration.Sharepoint;

/// <summary>
/// Interface to get diagnostics from an HTTP call.
/// </summary>
interface "HTTP Diagnostics"
{
    Access = Public;

    /// <summary>
    /// Gets reponse details.
    /// </summary>
    /// <returns>HttpResponseMessage.IsSuccessStatusCode</returns>
    procedure IsSuccessStatusCode(): Boolean;

    /// <summary>
    /// Gets response details.
    /// </summary>
    /// <returns>HttpResponseMessage.StatusCode</returns>
    procedure GetHttpStatusCode(): Integer;

    /// <summary>
    /// Gets response details.
    /// </summary>
    /// <returns>Retry-after header value</returns>
    procedure GetHttpRetryAfter(): Integer;

    /// <summary>
    /// Gets reponse details
    /// </summary>
    /// <returns>Error message</returns>
    procedure GetErrorMessage(): Text;

    /// <summary>
    /// Gets response details.
    /// </summary>
    /// <returns>HttpResponseMessage.ResponseReasonPhrase</returns>
    procedure GetResponseReasonPhrase(): Text;
}