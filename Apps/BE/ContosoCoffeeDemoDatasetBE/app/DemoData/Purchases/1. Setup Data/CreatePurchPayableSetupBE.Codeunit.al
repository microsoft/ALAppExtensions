// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Purchases;

using Microsoft.Purchases.Setup;
using Microsoft.DemoData.Finance;

codeunit 11379 "Create Purch. Payable Setup BE"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateGenJnlTemplateBE: Codeunit "Create Gen. Jnl Template BE";
    begin
        UpdatePurchasePayableSetup(CreateGenJnlTemplateBE.Purchase(), CreateGenJnlTemplateBE.PurchCreditMemo(), true);
    end;

    local procedure UpdatePurchasePayableSetup(PurchaseInvoiceTemplate: Code[10]; PurchaseInvCrMemoTemplate: Code[10]; CopyLineDesc: Boolean)
    var
        PurchPayableSetup: Record "Purchases & Payables Setup";
    begin
        if PurchPayableSetup.Get() then begin
            PurchPayableSetup.Validate("P. Invoice Template Name", PurchaseInvoiceTemplate);
            PurchPayableSetup.Validate("P. Cr. Memo Template Name", PurchaseInvCrMemoTemplate);
            PurchPayableSetup.Validate("P. Prep. Inv. Template Name", PurchaseInvoiceTemplate);
            PurchPayableSetup.Validate("P. Prep. Cr.Memo Template Name", PurchaseInvCrMemoTemplate);
            PurchPayableSetup.Validate("Copy Line Descr. to G/L Entry", CopyLineDesc);
            PurchPayableSetup.Validate("Allow VAT Difference", true);
            PurchPayableSetup.Modify(true);
        end;
    end;
}
