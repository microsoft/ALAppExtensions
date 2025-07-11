// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Purchases;

using Microsoft.Purchases.Setup;
using Microsoft.DemoData.Finance;
using Microsoft.DemoData.Foundation;

codeunit 17142 "Create AU Purch Payable Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdatePurchasePayableSetup();
    end;

    local procedure UpdatePurchasePayableSetup()
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        CreateNoSeries: Codeunit "Create No. Series";
        CreateAUPostingGroups: Codeunit "Create AU Posting Groups";
    begin
        PurchasesPayablesSetup.Get();

        PurchasesPayablesSetup.Validate("Invoice Nos.", CreateNoSeries.PostedPurchaseInvoice());
        PurchasesPayablesSetup.Validate("Credit Memo Nos.", CreateNoSeries.PostedPurchaseCreditMemo());
        PurchasesPayablesSetup.Validate("Copy Line Descr. to G/L Entry", true);
        PurchasesPayablesSetup.Validate("GST Prod. Posting Group", CreateAUPostingGroups.NonGst());
        PurchasesPayablesSetup.Modify(true);
    end;
}
