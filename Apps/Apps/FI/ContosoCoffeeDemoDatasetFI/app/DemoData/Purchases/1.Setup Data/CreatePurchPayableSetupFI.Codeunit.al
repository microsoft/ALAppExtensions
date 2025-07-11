// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Purchases;

using Microsoft.DemoData.Foundation;
using Microsoft.Purchases.Setup;

codeunit 13437 "Create Purch. Payable Setup FI"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    begin
        UpdatePurchasesPayablesSetup()
    end;

    local procedure UpdatePurchasesPayablesSetup()
    var
        CreateJobQueueCategory: Codeunit "Create Job Queue Category";
    begin
        ValidateRecordFields(CreateJobQueueCategory.SalesPurchasePosting());
    end;

    local procedure ValidateRecordFields(JobQueueCategoryCode: Code[10])
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Job Queue Category Code", JobQueueCategoryCode);
        PurchasesPayablesSetup.Modify(true);
    end;
}
