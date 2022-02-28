// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139610 SendRemittanceAdvice
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryUtility: Codeunit "Library - Utility";
        IsInitialized: Boolean;

    trigger OnRun()
    begin
        // [FEATURE] [Remittance Advice] [Email]
        IsInitialized := false;
    end;

    [Test]
    [HandlerFunctions('SelectSendingOptionHandler,EmailEditorHandler,CloseEmailEditorHandler')]
    procedure SendRemittanceAdviceFromPaymentJournal()
    begin
        SendRemittanceAdviceFromPaymentJournalInternal();
    end;

    procedure SendRemittanceAdviceFromPaymentJournalInternal()
    var
        CustomReportSelection: Record "Custom Report Selection";
        GenJournalLine: Record "Gen. Journal Line";
        Vendor: Record Vendor;
        LibraryWorkflow: Codeunit "Library - Workflow";
    begin
        // [SCENARIO 339846] Send remittance advice report to vendor by email from Payment Journal using customized Document Sending Profile
        Initialize();
        LibraryWorkflow.SetUpEmailAccount();

        // [GIVEN] Vendor with email
        // [GIVEN] Payment journal line
        // [GIVEN] Custom report selection 
        LibraryPurchase.CreateVendor(Vendor);
        Vendor."E-Mail" := LibraryUtility.GenerateRandomEmail();
        Vendor.Modify(true);
        CreateVendorRemittanceReportSelection(CustomReportSelection.Usage::"V.Remittance", Vendor."No.");
        CreateGenJnlLine(GenJournalLine, Vendor."No.");
        // [WHEN] Open Payment Journal and invoke "Send Remittance Advice" action
        LibraryVariableStorage.Enqueue(Vendor."E-Mail");
        SendFromPaymentJournal(GenJournalLine);
        // [THEN] Email Dialog opened and "To:" = "Email"
    end;

    [Test]
    [HandlerFunctions('SelectSendingOptionHandler,EmailEditorHandler,CloseEmailEditorHandler')]
    procedure SendRemittanceAdviceFromVendorLedgerEntry()
    begin
        SendRemittanceAdviceFromVendorLedgerEntryInternal();
    end;

    procedure SendRemittanceAdviceFromVendorLedgerEntryInternal()
    var
        CustomReportSelection: Record "Custom Report Selection";
        Vendor: Record Vendor;
        LibraryWorkflow: Codeunit "Library - Workflow";
    begin
        // [SCENARIO 339846] Send remittance advice report to vendor by email from Payment Journal using customized Document Sending Profile
        Initialize();
        LibraryWorkflow.SetUpEmailAccount();

        // [GIVEN] Vendor with email
        // [GIVEN] Vendor Ledger Entry
        // [GIVEN] Custom report selection 
        LibraryPurchase.CreateVendor(Vendor);
        Vendor."E-Mail" := LibraryUtility.GenerateRandomEmail();
        Vendor.Modify(true);
        CreateVendorRemittanceReportSelection(CustomReportSelection.Usage::"P.V.Remit.", Vendor."No.");
        MockVendorLedgerEntry(Vendor."No.");
        // [WHEN] Open Vendor Ledger Entries and invoke "Send Remittance Advice" action
        LibraryVariableStorage.Enqueue(Vendor."E-Mail");
        SendFromVendorLedgerEntry(Vendor."No.");
        // [THEN] Email Dialog opened and "To:" = "Email"
    end;

    local procedure Initialize()
    var
        LibraryAzureKVMockMgmt: Codeunit "Library - Azure KV Mock Mgmt.";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::SendRemittanceAdvice);
        LibraryVariableStorage.Clear();
        ResetDefaultDocumentSendingProfile();
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::SendRemittanceAdvice);
        LibraryAzureKVMockMgmt.InitMockAzureKeyvaultSecretProvider();
        LibraryAzureKVMockMgmt.EnsureSecretNameIsAllowed('SmtpSetup');
        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::SendRemittanceAdvice);
    end;

    local procedure CreateVendorRemittanceReportSelection(ReportSelectionUsage: Option; VendorNo: Code[20])
    var
        CustomReportSelection: Record "Custom Report Selection";
        ReportSelections: Record "Report Selections";
    begin
        ReportSelections.DeleteAll();
        CustomReportSelection.DeleteAll();

        CustomReportSelection.Init();
        CustomReportSelection."Source Type" := 23;
        CustomReportSelection."Source No." := VendorNo;
        CustomReportSelection.Usage := ReportSelectionUsage;
        CASE CustomReportSelection.Usage OF
            CustomReportSelection.Usage::"V.Remittance":
                CustomReportSelection."Report ID" := REPORT::"Remittance Advice - Journal";
            CustomReportSelection.Usage::"P.V.Remit.":
                CustomReportSelection."Report ID" := REPORT::"Remittance Advice - Entries";
        END;
        CustomReportSelection."Use for Email Attachment" := TRUE;
        CustomReportSelection.INSERT();

        ReportSelections.Init();
        ReportSelections.Validate(Usage, ReportSelectionUsage);
        ReportSelections.Validate("Report ID", CustomReportSelection."Report ID");
        ReportSelections.Validate("Use for Email Attachment", true);
        ReportSelections.Insert();
    end;

    local procedure CreateGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; VendorNo: Code[20])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        SourceCode: Record "Source Code";
    begin
        GenJournalTemplate.DeleteAll();

        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        GenJournalTemplate.Type := GenJournalTemplate.Type::General;
        LibraryERM.CreateSourceCode(SourceCode);
        GenJournalTemplate."Source Code" := SourceCode.Code;
        GenJournalTemplate.Modify(true);

        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        GenJournalTemplate.Type := GenJournalTemplate.Type::Payments;
        LibraryERM.CreateSourceCode(SourceCode);
        GenJournalTemplate."Source Code" := SourceCode.Code;
        GenJournalTemplate."Page ID" := 256;
        GenJournalTemplate.Modify(true);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryERM.CreateGeneralJnlLine(
            GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
            GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::Vendor,
            VendorNo, 100);
    end;

    local procedure MockVendorLedgerEntry(VendorNo: Code[20])
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        LastEntryNo: Integer;
    begin
        VendorLedgerEntry.FindLast();
        LastEntryNo := VendorLedgerEntry."Entry No.";
        VendorLedgerEntry.Init();
        VendorLedgerEntry."Entry No." := LastEntryNo + 1;
        VendorLedgerEntry."Vendor No." := VendorNo;
        VendorLedgerEntry."Posting Date" := WorkDate();
        VendorLedgerEntry."Document Type" := VendorLedgerEntry."Document Type"::Payment;
        VendorLedgerEntry."Document No." := LibraryUtility.GenerateGUID();
        VendorLedgerEntry.Insert();
    end;

    local procedure SendFromPaymentJournal(GenJournalLine: Record "Gen. Journal Line")
    var
        PaymentJournal: TestPage "Payment Journal";
    begin
        PaymentJournal.OpenEdit();
        PaymentJournal.CurrentJnlBatchName.SetValue(GenJournalLine."Journal Batch Name");
        PaymentJournal.SendRemittanceAdvice.Invoke();
        PaymentJournal.Close();
    end;

    local procedure SendFromVendorLedgerEntry(VendorNo: Code[20])
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorLedgerEntries: TestPage "Vendor Ledger Entries";
    begin
        VendorLedgerEntry.SETRANGE("Vendor No.", VendorNo);
        VendorLedgerEntry.SETRANGE("Document Type", VendorLedgerEntry."Document Type"::Payment);
        VendorLedgerEntry.FINDFIRST();
        VendorLedgerEntries.OPENEDIT();
        VendorLedgerEntries.GOTORECORD(VendorLedgerEntry);
        VendorLedgerEntries.SendRemittanceAdvice.INVOKE();
        VendorLedgerEntries.CLOSE();
    end;

    local procedure ResetDefaultDocumentSendingProfile()
    var
        DocumentSendingProfile: Record "Document Sending Profile";
    begin
        with DocumentSendingProfile do begin
            SetRange(Default, true);
            DeleteAll();

            Validate(Default, true);
            Validate(Description, LibraryUtility.GenerateGUID());
            Validate(Disk, Disk::No);
            Validate(Printer, Printer::No);
            Validate("E-Mail", "E-Mail"::No);
            Validate("Electronic Document", "Electronic Document"::No);
            Insert();
        end;
    end;

    [ModalPageHandler]
    procedure SelectSendingOptionHandler(var SelectSendingOptions: TestPage "Select Sending Options")
    var
        DocumentSendingProfile: Record "Document Sending Profile";
    begin
        SelectSendingOptions."E-Mail".SETVALUE(DocumentSendingProfile."E-Mail"::"Yes (Prompt for Settings)");
        SelectSendingOptions.Disk.SETVALUE(DocumentSendingProfile.Disk::PDF);
        SelectSendingOptions.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure EmailEditorHandler(var EmailEditor: TestPage "Email Editor")
    begin
        EmailEditor.ToField.AssertEquals(LibraryVariableStorage.DequeueText());
    end;

    [StrMenuHandler]
    [Scope('OnPrem')]
    procedure CloseEmailEditorHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Choice := 1;
    end;
}
