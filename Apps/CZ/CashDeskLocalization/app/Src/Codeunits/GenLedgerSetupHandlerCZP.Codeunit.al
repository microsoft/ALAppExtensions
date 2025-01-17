// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Calculation;

codeunit 11794 "Gen. Ledger Setup Handler CZP"
{
    [EventSubscriber(ObjectType::Table, Database::"General Ledger Setup", 'OnAfterInitVATDateCZL', '', false, false)]
    local procedure InitCashDocumentVatDateOnAfterInitVATDateCZL()
    var
        VATDateHandlerCZL: Codeunit "VAT Date Handler CZL";
    begin
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Cash Document Header CZP");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Posted Cash Document Hdr. CZP");
    end;
}
