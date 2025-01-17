// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Calculation;

codeunit 31433 "Gen. Ledger Setup Handler CZZ"
{
    [EventSubscriber(ObjectType::Table, Database::"General Ledger Setup", 'OnAfterInitVATDateCZL', '', false, false)]
    local procedure InitAdvanceLetterVatDateOnAfterInitVATDateCZL()
    var
        VATDateHandlerCZL: Codeunit "VAT Date Handler CZL";
    begin
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Purch. Adv. Letter Header CZZ");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Purch. Adv. Letter Entry CZZ");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Sales Adv. Letter Header CZZ");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Sales Adv. Letter Entry CZZ");
    end;
}
