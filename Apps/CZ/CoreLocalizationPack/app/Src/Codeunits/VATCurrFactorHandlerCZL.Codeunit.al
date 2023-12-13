// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Calculation;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Service.Contract;
using Microsoft.Service.Document;

codeunit 11779 "VAT Curr. Factor Handler CZL"
{
    [EventSubscriber(ObjectType::Report, Report::"Copy - VAT Posting Setup", 'OnAfterCopyVATPostingSetup', '', false, false)]
    local procedure CopyCZLfieldsOnAfterCopyVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; FromVATPostingSetup: Record "VAT Posting Setup"; Sales: Boolean; Purch: Boolean)
    begin
        if Sales then
            VATPostingSetup."Sales VAT Curr. Exch. Acc CZL" := FromVATPostingSetup."Sales VAT Curr. Exch. Acc CZL";
        if Purch then
            VATPostingSetup."Purch. VAT Curr. Exch. Acc CZL" := FromVATPostingSetup."Purch. VAT Curr. Exch. Acc CZL";
        VATPostingSetup."VIES Purchase CZL" := FromVATPostingSetup."VIES Purchase CZL";
        VATPostingSetup."VIES Sales CZL" := FromVATPostingSetup."VIES Sales CZL";
    end;

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
