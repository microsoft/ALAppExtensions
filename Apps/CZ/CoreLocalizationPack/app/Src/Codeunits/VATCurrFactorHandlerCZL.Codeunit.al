// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Calculation;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Service.Contract;
using Microsoft.Service.Document;

codeunit 11779 "VAT Curr. Factor Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::ServContractManagement, 'OnBeforeServHeaderModify', '', false, false)]
    local procedure CurrencyFactorToVATCurrencyFactorOnBeforeServHeaderModify(var ServiceHeader: Record "Service Header")
    begin
        ServiceHeader."VAT Currency Factor CZL" := ServiceHeader."Currency Factor";
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Entry", 'OnAfterCopyFromGenJnlLine', '', false, false)]
    local procedure VATDelayOnAfterCopyFromGenJnlLine(var VATEntry: Record "VAT Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        VATEntry.Validate("VAT Delay CZL", GenJournalLine."VAT Delay CZL");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnCalcPmtDiscIfAdjVATOnBeforeVATEntryFind', '', false, false)]
    local procedure VATDelayOnCalcPmtDiscIfAdjVATOnBeforeVATEntryFind(var VATEntry: Record "VAT Entry")
    begin
        VATEntry.SetRange("VAT Delay CZL", false);
    end;
}
