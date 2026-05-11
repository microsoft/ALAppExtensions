// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using System.Utilities;

codeunit 5588 "Voucher E-Document Check" implements "Digital Voucher Check"
{
    Access = Internal;

    /// <summary>
    /// Validates that an E-Document is attached to the document before posting.
    /// Only applies to Purchase Documents when the Digital Voucher feature is enabled and Check Type is set to E-Document.
    /// </summary>
    /// <param name="ErrorMessageMgt">Error message management for logging validation errors.</param>
    /// <param name="DigitalVoucherEntryType">The type of digital voucher entry being validated.</param>
    /// <param name="RecRef">Record reference to the document being validated.</param>
    internal procedure CheckVoucherIsAttachedToDocument(var ErrorMessageMgt: Codeunit "Error Message Management"; DigitalVoucherEntryType: Enum "Digital Voucher Entry Type"; RecRef: RecordRef)
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
        EDocument: Record "E-Document";
        DigitalVoucherFeature: Codeunit "Digital Voucher Feature";
        DigitalVoucherImpl: Codeunit "Digital Voucher Impl.";
        NotPossibleToPostWithoutEDocumentErr: Label 'Not possible to post without linking an E-Document.';
    begin
        if not DigitalVoucherFeature.IsFeatureEnabled() then
            exit;

        if DigitalVoucherEntryType <> DigitalVoucherEntryType::"Purchase Document" then
            exit;

        DigitalVoucherImpl.GetDigitalVoucherEntrySetup(DigitalVoucherEntrySetup, DigitalVoucherEntryType);
        if DigitalVoucherEntrySetup."Check Type" <> DigitalVoucherEntrySetup."Check Type"::"E-Document" then
            exit;

        EDocument.SetRange("Document Record ID", RecRef.RecordId());
        if EDocument.IsEmpty() then begin
            ErrorMessageMgt.LogSimpleErrorMessage(NotPossibleToPostWithoutEDocumentErr);
            exit;
        end;
    end;

    /// <summary>
    /// Generates a digital voucher for a posted document by delegating to the Attachment check type implementation.
    /// This procedure retrieves the digital voucher entry setup and invokes the attachment-based voucher generation.
    /// </summary>
    /// <param name="DigitalVoucherEntryType">The type of digital voucher entry for the posted document.</param>
    /// <param name="RecRef">Record reference to the posted document.</param>
    internal procedure GenerateDigitalVoucherForPostedDocument(DigitalVoucherEntryType: Enum "Digital Voucher Entry Type"; RecRef: RecordRef)
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
        DigitalVoucherImpl: Codeunit "Digital Voucher Impl.";
        DigitalVoucherCheck: Interface "Digital Voucher Check";
    begin
        DigitalVoucherImpl.GetDigitalVoucherEntrySetup(DigitalVoucherEntrySetup, DigitalVoucherEntryType);
        DigitalVoucherCheck := DigitalVoucherEntrySetup."Check Type"::Attachment;
        DigitalVoucherCheck.GenerateDigitalVoucherForPostedDocument(DigitalVoucherEntrySetup."Entry Type", RecRef);
    end;
}