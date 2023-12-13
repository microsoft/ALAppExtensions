// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.VAT.Setup;

codeunit 31005 "VAT Posting Setup Handler CZZ"
{
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Table, Database::"VAT Posting Setup", 'OnBeforeGetSalesAccount', '', false, false)]
    local procedure VATPostingSetupOnBeforeGetSalesAccount(var VATPostingSetup: Record "VAT Posting Setup"; var SalesVATAccountNo: Code[20]; var IsHandled: Boolean)
    begin
        VATPostingSetup.TestField("Sales Adv. Letter VAT Acc. CZZ");
        SalesVATAccountNo := VATPostingSetup."Sales Adv. Letter VAT Acc. CZZ";

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Posting Setup", 'OnBeforeGetPurchAccount', '', false, false)]
    local procedure VATPostingSetupOnBeforeGetPurchAccount(var VATPostingSetup: Record "VAT Posting Setup"; var PurchVATAccountNo: Code[20]; var IsHandled: Boolean)
    begin
        VATPostingSetup.TestField("Purch. Adv.Letter VAT Acc. CZZ");
        PurchVATAccountNo := VATPostingSetup."Purch. Adv.Letter VAT Acc. CZZ";

        IsHandled := true;
    end;
}
