// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.GeneralLedger.Preview;

codeunit 31455 "Sales Post Advance Letter CZZ"
{
    Access = Internal;
    EventSubscriberInstance = Manual;
    TableNo = "Sales Adv. Letter Entry CZZ";

    trigger OnRun()
    begin
        case DocumentType of
            DocumentType::PaymentVAT:
                SalesAdvLetterManagementCZZ.PostAdvancePaymentVAT(Rec, 0D, false);
            DocumentType::PaymentUsageVAT:
                SalesAdvLetterManagementCZZ.PostAdvancePaymentUsageVAT(Rec);
            DocumentType::CreditMemoVAT:
                SalesAdvLetterManagementCZZ.PostAdvanceCreditMemoVAT(Rec);
        end;

        if PreviewMode then
            GenJnlPostPreview.ThrowError();
    end;

    var
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
        SalesAdvLetterManagementCZZ: Codeunit "SalesAdvLetterManagement CZZ";
        DocumentType: Option PaymentVAT,PaymentUsageVAT,CreditMemoVAT;
        PreviewMode: Boolean;

    procedure PostPaymentVAT(var SalesAdvLetterEntry: Record "Sales Adv. Letter Entry CZZ"; Preview: Boolean)
    begin
        DocumentType := DocumentType::PaymentVAT;
        Post(SalesAdvLetterEntry, Preview);
    end;

    procedure PostPaymentUsageVAT(var SalesAdvLetterEntry: Record "Sales Adv. Letter Entry CZZ"; Preview: Boolean)
    begin
        DocumentType := DocumentType::PaymentUsageVAT;
        Post(SalesAdvLetterEntry, Preview);
    end;

    procedure PostCreditMemoVAT(var SalesAdvLetterEntry: Record "Sales Adv. Letter Entry CZZ"; Preview: Boolean)
    begin
        DocumentType := DocumentType::CreditMemoVAT;
        Post(SalesAdvLetterEntry, Preview);
    end;

    local procedure Post(var SalesAdvLetterEntry: Record "Sales Adv. Letter Entry CZZ"; Preview: Boolean)
    begin
        if Preview then begin
            PostPreview(SalesAdvLetterEntry);
            exit;
        end;
        Run(SalesAdvLetterEntry);
    end;

    procedure SetPreviewMode(NewPreviewMode: Boolean)
    begin
        PreviewMode := NewPreviewMode;
    end;

    procedure SetDocumentType(NewDocumentType: Option PaymentVAT,PaymentUsageVAT,CreditMemoVAT)
    begin
        DocumentType := NewDocumentType;
    end;

    procedure PostPreview(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    var
        SalesPostAdvanceLetterCZZ: Codeunit "Sales Post Advance Letter CZZ";
    begin
        BindSubscription(SalesPostAdvanceLetterCZZ);
        SalesPostAdvanceLetterCZZ.SetDocumentType(DocumentType);
        Clear(GenJnlPostPreview);
        GenJnlPostPreview.Preview(SalesPostAdvanceLetterCZZ, SalesAdvLetterEntryCZZ);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnRunPreview', '', false, false)]
    local procedure OnRunPreview(var Result: Boolean; Subscriber: Variant; RecVar: Variant)
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesPostAdvanceLetterCZZ: Codeunit "Sales Post Advance Letter CZZ";
    begin
        SalesAdvLetterEntryCZZ.Copy(RecVar);
        SalesPostAdvanceLetterCZZ.SetPreviewMode(true);
        SalesPostAdvanceLetterCZZ.SetDocumentType(DocumentType);
        Result := SalesPostAdvanceLetterCZZ.Run(SalesAdvLetterEntryCZZ);
    end;
}
