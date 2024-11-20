// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Action;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Interfaces;
using Microsoft.eServices.EDocument.Integration.Receive;

/// <summary>
/// Run E-Document Actions
/// </summary>
codeunit 6178 "E-Document Action Runner"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        IAction: Interface IDocumentAction;
    begin
        IAction := ActionType;
        this.UpdateStatusBool := IAction.InvokeAction(this.EDocument, this.EDocumentService, this.ActionContext);
    end;

    /// <summary>
    /// Sets the parameters for the E-Document Action
    /// </summary>
    procedure SetEDocumentAndService(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service")
    begin
        this.EDocument.Copy(EDocument);
        this.EDocumentService.Copy(EDocumentService);
    end;

    /// <summary>
    /// Gets the E-Document and the E-Document Service for the E-Document Action
    /// </summary>
    procedure GetEDocumentAndService(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service")
    begin
        EDocument.Copy(this.EDocument);
        EDocumentService.Copy(this.EDocumentService);
    end;

    /// <summary>
    /// Returns if running action lead to update in service status.
    /// Certain actions dont need to update service status, like asking if document was approved. 
    /// </summary>
    /// <returns>True if service status should be updated</returns>
    procedure ShouldActionUpdateStatus(): Boolean
    begin
        exit(this.UpdateStatusBool);
    end;

    /// <summary>
    /// Sets the action type for the E-Document Action.
    /// The implementation of the action that will run is determined by the ActionType.
    /// </summary>
    /// <param name="Action"></param>
    procedure SetActionType(Action: Enum "Integration Action Type")
    begin
        this.ActionType := Action;
    end;

    /// <summary>
    /// Sets the context for the E-Document Action
    /// </summary>
    /// <param name="ActionContext"></param>
    procedure SetContext(ActionContext: Codeunit ActionContext)
    begin
        this.ActionContext := ActionContext;
    end;

    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        ActionContext: Codeunit ActionContext;
        ActionType: Enum "Integration Action Type";
        UpdateStatusBool: Boolean;
}