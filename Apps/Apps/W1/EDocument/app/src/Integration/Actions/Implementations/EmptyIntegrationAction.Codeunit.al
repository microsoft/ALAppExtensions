// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Action;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Interfaces;
using Microsoft.eServices.EDocument.Integration.Receive;

/// <summary>
/// This codeunit is used to implement the "Action Invoker" interface. It is used to provide a default implementation for the "Action Invoker" interface.
/// </summary>
codeunit 6176 "Empty Integration Action" implements IDocumentAction
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure InvokeAction(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; ActionContext: Codeunit ActionContext): Boolean
    begin
        // This method serves as a placeholder implementation for the IDocumentAction interface.
        exit(false);
    end;


}