// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration;

/// <summary>
/// Codeunit to manage the HTTP state for the integration actions.
/// </summary>
codeunit 6190 "Http Message State"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    /// <summary>
    /// Retrieves the HTTP request message object.
    /// </summary>
    procedure GetHttpRequestMessage(): HttpRequestMessage;
    begin
        exit(this.HttpRequestMessage);
    end;

    /// <summary>
    /// Sets the HTTP request message object.
    /// </summary>
    procedure SetHttpRequestMessage(HttpRequestMessage: HttpRequestMessage);
    begin
        this.HttpRequestMessage := HttpRequestMessage;
    end;

    /// <summary>
    /// Retrieves the HTTP response message object.
    /// </summary>
    procedure GetHttpResponseMessage(): HttpResponseMessage;
    begin
        exit(this.HttpResponseMessage);
    end;

    /// <summary>
    /// Sets the HTTP response message object.
    /// </summary>
    procedure SetHttpResponseMessage(HttpResponseMessage: HttpResponseMessage);
    begin
        this.HttpResponseMessage := HttpResponseMessage;
    end;

    var
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
}