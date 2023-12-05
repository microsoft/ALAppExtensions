// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using System.Utilities;

codeunit 5580 "Voucher Attachment Check" implements "Digital Voucher Check"
{
    Access = Internal;

    var
        DigitalVoucherImpl: Codeunit "Digital Voucher Impl.";
        NotPossibleToPostWithoutVoucherErr: Label 'Not possible to post without attaching the digital voucher.';

    procedure CheckVoucherIsAttachedToDocument(var ErrorMessageMgt: Codeunit "Error Message Management"; DigitalVoucherEntryType: Enum "Digital Voucher Entry Type"; RecRef: RecordRef)
    begin
        if not DigitalVoucherImpl.CheckDigitalVoucherForDocument(DigitalVoucherEntryType, RecRef) then
            if DigitalVoucherEntryType = DigitalVoucherEntryType::"General Journal" then
                error(NotPossibleToPostWithoutVoucherErr)
            else
                ErrorMessageMgt.LogSimpleErrorMessage(NotPossibleToPostWithoutVoucherErr);
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
        if not DigitalVoucherEntrySetup."Generate Automatically" then
            exit;
        DigitalVoucherImpl.GenerateDigitalVoucherForDocument(RecRef);
    end;

}
