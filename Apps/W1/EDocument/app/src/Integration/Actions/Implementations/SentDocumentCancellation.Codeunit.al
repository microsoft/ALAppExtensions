// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Action;

using Microsoft.eServices.EDocument.Integration.Interfaces;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Receive;


/// <summary>
/// Executes the cancellation check for the sent E-Document.
/// </summary>
codeunit 6183 "Sent Document Cancellation" implements IDocumentAction
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure InvokeAction(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; ActionContext: Codeunit ActionContext): Boolean
    begin
        ActionContext.Status().SetErrorStatus(Enum::"E-Document Service Status"::"Cancel Error");
        ActionContext.Status().SetStatus(Enum::"E-Document Service Status"::"Canceled");
        ISentDocumentActions := EDocumentService."Sent Actions Integration";
        exit(ISentDocumentActions.GetCancellationStatus(EDocument, EDocumentService, ActionContext));
    end;

    var
        ISentDocumentActions: Interface ISentDocumentActions;

}