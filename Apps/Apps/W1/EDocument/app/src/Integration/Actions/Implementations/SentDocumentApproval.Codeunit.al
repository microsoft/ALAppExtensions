// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Action;

using Microsoft.eServices.EDocument.Integration.Interfaces;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Receive;


/// <summary>
/// Executes the approval check for the sent E-Document.
/// </summary>
codeunit 6182 "Sent Document Approval" implements IDocumentAction
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure InvokeAction(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; ActionContext: Codeunit ActionContext): Boolean
    var
        IDocumentSender: Interface IDocumentSender;
    begin
        ActionContext.Status().SetErrorStatus(Enum::"E-Document Service Status"::"Approval Error");
        ActionContext.Status().SetStatus(Enum::"E-Document Service Status"::"Approved");
        IDocumentSender := EDocumentService."Service Integration V2";
        if IDocumentSender is ISentDocumentActions then
            exit((IDocumentSender as ISentDocumentActions).GetApprovalStatus(EDocument, EDocumentService, ActionContext));
    end;

}