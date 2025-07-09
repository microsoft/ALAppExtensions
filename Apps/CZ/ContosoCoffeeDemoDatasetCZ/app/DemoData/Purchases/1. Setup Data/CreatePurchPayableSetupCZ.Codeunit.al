// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Purchases;

using Microsoft.Purchases.Setup;

codeunit 31207 "Create Purch. Payable Setup CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdatePurchasesPayablesSetup()
    end;

    local procedure UpdatePurchasesPayablesSetup()
    begin
        ValidateRecordFields(false, true, true);
    end;

    local procedure ValidateRecordFields(InvoiceRounding: Boolean; AllowVatDifference: Boolean; AllowMultiplePostingGroups: Boolean)
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Invoice Rounding", InvoiceRounding);
        PurchasesPayablesSetup.Validate("Allow VAT Difference", AllowVatDifference);
        PurchasesPayablesSetup.Validate("Allow Multiple Posting Groups", AllowMultiplePostingGroups);
        PurchasesPayablesSetup.Modify(true);
    end;
}
