// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Action;

using Microsoft.eServices.EDocument;

/// <summary>
/// Codeunit to manage the state for the integration actions.
/// </summary>
codeunit 6184 "Integration Action Status"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    /// <summary>
    /// Sets the status of the integration action.
    /// </summary>
    procedure SetStatus(Status: Enum "E-Document Service Status")
    begin
        this.Status := Status;
    end;

    /// <summary>
    /// Retrieves the status of the integration action.
    /// </summary>
    procedure GetStatus(): Enum "E-Document Service Status"
    begin
        exit(this.Status);
    end;

    /// <summary>
    /// Sets the error status of an integration action. 
    /// Used when actions result in an error by runtime or logged error message.
    /// </summary>
    procedure SetErrorStatus(ErrorStatus: Enum "E-Document Service Status")
    begin
        this.ErrorStatus := ErrorStatus;
    end;

    /// <summary>
    /// Retrieves the error status of the integration action.
    /// </summary>
    procedure GetErrorStatus(): Enum "E-Document Service Status"
    begin
        exit(this.ErrorStatus);
    end;


    var
        Status, ErrorStatus : Enum "E-Document Service Status";
}