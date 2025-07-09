// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.eServices;

using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Finance;

codeunit 5232 "Create Incoming Document Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoEServices: Codeunit "Contoso eServices";
        CreateGenJournalTemplate: Codeunit "Create Gen. Journal Template";
        CreateGenJournalBatch: Codeunit "Create Gen. Journal Batch";
    begin
        ContosoEServices.InsertEServicesIncomingDocumentSetup(CreateGenJournalTemplate.General(), CreateGenJournalBatch.Default(), false, false);
    end;
}
