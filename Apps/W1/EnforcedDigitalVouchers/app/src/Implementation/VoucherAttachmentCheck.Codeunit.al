// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using System.Utilities;
using Microsoft.Service.Document;

codeunit 5580 "Voucher Attachment Check" implements "Digital Voucher Check"
{
    Access = Internal;

    var
        DigitalVoucherImpl: Codeunit "Digital Voucher Impl.";
        NotPossibleToPostWithoutVoucherErr: Label 'Not possible to post without attaching the digital voucher.';

    procedure CheckVoucherIsAttachedToDocument(var ErrorMessageMgt: Codeunit "Error Message Management"; DigitalVoucherEntryType: Enum "Digital Voucher Entry Type"; RecRef: RecordRef)
    begin
        if DigitalVoucherImpl.CheckDigitalVoucherForDocument(DigitalVoucherEntryType, RecRef) then
            exit;
        if (DigitalVoucherEntryType in [DigitalVoucherEntryType::"General Journal", DigitalVoucherEntryType::"Purchase Journal", DigitalVoucherEntryType::"Sales Journal"]) or
           (RecRef.Number() = Database::"Service Header")
        then
            error(NotPossibleToPostWithoutVoucherErr);
        ErrorMessageMgt.LogSimpleErrorMessage(NotPossibleToPostWithoutVoucherErr);
    end;

    procedure GenerateDigitalVoucherForPostedDocument(DigitalVoucherEntryType: Enum "Digital Voucher Entry Type"; RecRef: RecordRef)
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
        IncomingDocument: Record "Incoming Document";
        VoucherAttached: Boolean;
    begin
        DigitalVoucherImpl.GetDigitalVoucherEntrySetup(DigitalVoucherEntrySetup, DigitalVoucherEntryType);
        VoucherAttached := DigitalVoucherImpl.GetIncomingDocumentRecordFromRecordRef(IncomingDocument, RecRef);
        if VoucherAttached and DigitalVoucherEntrySetup."Skip If Manually Added" then
            exit;
        if not DigitalVoucherEntrySetup."Generate Automatically" then
            exit;
        DigitalVoucherImpl.GenerateDigitalVoucherForDocument(RecRef);
    end;

}
