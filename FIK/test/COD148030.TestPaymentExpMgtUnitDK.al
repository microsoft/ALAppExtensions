// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148030 "Payment Exp Mgt Unit Test DK"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        BankAccNotFoundErr: Label 'The %1 does not exist.', Locked = true;
        PmtDataExportingFlagErr: Label 'Payment data on %1 exporting status is wrong.', Locked = true;
        IsInitialized: Boolean;
        RollbackChangesErr: Label 'Roll back all the changes.', Locked = true;
        AnyText: Text[20];
        AnyDecimal: Decimal;
        AnyDate: Date;

    trigger OnRun();
    begin
        // [FEATURE] [FIK]
        IsInitialized := FALSE;
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerNo')]
    procedure CustLedgerEntryExportedMarked();
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustomerLedgerEntries: TestPage "Customer Ledger Entries";
    begin
        Initialize();

        // Setup
        CreateCustLedgerEntry(CustLedgerEntry, CustLedgerEntry."Document Type"::Refund, TRUE);

        // Post-Setup
        Assert.IsTrue(CustLedgerEntry."Exported to Payment File", STRSUBSTNO(PmtDataExportingFlagErr, CustLedgerEntry.TABLECAPTION()));

        // Exercise
        CustomerLedgerEntries.OPENVIEW();
        CustomerLedgerEntries.GOTORECORD(CustLedgerEntry);
        CustomerLedgerEntries.ExportPaymentsToFile.INVOKE();

        // Verify
        // Prompt: Export again?

        // Cleanup
        ASSERTERROR ERROR(RollbackChangesErr);
    end;

    [Test]
    procedure CustLedgerEntryNotExportedMarked();
    var
        BankAccount: Record "Bank Account";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustomerLedgerEntries: TestPage "Customer Ledger Entries";
    begin
        Initialize();

        // Setup
        CreateCustLedgerEntry(CustLedgerEntry, CustLedgerEntry."Document Type"::Refund, FALSE);

        // Post-Setup
        Assert.IsFalse(CustLedgerEntry."Exported to Payment File", STRSUBSTNO(PmtDataExportingFlagErr, CustLedgerEntry.TABLECAPTION()));

        // Exercise
        CustomerLedgerEntries.OPENVIEW();
        CustomerLedgerEntries.GOTORECORD(CustLedgerEntry);
        ASSERTERROR CustomerLedgerEntries.ExportPaymentsToFile.INVOKE();

        // Verify
        Assert.ExpectedError(STRSUBSTNO(BankAccNotFoundErr, BankAccount.TABLECAPTION()));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerNo')]
    procedure VendorLedgerEntryExportedMarked();
    var
        VendLedgerEntry: Record "Vendor Ledger Entry";
        VendorLedgerEntries: TestPage "Vendor Ledger Entries";
    begin
        Initialize();

        // Setup
        CreateVendorLedgerEntry(VendLedgerEntry, VendLedgerEntry."Document Type"::Payment, TRUE);

        // Post-Setup
        Assert.IsTrue(VendLedgerEntry."Exported to Payment File", STRSUBSTNO(PmtDataExportingFlagErr, VendLedgerEntry.TABLECAPTION()));

        // Exercise
        VendorLedgerEntries.OPENVIEW();
        VendorLedgerEntries.GOTORECORD(VendLedgerEntry);
        VendorLedgerEntries.ExportPaymentsToFile.INVOKE();

        // Verify
        // Prompt: Export again?

        // Cleanup
        ASSERTERROR ERROR(RollbackChangesErr);
    end;

    [Test]
    procedure VendorLedgerEntryNotExportedMarked();
    var
        BankAccount: Record "Bank Account";
        VendLedgerEntry: Record "Vendor Ledger Entry";
        VendorLedgerEntries: TestPage "Vendor Ledger Entries";
    begin
        Initialize();

        // Setup
        CreateVendorLedgerEntry(VendLedgerEntry, VendLedgerEntry."Document Type"::Payment, FALSE);

        // Post-Setup
        Assert.IsFalse(VendLedgerEntry."Exported to Payment File", STRSUBSTNO(PmtDataExportingFlagErr, VendLedgerEntry.TABLECAPTION()));

        // Exercise
        VendorLedgerEntries.OPENVIEW();
        VendorLedgerEntries.GOTORECORD(VendLedgerEntry);
        ASSERTERROR VendorLedgerEntries.ExportPaymentsToFile.INVOKE();

        // Verify
        Assert.ExpectedError(STRSUBSTNO(BankAccNotFoundErr, BankAccount.TABLECAPTION()));
    end;

    local procedure Initialize();
    var
        PaymentExportData: Record "Payment Export Data";
    begin
        IF IsInitialized THEN
            EXIT;

        IsInitialized := TRUE;

        AnyText := LibraryUtility.GenerateRandomCode(PaymentExportData.FIELDNO("Short Advice"), DATABASE::"Payment Export Data");
        AnyDecimal := LibraryRandom.RandDecInRange(-1000000, 1000000, 2);
        AnyDate := LibraryUtility.GenerateRandomDate(WORKDATE() - 200, WORKDATE() + 200);
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerNo(Question: Text[1024]; var Reply: Boolean);
    begin
        Reply := FALSE;
    end;

    local procedure CreateCustLedgerEntry(var CustLedgerEntry: Record "Cust. Ledger Entry"; DocumentType: Option; Exported: Boolean);
    var
        PaymentMethod: Record "Payment Method";
    begin
        WITH CustLedgerEntry DO BEGIN
            INIT();
            "Entry No." := LastCustLedgerEntryNo() + 1000;
            "Customer No." := LibrarySales.CreateCustomerNo();
            "Posting Date" := WORKDATE();
            "Document Type" := DocumentType;
            "Document No." := LibraryUtility.GenerateGUID();
            Open := TRUE;
            "Due Date" := CALCDATE('<1D>', "Posting Date");
            "Bal. Account Type" := "Bal. Account Type"::"Bank Account";
            "Bal. Account No." := LibraryUtility.GenerateGUID();
            Amount := LibraryRandom.RandDecInRange(100, 1000, 2);
            CreatePaymentMethod(PaymentMethod);
            "Payment Method Code" := PaymentMethod.Code;
            "Recipient Bank Account" := LibraryUtility.GenerateGUID();
            "Message to Recipient" := LibraryUtility.GenerateGUID();
            "Exported to Payment File" := Exported;
            INSERT();
        END;
    end;

    local procedure CreateVendorLedgerEntry(var VendLedgerEntry: Record "Vendor Ledger Entry"; DocumentType: Option; Exported: Boolean);
    var
        PaymentMethod: Record "Payment Method";
    begin
        WITH VendLedgerEntry DO BEGIN
            INIT();
            "Entry No." := LastVendorLedgerEntryNo() + 1000;
            "Vendor No." := LibraryPurchase.CreateVendorNo();
            "Posting Date" := WORKDATE();
            "Document Type" := DocumentType;
            "Document No." := LibraryUtility.GenerateGUID();
            Open := TRUE;
            "Due Date" := CALCDATE('<1D>', "Posting Date");
            Amount := LibraryRandom.RandDecInRange(100, 1000, 2);
            "Bal. Account Type" := "Bal. Account Type"::"Bank Account";
            "Bal. Account No." := LibraryUtility.GenerateGUID();
            LibraryERM.CreatePaymentMethod(PaymentMethod);
            "Payment Method Code" := PaymentMethod.Code;
            "Recipient Bank Account" := LibraryUtility.GenerateGUID();
            "Message to Recipient" := LibraryUtility.GenerateGUID();
            "Exported to Payment File" := Exported;
            INSERT();
        END;
    end;

    local procedure LastCustLedgerEntryNo(): Integer;
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        IF CustLedgerEntry.FINDLAST() THEN
            EXIT(CustLedgerEntry."Entry No.");
        EXIT(0);
    end;

    local procedure LastVendorLedgerEntryNo(): Integer;
    var
        VendLedgerEntry: Record "Vendor Ledger Entry";
    begin
        IF VendLedgerEntry.FINDLAST() THEN
            EXIT(VendLedgerEntry."Entry No.");
        EXIT(0);
    end;

    local procedure CreatePaymentMethod(var PaymentMethod: Record "Payment Method");
    begin
        LibraryERM.CreatePaymentMethod(PaymentMethod);
        PaymentMethod.VALIDATE(PaymentTypeValidation, PaymentMethod.PaymentTypeValidation::Domestic);
        PaymentMethod.MODIFY(TRUE);
    end;
}



