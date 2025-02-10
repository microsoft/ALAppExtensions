// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Receive;

using Microsoft.eServices.EDocument.Integration.Action;
using Microsoft.eServices.EDocument.Integration;

/// <summary>
/// Represents the context for an action.
/// </summary>
codeunit 6187 ActionContext
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    /// <summary>
    /// Contains the HTTP message state.
    /// </summary>
    procedure Http(): Codeunit "Http Message State"
    begin
        exit(this.HttpMessageState);
    end;

    /// <summary>
    /// Contains the status of the integration action.
    /// </summary>
    procedure Status(): Codeunit "Integration Action Status"
    begin
        exit(this.IntegrationActionStatus);
    end;

    var
        HttpMessageState: Codeunit "Http Message State";
        IntegrationActionStatus: Codeunit "Integration Action Status";

}