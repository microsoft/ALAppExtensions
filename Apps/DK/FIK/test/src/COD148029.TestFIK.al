// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

Codeunit 148029 TestFIK
{

    Subtype = Test;
    TestPermissions = Disabled;

    VAR
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        Initialized: Boolean;
        CorrectFIK71: Text[15];
        WrongFIK71: Text[15];
        FIK71Weight: Text[14];
        CorrectFIK04: Text[16];
        WrongFIK04: Text[16];
        FIK04Weight: Text[15];
        ShortFIK0471: Text[4];
        ControlCypherErr: Label 'The expected control cypher does not match the actual.';
        WrongFIKErr: Label 'The Payment Reference that you entered does not have the correct control cipher.';
        FIKLengthErr: Label 'Payment Reference for %1 cannot be longer than %2.';
        PmtReferenceErr: Label '%1 should be blank for %2 %3.', Comment = '%1=Field;%2=Table;%3=Field', Locked = true;
        RecordNotFoundErr: Label '%1 was not found.', Comment = '%1=Table', Locked = true;
        PostingErr: Label 'Payment Reference should be blank for payment method %1.', Comment = '%1 table caption, %2 option value', Locked = true;
        TestFieldLedgerErr: Label '%1 must have a value in %2: %3=%4. It cannot be zero or empty.', Locked = true;
        TestFieldPurchInvErr: Label '%1 must have a value in %2: %3=%4, %5=%6. It cannot be zero or empty.', Locked = true;
        TestFieldGenJnlLineErr: Label '%1 must have a value in %2: %3=%4, %5=%6, %7=%8. It cannot be zero or empty.', Locked = true;
        TestFieldPaymentMethodErr: Label '%1 must not be %2 in %3: %4=%5', Locked = true;
        PaddingErr: Label 'Field value is not padded correctly.', Locked = true;
        LengthErr: Label 'Padded value does not have correct length.', Locked = true;

    trigger OnRun();
    begin
        // [FEATURE] [FIK]
    end;

    [Test]
    PROCEDURE TestGenerationOfControlCiffers();
    BEGIN
        CleanUp();
        Initialize();

        VerifyGenerationOfControlCiffer('10', '9');
        VerifyGenerationOfControlCiffer('20', '8');
        VerifyGenerationOfControlCiffer('30', '7');
        VerifyGenerationOfControlCiffer('40', '6');
        VerifyGenerationOfControlCiffer('50', '5');
        VerifyGenerationOfControlCiffer('60', '4');
        VerifyGenerationOfControlCiffer('70', '3');
        VerifyGenerationOfControlCiffer('80', '2');
        VerifyGenerationOfControlCiffer('90', '1');
        VerifyGenerationOfControlCiffer('00', '0');
        VerifyGenerationOfControlCiffer('23', '2');
        VerifyGenerationOfControlCiffer('67', '9');
        VerifyGenerationOfControlCiffer('05', '9');
        VerifyGenerationOfControlCiffer(CopyStr(PADSTR('', 14, '1'), 1, 20), '9');
        VerifyGenerationOfControlCiffer(CopyStr(PADSTR('', 14, '2'), 1, 20), '8');
    END;

    [Test]
    PROCEDURE TestBoundariesExpectBlank();
    VAR
        CompanyInformation: Record "Company Information";
    BEGIN
        Initialize();

        VerifyGenerationOfControlCiffer(CopyStr(PADSTR('', 20, '2'), 1, 20), '');
        VerifyGenerationOfControlCiffer(CopyStr(PADSTR('', 15, '2'), 1, 20), '');
        VerifyGenerationOfControlCiffer('A', '');
        CompanyInformation.GET();
        CompanyInformation.BankCreditorNo := '';
        CompanyInformation.MODIFY();
        VerifyGenerationOfControlCiffer('00', '');
    END;

    LOCAL PROCEDURE VerifyGenerationOfControlCiffer(InvoiceNo: Code[20]; ExpectedControlDigit: Code[1]);
    VAR
        SalesInvoiceHeader: Record "Sales Invoice Header";
        FIKManagement: Codeunit FIKManagement;
    BEGIN
        Initialize();

        SalesInvoiceHeader."No." := InvoiceNo;
        Assert.AreEqual(ExpectedControlDigit, COPYSTR(FIKManagement.GetFIK71String(SalesInvoiceHeader."No."), 19, 1), ControlCypherErr);
    END;

    [Test]
    PROCEDURE ValidateFIK71();
    VAR
        PaymentMethod: Record "Payment Method";
        FIKManagement: Codeunit FIKManagement;
    BEGIN
        Initialize();

        CreatePaymentMethod(PaymentMethod, PaymentMethod.PaymentTypeValidation::"FIK 71");
        FIKManagement.EvaluateFIK(CorrectFIK71, PaymentMethod.Code);
    END;

    [Test]
    PROCEDURE ValidateFIK71LengthOnPurchInvError();
    VAR
        PaymentMethod: Record "Payment Method";
        PurchHeader: Record "Purchase Header";
        VendorNo: Code[20];
    BEGIN
        Initialize();

        // Setup
        VendorNo := CreateVendorWithPaymentMethod(PaymentMethod.PaymentTypeValidation::"FIK 71");
        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Invoice, VendorNo);

        // Exercise
        ASSERTERROR PurchHeader.VALIDATE("Payment Reference",
            FORMAT(LibraryRandom.RandIntInRange(11111111, 99999999)) + FORMAT(LibraryRandom.RandIntInRange(11111111, 99999999)));

        // Verify
        Assert.ExpectedError(STRSUBSTNO(FIKLengthErr, PaymentMethod.PaymentTypeValidation::"FIK 71", 15));
    END;

    [Test]
    PROCEDURE ValidateFIK71LengthOnGenJnlError();
    VAR
        PaymentMethod: Record "Payment Method";
        GenJnlLine: Record "Gen. Journal Line";
    BEGIN
        Initialize();

        // Setup
        CreateGenJnlLine(GenJnlLine, PaymentMethod.PaymentTypeValidation::"FIK 71");

        // Exercise
        ASSERTERROR GenJnlLine.VALIDATE("Payment Reference",
            FORMAT(LibraryRandom.RandIntInRange(11111111, 99999999)) + FORMAT(LibraryRandom.RandIntInRange(11111111, 99999999)));

        // Verify
        Assert.ExpectedError(STRSUBSTNO(FIKLengthErr, PaymentMethod.PaymentTypeValidation::"FIK 71", 15));
    END;

    [Test]
    PROCEDURE ValidateFIK71IsTransferredToLedgerEntry();
    VAR
        PaymentMethod: Record "Payment Method";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorNo: Code[20];
    BEGIN
        Initialize();

        // Setup
        VendorNo := CreateVendorWithPaymentMethod(PaymentMethod.PaymentTypeValidation::"FIK 71");
        LibraryERM.SelectGenJnlBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, VendorNo, LibraryRandom.RandDec(1000, 2));
        GenJnlLine.VALIDATE("Payment Reference", CorrectFIK71);
        GenJnlLine.MODIFY(TRUE);

        // Exercise
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Verify
        VendorLedgerEntry.SETRANGE("Vendor No.", VendorNo);
        VendorLedgerEntry.SETRANGE("Document Type", VendorLedgerEntry."Document Type"::Payment);
        VendorLedgerEntry.FINDLAST();
        VendorLedgerEntry.TESTFIELD("Payment Reference", CorrectFIK71);
    END;

    [Test]
    PROCEDURE ValidateFIK71LengthOnLedgerEntryError();
    VAR
        PaymentMethod: Record "Payment Method";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorNo: Code[20];
    BEGIN
        Initialize();

        // Setup
        VendorNo := CreateVendorWithPaymentMethod(PaymentMethod.PaymentTypeValidation::"FIK 71");

        LibraryERM.SelectGenJnlBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, VendorNo, LibraryRandom.RandDec(1000, 2));
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Exercise
        VendorLedgerEntry.SETRANGE("Vendor No.", VendorNo);
        VendorLedgerEntry.SETRANGE("Document Type", VendorLedgerEntry."Document Type"::Payment);
        VendorLedgerEntry.FINDLAST();
        ASSERTERROR VendorLedgerEntry.VALIDATE("Payment Reference",
            FORMAT(LibraryRandom.RandIntInRange(11111111, 99999999)) + FORMAT(LibraryRandom.RandIntInRange(11111111, 99999999)));

        // Verify
        Assert.ExpectedError(STRSUBSTNO(FIKLengthErr, PaymentMethod.PaymentTypeValidation::"FIK 71", 15));
    END;

    [Test]
    PROCEDURE ValidateFIK71CheckSumOnGenJnl();
    VAR
        PaymentMethod: Record "Payment Method";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        VendorNo: Code[20];
    BEGIN
        Initialize();

        // Setup
        VendorNo := CreateVendorWithPaymentMethod(PaymentMethod.PaymentTypeValidation::"FIK 71");
        LibraryERM.SelectGenJnlBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, VendorNo, LibraryRandom.RandDec(1000, 2));

        // Exercise
        ASSERTERROR GenJnlLine.VALIDATE("Payment Reference", WrongFIK71);

        // Verify
        Assert.ExpectedError(WrongFIKErr);
    END;

    [Test]
    PROCEDURE ValidateFIK04();
    VAR
        PaymentMethod: Record "Payment Method";
        FIKManagement: Codeunit FIKManagement;
    BEGIN
        Initialize();

        CreatePaymentMethod(PaymentMethod, PaymentMethod.PaymentTypeValidation::"FIK 04");
        FIKManagement.EvaluateFIK(CorrectFIK04, PaymentMethod.Code);
    END;

    [Test]
    PROCEDURE ValidateFIK04IsTransferredToLedgerEntry();
    VAR
        PaymentMethod: Record "Payment Method";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorNo: Code[20];
    BEGIN
        Initialize();

        // Setup
        VendorNo := CreateVendorWithPaymentMethod(PaymentMethod.PaymentTypeValidation::"FIK 04");
        LibraryERM.SelectGenJnlBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, VendorNo, LibraryRandom.RandDec(1000, 2));
        GenJnlLine.VALIDATE("Payment Reference", CorrectFIK04);
        GenJnlLine.MODIFY(TRUE);

        // Exercise
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Verify
        VendorLedgerEntry.SETRANGE("Vendor No.", VendorNo);
        VendorLedgerEntry.SETRANGE("Document Type", VendorLedgerEntry."Document Type"::Payment);
        VendorLedgerEntry.FINDLAST();
        VendorLedgerEntry.TESTFIELD("Payment Reference", CorrectFIK04);
    END;

    [Test]
    PROCEDURE ValidateFIK04CheckSumOnGenJnl();
    VAR
        PaymentMethod: Record "Payment Method";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        VendorNo: Code[20];
    BEGIN
        Initialize();

        // Setup
        VendorNo := CreateVendorWithPaymentMethod(PaymentMethod.PaymentTypeValidation::"FIK 04");
        LibraryERM.SelectGenJnlBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, VendorNo, LibraryRandom.RandDec(1000, 2));

        // Exercise
        ASSERTERROR GenJnlLine.VALIDATE("Payment Reference", WrongFIK04);

        // Verify
        Assert.ExpectedError(WrongFIKErr);
    END;

    [Test]
    PROCEDURE ValidateFIK01BlankPmtRefOnGenJnl();
    VAR
        PaymentMethod: Record "Payment Method";
        GenJnlLine: Record "Gen. Journal Line";
    BEGIN
        Initialize();

        // Setup
        CreateGenJnlLine(GenJnlLine, PaymentMethod.PaymentTypeValidation::"FIK 71");
        GenJnlLine.VALIDATE("Payment Reference", CorrectFIK71);
        GenJnlLine.MODIFY(TRUE);

        // Exercise
        CreatePaymentMethod(PaymentMethod, PaymentMethod.PaymentTypeValidation::"FIK 01");
        GenJnlLine.VALIDATE("Payment Method Code", PaymentMethod.Code);
        GenJnlLine.MODIFY(TRUE);

        // Verify
        GenJnlLine.TESTFIELD("Payment Reference", '');
    END;

    [Test]
    PROCEDURE ValidateFIK73BlankPmtRefOnGenJnl();
    VAR
        PaymentMethod: Record "Payment Method";
        GenJnlLine: Record "Gen. Journal Line";
    BEGIN
        Initialize();

        // Setup
        CreateGenJnlLine(GenJnlLine, PaymentMethod.PaymentTypeValidation::"FIK 71");
        GenJnlLine.VALIDATE("Payment Reference", CorrectFIK71);
        GenJnlLine.MODIFY(TRUE);

        // Exercise
        CreatePaymentMethod(PaymentMethod, PaymentMethod.PaymentTypeValidation::"FIK 73");
        GenJnlLine.VALIDATE("Payment Method Code", PaymentMethod.Code);
        GenJnlLine.MODIFY(TRUE);

        // Verify
        GenJnlLine.TESTFIELD("Payment Reference", '');
    END;

    [Test]
    PROCEDURE ValidatePmtMethodTriggersPmtRefCheckOnGenJnl();
    VAR
        PaymentMethod: Record "Payment Method";
        GenJnlLine: Record "Gen. Journal Line";
    BEGIN
        Initialize();

        // Setup
        CreateGenJnlLine(GenJnlLine, PaymentMethod.PaymentTypeValidation::"FIK 04");
        GenJnlLine.VALIDATE("Payment Reference", CorrectFIK04);
        GenJnlLine.MODIFY(TRUE);

        // Exercise
        CreatePaymentMethod(PaymentMethod, PaymentMethod.PaymentTypeValidation::"FIK 71");
        ASSERTERROR GenJnlLine.VALIDATE("Payment Method Code", PaymentMethod.Code);

        // Verify
        Assert.ExpectedError(STRSUBSTNO(FIKLengthErr, PaymentMethod.PaymentTypeValidation::"FIK 71", 15));
    END;

    [Test]
    PROCEDURE ValidatePmtMethodTriggersPmtRefCheckOnVendLedgerEntry();
    VAR
        PaymentMethod: Record "Payment Method";
        GenJnlLine: Record "Gen. Journal Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    BEGIN
        Initialize();

        // Setup
        CreateGenJnlLine(GenJnlLine, PaymentMethod.PaymentTypeValidation::"FIK 04");
        CreatePaymentMethod(PaymentMethod, PaymentMethod.PaymentTypeValidation::"FIK 71");

        LibraryERM.PostGeneralJnlLine(GenJnlLine);
        VendorLedgerEntry.SETRANGE("Vendor No.", GenJnlLine."Account No.");
        VendorLedgerEntry.SETRANGE("Document Type", VendorLedgerEntry."Document Type"::Payment);
        VendorLedgerEntry.FINDLAST();
        VendorLedgerEntry.VALIDATE("Payment Reference", CorrectFIK04);
        VendorLedgerEntry.MODIFY(TRUE);

        // Exercise
        ASSERTERROR VendorLedgerEntry.VALIDATE("Payment Method Code", PaymentMethod.Code);

        // Verify
        Assert.ExpectedError(STRSUBSTNO(FIKLengthErr, PaymentMethod.PaymentTypeValidation::"FIK 71", 15));
    END;

    [Test]
    PROCEDURE ValidateFIK01BlankPmtRefOnPurchInv();
    VAR
        PaymentMethod: Record "Payment Method";
        PurchHeader: Record "Purchase Header";
        VendorNo: Code[20];
    BEGIN
        Initialize();

        // Setup
        VendorNo := CreateVendorWithPaymentMethod(PaymentMethod.PaymentTypeValidation::"FIK 71");
        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Invoice, VendorNo);
        PurchHeader.VALIDATE("Payment Reference", CorrectFIK71);
        PurchHeader.MODIFY(TRUE);

        // Exercise
        CreatePaymentMethod(PaymentMethod, PaymentMethod.PaymentTypeValidation::"FIK 01");
        PurchHeader.VALIDATE("Payment Method Code", PaymentMethod.Code);
        PurchHeader.MODIFY(TRUE);

        // Verify
        PurchHeader.TESTFIELD("Payment Reference", '');
    END;

    [Test]
    PROCEDURE ValidateFIK73BlankPmtRefOnPurchInv();
    VAR
        PaymentMethod: Record "Payment Method";
        PurchHeader: Record "Purchase Header";
        VendorNo: Code[20];
    BEGIN
        Initialize();

        // Setup
        VendorNo := CreateVendorWithPaymentMethod(PaymentMethod.PaymentTypeValidation::"FIK 71");
        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Invoice, VendorNo);
        PurchHeader.VALIDATE("Payment Reference", CorrectFIK71);
        PurchHeader.MODIFY(TRUE);

        // Exercise
        CreatePaymentMethod(PaymentMethod, PaymentMethod.PaymentTypeValidation::"FIK 73");
        PurchHeader.VALIDATE("Payment Method Code", PaymentMethod.Code);
        PurchHeader.MODIFY(TRUE);

        // Verify
        PurchHeader.TESTFIELD("Payment Reference", '');
    END;

    [Test]
    PROCEDURE UpdateFIK71OnVendorLedgerEntry();
    VAR
        PaymentMethod: Record "Payment Method";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorNo: Code[20];
    BEGIN
        Initialize();

        // Setup
        VendorNo := CreateVendorWithPaymentMethod(PaymentMethod.PaymentTypeValidation::"FIK 71");
        LibraryERM.SelectGenJnlBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, VendorNo, LibraryRandom.RandDec(1000, 2));
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Exercise
        VendorLedgerEntry.SETRANGE("Vendor No.", VendorNo);
        VendorLedgerEntry.SETRANGE("Document Type", VendorLedgerEntry."Document Type"::Payment);
        VendorLedgerEntry.FINDLAST();
        VendorLedgerEntry.VALIDATE("Payment Reference", CorrectFIK71);
        CODEUNIT.RUN(CODEUNIT::"Vend. Entry-Edit", VendorLedgerEntry);

        // Verify
        VendorLedgerEntry.SETRANGE("Vendor No.", VendorNo);
        VendorLedgerEntry.SETRANGE("Document Type", VendorLedgerEntry."Document Type"::Payment);
        VendorLedgerEntry.SETRANGE("Payment Reference", CorrectFIK71);
        Assert.IsFalse(VendorLedgerEntry.ISEMPTY(), STRSUBSTNO(RecordNotFoundErr, VendorLedgerEntry.TABLECAPTION()));
    END;

    [Test]
    PROCEDURE UpdateFIK01PmtRefOnVendorLedgerEntryError();
    VAR
        PaymentMethod: Record "Payment Method";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorNo: Code[20];
    BEGIN
        Initialize();

        // Setup
        VendorNo := CreateVendorWithPaymentMethod(PaymentMethod.PaymentTypeValidation::"FIK 01");
        LibraryERM.SelectGenJnlBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, VendorNo, LibraryRandom.RandDec(1000, 2));
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Exercise
        VendorLedgerEntry.SETRANGE("Vendor No.", VendorNo);
        VendorLedgerEntry.SETRANGE("Document Type", VendorLedgerEntry."Document Type"::Payment);
        VendorLedgerEntry.FINDLAST();
        ASSERTERROR VendorLedgerEntry.VALIDATE("Payment Reference", CorrectFIK71);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(PmtReferenceErr, VendorLedgerEntry.FIELDCAPTION("Payment Reference"),
            PaymentMethod.TABLECAPTION(), VendorLedgerEntry."Payment Method Code"));
    END;

    [Test]
    PROCEDURE UpdateFIK73PmtRefOnVendorLedgerEntryError();
    VAR
        PaymentMethod: Record "Payment Method";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorNo: Code[20];
    BEGIN
        Initialize();

        // Setup
        VendorNo := CreateVendorWithPaymentMethod(PaymentMethod.PaymentTypeValidation::"FIK 73");
        LibraryERM.SelectGenJnlBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, VendorNo, LibraryRandom.RandDec(1000, 2));
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Exercise
        VendorLedgerEntry.SETRANGE("Vendor No.", VendorNo);
        VendorLedgerEntry.SETRANGE("Document Type", VendorLedgerEntry."Document Type"::Payment);
        VendorLedgerEntry.FINDLAST();
        ASSERTERROR VendorLedgerEntry.VALIDATE("Payment Reference", CorrectFIK71);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(PmtReferenceErr, VendorLedgerEntry.FIELDCAPTION("Payment Reference"),
            PaymentMethod.TABLECAPTION(), VendorLedgerEntry."Payment Method Code"));
    END;

    [Test]
    PROCEDURE UpdateFIK01PmtRefOnGenJnlEntryError();
    VAR
        PaymentMethod: Record "Payment Method";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        VendorNo: Code[20];
    BEGIN
        Initialize();

        // Setup
        VendorNo := CreateVendorWithPaymentMethod(PaymentMethod.PaymentTypeValidation::"FIK 01");
        LibraryERM.SelectGenJnlBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, VendorNo, LibraryRandom.RandDec(1000, 2));

        // Exercise
        ASSERTERROR GenJnlLine.VALIDATE("Payment Reference", CorrectFIK71);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(PmtReferenceErr, GenJnlLine.FIELDCAPTION("Payment Reference"),
            PaymentMethod.TABLECAPTION(), GenJnlLine."Payment Method Code"));
    END;

    [Test]
    PROCEDURE UpdateFIK73PmtRefOnGenJnlEntryError();
    VAR
        PaymentMethod: Record "Payment Method";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        VendorNo: Code[20];
    BEGIN
        Initialize();

        // Setup
        VendorNo := CreateVendorWithPaymentMethod(PaymentMethod.PaymentTypeValidation::"FIK 73");
        LibraryERM.SelectGenJnlBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, VendorNo, LibraryRandom.RandDec(1000, 2));

        // Exercise
        ASSERTERROR GenJnlLine.VALIDATE("Payment Reference", CorrectFIK71);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(PmtReferenceErr, GenJnlLine.FIELDCAPTION("Payment Reference"),
            PaymentMethod.TABLECAPTION(), GenJnlLine."Payment Method Code"));
    END;

    [Test]
    PROCEDURE UpdateFIK01PmtRefOnPurchInvEntryError();
    VAR
        PaymentMethod: Record "Payment Method";
        PurchHeader: Record "Purchase Header";
        VendorNo: Code[20];
    BEGIN
        Initialize();

        // Setup
        VendorNo := CreateVendorWithPaymentMethod(PaymentMethod.PaymentTypeValidation::"FIK 01");
        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Invoice, VendorNo);

        // Exercise
        ASSERTERROR PurchHeader.VALIDATE("Payment Reference", CorrectFIK71);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(PmtReferenceErr, PurchHeader.FIELDCAPTION("Payment Reference"),
            PaymentMethod.TABLECAPTION(), PurchHeader."Payment Method Code"));
    END;

    [Test]
    PROCEDURE UpdateFIK73PmtRefOnPurchInvEntryError();
    VAR
        PaymentMethod: Record "Payment Method";
        PurchHeader: Record "Purchase Header";
        VendorNo: Code[20];
    BEGIN
        Initialize();

        // Setup
        VendorNo := CreateVendorWithPaymentMethod(PaymentMethod.PaymentTypeValidation::"FIK 73");
        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Invoice, VendorNo);

        // Exercise
        ASSERTERROR PurchHeader.VALIDATE("Payment Reference", CorrectFIK71);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(PmtReferenceErr, PurchHeader.FIELDCAPTION("Payment Reference"),
            PaymentMethod.TABLECAPTION(), PurchHeader."Payment Method Code"));
    END;

    [Test]
    PROCEDURE ValidateFIK71OnPostPurchInv();
    VAR
        PaymentMethod: Record "Payment Method";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        Item: Record Item;
        VendorNo: Code[20];
    BEGIN
        Initialize();

        // Setup
        VendorNo := CreateVendorWithPaymentMethod(PaymentMethod.PaymentTypeValidation::"FIK 71");
        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Invoice, VendorNo);
        LibraryPurchase.CreatePurchaseLine(PurchLine, PurchHeader, PurchLine.Type::Item, LibraryInventory.CreateItem(Item), 1);
        PurchHeader.VALIDATE("Payment Reference", CorrectFIK71);
        PurchHeader.MODIFY(TRUE);

        // Exercise
        PaymentMethod.GET(PurchHeader."Payment Method Code");
        PaymentMethod.VALIDATE(PaymentTypeValidation, PaymentMethod.PaymentTypeValidation::"FIK 73");
        PaymentMethod.MODIFY(TRUE);

        // Verify
        ASSERTERROR LibraryPurchase.PostPurchaseDocument(PurchHeader, TRUE, TRUE);
        Assert.ExpectedError(STRSUBSTNO(PostingErr, PaymentMethod.PaymentTypeValidation));
    END;

    [Test]
    PROCEDURE ValidateFIK71OnPostGenJnlLine();
    VAR
        PaymentMethod: Record "Payment Method";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        VendorNo: Code[20];
    BEGIN
        Initialize();

        // Setup
        VendorNo := CreateVendorWithPaymentMethod(PaymentMethod.PaymentTypeValidation::"FIK 71");
        LibraryERM.SelectGenJnlBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, VendorNo, LibraryRandom.RandDec(1000, 2));
        GenJnlLine.VALIDATE("Payment Reference", CorrectFIK71);
        GenJnlLine.MODIFY(TRUE);

        PaymentMethod.GET(GenJnlLine."Payment Method Code");
        PaymentMethod.VALIDATE(PaymentTypeValidation, PaymentMethod.PaymentTypeValidation::"FIK 73");
        PaymentMethod.MODIFY(TRUE);

        ASSERTERROR LibraryERM.PostGeneralJnlLine(GenJnlLine);
        Assert.ExpectedError(STRSUBSTNO(PostingErr, PaymentMethod.PaymentTypeValidation));
    END;

    [Test]
    PROCEDURE TestFieldPaymentMethodGenJnlLineError();
    VAR
        PaymentMethod: Record "Payment Method";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        VendorNo: Code[20];
    BEGIN
        Initialize();

        // Setup
        VendorNo := CreateVendorWithPaymentMethod(PaymentMethod.PaymentTypeValidation::"FIK 71");
        LibraryERM.SelectGenJnlBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, VendorNo, LibraryRandom.RandDec(1000, 2));
        GenJnlLine.VALIDATE("Payment Method Code", '');

        // Exercise
        ASSERTERROR GenJnlLine.VALIDATE("Payment Reference", CorrectFIK71);

        // Verify
        Assert.ExpectedError(STRSUBSTNO(TestFieldGenJnlLineErr, GenJnlLine.FIELDCAPTION("Payment Method Code"), GenJnlLine.TABLECAPTION(),
          GenJnlLine.FIELDCAPTION("Journal Template Name"), GenJnlLine."Journal Template Name",
          GenJnlLine.FIELDCAPTION("Journal Batch Name"), GenJnlLine."Journal Batch Name",
          GenJnlLine.FIELDCAPTION("Line No."), FORMAT(GenJnlLine."Line No.")));
        //Assert.ExpectedError(TestFieldGenJnlLineErr);
    END;

    [Test]
    PROCEDURE TestFieldPaymentTypeValidationGenJnlLineError();
    VAR
        PaymentMethod: Record "Payment Method";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        VendorNo: Code[20];
    BEGIN
        Initialize();

        // Setup
        VendorNo := CreateVendorWithPaymentMethod(PaymentMethod.PaymentTypeValidation::"FIK 71");
        LibraryERM.SelectGenJnlBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, VendorNo, LibraryRandom.RandDec(1000, 2));

        PaymentMethod.GET(GenJnlLine."Payment Method Code");
        PaymentMethod.VALIDATE(PaymentTypeValidation, PaymentMethod.PaymentTypeValidation::" ");
        PaymentMethod.MODIFY();

        // Exercise
        ASSERTERROR GenJnlLine.VALIDATE("Payment Reference", CorrectFIK71);

        // Verify
        Assert.ExpectedError(STRSUBSTNO(TestFieldPaymentMethodErr, PaymentMethod.FIELDCAPTION(PaymentTypeValidation),
          PaymentMethod.PaymentTypeValidation::" ", PaymentMethod.TABLECAPTION(), PaymentMethod.FIELDCAPTION(Code),
          PaymentMethod.Code));
    END;

    [Test]
    PROCEDURE TestFieldPaymentMethodVendorLedgerEntryError();
    VAR
        PaymentMethod: Record "Payment Method";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorNo: Code[20];
    BEGIN
        Initialize();

        // Setup
        VendorNo := CreateVendorWithPaymentMethod(PaymentMethod.PaymentTypeValidation::"FIK 71");
        LibraryERM.SelectGenJnlBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, VendorNo, LibraryRandom.RandDec(1000, 2));

        LibraryERM.PostGeneralJnlLine(GenJnlLine);
        VendorLedgerEntry.SETRANGE("Vendor No.", VendorNo);
        VendorLedgerEntry.SETRANGE("Document Type", VendorLedgerEntry."Document Type"::Payment);
        VendorLedgerEntry.FINDLAST();
        VendorLedgerEntry.VALIDATE("Payment Method Code", '');

        // Exercise
        ASSERTERROR VendorLedgerEntry.VALIDATE("Payment Reference", CorrectFIK71);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(TestFieldLedgerErr, VendorLedgerEntry.FIELDCAPTION("Payment Method Code"), VendorLedgerEntry.TABLECAPTION(),
            VendorLedgerEntry.FIELDCAPTION("Entry No."), FORMAT(VendorLedgerEntry."Entry No.")));
        //Assert.ExpectedError(TestFieldLedgerErr);
    END;

    [Test]
    PROCEDURE TestFieldPaymentValidationTypeVendorLedgerEntryError();
    VAR
        PaymentMethod: Record "Payment Method";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorNo: Code[20];
    BEGIN
        Initialize();

        // Setup
        VendorNo := CreateVendorWithPaymentMethod(PaymentMethod.PaymentTypeValidation::"FIK 71");
        LibraryERM.SelectGenJnlBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, VendorNo, LibraryRandom.RandDec(1000, 2));

        LibraryERM.PostGeneralJnlLine(GenJnlLine);
        VendorLedgerEntry.SETRANGE("Vendor No.", VendorNo);
        VendorLedgerEntry.SETRANGE("Document Type", VendorLedgerEntry."Document Type"::Payment);
        VendorLedgerEntry.FINDLAST();

        PaymentMethod.GET(VendorLedgerEntry."Payment Method Code");
        PaymentMethod.VALIDATE(PaymentTypeValidation, PaymentMethod.PaymentTypeValidation::" ");
        PaymentMethod.MODIFY();

        // Exercise
        ASSERTERROR VendorLedgerEntry.VALIDATE("Payment Reference", CorrectFIK71);

        // Verify
        Assert.ExpectedError(STRSUBSTNO(TestFieldPaymentMethodErr, PaymentMethod.FIELDCAPTION(PaymentTypeValidation),
          PaymentMethod.PaymentTypeValidation::" ", PaymentMethod.TABLECAPTION(), PaymentMethod.FIELDCAPTION(Code),
          PaymentMethod.Code));
    END;

    [Test]
    PROCEDURE TestFieldPaymentMethodPurchaseInvError();
    VAR
        PaymentMethod: Record "Payment Method";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        Item: Record Item;
        VendorNo: Code[20];
    BEGIN
        Initialize();

        // Setup
        VendorNo := CreateVendorWithPaymentMethod(PaymentMethod.PaymentTypeValidation::"FIK 71");
        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Invoice, VendorNo);
        LibraryPurchase.CreatePurchaseLine(PurchLine, PurchHeader, PurchLine.Type::Item, LibraryInventory.CreateItem(Item), 1);

        // Exercise
        PurchHeader.VALIDATE("Payment Method Code", '');
        ASSERTERROR PurchHeader.VALIDATE("Payment Reference", CorrectFIK71);

        // Verify
        Assert.ExpectedError(STRSUBSTNO(TestFieldPurchInvErr, PurchHeader.FIELDCAPTION("Payment Method Code"), PurchHeader.TABLECAPTION(),
          PurchHeader.FIELDCAPTION("Document Type"), PurchHeader."Document Type"::Invoice,
          PurchHeader.FIELDCAPTION("No."), FORMAT(PurchHeader."No.")));
    END;

    [Test]
    PROCEDURE TestFieldPaymentValidationTypePurchaseInvError();
    VAR
        PaymentMethod: Record "Payment Method";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        Item: Record Item;
        VendorNo: Code[20];
    BEGIN
        Initialize();

        // Setup
        VendorNo := CreateVendorWithPaymentMethod(PaymentMethod.PaymentTypeValidation::"FIK 71");
        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Invoice, VendorNo);
        LibraryPurchase.CreatePurchaseLine(PurchLine, PurchHeader, PurchLine.Type::Item, LibraryInventory.CreateItem(Item), 1);

        // Exercise
        PaymentMethod.GET(PurchHeader."Payment Method Code");
        PaymentMethod.VALIDATE(PaymentTypeValidation, PaymentMethod.PaymentTypeValidation::" ");
        PaymentMethod.MODIFY();

        ClearLastError();
        ASSERTERROR PurchHeader.VALIDATE("Payment Reference", CorrectFIK71);

        // Verify
        Assert.ExpectedError(STRSUBSTNO(TestFieldPaymentMethodErr, PaymentMethod.FIELDCAPTION(PaymentTypeValidation),
          PaymentMethod.PaymentTypeValidation::" ", PaymentMethod.TABLECAPTION(), PaymentMethod.FIELDCAPTION(Code),
          PaymentMethod.Code));
    END;

    [Test]
    PROCEDURE GenJnlLineCreditorNoPadding();
    VAR
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        FIKManagement: Codeunit FIKManagement;
    BEGIN
        Initialize();

        // Pre-Setup
        CreateGenJnlLine(GenJnlLine, PaymentMethod.PaymentTypeValidation::"FIK 71");

        // Exercise
        GenJnlLine.VALIDATE("Creditor No.", FORMAT(LibraryRandom.RandIntInRange(111, 999)));

        // Verify
        Assert.AreEqual(FIKManagement.GetCreditorNoLength(), STRLEN(GenJnlLine."Creditor No."), LengthErr);
        Assert.IsTrue(STRPOS(GenJnlLine."Creditor No.", PADSTR('', 5, '0')) > 0, PaddingErr);
    END;

    [Test]
    PROCEDURE GenJnlLineGiroAccNoPadding();
    VAR
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
    BEGIN
        Initialize();

        // Pre-Setup
        CreateGenJnlLine(GenJnlLine, PaymentMethod.PaymentTypeValidation::"FIK 04");
        // Exercise
        GenJnlLine.VALIDATE(GiroAccNo, FORMAT(LibraryRandom.RandIntInRange(111, 999)));

        // Verify
        Assert.AreEqual(STRLEN(GenJnlLine.GiroAccNo),
          LibraryUtility.GetFieldLength(DATABASE::"Gen. Journal Line", GenJnlLine.FIELDNO(GiroAccNo)), LengthErr);
        Assert.IsTrue(STRPOS(GenJnlLine.GiroAccNo, PADSTR('', 4, '0')) > 0, PaddingErr);
    END;

    [Test]
    PROCEDURE GenJnlLinePaymentReference04Padding();
    VAR
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
    BEGIN
        Initialize();

        // Pre-Setup
        CreateGenJnlLine(GenJnlLine, PaymentMethod.PaymentTypeValidation::"FIK 04");

        // Exercise
        GenJnlLine.VALIDATE("Payment Reference", ShortFIK0471);

        // Verify
        Assert.AreEqual(STRLEN(GenJnlLine."Payment Reference"), 16, LengthErr);
        Assert.IsTrue(STRPOS(GenJnlLine."Payment Reference", PADSTR('', 12, '0')) > 0, PaddingErr);
    END;

    [Test]
    PROCEDURE GenJnlLinePaymentReference71Padding();
    VAR
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
    BEGIN
        Initialize();

        // Pre-Setup
        CreateGenJnlLine(GenJnlLine, PaymentMethod.PaymentTypeValidation::"FIK 71");

        // Exercise
        GenJnlLine.VALIDATE("Payment Reference", ShortFIK0471);

        // Verify
        Assert.AreEqual(STRLEN(GenJnlLine."Payment Reference"), 15, LengthErr);
        Assert.IsTrue(STRPOS(GenJnlLine."Payment Reference", PADSTR('', 11, '0')) > 0, PaddingErr);
    END;

    [Test]
    PROCEDURE VendLedgerEntryCreditorNoPadding();
    VAR
        VendLedgEntry: Record "Vendor Ledger Entry";
        FIKManagement: Codeunit FIKManagement;
    BEGIN
        Initialize();

        // Setup
        VendLedgEntry.SETRANGE("Recipient Bank Account", '');
        VendLedgEntry.FINDLAST();
        // Exercise
        VendLedgEntry.VALIDATE("Creditor No.", FORMAT(LibraryRandom.RandIntInRange(111, 999)));

        // Verify
        Assert.AreEqual(FIKManagement.GetCreditorNoLength(), STRLEN(VendLedgEntry."Creditor No."), LengthErr);
        Assert.IsTrue(STRPOS(VendLedgEntry."Creditor No.", PADSTR('', 5, '0')) > 0, PaddingErr);
    END;

    [Test]
    PROCEDURE VendLedgerEntryGiroAccNoPadding();
    VAR
        VendLedgEntry: Record "Vendor Ledger Entry";
    BEGIN
        Initialize();

        // Setup
        VendLedgEntry.SETRANGE("Recipient Bank Account", '');
        VendLedgEntry.FINDLAST();
        // Exercise
        VendLedgEntry.VALIDATE(GiroAccNo, FORMAT(LibraryRandom.RandIntInRange(111, 999)));

        // Verify
        Assert.AreEqual(STRLEN(VendLedgEntry.GiroAccNo),
          LibraryUtility.GetFieldLength(DATABASE::"Vendor Ledger Entry", VendLedgEntry.FIELDNO(GiroAccNo)), LengthErr);
        Assert.IsTrue(STRPOS(VendLedgEntry.GiroAccNo, PADSTR('', 4, '0')) > 0, PaddingErr);
    END;

    [Test]
    PROCEDURE VendLedgerEntryPaymentReference04Padding();
    VAR
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        VendLedgEntry: Record "Vendor Ledger Entry";
    BEGIN
        Initialize();

        // Pre-Setup
        CreateGenJnlLine(GenJnlLine, PaymentMethod.PaymentTypeValidation::"FIK 04");
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Setup
        VendLedgEntry.SETRANGE("Vendor No.", GenJnlLine."Account No.");
        VendLedgEntry.SETRANGE("Document Type", VendLedgEntry."Document Type"::Payment);
        VendLedgEntry.FINDLAST();

        // Exercise
        VendLedgEntry.VALIDATE("Payment Reference", ShortFIK0471);

        // Verify
        Assert.AreEqual(STRLEN(VendLedgEntry."Payment Reference"), 16, LengthErr);
        Assert.IsTrue(STRPOS(VendLedgEntry."Payment Reference", PADSTR('', 12, '0')) > 0, PaddingErr);
    END;

    [Test]
    PROCEDURE VendLedgerEntryPaymentReference71Padding();
    VAR
        VendLedgEntry: Record "Vendor Ledger Entry";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
    BEGIN
        Initialize();

        // Pre-Setup
        CreateGenJnlLine(GenJnlLine, PaymentMethod.PaymentTypeValidation::"FIK 71");
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Setup
        VendLedgEntry.SETRANGE("Vendor No.", GenJnlLine."Account No.");
        VendLedgEntry.SETRANGE("Document Type", VendLedgEntry."Document Type"::Payment);
        VendLedgEntry.FINDLAST();

        // Exercise
        VendLedgEntry.VALIDATE("Payment Reference", ShortFIK0471);

        // Verify
        Assert.AreEqual(STRLEN(VendLedgEntry."Payment Reference"), 15, LengthErr);
        Assert.IsTrue(STRPOS(VendLedgEntry."Payment Reference", PADSTR('', 11, '0')) > 0, PaddingErr);
    END;

    [Test]
    PROCEDURE PurchInvPaymentReference04Padding();
    VAR
        PaymentMethod: Record "Payment Method";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        Item: Record Item;
        VendorNo: Code[20];
    BEGIN
        Initialize();

        // Setup
        VendorNo := CreateVendorWithPaymentMethod(PaymentMethod.PaymentTypeValidation::"FIK 04");
        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Invoice, VendorNo);
        LibraryPurchase.CreatePurchaseLine(PurchLine, PurchHeader, PurchLine.Type::Item, LibraryInventory.CreateItem(Item), 1);

        // Exercise
        PurchHeader.VALIDATE("Payment Reference", ShortFIK0471);

        // Verify
        Assert.AreEqual(STRLEN(PurchHeader."Payment Reference"), 16, LengthErr);
        Assert.IsTrue(STRPOS(PurchHeader."Payment Reference", PADSTR('', 12, '0')) > 0, PaddingErr);
    END;

    [Test]
    PROCEDURE PurchInvPaymentReference71Padding();
    VAR
        PaymentMethod: Record "Payment Method";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        Item: Record Item;
        VendorNo: Code[20];
    BEGIN
        Initialize();

        // Setup
        VendorNo := CreateVendorWithPaymentMethod(PaymentMethod.PaymentTypeValidation::"FIK 71");
        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Invoice, VendorNo);
        LibraryPurchase.CreatePurchaseLine(PurchLine, PurchHeader, PurchLine.Type::Item, LibraryInventory.CreateItem(Item), 1);

        // Exercise
        PurchHeader.VALIDATE("Payment Reference", ShortFIK0471);

        // Verify
        Assert.AreEqual(STRLEN(PurchHeader."Payment Reference"), 15, LengthErr);
        Assert.IsTrue(STRPOS(PurchHeader."Payment Reference", PADSTR('', 11, '0')) > 0, PaddingErr);
    END;

    [Test]
    PROCEDURE PurchInvCreditorNoPadding();
    VAR
        PaymentMethod: Record "Payment Method";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        Item: Record Item;
        VendorNo: Code[20];
        bla: Integer;
        bla2: Text;
    BEGIN
        Initialize();

        // Setup
        VendorNo := CreateVendorWithPaymentMethod(PaymentMethod.PaymentTypeValidation::"FIK 04");
        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Invoice, VendorNo);
        LibraryPurchase.CreatePurchaseLine(PurchLine, PurchHeader, PurchLine.Type::Item, LibraryInventory.CreateItem(Item), 1);

        // Exercise
        PurchHeader.VALIDATE("Creditor No.", FORMAT(LibraryRandom.RandIntInRange(111, 333)));

        // Verify
        Assert.AreEqual(STRLEN(PurchHeader."Creditor No."), 8, LengthErr);

        bla2 := PadStr(PurchHeader."Creditor No.", 5, '0');
        bla := STRPOS(PurchHeader."Creditor No.", PADSTR('', 5, '0'));
        Assert.IsTrue(STRPOS(PurchHeader."Creditor No.", PADSTR('', 5, '0')) > 0, PaddingErr);
    END;

    [Test]
    PROCEDURE PurchInvGiroAccPadding();
    VAR
        PaymentMethod: Record "Payment Method";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        Item: Record Item;
        VendorNo: Code[20];
    BEGIN
        Initialize();

        // Setup
        VendorNo := CreateVendorWithPaymentMethod(PaymentMethod.PaymentTypeValidation::"FIK 71");
        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Invoice, VendorNo);
        LibraryPurchase.CreatePurchaseLine(PurchLine, PurchHeader, PurchLine.Type::Item, LibraryInventory.CreateItem(Item), 1);

        // Exercise
        PurchHeader.VALIDATE(GiroAccNo, FORMAT(LibraryRandom.RandIntInRange(111, 333)));

        // Verify
        Assert.AreEqual(
          STRLEN(PurchHeader.GiroAccNo),
          LibraryUtility.GetFieldLength(DATABASE::"Purchase Header", PurchHeader.FIELDNO(GiroAccNo)), LengthErr);
        Assert.IsTrue(STRPOS(PurchHeader.GiroAccNo, PADSTR('', 4, '0')) > 0, PaddingErr);
    END;

    [Test]
    PROCEDURE VendorCreditorNoPadding();
    VAR
        Vendor: Record Vendor;
    BEGIN
        Initialize();

        // Setup
        Vendor.INIT();
        // Exercise
        Vendor.VALIDATE(GiroAccNo, FORMAT(LibraryRandom.RandIntInRange(111, 333)));

        // Verify
        Assert.AreEqual(
          STRLEN(Vendor.GiroAccNo), LibraryUtility.GetFieldLength(DATABASE::Vendor, Vendor.FIELDNO(GiroAccNo)), LengthErr);
        Assert.IsTrue(STRPOS(Vendor.GiroAccNo, PADSTR('', 4, '0')) > 0, PaddingErr);
    END;

    [Test]
    PROCEDURE VendorGiroAccPadding();
    VAR
        Vendor: Record Vendor;
    BEGIN
        Initialize();

        // Setup
        Vendor.INIT();
        // Exercise
        Vendor.VALIDATE(GiroAccNo, FORMAT(LibraryRandom.RandIntInRange(111, 333)));

        // Verify
        Assert.AreEqual(
          STRLEN(Vendor.GiroAccNo), LibraryUtility.GetFieldLength(DATABASE::Vendor, Vendor.FIELDNO(GiroAccNo)), LengthErr);
        Assert.IsTrue(STRPOS(Vendor.GiroAccNo, PADSTR('', 4, '0')) > 0, PaddingErr);
    END;

    [Test]
    PROCEDURE BankAccNoPaddingTooShort();
    VAR
        BankAcc: Record "Bank Account";
        BankAccNo: Code[10];
    BEGIN
        Initialize();

        // Setup
        LibraryERM.CreateBankAccount(BankAcc);
        BankAccNo := LibraryUtility.GenerateRandomCode(BankAcc.FIELDNO("Bank Account No."), DATABASE::"Bank Account");
        BankAccNo := COPYSTR(BankAccNo, 1, 9);

        // Exercise.
        BankAcc.VALIDATE("Bank Account No.", BankAccNo);

        // Verify
        Assert.AreEqual(10, STRLEN(BankAcc."Bank Account No."), LengthErr);
        Assert.AreEqual('0', COPYSTR(BankAcc."Bank Account No.", 1, 1), PaddingErr);
    END;

    [Test]
    PROCEDURE BankAccNoPaddingEmpty();
    VAR
        BankAcc: Record "Bank Account";
    BEGIN
        Initialize();

        // Setup
        LibraryERM.CreateBankAccount(BankAcc);

        // Exercise.
        BankAcc.VALIDATE("Bank Account No.", '');

        // Verify
        Assert.AreEqual('', BankAcc."Bank Account No.", PaddingErr);
    END;

    [Test]
    PROCEDURE BankRegNoPaddingTooShort();
    VAR
        BankAcc: Record "Bank Account";
        BankRegNo: Code[10];
    BEGIN
        Initialize();

        // Setup
        LibraryERM.CreateBankAccount(BankAcc);
        BankRegNo := LibraryUtility.GenerateRandomCode(BankAcc.FIELDNO("Bank Branch No."), DATABASE::"Bank Account");
        BankRegNo := COPYSTR(BankRegNo, 1, 3);

        // Exercise.
        BankAcc.VALIDATE("Bank Branch No.", BankRegNo);

        // Verify
        Assert.AreEqual(4, STRLEN(BankAcc."Bank Branch No."), LengthErr);
        Assert.AreEqual('0', COPYSTR(BankAcc."Bank Branch No.", 1, 1), PaddingErr);
    END;

    [Test]
    PROCEDURE BankRegNoPaddingEmpty();
    VAR
        BankAcc: Record "Bank Account";
    BEGIN
        Initialize();

        // Setup
        LibraryERM.CreateBankAccount(BankAcc);

        // Exercise.
        BankAcc.VALIDATE("Bank Branch No.", '');

        // Verify
        Assert.AreEqual('', BankAcc."Bank Branch No.", PaddingErr);
    END;

    [Test]
    PROCEDURE VendorBankAccNoPaddingTooShort();
    VAR
        Vendor: Record Vendor;
        VendorBankAccount: Record "Vendor Bank Account";
        BankAccNo: Code[10];
    BEGIN
        Initialize();

        // Setup
        LibraryPurchase.CreateVendor(Vendor);
        LibraryPurchase.CreateVendorBankAccount(VendorBankAccount, Vendor."No.");
        BankAccNo := LibraryUtility.GenerateRandomCode(VendorBankAccount.FIELDNO("Bank Account No."), DATABASE::"Vendor Bank Account");
        BankAccNo := COPYSTR(BankAccNo, 1, 9);

        // Exercise.
        VendorBankAccount.VALIDATE("Bank Account No.", BankAccNo);

        // Verify
        Assert.AreEqual(10, STRLEN(VendorBankAccount."Bank Account No."), LengthErr);
        Assert.AreEqual('0', COPYSTR(VendorBankAccount."Bank Account No.", 1, 1), PaddingErr);
    END;

    [Test]
    PROCEDURE VendorBankAccNoPaddingEmpty();
    VAR
        Vendor: Record Vendor;
        VendorBankAccount: Record "Vendor Bank Account";
    BEGIN
        Initialize();

        // Setup
        LibraryPurchase.CreateVendor(Vendor);
        LibraryPurchase.CreateVendorBankAccount(VendorBankAccount, Vendor."No.");

        // Exercise.
        VendorBankAccount.VALIDATE("Bank Account No.", '');

        // Verify
        Assert.AreEqual('', VendorBankAccount."Bank Account No.", PaddingErr);
    END;

    [Test]
    PROCEDURE VendorBankRegNoPaddingTooShort();
    VAR
        Vendor: Record Vendor;
        VendorBankAccount: Record "Vendor Bank Account";
        BankRegNo: Code[10];
    BEGIN
        Initialize();

        // Setup
        LibraryPurchase.CreateVendor(Vendor);
        LibraryPurchase.CreateVendorBankAccount(VendorBankAccount, Vendor."No.");
        BankRegNo := LibraryUtility.GenerateRandomCode(VendorBankAccount.FIELDNO("Bank Branch No."), DATABASE::"Vendor Bank Account");
        BankRegNo := COPYSTR(BankRegNo, 1, 3);

        // Exercise.
        VendorBankAccount.VALIDATE("Bank Branch No.", BankRegNo);

        // Verify
        Assert.AreEqual(4, STRLEN(VendorBankAccount."Bank Branch No."), LengthErr);
        Assert.AreEqual('0', COPYSTR(VendorBankAccount."Bank Branch No.", 1, 1), PaddingErr);
    END;

    [Test]
    PROCEDURE VendorBankRegNoPaddingEmpty();
    VAR
        Vendor: Record Vendor;
        VendorBankAccount: Record "Vendor Bank Account";
    BEGIN
        Initialize();

        // Setup
        LibraryPurchase.CreateVendor(Vendor);
        LibraryPurchase.CreateVendorBankAccount(VendorBankAccount, Vendor."No.");

        // Exercise.
        VendorBankAccount.VALIDATE("Bank Branch No.", '');

        // Verify
        Assert.AreEqual('', VendorBankAccount."Bank Branch No.", PaddingErr);
    END;

    [Test]
    PROCEDURE CustomerBankAccNoPaddingTooShort();
    VAR
        Customer: Record Customer;
        CustomerBankAccount: Record "Customer Bank Account";
        BankAccNo: Code[10];
    BEGIN
        Initialize();

        // Setup
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomerBankAccount(CustomerBankAccount, Customer."No.");
        BankAccNo :=
          LibraryUtility.GenerateRandomCode(CustomerBankAccount.FIELDNO("Bank Account No."), DATABASE::"Customer Bank Account");
        BankAccNo := COPYSTR(BankAccNo, 1, 9);

        // Exercise.
        CustomerBankAccount.VALIDATE("Bank Account No.", BankAccNo);

        // Verify
        Assert.AreEqual(10, STRLEN(CustomerBankAccount."Bank Account No."), LengthErr);
        Assert.AreEqual('0', COPYSTR(CustomerBankAccount."Bank Account No.", 1, 1), PaddingErr);
    END;

    [Test]
    PROCEDURE CustomerBankAccNoPaddingEmpty();
    VAR
        Customer: Record Customer;
        CustomerBankAccount: Record "Customer Bank Account";
    BEGIN
        Initialize();

        // Setup
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomerBankAccount(CustomerBankAccount, Customer."No.");

        // Exercise.
        CustomerBankAccount.VALIDATE("Bank Account No.", '');

        // Verify
        Assert.AreEqual('', CustomerBankAccount."Bank Account No.", PaddingErr);
    END;

    [Test]
    PROCEDURE CustomerBankRegNoPaddingTooShort();
    VAR
        Customer: Record Customer;
        CustomerBankAccount: Record "Customer Bank Account";
        BankRegNo: Code[10];
    BEGIN
        Initialize();

        // Setup
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomerBankAccount(CustomerBankAccount, Customer."No.");
        BankRegNo := LibraryUtility.GenerateRandomCode(CustomerBankAccount.FIELDNO("Bank Branch No."), DATABASE::"Customer Bank Account");
        BankRegNo := COPYSTR(BankRegNo, 1, 3);

        // Exercise.
        CustomerBankAccount.VALIDATE("Bank Branch No.", BankRegNo);

        // Verify
        Assert.AreEqual(4, STRLEN(CustomerBankAccount."Bank Branch No."), LengthErr);
        Assert.AreEqual('0', COPYSTR(CustomerBankAccount."Bank Branch No.", 1, 1), PaddingErr);
    END;

    [Test]
    PROCEDURE CustomerBankRegNoPaddingEmpty();
    VAR
        Customer: Record Customer;
        CustomerBankAccount: Record "Customer Bank Account";
    BEGIN
        Initialize();

        // Setup
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomerBankAccount(CustomerBankAccount, Customer."No.");

        // Exercise.
        CustomerBankAccount.VALIDATE("Bank Branch No.", '');

        // Verify
        Assert.AreEqual('', CustomerBankAccount."Bank Branch No.", PaddingErr);
    END;

    [Test]
    procedure VerifyGetCreditorNoLength();
    var
        FIKManagement: Codeunit FIKManagement;
    begin
        // [FEATURE] [UT]
        // [SCENARIO 284643] "Creditor No." length should be 8 digits in FIK
        Assert.AreEqual(8, FIKManagement.GetCreditorNoLength(), '');
    end;

    [Test]
    procedure VerifyFormValidCreditorNo();
    var
        FIKManagement: Codeunit FIKManagement;
        CreditorNo: Code[20];
    begin
        // [FEATURE] [UT]
        // [SCENARIO 284643] "Creditor No." should be padded to standard length with zeroes
        CreditorNo := FORMAT(LibraryRandom.RandIntInRange(111, 999));
        Assert.AreEqual(
            (PADSTR('', FIKManagement.GetCreditorNoLength() - STRLEN(CreditorNo), '0') + CreditorNo),
            FIKManagement.FormValidCreditorNo(CreditorNo),
            '"Creditor No." should be padded to standard length with zeroes');
    end;

    LOCAL PROCEDURE Initialize();
    VAR
        CompanyInformation: Record "Company Information";
    BEGIN
        IF Initialized THEN
            EXIT;
        CompanyInformation.GET();
        CompanyInformation.BankCreditorNo := '12345678';
        CompanyInformation.MODIFY();
        CorrectFIK71 := '000100017156728';
        WrongFIK71 := '000100017156723';
        FIK71Weight := '12121212121212';
        CorrectFIK04 := '2150263480000023';
        WrongFIK04 := '2150263480000025';
        FIK04Weight := '212121212121212';
        ShortFIK0471 := '1875';
        Initialized := TRUE
    END;

    LOCAL PROCEDURE CleanUp();
    VAR
    BEGIN
        Initialized := False;
    END;

    LOCAL PROCEDURE CreateVendorWithPaymentMethod(PaymentForm: Option): Code[20];
    VAR
        PaymentMethod: Record "Payment Method";
        Vendor: Record Vendor;
    BEGIN
        CreatePaymentMethod(PaymentMethod, PaymentForm);
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.VALIDATE("Payment Method Code", PaymentMethod.Code);
        Vendor.VALIDATE("Creditor No.", FORMAT(LibraryRandom.RandIntInRange(11111111, 99999999)));
        Vendor.VALIDATE(GiroAccNo, FORMAT(LibraryRandom.RandIntInRange(1111111, 9999999)));
        Vendor.MODIFY(TRUE);
        EXIT(Vendor."No.");
    END;

    LOCAL PROCEDURE CreatePaymentMethod(VAR PaymentMethod: Record "Payment Method"; PaymentForm: Option);
    BEGIN
        LibraryERM.CreatePaymentMethod(PaymentMethod);
        PaymentMethod.VALIDATE(PaymentTypeValidation, PaymentForm);
        PaymentMethod.MODIFY(TRUE);
    END;

    LOCAL PROCEDURE CreateGenJnlLine(VAR GenJnlLine: Record "Gen. Journal Line"; PaymentForm: Option);
    VAR
        BankAccount: Record "Bank Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        VendorNo: Code[20];
    BEGIN
        VendorNo := CreateVendorWithPaymentMethod(PaymentForm);
        LibraryERM.CreateBankAccount(BankAccount);
        LibraryPurchase.SelectPmtJnlBatch(GenJnlBatch);

        GenJnlBatch.VALIDATE("Bal. Account Type", GenJnlBatch."Bal. Account Type"::"Bank Account");
        GenJnlBatch.VALIDATE("Bal. Account No.", BankAccount."No.");
        GenJnlBatch.MODIFY(TRUE);

        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, VendorNo, LibraryRandom.RandDec(1000, 2));
    END;


}



