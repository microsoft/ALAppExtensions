// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.GeneralLedger.Preview;

codeunit 31456 "Purch. Post Advance Letter CZZ"
{
    Access = Internal;
    EventSubscriberInstance = Manual;
    TableNo = "Purch. Adv. Letter Entry CZZ";

    trigger OnRun()
    begin
        case DocumentType of
            DocumentType::PaymentVAT:
                PurchAdvLetterManagementCZZ.PostAdvancePaymentVAT(Rec, 0D);
            DocumentType::PaymentUsageVAT:
                PurchAdvLetterManagementCZZ.PostAdvancePaymentUsageVAT(Rec);
            DocumentType::CreditMemoVAT:
                PurchAdvLetterManagementCZZ.PostAdvanceCreditMemoVAT(Rec);
            DocumentType::CancelUsageVAT:
                PurchAdvLetterManagementCZZ.PostCancelUsageVAT(Rec);
        end;

        if PreviewMode then
            GenJnlPostPreview.ThrowError();
    end;

    var
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
        PurchAdvLetterManagementCZZ: Codeunit "PurchAdvLetterManagement CZZ";
        DocumentType: Option PaymentVAT,PaymentUsageVAT,CreditMemoVAT,CancelUsageVAT;
        PreviewMode: Boolean;

    procedure PostPaymentVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; Preview: Boolean)
    begin
        DocumentType := DocumentType::PaymentVAT;
        Post(PurchAdvLetterEntryCZZ, Preview);
    end;

    procedure PostPaymentUsageVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; Preview: Boolean)
    begin
        DocumentType := DocumentType::PaymentUsageVAT;
        Post(PurchAdvLetterEntryCZZ, Preview);
    end;

    procedure PostCreditMemoVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; Preview: Boolean)
    begin
        DocumentType := DocumentType::CreditMemoVAT;
        Post(PurchAdvLetterEntryCZZ, Preview);
    end;

    procedure PostCancelUsageVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; Preview: Boolean)
    begin
        DocumentType := DocumentType::CancelUsageVAT;
        Post(PurchAdvLetterEntryCZZ, Preview);
    end;

    local procedure Post(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; Preview: Boolean)
    begin
        if Preview then begin
            PostPreview(PurchAdvLetterEntryCZZ);
            exit;
        end;
        Run(PurchAdvLetterEntryCZZ);
    end;

    procedure SetPreviewMode(NewPreviewMode: Boolean)
    begin
        PreviewMode := NewPreviewMode;
    end;

    procedure SetDocumentType(NewDocumentType: Option PaymentVAT,PaymentUsageVAT,CreditMemoVAT,CancelUsageVAT)
    begin
        DocumentType := NewDocumentType;
    end;

    local procedure PostPreview(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    var
        PurchPostAdvanceLetterCZZ: Codeunit "Purch. Post Advance Letter CZZ";
    begin
        BindSubscription(PurchPostAdvanceLetterCZZ);
        PurchPostAdvanceLetterCZZ.SetDocumentType(DocumentType);
        Clear(GenJnlPostPreview);
        GenJnlPostPreview.Preview(PurchPostAdvanceLetterCZZ, PurchAdvLetterEntryCZZ);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnRunPreview', '', false, false)]
    local procedure OnRunPreview(var Result: Boolean; Subscriber: Variant; RecVar: Variant)
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchPostAdvanceLetterCZZ: Codeunit "Purch. Post Advance Letter CZZ";
    begin
        PurchAdvLetterEntryCZZ.Copy(RecVar);
        PurchPostAdvanceLetterCZZ.SetPreviewMode(true);
        PurchPostAdvanceLetterCZZ.SetDocumentType(DocumentType);
        Result := PurchPostAdvanceLetterCZZ.Run(PurchAdvLetterEntryCZZ);
    end;
}
