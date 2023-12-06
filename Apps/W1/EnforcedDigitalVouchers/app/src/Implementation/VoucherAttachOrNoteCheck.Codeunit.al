// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using System.Environment.Configuration;
using System.Utilities;

codeunit 5581 "Voucher Attach Or Note Check" implements "Digital Voucher Check"
{
    Access = Internal;

    var
        DigitalVoucherImpl: Codeunit "Digital Voucher Impl.";
        NotPossibleToPostWithoutVoucherOrNoteErr: Label 'Not possible to post without attaching the digital voucher or adding the note.';

    procedure CheckVoucherIsAttachedToDocument(var ErrorMessageMgt: Codeunit "Error Message Management"; DigitalVoucherEntryType: Enum "Digital Voucher Entry Type"; RecRef: RecordRef)
    begin
        if not DigitalVoucherImpl.CheckDigitalVoucherForDocument(DigitalVoucherEntryType, RecRef) then
            if not DocumentHasNote(RecRef) then
                ErrorMessageMgt.LogSimpleErrorMessage(NotPossibleToPostWithoutVoucherOrNoteErr);
    end;

    procedure GenerateDigitalVoucherForPostedDocument(DigitalVoucherEntryType: Enum "Digital Voucher Entry Type"; RecRef: RecordRef)
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
        IncomingDocument: Record "Incoming Document";
        VoucherAttached: Boolean;
    begin
        DigitalVoucherEntrySetup.Get(DigitalVoucherEntryType);
        VoucherAttached := DigitalVoucherImpl.GetIncomingDocumentRecordFromRecordRef(IncomingDocument, RecRef);
        if VoucherAttached and DigitalVoucherEntrySetup."Skip If Manually Added" then
            exit;
        if (not DigitalVoucherEntrySetup."Generate Automatically") or DocumentHasNote(RecRef) then
            exit;
        DigitalVoucherImpl.GenerateDigitalVoucherForDocument(RecRef);
    end;

    local procedure DocumentHasNote(RecRef: RecordRef): Boolean
    var
        RecordLink: Record "Record Link";
    begin
        RecordLink.SetRange("Record ID", RecRef.RecordId);
        exit(not RecordLink.IsEmpty());
    end;
}
