// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Action;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Interfaces;

/// <summary>
/// Run E-Document Actions
/// </summary>
codeunit 6178 "E-Document Action Runner"
{
    Access = Internal;

    trigger OnRun()
    var
        IAction: Interface "Action Invoker";
    begin
        IAction := ActionType;
        UpdateStatusBool := IAction.InvokeAction(this.EDocument, this.EDocumentService, this.HttpRequestMessage, this.HttpResponseMessage, EDocumentServiceStatus);
    end;

    /// <summary>
    /// Gets the fallback service status. Called when a runtime error occurs in InvokeAction, and we need to fall back to an status on the E-Document.
    /// </summary>
    procedure GetFallbackStatus(): Enum "E-Document Service Status"
    var
        IAction: Interface "Action Invoker";
    begin
        IAction := ActionType;
        exit(IAction.GetFallbackStatus(this.EDocument, this.EDocumentService));
    end;

    /// <summary>
    /// Sets the parameters for the E-Document Action
    /// </summary>
    procedure SetParameters(var EDoc: Record "E-Document"; var Service: Record "E-Document Service")
    begin
        this.EDocument.Copy(EDoc);
        this.EDocumentService.Copy(Service);
    end;

    /// <summary>
    /// Gets the parameters for the E-Document Action, including the HttpRequestMessage and HttpResponseMessage used for the E-Document Action
    /// </summary>
    procedure GetParameters(var EDoc: Record "E-Document"; var Service: Record "E-Document Service"; var RequestMessage: HttpRequestMessage; var ResponseMessage: HttpResponseMessage)
    begin
        EDoc.Copy(this.EDocument);
        Service.Copy(this.EDocumentService);
        RequestMessage := this.HttpRequestMessage;
        ResponseMessage := this.HttpResponseMessage;
    end;

    /// <summary>
    /// Gets the status of the E-Document Service
    /// </summary>
    procedure GetStatus(): Enum "E-Document Service Status"
    begin
        exit(EDocumentServiceStatus);
    end;

    /// <summary>
    /// Returns if running action lead to update in service status.
    /// Certain actions dont need to update service status, like asking if document was approved. 
    /// </summary>
    /// <returns>True if service status should be updated</returns>
    procedure UpdateStatus(): Boolean
    begin
        exit(UpdateStatusBool);
    end;

    /// <summary>
    /// Sets the action type for the E-Document Action.
    /// The implementation of the action that will run is determined by the ActionType.
    /// </summary>
    /// <param name="Action"></param>
    procedure SetActionType(Action: Enum "Integration Action Type")
    begin
        ActionType := Action;
    end;

    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        EDocumentServiceStatus: Enum "E-Document Service Status";
        ActionType: Enum "Integration Action Type";
        UpdateStatusBool: Boolean;
}