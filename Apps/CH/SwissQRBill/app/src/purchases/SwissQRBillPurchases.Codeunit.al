// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.EServices.EDocument;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Vendor;
using Microsoft.Utilities;

codeunit 11502 "Swiss QR-Bill Purchases"
{
    var
        SwissQRBillIncomingDoc: Codeunit "Swiss QR-Bill Incoming Doc";
        ImportSuccessMsg: Label 'QR-Bill successfully imported.';
        ImportAnotherQst: Label 'Do you want to import another QR-Bill?';
        ScanAnotherQst: Label 'Do you want to scan another QR-Bill?';
        ImportWarningTxt: Label 'QR-Bill import warning.';
        ImportCancelledMsg: Label 'QR-Bill import was cancelled.';
        ContinueQst: Label 'Do you want to continue?';
        JournalProcessVendorNotFoundTxt: Label 'Could not find a vendor with IBAN or QR-IBAN:\%1', Comment = '%1 - IBAN value';
        PurchInvoicePmtRefAlreadyExistsTxt: Label 'Purchase invoice with the same payment reference already exists for this vendor:';
        PurchOrderPmtRefAlreadyExistsTxt: Label 'Purchase order with the same payment reference already exists for this vendor:';
        VendorLedgerEntryPmtRefAlreadyExistsTxt: Label 'Vendor ledger entry with the same payment reference already exists for this vendor:';
        JnlLinePmtRefAlreadyExistsTxt: Label 'Purchase journal line with the same payment reference already exists for this vendor:';
        IncDocPmtRefAlreadyExistsTxt: Label 'Incoming Document with the same payment reference already exists for this vendor:';
        PurchDocAlreadyQRImportedQst: Label 'The purchase document already has imported QR-Bill.\\Do you want to continue?';
        PurchDocDiffVendorMsg: Label 'The IBAN/QR-IBAN value from the QR-Bill is used on a vendor bank account belonging to another vendor:\%1 %2.\\On this purchase document you can only scan or import QR-Bills that match the vendor:\%3 %4.', Comment = '%1, %3- vendor numbers, %2, %4 - vendor names';
        PurhDocVendBankAccountQst: Label 'A vendor bank account with IBAN or QR-IBAN\%1\was not found.\\Do you want to create a new vendor bank account?', Comment = '%1 - IBAN value';
        VendorTxt: Label 'Vendor: %1 %2', Comment = '%1 - vendor no., %2 - vendor name';
        PaymentRefTxt: Label 'Payment Reference: %1', Comment = '%1 - payment reference number';
        DocumentNoTxt: Label 'Document No.: %1', Comment = '%1 - document no.';
        VendLedgerEntryTxt: Label 'Vendor Ledger Entry No.: %1', Comment = '%1 - vendor ledger entry no.';
        IncDocEntryTxt: Label 'Incoming Document Entry No.: %1', Comment = '%1 - incoming document entry no.';
        JnlTemplateTxt: Label 'Journal Template Name: %1', Comment = '%1 - journal template name';
        JnlBatchTxt: Label 'Journal Batch Name: %1', Comment = '%1 - journal batch name';
        JnlLineTxt: Label 'Line No.: %1', Comment = '%1 - journal line no.';
        ShowDocumentTxt: Label 'Show the purchase document.';
        ShowVendorLedgerEntryTxt: Label 'Show the vendor ledger entry.';
        ShowPurchaseJournalLineTxt: Label 'Show the purchase journl line.';
        ShowIncomingDocTxt: Label 'Show the incoming document.';
        CurrencyErr: Label 'Purchase document currency must be equal to QR-Bill currency ''%1''. Current value is ''%2''.', Comment = '%1, %2 - currency codes';
        AmountErr: Label 'Purchase document amount must be equal to QR-Bill amount %1. Current value is %2.', Comment = '%1, %2 - amounts';

    internal procedure CheckConfirmIfPmtReferenceAlreadyExist(VendorNo: Code[20]; PmtReference: Code[50]; ImportWarningMsg: Boolean; ShowNotification: Boolean; CheckIncDoc: Boolean) Result: Boolean
    var
        PurchaseHeader: Record "Purchase Header";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        GenJournalLine: Record "Gen. Journal Line";
        IncomingDocument: Record "Incoming Document";
        ConfirmMsg: Text;
    begin
        RecallPmtReferenceNotifications();
        if (PmtReference = '') or (VendorNo = '') then
            exit(true);

        case true of
            FindPurchDocWithPmtReference(PurchaseHeader, VendorNo, PmtReference):
                begin
                    ConfirmMsg := CreatePmtReferencePurchDocMsg(PurchaseHeader);
                    ShowPurchDocPmtReferenceNotification(PurchaseHeader, ShowNotification, ImportWarningMsg);
                end;
            FindJnlLineWithPmtReference(GenJournalLine, VendorNo, PmtReference):
                begin
                    ConfirmMsg := CreatePmtReferenceJnlLineMsg(GenJournalLine);
                    ShowJnlLinePmtReferenceNotification(GenJournalLine, ShowNotification, ImportWarningMsg);
                end;
            CheckIncDoc and FindIncDocWithPmtReference(IncomingDocument, VendorNo, PmtReference):
                begin
                    ConfirmMsg := CreatePmtReferenceIncDocMsg(IncomingDocument);
                    ShowIncDocPmtReferenceNotification(IncomingDocument, ShowNotification, ImportWarningMsg);
                end;
            FindVLEWithPmtReference(VendorLedgerEntry, VendorNo, PmtReference):
                begin
                    ConfirmMsg := CreatePmtReferenceVLEMsg(VendorLedgerEntry);
                    ShowVLEPmtReferenceNotification(VendorLedgerEntry, ShowNotification, ImportWarningMsg);
                end;
        end;

        Result := ConfirmMsg = '';
        if not Result then begin
            ConfirmMsg := ConfirmMsg + '\\' + ContinueQst;
            if ImportWarningMsg then
                ConfirmMsg := ImportWarningTxt + '\\' + ConfirmMsg;
            Result := Confirm(ConfirmMsg);
        end;

        if not Result then
            Error('');
    end;

    local procedure CreatePmtReferencePurchDocMsg(PurchaseHeader: Record "Purchase Header") Result: Text
    begin
        with PurchaseHeader do begin
            if "Document Type" = "Document Type"::Invoice then
                Result := PurchInvoicePmtRefAlreadyExistsTxt
            else
                Result := PurchOrderPmtRefAlreadyExistsTxt;
            AddMessageText(Result, StrSubstNo(VendorTxt, "Pay-to Vendor No.", "Pay-to Name"), '\');
            AddMessageText(Result, StrSubstNo(PaymentRefTxt, "Payment Reference"), '\');
            AddMessageText(Result, StrSubstNo(DocumentNoTxt, "No."), '\');
        end;
    end;

    local procedure CreatePmtReferenceJnlLineMsg(GenJournalLine: Record "Gen. Journal Line") Result: Text
    var
        Vendor: Record Vendor;
    begin
        with GenJournalLine do
            if Vendor.Get("Account No.") then begin
                Result := JnlLinePmtRefAlreadyExistsTxt;
                AddMessageText(Result, StrSubstNo(VendorTxt, "Account No.", Vendor.Name), '\');
                AddMessageText(Result, StrSubstNo(PaymentRefTxt, "Payment Reference"), '\');
                AddMessageText(Result, StrSubstNo(JnlTemplateTxt, "Journal Template Name"), '\');
                AddMessageText(Result, StrSubstNo(JnlBatchTxt, "Journal Batch Name"), '\');
                AddMessageText(Result, StrSubstNo(JnlLineTxt, "Line No."), '\');
            end;
    end;

    local procedure CreatePmtReferenceIncDocMsg(IncomingDocument: Record "Incoming Document") Result: Text
    begin
        with IncomingDocument do begin
            Result := IncDocPmtRefAlreadyExistsTxt;
            AddMessageText(Result, StrSubstNo(VendorTxt, "Vendor No.", "Vendor Name"), '\');
            AddMessageText(Result, StrSubstNo(PaymentRefTxt, "Swiss QR-Bill Reference No."), '\');
            AddMessageText(Result, StrSubstNo(IncDocEntryTxt, "Entry No."), '\');
        end;
    end;

    local procedure CreatePmtReferenceVLEMsg(VendorLedgerEntry: Record "Vendor Ledger Entry") Result: Text
    begin
        with VendorLedgerEntry do begin
            Result := VendorLedgerEntryPmtRefAlreadyExistsTxt;
            AddMessageText(Result, StrSubstNo(VendorTxt, "Vendor No.", "Vendor Name"), '\');
            AddMessageText(Result, StrSubstNo(PaymentRefTxt, "Payment Reference"), '\');
            AddMessageText(Result, StrSubstNo(VendLedgerEntryTxt, "Entry No."), '\');
        end;
    end;

    local procedure RecallPmtReferenceNotifications()
    var
        Notification: Notification;
    begin
        Notification.Id := GetPurchDocPmtReferenceNotifyGuid();
        Notification.Recall();

        Notification.Id := GetVLEPmtReferencetNotifyGuid();
        Notification.Recall();

        Notification.Id := GetJnlLinePmtReferenceNotifyGuid();
        Notification.Recall();

        Notification.Id := GetIncDocPmtReferenceNotifyGuid();
        Notification.Recall();
    end;

    local procedure GetPurchDocPmtReferenceNotifyGuid(): Guid
    begin
        exit('C689C33F-D006-4812-825B-13F24695D50B');
    end;

    local procedure GetVLEPmtReferencetNotifyGuid(): Guid
    begin
        exit('0AB6206F-C714-4B8F-B4AF-A5C1D12A311A');
    end;

    local procedure GetJnlLinePmtReferenceNotifyGuid(): Guid
    begin
        exit('EE2FA3F2-16BE-4465-BD75-356551CA22F6');
    end;

    local procedure GetIncDocPmtReferenceNotifyGuid(): Guid
    begin
        exit('3D5F8500-AC15-456E-B250-0A0E47909F81');
    end;

    local procedure AddMessageText(var TargetMessage: Text; AddText: Text; Sep: Text)
    begin
        TargetMessage += Sep + AddText;
    end;

    local procedure ShowPurchDocPmtReferenceNotification(PurchaseHeader: Record "Purchase Header"; ShowNotification: Boolean; ImportWarningMsg: Boolean)
    var
        Notification: Notification;
        NotifyMessage: Text;
    begin
        if not ShowNotification then
            exit;

        if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Invoice then
            NotifyMessage := PurchInvoicePmtRefAlreadyExistsTxt
        else
            NotifyMessage := PurchOrderPmtRefAlreadyExistsTxt;
        AddMessageText(NotifyMessage, StrSubstNo(VendorTxt, PurchaseHeader."Pay-to Vendor No.", PurchaseHeader."Pay-to Name"), ' ');
        AddMessageText(NotifyMessage, StrSubstNo(PaymentRefTxt, PurchaseHeader."Payment Reference"), ', ');
        AddMessageText(NotifyMessage, StrSubstNo(DocumentNoTxt, PurchaseHeader."No."), ', ');

        if ImportWarningMsg then
            NotifyMessage := ImportWarningTxt + ' ' + NotifyMessage;

        Notification.Id := GetPurchDocPmtReferenceNotifyGuid();
        Notification.Message := NotifyMessage;
        Notification.AddAction(ShowDocumentTxt, Codeunit::"Swiss QR-Bill Purchases", 'ShowPurchDocFromPmtReferenceNotification');
        Notification.Scope := NotificationScope::LocalScope;
        Notification.SetData(PurchaseHeader.FieldName("Document Type"), Format(PurchaseHeader."Document Type"));
        Notification.SetData(PurchaseHeader.FieldName("No."), PurchaseHeader."No.");
        Notification.Send();
    end;

    local procedure ShowVLEPmtReferenceNotification(VendorLedgerEntry: Record "Vendor Ledger Entry"; ShowNotification: Boolean; ImportWarningMsg: Boolean)
    var
        Notification: Notification;
        NotifyMessage: Text;
    begin
        if not ShowNotification then
            exit;

        NotifyMessage := VendorLedgerEntryPmtRefAlreadyExistsTxt;
        AddMessageText(NotifyMessage, StrSubstNo(VendorTxt, VendorLedgerEntry."Vendor No.", VendorLedgerEntry."Vendor Name"), ' ');
        AddMessageText(NotifyMessage, StrSubstNo(PaymentRefTxt, VendorLedgerEntry."Payment Reference"), ', ');
        AddMessageText(NotifyMessage, StrSubstNo(VendLedgerEntryTxt, VendorLedgerEntry."Entry No."), ', ');

        if ImportWarningMsg then
            NotifyMessage := ImportWarningTxt + ' ' + NotifyMessage;

        Notification.Id := GetVLEPmtReferencetNotifyGuid();
        Notification.Message := NotifyMessage;
        Notification.AddAction(ShowVendorLedgerEntryTxt, Codeunit::"Document Notifications", 'ShowVendorLedgerEntry');
        Notification.Scope := NotificationScope::LocalScope;
        Notification.SetData(VendorLedgerEntry.FieldName("Entry No."), Format(VendorLedgerEntry."Entry No."));
        Notification.Send();
    end;

    local procedure ShowJnlLinePmtReferenceNotification(GenJournalLine: Record "Gen. Journal Line"; ShowNotification: Boolean; ImportWarningMsg: Boolean)
    var
        Vendor: Record Vendor;
        Notification: Notification;
        NotifyMessage: Text;
    begin
        if not ShowNotification or not Vendor.Get(GenJournalLine."Account No.") then
            exit;

        NotifyMessage := JnlLinePmtRefAlreadyExistsTxt;
        AddMessageText(NotifyMessage, StrSubstNo(VendorTxt, GenJournalLine."Account No.", Vendor.Name), ' ');
        AddMessageText(NotifyMessage, StrSubstNo(PaymentRefTxt, GenJournalLine."Payment Reference"), ', ');
        AddMessageText(NotifyMessage, StrSubstNo(JnlTemplateTxt, GenJournalLine."Journal Template Name"), ', ');
        AddMessageText(NotifyMessage, StrSubstNo(JnlBatchTxt, GenJournalLine."Journal Batch Name"), ', ');
        AddMessageText(NotifyMessage, StrSubstNo(JnlLineTxt, GenJournalLine."Line No."), ', ');

        if ImportWarningMsg then
            NotifyMessage := ImportWarningTxt + ' ' + NotifyMessage;

        Notification.Id := GetIncDocPmtReferenceNotifyGuid();
        Notification.Message := NotifyMessage;
        Notification.AddAction(
            ShowPurchaseJournalLineTxt, Codeunit::"Swiss QR-Bill Purchases", 'ShowJournalLineFromPmtReferenceNotification');
        Notification.Scope := NotificationScope::LocalScope;
        Notification.SetData(GenJournalLine.FieldName("Journal Template Name"), Format(GenJournalLine."Journal Template Name"));
        Notification.SetData(GenJournalLine.FieldName("Journal Batch Name"), Format(GenJournalLine."Journal Batch Name"));
        Notification.SetData(GenJournalLine.FieldName("Line No."), Format(GenJournalLine."Line No."));
        Notification.Send();
    end;

    local procedure ShowIncDocPmtReferenceNotification(IncomingDocument: Record "Incoming Document"; ShowNotification: Boolean; ImportWarningMsg: Boolean)
    var
        Notification: Notification;
        NotifyMessage: Text;
    begin
        if not ShowNotification then
            exit;

        NotifyMessage := IncDocPmtRefAlreadyExistsTxt;
        AddMessageText(NotifyMessage, StrSubstNo(VendorTxt, IncomingDocument."Vendor No.", IncomingDocument."Vendor Name"), ' ');
        AddMessageText(NotifyMessage, StrSubstNo(PaymentRefTxt, IncomingDocument."Swiss QR-Bill Reference No."), ', ');
        AddMessageText(NotifyMessage, StrSubstNo(IncDocEntryTxt, IncomingDocument."Entry No."), ', ');

        if ImportWarningMsg then
            NotifyMessage := ImportWarningTxt + ' ' + NotifyMessage;

        Notification.Id := GetJnlLinePmtReferenceNotifyGuid();
        Notification.Message := NotifyMessage;
        Notification.AddAction(ShowIncomingDocTxt, Codeunit::"Swiss QR-Bill Purchases", 'ShowIncDocFromPmtReferenceNotification');
        Notification.Scope := NotificationScope::LocalScope;
        Notification.SetData(IncomingDocument.FieldName("Entry No."), Format(IncomingDocument."Entry No."));
        Notification.Send();
    end;

    local procedure FindPurchDocWithPmtReference(var PurchaseHeader: Record "Purchase Header"; VendorNo: Code[20]; PmtReference: Code[50]): Boolean
    begin
        with PurchaseHeader do begin
            SetFilter(
                "Document Type",
                Format("Document Type"::Invoice) + '|' + Format("Document Type"::Order));
            SetRange("Pay-to Vendor No.", VendorNo);
            SetRange("Payment Reference", DelChr(PmtReference));
            exit(FindFirst());
        end;
    end;

    local procedure FindVLEWithPmtReference(var VendorLedgerEntry: Record "Vendor Ledger Entry"; VendorNo: Code[20]; PmtReference: Code[50]): Boolean
    begin
        with VendorLedgerEntry do begin
            SetRange("Document Type", "Document Type"::Invoice);
            SetRange("Vendor No.", VendorNo);
            SetRange("Payment Reference", DelChr(PmtReference));
            SetRange(Reversed, false);
            exit(FindFirst());
        end;
    end;

    local procedure FindJnlLineWithPmtReference(var GenJournalLine: Record "Gen. Journal Line"; VendorNo: Code[20]; PmtReference: Code[50]): Boolean
    begin
        with GenJournalLine do begin
            SetRange("Document Type", "Document Type"::Invoice);
            SetRange("Account Type", "Account Type"::Vendor);
            SetRange("Account No.", VendorNo);
            SetRange("Payment Reference", DelChr(PmtReference));
            exit(FindFirst());
        end;
    end;

    local procedure FindIncDocWithPmtReference(var IncomingDocument: Record "Incoming Document"; VendorNo: Code[20]; PmtReference: Code[50]): Boolean
    begin
        with IncomingDocument do begin
            SetFilter(
                Status,
                Format(Status::New) + '|' + Format(Status::"Pending Approval") + '|' + Format(Status::Released));
            SetRange("Vendor No.", VendorNo);
            SetRange("Swiss QR-Bill Reference No.", DelChr(PmtReference));
            exit(FindFirst());
        end;
    end;

    internal procedure ShowPurchDocFromPmtReferenceNotification(Notification: Notification)
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if not Notification.HasData(PurchaseHeader.FieldName("Document Type")) or
           not Notification.HasData(PurchaseHeader.FieldName("No."))
        then
            exit;

        Evaluate(PurchaseHeader."Document Type", Notification.GetData(PurchaseHeader.FieldName("Document Type")));
        Evaluate(PurchaseHeader."No.", Notification.GetData(PurchaseHeader.FieldName("No.")));
        PurchaseHeader.SetRecFilter();

        case PurchaseHeader."Document Type" of
            PurchaseHeader."Document Type"::Invoice:
                Page.RunModal(Page::"Purchase Invoice", PurchaseHeader);
            PurchaseHeader."Document Type"::Order:
                Page.RunModal(Page::"Purchase Order", PurchaseHeader);
        end;
    end;

    internal procedure ShowJournalLineFromPmtReferenceNotification(Notification: Notification)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        if not Notification.HasData(GenJournalLine.FieldName("Journal Template Name")) or
           not Notification.HasData(GenJournalLine.FieldName("Journal Batch Name")) or
           not Notification.HasData(GenJournalLine.FieldName("Line No."))
        then
            exit;

        Evaluate(GenJournalLine."Journal Template Name", Notification.GetData(GenJournalLine.FieldName("Journal Template Name")));
        Evaluate(GenJournalLine."Journal Batch Name", Notification.GetData(GenJournalLine.FieldName("Journal Batch Name")));
        Evaluate(GenJournalLine."Line No.", Notification.GetData(GenJournalLine.FieldName("Line No.")));
        GenJournalLine.SetRecFilter();
        Page.RunModal(Page::"Purchase Journal", GenJournalLine);
    end;

    internal procedure ShowIncDocFromPmtReferenceNotification(Notification: Notification)
    var
        IncomingDocument: Record "Incoming Document";
    begin
        if not Notification.HasData(IncomingDocument.FieldName("Entry No.")) then
            exit;

        Evaluate(IncomingDocument."Entry No.", Notification.GetData(IncomingDocument.FieldName("Entry No.")));
        IncomingDocument.SetRecFilter();
        Page.RunModal(Page::"Incoming Document", IncomingDocument);
    end;

    internal procedure VoidPurchDocQRBill(var PurchaseHeader: Record "Purchase Header")
    begin
        with PurchaseHeader do begin
            Clear("Payment Reference");
            Clear("Posting Description");
            Clear("Vendor Invoice No.");

            Clear("Swiss QR-Bill");
            Clear("Swiss QR-Bill Amount");
            Clear("Swiss QR-Bill Bill Info");
            Clear("Swiss QR-Bill Currency");
            Clear("Swiss QR-Bill IBAN");
            Clear("Swiss QR-Bill Unstr. Message");
            Modify();
        end;
    end;

    internal procedure UpdatePurchDocFromQRCode(var PurchaseHeader: Record "Purchase Header"; FromFile: Boolean)
    var
        TempIncomingDocument: Record "Incoming Document" temporary;
    begin
        PurchaseHeader.TestField("No.");
        if PurchaseHeader."Swiss QR-Bill" then
            if not Confirm(PurchDocAlreadyQRImportedQst) then
                exit;

        if SwissQRBillIncomingDoc.QRBillImportDecodeToPurchase(TempIncomingDocument, FromFile) then
            ImportToPurchaseDoc(PurchaseHeader, TempIncomingDocument);
    end;

    internal procedure NewPurchaseJournalLineFromQRCode(var GenJournalLine: Record "Gen. Journal Line"; FromFile: Boolean)
    var
        TempIncomingDocument: Record "Incoming Document" temporary;
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        NewGenJournalLine: Record "Gen. Journal Line";
        NoSeriesBatch: Codeunit "No. Series - Batch";
        LastLineNo: Integer;
        Finish: Boolean;
        MessageResult: Text;
        NewDocumentNo: Code[20];
    begin
        GenJournalLine.TestField("Journal Template Name");
        GenJournalLine.TestField("Journal Batch Name");

        NewGenJournalLine.Copy(GenJournalLine);
        PreparePurchaseJournalLine(NewGenJournalLine, GenJournalTemplate, GenJournalBatch, LastLineNo, NewDocumentNo);
        repeat
            Clear(TempIncomingDocument);
            if SwissQRBillIncomingDoc.QRBillImportDecodeToPurchase(TempIncomingDocument, FromFile) then begin
                InitPurchaseJournalLine(NewGenJournalLine, GenJournalTemplate, GenJournalBatch, NewDocumentNo);
                finish := not ImportToPurchaseJournal(NewGenJournalLine, TempIncomingDocument, FromFile, MessageResult);
                if not Finish then begin
                    LastLineNo += 10000;
                    NewGenJournalLine."Line No." := LastLineNo;
                    NewGenJournalLine.Insert();
                    NewDocumentNo := NoSeriesBatch.SimulateGetNextNo(GenJournalBatch."No. Series", NewGenJournalLine."Posting Date", NewDocumentNo);
                    Commit();
                    finish := not Confirm(MessageResult)
                end else
                    Message(MessageResult);
            end else
                finish := true;
        until finish;
    end;

    local procedure PreparePurchaseJournalLine(var GenJournalLine: Record "Gen. Journal Line"; var GenJournalTemplate: Record "Gen. Journal Template"; var GenJournalBatch: Record "Gen. Journal Batch"; var LastLineNo: Integer; var NewDocumentNo: Code[20])
    var
        NoSeriesBatch: Codeunit "No. Series - Batch";
    begin
        with GenJournalLine do begin
            GenJournalTemplate.Get("Journal Template Name");
            GenJournalBatch.Get("Journal Template Name", "Journal Batch Name");
            SetRange("Journal Template Name", "Journal Template Name");
            SetRange("Journal Batch Name", "Journal Batch Name");
            if FindLast() then begin
                LastLineNo := "Line No.";
                NewDocumentNo := "Document No.";
            end;
            if NewDocumentNo = '' then
                NewDocumentNo := NoSeriesBatch.PeekNextNo(GenJournalBatch."No. Series", WorkDate())
            else
                NewDocumentNo := NoSeriesBatch.SimulateGetNextNo(GenJournalBatch."No. Series", GenJournalLine."Posting Date", NewDocumentNo)
        end;
    end;

    local procedure InitPurchaseJournalLine(var GenJournalLine: Record "Gen. Journal Line"; GenJournalTemplate: Record "Gen. Journal Template"; GenJournalBatch: Record "Gen. Journal Batch"; NewDocumentNo: Code[20])
    begin
        with GenJournalLine do begin
            Init();
            "Journal Template Name" := GenJournalTemplate.Name;
            "Journal Batch Name" := GenJournalBatch.Name;
            "Posting Date" := WorkDate();
            "Document No." := NewDocumentNo;
            "Source Code" := GenJournalTemplate."Source Code";
            "Reason Code" := GenJournalBatch."Reason Code";
            "Posting No. Series" := GenJournalBatch."Posting No. Series";
            "Bal. Account Type" := GenJournalBatch."Bal. Account Type";
            Validate("Bal. Account No.", GenJournalBatch."Bal. Account No.");
        end;
    end;

    local procedure ImportToPurchaseJournal(var GenJournalLine: Record "Gen. Journal Line"; IncomingDocument: Record "Incoming Document"; FromFile: Boolean; var MessageResult: Text): Boolean
    begin
        if IncomingDocument."Vendor Bank Account No." = '' then begin
            MessageResult := StrSubstNo(JournalProcessVendorNotFoundTxt, IncomingDocument."Vendor IBAN");
            MessageResult := SwissQRBillIncomingDoc.GetImportFailedTxt() + '\\' + MessageResult;
            exit(false);
        end;

        SwissQRBillIncomingDoc.UpdateGenJournalLineFromIncomingDoc(GenJournalLine, IncomingDocument);
        if FromFile then
            MessageResult := ImportSuccessMsg + '\\' + ImportAnotherQst
        else
            MessageResult := ImportSuccessMsg + '\\' + ScanAnotherQst;

        exit(true);
    end;

    local procedure ImportToPurchaseDoc(var PurchaseHeader: Record "Purchase Header"; IncomingDocument: Record "Incoming Document")
    var
        VendorBankAccount: Record "Vendor Bank Account";
        SwissQRBillCreateVendBank: Page "Swiss QR-Bill Create Vend Bank";
        MessageResult: Text;
    begin
        case true of
            (IncomingDocument."Vendor No." <> '') and
            ((IncomingDocument."Vendor No." = PurchaseHeader."Pay-to Vendor No.") or (PurchaseHeader."Pay-to Vendor No." = '')):
                begin
                    SwissQRBillIncomingDoc.UpdatePurchDocFromIncDoc(PurchaseHeader, IncomingDocument);
                    MessageResult := ImportSuccessMsg;
                end;
            (IncomingDocument."Vendor No." <> '') and
            (IncomingDocument."Vendor No." <> PurchaseHeader."Pay-to Vendor No."):
                begin
                    MessageResult :=
                        StrSubstNo(PurchDocDiffVendorMsg,
                            IncomingDocument."Vendor No.", IncomingDocument."Vendor Name",
                            PurchaseHeader."Pay-to Vendor No.", PurchaseHeader."Pay-to Name");
                    MessageResult := SwissQRBillIncomingDoc.GetImportFailedTxt() + '\\' + MessageResult;
                end;
            else begin
                PurchaseHeader.TestField("Pay-to Vendor No.");
                if Confirm(StrSubstNo(PurhDocVendBankAccountQst, IncomingDocument."Vendor IBAN")) then begin
                    VendorBankAccount."Vendor No." := PurchaseHeader."Pay-to Vendor No.";
                    VendorBankAccount.Validate(IBAN, IncomingDocument."Vendor IBAN");
                    VendorBankAccount."Payment Form" := VendorBankAccount."Payment Form"::"Bank Payment Domestic";
                    SwissQRBillCreateVendBank.LookupMode(true);
                    SwissQRBillCreateVendBank.SetDetails(VendorBankAccount);
                    if SwissQRBillCreateVendBank.RunModal() = Action::LookupOK then begin
                        SwissQRBillCreateVendBank.GetDetails(VendorBankAccount);
                        VendorBankAccount.Insert(true);
                        SwissQRBillIncomingDoc.UpdatePurchDocFromIncDoc(PurchaseHeader, IncomingDocument);
                        MessageResult := ImportSuccessMsg;
                    end else
                        MessageResult := ImportCancelledMsg;
                end else
                    MessageResult := ImportCancelledMsg;
            end;
        end;

        Message(MessageResult)
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Post Invoice Events", 'OnPostLedgerEntryOnBeforeGenJnlPostLine', '', false, false)]
    local procedure OnPostLedgerEntryOnBeforeGenJnlPostLine(
            var GenJnlLine: Record "Gen. Journal Line";
            var PurchHeader: Record "Purchase Header";
            var TotalPurchLine: Record "Purchase Line";
            var TotalPurchLineLCY: Record "Purchase Line";
            var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        QRBillCurrencyCode: Code[10];
        ErrText: Text;
    begin
        if PurchHeader."Swiss QR-Bill" and (PurchHeader."Prepayment %" = 0) and (PurchHeader."Swiss QR-Bill Amount" <> 0) then begin
            QRBillCurrencyCode := SwissQRBillIncomingDoc.GetCurrency(PurchHeader."Swiss QR-Bill Currency");
            if PurchHeader."Currency Code" <> QRBillCurrencyCode then begin
                ErrText := StrSubstNo(CurrencyErr, QRBillCurrencyCode, PurchHeader."Currency Code");
                Error(ErrText);
            end;
            if Abs(TotalPurchLine."Amount Including VAT") <> PurchHeader."Swiss QR-Bill Amount" then begin
                ErrText := StrSubstNo(AmountErr, PurchHeader."Swiss QR-Bill Amount", Abs(TotalPurchLine."Amount Including VAT"));
                Error(ErrText);
            end;
            VoidPurchDocQRBill(PurchHeader);
        end;
    end;
}
