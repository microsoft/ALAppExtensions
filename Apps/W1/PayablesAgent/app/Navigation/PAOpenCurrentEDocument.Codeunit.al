// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.PayablesAgent;

using Microsoft.eServices.EDocument;

codeunit 3308 "PA Open Current E-Document"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        EDocument: Record "E-Document";
        PayablesAgent: Codeunit "Payables Agent";
        InboundEDocuments: Page "Inbound E-Documents";
    begin
        EDocument := PayablesAgent.GetCurrentSessionsEDocument();
        EDocument.SetRecFilter();
        InboundEDocuments.SetTableView(EDocument);
        InboundEDocuments.Run();
    end;
}