// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.PostingHandler;

using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Inventory.Transfer;

codeunit 20337 "Transfer Rcpt. Posting Handler"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnAfterInsertTransRcptLine', '', false, false)]
    procedure OnAfterInsertTransRcptLine(
        TransLine: Record "Transfer Line";
        var TransRcptLine: Record "Transfer Receipt Line")
    var
        TempTaxTransactionValue: Record "Tax Transaction Value" temporary;
        TaxDocumentGLPosting: Codeunit "Tax Document GL Posting";
    begin
        // Prepares Transaction value based on Quantity and and Qty to Invoice
        TaxDocumentGLPosting.PrepareTransactionValueToPost(
            TransLine.RecordId(),
            TransLine.Quantity,
            TransRcptLine.Quantity,
            '',
            0,
            TempTaxTransactionValue);

        TaxDocumentGLPosting.TransferTransactionValue(
            TransLine.RecordId(),
            TransRcptLine.RecordId(),
            TempTaxTransactionValue);
    end;

}
