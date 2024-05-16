﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ReceivablesPayables;

using Microsoft.Finance.GeneralLedger.Journal;

codeunit 31307 "Inv. Post. Buffer Handler CZL"
{
    Access = Internal;

#if not CLEAN23
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Table, Database::"Invoice Post. Buffer", 'OnBeforeInvPostBufferModify', '', false, false)]
    local procedure UpdateExtendedAmountsOnBeforeInvPostBufferModify(var InvoicePostBuffer: Record "Invoice Post. Buffer"; FromInvoicePostBuffer: Record "Invoice Post. Buffer")
    begin
        InvoicePostBuffer."Ext. Amount CZL" += FromInvoicePostBuffer."Ext. Amount CZL";
        InvoicePostBuffer."Ext. Amount Incl. VAT CZL" += FromInvoicePostBuffer."Ext. Amount Incl. VAT CZL";
    end;
#pragma warning restore AL0432
#endif
#if not CLEAN24
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Table, Database::"Invoice Posting Buffer", 'OnUpdateOnBeforeModify', '', false, false)]
    local procedure UpdateExtendedAmountsOnUpdateOnBeforeModify(var InvoicePostingBuffer: Record "Invoice Posting Buffer"; FromInvoicePostingBuffer: Record "Invoice Posting Buffer")
    begin
        InvoicePostingBuffer."Ext. Amount CZL" += FromInvoicePostingBuffer."Ext. Amount CZL";
        InvoicePostingBuffer."Ext. Amount Incl. VAT CZL" += FromInvoicePostingBuffer."Ext. Amount Incl. VAT CZL";
    end;
#pragma warning restore AL0432
#endif
#if not CLEAN23
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Table, Database::"Invoice Post. Buffer", 'OnAfterCopyToGenJnlLine', '', false, false)]
    local procedure CopyFieldsOnAfterCopyToGenJnlLineOld(var GenJnlLine: Record "Gen. Journal Line"; InvoicePostBuffer: Record "Invoice Post. Buffer");
    begin
        GenJnlLine.Correction := InvoicePostBuffer."Correction CZL";
        GenJnlLine."VAT Reporting Date" := InvoicePostBuffer."VAT Date CZL";
        GenJnlLine."Original Doc. VAT Date CZL" := InvoicePostBuffer."Original Doc. VAT Date CZL";
    end;
#pragma warning restore AL0432
#endif

    [EventSubscriber(ObjectType::Table, Database::"Invoice Posting Buffer", 'OnAfterCopyToGenJnlLine', '', false, false)]
    local procedure CopyFieldsOnAfterCopyToGenJnlLine(var GenJnlLine: Record "Gen. Journal Line"; InvoicePostingBuffer: Record "Invoice Posting Buffer");
    begin
        GenJnlLine.Correction := InvoicePostingBuffer."Correction CZL";
        GenJnlLine."VAT Reporting Date" := InvoicePostingBuffer."VAT Date CZL";
        GenJnlLine."Original Doc. VAT Date CZL" := InvoicePostingBuffer."Original Doc. VAT Date CZL";
    end;
}
