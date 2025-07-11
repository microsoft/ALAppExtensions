// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

using Microsoft.Finance.GeneralLedger.Journal;

codeunit 18550 "Tax Base Library"
{
    procedure GetTotalTDSIncludingSheCess(DocumentNo: Code[20]; var TotalTDSEncludingSheCess: Decimal; var AccountNo: Code[20]; var EntryNo: Integer)
    begin
        OnAfterGetTotalTDSIncludingSheCess(DocumentNo, TotalTDSEncludingSheCess, AccountNo, EntryNo);
    end;

    procedure ReverseTDSEntry(EntryNo: Integer; TransactionNo: Integer)
    begin
        OnAfterReverseTDSEntry(EntryNo, TransactionNo);
    end;

    procedure GetTDSAmount(GenJournalLine: Record "Gen. Journal Line"; var Amount: Decimal)
    begin
        OnGetTDSAmount(GenJournalLine, Amount);
    end;

    procedure GetVoucherAccNo(var LocationCode: Code[20]; var AccountNo: Code[20]; var ForUpiPayment: Boolean)
    begin
        OnGetVoucherAccNo(LocationCode, AccountNo, ForUpiPayment);
    end;

    procedure GetBankAccUpiId(BankCode: Code[20]; var UPIID: Text[50])
    begin
        OnGetBankAccUpiId(BankCode, UPIID);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetTotalTDSIncludingSheCess(DocumentNo: Code[20]; var TotalTDSEncludingSheCess: Decimal; var AccountNo: Code[20]; var EntryNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReverseTDSEntry(EntryNo: Integer; TransactionNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetTDSAmount(GenJournalLine: Record "Gen. Journal Line"; var Amount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetVoucherAccNo(var LocationCode: Code[20]; var AccountNo: Code[20]; var ForUpiPayment: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetBankAccUpiId(BankCode: Code[20]; var UPIID: Text[50])
    begin
    end;
}
