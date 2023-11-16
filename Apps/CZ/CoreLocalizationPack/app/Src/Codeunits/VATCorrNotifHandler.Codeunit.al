// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Calculation;

using Microsoft.CRM.Outlook;
using Microsoft.Foundation.Enums;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Utilities;

codeunit 31029 "VAT Corr. Notif. Handler CZL"
{
    [EventSubscriber(ObjectType::Page, Page::"Purchase Invoice", 'OnPostDocumentBeforeNavigateAfterPosting', '', false, false)]
    local procedure ShowVATLCYCorrectionAfterPostingPurchaseInvoice(var PurchaseHeader: Record "Purchase Header"; var PostingCodeunitID: Integer; var Navigate: Enum "Navigate After Posting"; DocumentIsPosted: Boolean; var IsHandled: Boolean)
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        InstructionMgt: Codeunit "Instruction Mgt.";
        InstructionMgtCZL: Codeunit "Instruction Mgt. CZL";
        OfficeManagement: Codeunit "Office Management";
        PostedPurchaseInvoice: Page "Posted Purchase Invoice";
        OpenVATLCYCorrectionQst: Label 'The invoice has been posted in a foreign currency, please check the conversion of the VAT amount to local currency.\\Do you want to open the posted invoice %1 and check now?', Comment = '%1 = posted document number';
        PopUpVATLCYCorrectionCZL: Boolean;
    begin
        if IsHandled then
            exit;
        PurchInvHeader.SetRange("Pre-Assigned No.", PurchaseHeader."No.");
        PurchInvHeader.SetRange("Order No.", '');
        if not PurchInvHeader.FindFirst() then
            exit;
        if not PurchInvHeader.IsVATLCYCorrectionAllowedCZL() then
            exit;

        if OfficeManagement.IsAvailable() then
            PopUpVATLCYCorrectionCZL := true
        else
            if InstructionMgt.IsEnabled(InstructionMgtCZL.ShowVATLCYCorrectionConfirmationMessageCode()) then
                if InstructionMgt.ShowConfirm(StrSubstNo(OpenVATLCYCorrectionQst, PurchInvHeader."No."), InstructionMgtCZL.ShowVATLCYCorrectionConfirmationMessageCode()) then
                    PopUpVATLCYCorrectionCZL := true;

        if not PopUpVATLCYCorrectionCZL then
            exit;

        IsHandled := true;
        PostedPurchaseInvoice.SetTableView(PurchInvHeader);
        PostedPurchaseInvoice.SetRecord(PurchInvHeader);
        PostedPurchaseInvoice.SetRecPopUpVATLCYCorrectionCZL(true);
        PostedPurchaseInvoice.Run();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Posted Purchase Invoice", 'OnAfterGetCurrRecordEvent', '', false, false)]
    local procedure PopUpVATLCYCorrectionCZLOnOpenPostedPurchaseInvoice(var Rec: Record "Purch. Inv. Header")
    begin
        if not Rec.GetPopUpVATLCYCorrectionCZL() then
            exit;
        Rec.SetPopUpVATLCYCorrectionCZL(false);
        Rec.MakeVATLCYCorrectionCZL();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Credit Memo", 'OnPostDocumentBeforeNavigateAfterPosting', '', false, false)]
    local procedure ShowVATLCYCorrectionAfterPostingPurchaseCreditMemo(var PurchaseHeader: Record "Purchase Header"; var PostingCodeunitID: Integer; var Navigate: Enum "Navigate After Posting"; DocumentIsPosted: Boolean; var IsHandled: Boolean)
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        InstructionMgt: Codeunit "Instruction Mgt.";
        InstructionMgtCZL: Codeunit "Instruction Mgt. CZL";
        OfficeManagement: Codeunit "Office Management";
        PostedPurchaseCreditMemo: Page "Posted Purchase Credit Memo";
        OpenVATLCYCorrectionQst: Label 'The credit memo has been posted in a foreign currency, please check the conversion of the VAT amount to local currency.\\Do you want to open the posted credit memo %1 and check now?', Comment = '%1 = posted document number';
        PopUpVATLCYCorrectionCZL: Boolean;
    begin
        if IsHandled then
            exit;
        PurchCrMemoHdr.SetRange("Pre-Assigned No.", PurchaseHeader."No.");
        if not PurchCrMemoHdr.FindFirst() then
            exit;
        if not PurchCrMemoHdr.IsVATLCYCorrectionAllowedCZL() then
            exit;

        if OfficeManagement.IsAvailable() then
            PopUpVATLCYCorrectionCZL := true
        else
            if InstructionMgt.IsEnabled(InstructionMgtCZL.ShowVATLCYCorrectionConfirmationMessageCode()) then
                if InstructionMgt.ShowConfirm(StrSubstNo(OpenVATLCYCorrectionQst, PurchCrMemoHdr."No."), InstructionMgtCZL.ShowVATLCYCorrectionConfirmationMessageCode()) then
                    PopUpVATLCYCorrectionCZL := true;

        if not PopUpVATLCYCorrectionCZL then
            exit;

        IsHandled := true;
        PostedPurchaseCreditMemo.SetTableView(PurchCrMemoHdr);
        PostedPurchaseCreditMemo.SetRecord(PurchCrMemoHdr);
        PostedPurchaseCreditMemo.SetRecPopUpVATLCYCorrectionCZL(true);
        PostedPurchaseCreditMemo.Run();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Posted Purchase Credit Memo", 'OnAfterGetCurrRecordEvent', '', false, false)]
    local procedure PopUpVATLCYCorrectionCZLOnOpenPostedPurchaseCreditMemo(var Rec: Record "Purch. Cr. Memo Hdr.")
    begin
        if not Rec.GetPopUpVATLCYCorrectionCZL() then
            exit;
        Rec.SetPopUpVATLCYCorrectionCZL(false);
        Rec.MakeVATLCYCorrectionCZL();
    end;
}
