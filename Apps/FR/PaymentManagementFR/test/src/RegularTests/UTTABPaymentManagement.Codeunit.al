// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;
using System.TestLibraries.Utilities;

codeunit 144040 "UT TAB Payment Management"
{
    // // [FEATURE] [Payment Slip] [UT]
    //   1-3. Purpose of the test is to verify error On Validate Account No. for Vendor with Blocked Type Payment and All and Customer with Blocked Type All of Payment Line table.
    //   4-5. Purpose of the test is to validate On Validate Account No. Trigger Customer with Blocked Type Ship and Invoice of Payment Line table.
    //     6. Purpose of the test is to verify error on OnValidate UnrealizedVAT General Ledger Setup table.
    //   7-8. Purpose of the test is to verify error on OnValidate UnrealizedVAT Reversal Type Delayed and Application Payment Class table.
    //     9. Purpose of this test to verify Payment Class is deleted from Payment Class table.
    //    10. Purpose of this test to verify Payment Class, Payment Status, Payment Step and Payment Step Ledger is deleted when payment slip is not created.
    // 11-12. Purpose of the test is to validate OnValidate trigger of Action Type on Payment Step Card to check Realize VAT control.
    // 
    // Covers Test Cases for WI - 344458
    // ----------------------------------------------------------------------------------------------------------------------------------
    // Test Function Name                                                                                                         TFS ID
    // ----------------------------------------------------------------------------------------------------------------------------------
    // OnValidateAccountNoPmtLineBlockedVendTypePmtError, OnValidateAccountNoPmtLineBlockedVendTypeAllError                       169539
    // OnValidateAccountNoPmtLineBlockedCustTypeAllError, OnValidateAccountNoPmtLineBlockedCustTypeShip                           169540
    // OnValidateAccountNoPmtLineBlockedCustTypeInvoice                                                                           169541
    // 
    // Covers Test Cases for WI - 344508
    // ----------------------------------------------------------------------------------------------------------------------------------
    // Test Function Name                                                                                                         TFS ID
    // ----------------------------------------------------------------------------------------------------------------------------------
    // OnValidateUnrealizedVATGLSetupError                                                                                        169442
    // OnValidateUnrealizedVATReversalTypeDelayedPmtClass                                                                         169443
    // OnValidateUnrealizedVATReversalTypeApplnPmtClass                                                                           169444
    // 
    // Covers Test Cases for WI - 345066
    // ----------------------------------------------------------------------------------------------------------------------------------
    // Test Function Name                                                                                                         TFS ID
    // ----------------------------------------------------------------------------------------------------------------------------------
    // OnDeletePaymentClass                                                                                                       169514
    // OnDeletePaymentClassPaymentSlipNotCreated                                                                                  169530
    // 
    // Covers Test Cases for WI - 345175
    // ----------------------------------------------------------------------------------------------------------------------------------
    // Test Function Name                                                                                                         TFS ID
    // ----------------------------------------------------------------------------------------------------------------------------------
    // OnValidateActionTypeRealizeVATEnablePaymentStepCard                                                                         169525
    // OnValidateActionTypeRealizeVATDisablePaymentStepCard                                                                        169532

    Subtype = Test;
    TestPermissions = Disabled;
    TestType = Uncategorized;
#if not CLEAN28
    EventSubscriberInstance = Manual;
#endif

    trigger OnRun()
    begin
    end;

    var
        Assert: Codeunit Assert;
        LibraryUTUtility: Codeunit "Library UT Utility";
        LibraryDimension: Codeunit "Library - Dimension";
        LibrarySales: Codeunit "Library - Sales";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        DialogErr: Label 'Dialog';
        PaymentClassErr: Label 'Payment Class should not exist.';
        TestFieldErr: Label 'TestField';
        UnexpectedErr: Label 'Expected and Actual value are not same.';

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnValidateAccountNoPmtLineBlockedVendTypePmtError()
    var
        PaymentLine: Record "Payment Line FR";
        Vendor: Record Vendor;
    begin
        // Purpose of the test is to verify error on OnValidate Account No. for Vendor with Blocked Type Payment of Table ID - 10806 Payment Line.
        // Test to verify error "Blocked must be equal to ' '  in Vendor: No.=10:29:57 AMXX002. Current value is 'Payment'".
        OnValidateAccountNoErrorInPaymentLine(
          PaymentLine."Account Type"::Vendor, CreateBlockedVendor(Vendor.Blocked::Payment), TestFieldErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnValidateAccountNoPmtLineBlockedVendTypeAllError()
    var
        PaymentLine: Record "Payment Line FR";
        Vendor: Record Vendor;
    begin
        // Purpose of the test is to verify error on OnValidate Account No. for Vendor with Blocked Type All of Table ID - 10806 Payment Line.
        // Test to verify error "Blocked must be equal to ' '  in Vendor: No.=2:04:38 PMXX004. Current value is 'All'".
        OnValidateAccountNoErrorInPaymentLine(PaymentLine."Account Type"::Vendor, CreateBlockedVendor(Vendor.Blocked::All), TestFieldErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnValidateAccountNoPmtLineBlockedCustTypeAllError()
    var
        Customer: Record Customer;
        PaymentLine: Record "Payment Line FR";
    begin
        // Purpose of the test is to verify error on OnValidate Account No. for Customer with Blocked Type All of Table ID - 10806 Payment Line.
        // Test to verify error "Blocked must not be All in Customer No.='1:29:10 PMXX004'".
        OnValidateAccountNoErrorInPaymentLine(
          PaymentLine."Account Type"::Customer, CreateBlockedCustomer(Customer.Blocked::All), 'NCLCSRTS');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnValidateAccountNoPmtLineBlockedCustTypeShip()
    var
        Customer: Record Customer;
        PaymentLine: Record "Payment Line FR";
    begin
        // Purpose of the test is to check Customer with Blocked Type Ship is validating on Account No. of Table ID - 10806 Payment Line.
        OnValidateAccountNoInPaymentLine(PaymentLine."Account Type"::Customer, CreateBlockedCustomer(Customer.Blocked::Ship));
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnValidateAccountNoPmtLineBlockedCustTypeInvoice()
    var
        Customer: Record Customer;
        PaymentLine: Record "Payment Line FR";
    begin
        // Purpose of the test is to check Customer with Blocked Type Invoice is validating on Account No. of Table ID - 10806 Payment Line.
        OnValidateAccountNoInPaymentLine(PaymentLine."Account Type"::Customer, CreateBlockedCustomer(Customer.Blocked::Invoice));
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnValidateUnrealizedVATGLSetupError()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        PaymentClass: Record "Payment Class FR";
    begin
        // Purpose of the test is to verify error on OnValidate UnrealizedVAT False Table ID - 98 General Ledger Setup.
        // Setup: Update General Ledger Setup and Create Payment Class.

        CreatePaymentClass(PaymentClass);

        // Exercise.
        asserterror GeneralLedgerSetup.Validate("Unrealized VAT", false);

        // Verify: Verify expected error code, Actual error is "Payment Class 4:27:08 PMXX001 has Unrealized VAT Reversal set to Delayed.".
        Assert.ExpectedErrorCode(DialogErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnValidateUnrealizedVATReversalTypeDelayedPmtClass()
    var
        PaymentClass: Record "Payment Class FR";
    begin
        // Purpose of the test is to verify error on OnValidate UnrealizedVAT Reversal Type Delayed Table ID - 10803 Payment Class.
        // Verify error "Unrealized VAT must be equal to 'Yes'  in General Ledger Setup: Primary Key=. Current value is 'No'."
        UnrealizedVATReversalTypePaymentClass(PaymentClass."Unrealized VAT Reversal"::Delayed, TestFieldErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnValidateUnrealizedVATReversalTypeApplnPmtClass()
    var
        PaymentClass: Record "Payment Class FR";
    begin
        // Purpose of the test is to verify error on OnValidate UnrealizedVAT Reversal Type Application Table ID - 10803 Payment Class.
        // Verify error "Payment Class 5:03:16 PMXX001 has at least one Payment Step for which Realize VAT is checked.".
        UnrealizedVATReversalTypePaymentClass(PaymentClass."Unrealized VAT Reversal"::Application, DialogErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnDeletePaymentClass()
    var
        PaymentClass: Record "Payment Class FR";
    begin
        // Purpose of the test is to delete Payment Class.
        // Setup: Create Payment Class.

        CreatePaymentClass(PaymentClass);

        // Exercise.
        PaymentClass.Delete();

        // Verify:  Verify Payment Class is deleted.
        Assert.IsFalse(PaymentClass.Get(PaymentClass.Code), PaymentClassErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnDeletePaymentClassPaymentSlipNotCreated()
    var
        PaymentClass: Record "Payment Class FR";
        PaymentStatus: Record "Payment Status FR";
        PaymentStep: Record "Payment Step FR";
        PaymentStepLedger: Record "Payment Step Ledger FR";
    begin
        // Purpose of the test is to delete Payment Class when Payment Slip is not created.
        // Setup: Create Payment Class, Payment Status, Payment Step and Payment Step Ledger.

        CreatePaymentClass(PaymentClass);
        CreatePaymentStatus(PaymentStatus, PaymentClass.Code);
        CreatePaymentStep(PaymentStep, PaymentClass.Code);
        CreatePaymentStepLedger(PaymentStepLedger, PaymentClass.Code);

        // Excercise.
        PaymentClass.Delete(true);

        // Verify:  Verify Payment Class is deleted in Payment Class, Payment Status, Payment Step and Payment Step Ledger.
        Assert.IsFalse(PaymentClass.Get(PaymentClass.Code), PaymentClassErr);
        Assert.IsTrue(PaymentStatus.IsEmpty(), PaymentClassErr);
        Assert.IsTrue(PaymentStep.IsEmpty(), PaymentClassErr);
        Assert.IsTrue(PaymentStepLedger.IsEmpty(), PaymentClassErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnValidateActionTypeRealizeVATEnablePaymentStepCard()
    var
        PaymentClass: Record "Payment Class FR";
    begin
        // Purpose of the test is to validate OnValidate trigger of Action Type for enable Relize VAT control on Payment Step Card page ID - 10824.
        UnrealizedVATReversalOnPaymentClass(PaymentClass."Unrealized VAT Reversal"::Delayed, true);  // Using True for check control state on page.    
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnValidateActionTypeRealizeVATDisablePaymentStepCard()
    var
        PaymentClass: Record "Payment Class FR";
    begin
        // Purpose of the test is to validate OnValidate trigger of Action Type disable Relize VAT control on Payment Step Card page ID - 10824.
        UnrealizedVATReversalOnPaymentClass(PaymentClass."Unrealized VAT Reversal"::Application, false);  // Using True for check control state on page.    
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure OnValidateShortcutDimension12Code()
    var
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
        DimValue: array[2] of Record "Dimension Value";
        GLSetup: Record "General Ledger Setup";
    begin
        // [FEATURE] [Dimension]
        // [SCENARIO 375959] Payment Line Global Dimension changed after change on Payment Slip
        Initialize();


        // [GIVEN] Payment Header with one line
        CreatePaymentSlip(PaymentLine, PaymentLine."Account Type"::Customer);

        // [GIVEN] 2 global Dimension Values, X1 and X2
        GLSetup.Get();
        LibraryDimension.CreateDimensionValue(DimValue[1], GLSetup."Global Dimension 1 Code");
        LibraryDimension.CreateDimensionValue(DimValue[2], GLSetup."Global Dimension 2 Code");

        // [WHEN] Payment Slip "Department Code" = X1
        PaymentHeader.Get(PaymentLine."No.");
        PaymentHeader.Validate("Shortcut Dimension 1 Code", DimValue[1].Code);
        PaymentHeader.Modify();

        // [THEN] Payment Line "Department Code" = X1
        VerifyPaymentLineDimSetID(PaymentLine, PaymentHeader."Dimension Set ID");

        // [WHEN] Payment Slip "Project Code" = X2
        PaymentHeader.Get(PaymentLine."No.");
        PaymentHeader.Validate("Shortcut Dimension 2 Code", DimValue[2].Code);
        PaymentHeader.Modify();

        // [THEN] Payment Line "Project Code" = X2
        VerifyPaymentLineDimSetID(PaymentLine, PaymentHeader."Dimension Set ID");

        // [WHEN] Payment Slip "Department Code" and "Project Code" cleared
        PaymentHeader.Get(PaymentLine."No.");
        PaymentHeader.Validate("Shortcut Dimension 1 Code", '');
        PaymentHeader.Validate("Shortcut Dimension 2 Code", '');
        PaymentHeader.Modify();

        // [THEN] Payment Line has no Dimensions set
        VerifyPaymentLineDimSetID(PaymentLine, 0);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,DimensionValueListModalPageHandler')]
    procedure OnLookupShortcutDimension12Code()
    var
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
        DimValue: array[2] of Record "Dimension Value";
        GLSetup: Record "General Ledger Setup";
        PaymentSlip: TestPage "Payment Slip FR";
    begin
        // [FEATURE] [Dimension]
        // [SCENARIO 375959] Payment Line Global Dimension changed after change on Payment Slip using Lookup
        Initialize();


        // [GIVEN] Payment Header with one line
        CreatePaymentSlip(PaymentLine, PaymentLine."Account Type"::Customer);

        // [GIVEN] 2 Global Dimension Values, X1 and X2
        GLSetup.Get();
        LibraryDimension.CreateDimensionValue(DimValue[1], GLSetup."Global Dimension 1 Code");
        LibraryDimension.CreateDimensionValue(DimValue[2], GLSetup."Global Dimension 2 Code");

        // [WHEN] Payment Slip "Department Code" = X1 using Lookup
        PaymentHeader.Get(PaymentLine."No.");
        PaymentSlip.OpenEdit();
        PaymentSlip.GotoRecord(PaymentHeader);
        LibraryVariableStorage.Enqueue(DimValue[1]."Dimension Code");
        LibraryVariableStorage.Enqueue(DimValue[1].Code);
        PaymentSlip."Shortcut Dimension 1 Code".Lookup();
        PaymentHeader.FindFirst();

        // [THEN] Payment Line "Department Code" = X1
        VerifyPaymentLineDimSetID(PaymentLine, PaymentHeader."Dimension Set ID");

        // [WHEN] Payment Slip "Project Code" = X2 using Lookup
        LibraryVariableStorage.Enqueue(DimValue[2]."Dimension Code");
        LibraryVariableStorage.Enqueue(DimValue[2].Code);
        PaymentSlip."Shortcut Dimension 2 Code".Lookup();
        PaymentHeader.FindFirst();

        // [THEN] Payment Line "Project Code" = X2
        VerifyPaymentLineDimSetID(PaymentLine, PaymentHeader."Dimension Set ID");
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure PaymentHeaderLineMergeDimension()
    var
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
        DimensionValue: array[2] of Record "Dimension Value";
        GLSetup: Record "General Ledger Setup";
        DimensionSetEntry: Record "Dimension Set Entry";
        CustomerNo: Code[20];
    begin
        // [FEATURE] [Dimension]
        // [SCENARIO 376115] Payment Header Dimension merges with Payment Line Dimension
        Initialize();


        // [GIVEN] Customer with Default Dimension "D1"
        CustomerNo := CreateCustomerWithDefaultDimension(DimensionValue[1]);

        // [GIVEN] Payment Header with Dimension "D2"
        GLSetup.Get();
        LibraryDimension.CreateDimensionValue(DimensionValue[2], GLSetup."Global Dimension 1 Code");
        CreatePaymentSlip(PaymentLine, PaymentLine."Account Type"::Customer);
        PaymentHeader.Get(PaymentLine."No.");
        PaymentHeader.Validate("Shortcut Dimension 1 Code", DimensionValue[2].Code);
        PaymentHeader.Modify();

        // [WHEN] Customer No. is validated on Payment Line
        PaymentLineSetAccountNo(PaymentLine, CustomerNo);

        // [THEN] Payment Line has Dimension "D1" and "D2"
        VerifyDimensionCountByDimSetID(DimensionSetEntry, PaymentLine."Dimension Set ID", 2);
        DimensionSetEntry.SetFilter(
          "Dimension Code", '%1|%2', DimensionValue[2]."Dimension Code", DimensionValue[1]."Dimension Code");
        Assert.RecordCount(DimensionSetEntry, 2);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure PaymentHeaderOverwriteLineDimensionValue()
    var
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
        DimensionValue: array[2] of Record "Dimension Value";
        DefaultDimension: Record "Default Dimension";
        GLSetup: Record "General Ledger Setup";
        DimensionSetEntry: Record "Dimension Set Entry";
        CustomerNo: Code[20];
    begin
        // [FEATURE] [Dimension]
        // [SCENARIO 376115] Payment Header Dimension Value overwrites Dimension Value of Payment Line with same Dimension
        Initialize();


        // [GIVEN] Payment Header with Dimension "D1" and Dimension Value "DV1"
        GLSetup.Get();
        LibraryDimension.CreateDimensionValue(DimensionValue[1], GLSetup."Global Dimension 1 Code");
        CreatePaymentSlip(PaymentLine, PaymentLine."Account Type"::Customer);
        PaymentHeader.Get(PaymentLine."No.");
        PaymentHeader.Validate("Shortcut Dimension 1 Code", DimensionValue[1].Code);
        PaymentHeader.Modify();

        // [GIVEN] Customer with Default Dimension "D1" and Dimension Value "DV2"
        CustomerNo := LibrarySales.CreateCustomerNo();
        LibraryDimension.CreateDimensionValue(DimensionValue[2], DimensionValue[1]."Dimension Code");
        LibraryDimension.CreateDefaultDimensionCustomer(
          DefaultDimension, CustomerNo, DimensionValue[2]."Dimension Code", DimensionValue[2].Code);

        // [WHEN] Customer No. is validated on Payment Line
        PaymentLineSetAccountNo(PaymentLine, CustomerNo);

        // [THEN] Payment Line has Dimension D1 with Dimension Value "DV1"
        VerifyDimensionCountByDimSetID(DimensionSetEntry, PaymentLine."Dimension Set ID", 1);
        DimensionSetEntry.SetFilter("Dimension Value Code", DimensionValue[1].Code);
        Assert.RecordIsNotEmpty(DimensionSetEntry);
    end;

    [Test]
    procedure PaymentLineAccountDimension()
    var
        PaymentLine: Record "Payment Line FR";
        DimensionValue: Record "Dimension Value";
        DimensionSetEntry: Record "Dimension Set Entry";
        CustomerNo: Code[20];
    begin
        // [FEATURE] [Dimension]
        // [SCENARIO 376115] Payment Line Dimension is taken from validated Account
        Initialize();


        // [GIVEN] Customer with Default Dimension "D1"
        CustomerNo := CreateCustomerWithDefaultDimension(DimensionValue);

        // [GIVEN] Payment Header with no Dimensions
        CreatePaymentSlip(PaymentLine, PaymentLine."Account Type"::Customer);

        // [WHEN] Customer No. is validated on Payment Line
        PaymentLineSetAccountNo(PaymentLine, CustomerNo);

        // [THEN] Payment Line has Dimension "D1"
        VerifyDimensionCountByDimSetID(DimensionSetEntry, PaymentLine."Dimension Set ID", 1);
        DimensionSetEntry.SetFilter("Dimension Value Code", DimensionValue.Code);
        Assert.RecordIsNotEmpty(DimensionSetEntry);
    end;

    [Test]
    procedure VendorPaymentLineOnDelete()
    var
        PaymentHeader: array[2] of Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
        VendorLedgerEntry: array[2] of Record "Vendor Ledger Entry";
        AppliesToID: Code[20];
    begin
        // [SCENARIO 304798] Deleting Payment Slip leads to only associated Vendor Ledger Entries having empty Applies-to ID
        Initialize();


        AppliesToID := LibraryUtility.GenerateRandomCode(PaymentLine.FieldNo("Applies-to ID"), DATABASE::"Vendor Ledger Entry");

        // [GIVEN] Payment Slip "X1" with Payment Line applied to Vendor Ledger Entry "Y1" with "Applies-To ID" equal "Z"
        MockVendorLedgerEntry(VendorLedgerEntry[1], AppliesToID);
        MockPaymentSlipWithPaymentLine(
          PaymentHeader[1], PaymentLine."Account Type"::Vendor, AppliesToID,
          VendorLedgerEntry[1]."Document No.", VendorLedgerEntry[1]."Document Type");

        // [GIVEN] Payment Slip "X2" with Payment Line applied to Vendor Ledger Entry "Y2" using "Applies-To ID" equal "Z"
        MockVendorLedgerEntry(VendorLedgerEntry[2], AppliesToID);
        MockPaymentSlipWithPaymentLine(
          PaymentHeader[2], PaymentLine."Account Type"::Vendor, AppliesToID,
          VendorLedgerEntry[2]."Document No.", VendorLedgerEntry[2]."Document Type");

        // [WHEN] Deleting Payment Slip "X1".
        PaymentHeader[1].Delete(true);

        // [THEN] Vendor Ledger Entry "Y1" has "Applies-To ID" equal to ""
        VendorLedgerEntry[1].Get(VendorLedgerEntry[1]."Entry No.");
        Assert.AreEqual('', VendorLedgerEntry[1]."Applies-to ID", '');
        // [THEN] Vendor Ledger Entry "Y2" has "Applies-To ID" equal to "Z"
        VendorLedgerEntry[2].Get(VendorLedgerEntry[2]."Entry No.");
        Assert.AreEqual(AppliesToID, VendorLedgerEntry[2]."Applies-to ID", '');
    end;

    [Test]
    procedure CustomerPaymentLineOnDelete()
    var
        PaymentHeader: array[2] of Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
        CustLedgerEntry: array[2] of Record "Cust. Ledger Entry";
        AppliesToID: Code[20];
    begin
        // [SCENARIO 304798] Deleting Payment Slip leads to only associated Customer Ledger Entries having empty Applies-to ID
        Initialize();


        AppliesToID := LibraryUtility.GenerateRandomCode(PaymentLine.FieldNo("Applies-to ID"), DATABASE::"Cust. Ledger Entry");

        // [GIVEN] Payment Slip "X1" with Payment Line applied to Customer Ledger Entry "Y1" with "Applies-To ID" equal "Z"
        MockCustomerLedgerEntry(CustLedgerEntry[1], AppliesToID);
        MockPaymentSlipWithPaymentLine(
          PaymentHeader[1], PaymentLine."Account Type"::Customer, AppliesToID,
          CustLedgerEntry[1]."Document No.", CustLedgerEntry[1]."Document Type");

        // [GIVEN] Payment Slip "X2" with Payment Line applied to Customer Ledger Entry "Y2" using "Applies-To ID" equal "Z"
        MockCustomerLedgerEntry(CustLedgerEntry[2], AppliesToID);
        MockPaymentSlipWithPaymentLine(
          PaymentHeader[2], PaymentLine."Account Type"::Customer, AppliesToID,
          CustLedgerEntry[2]."Document No.", CustLedgerEntry[2]."Document Type");

        // [WHEN] Deleting Payment Slip "X1".
        PaymentHeader[1].Delete(true);

        // [THEN] Customer Ledger Entry "Y1" has "Applies-To ID" equal to ""
        CustLedgerEntry[1].Get(CustLedgerEntry[1]."Entry No.");
        Assert.AreEqual('', CustLedgerEntry[1]."Applies-to ID", '');
        // [THEN] Customer Ledger Entry "Y2" has "Applies-To ID" equal to "Z"
        CustLedgerEntry[2].Get(CustLedgerEntry[2]."Entry No.");
        Assert.AreEqual(AppliesToID, CustLedgerEntry[2]."Applies-to ID", '');
    end;

    [Test]
    [HandlerFunctions('ApplyCustomerEntriesModalPageHandler')]
    procedure PaymentApplyKeepsAppliesToDocNoAndDocTypeWhenAccTypeCustomerAndCustLedEntryExists()
    var
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        AppliesToID: Code[20];
    begin
        // [FEATURE] [UT]
        // [SCENARIO 315612] Codeunit "Payment-Apply" doesn't delete "Applies-to Doc. No." and "Applies-to Doc. Type".
        Initialize();


        // [GIVEN] Payment Line with "Account Type"::Customer and existing Customer Ledger entry.
        AppliesToID := LibraryUtility.GenerateRandomCode(PaymentLine.FieldNo("Applies-to ID"), DATABASE::"Cust. Ledger Entry");
        MockCustomerLedgerEntry(CustLedgerEntry, AppliesToID);
        MockPaymentSlipWithPaymentLine(
          PaymentHeader, PaymentLine."Account Type"::Customer, AppliesToID,
          CustLedgerEntry."Document No.", CustLedgerEntry."Document Type");
        PaymentLine.SetRange("No.", PaymentHeader."No.");
        PaymentLine.FindFirst();

        // [WHEN] Codeunit "Payment-Apply" is run for Payment Line.
        CODEUNIT.Run(CODEUNIT::"Payment-Apply FR", PaymentLine);

        // [THEN] "Applies-to Doc. No." and "Applies-to Doc. Type" are the same as before.
        Assert.AreEqual(CustLedgerEntry."Document No.", PaymentLine."Applies-to Doc. No.", '');
        Assert.AreEqual(CustLedgerEntry."Document Type", PaymentLine."Applies-to Doc. Type", '');
    end;

    [Test]
    [HandlerFunctions('ApplyVendorEntriesModalPageHandler')]
    procedure PaymentApplyKeepsAppliesToDocNoAndDocTypeWhenAccTypeVendorAndVendLedEntryExists()
    var
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        AppliesToID: Code[20];
    begin
        // [FEATURE] [UT]
        // [SCENARIO 315612] Codeunit "Payment-Apply" doesn't delete "Applies-to Doc. No." and "Applies-to Doc. Type".
        Initialize();


        // [GIVEN] Payment Line with "Account Type"::Vendor and existing Vendor Ledger entry.
        AppliesToID := LibraryUtility.GenerateRandomCode(PaymentLine.FieldNo("Applies-to ID"), DATABASE::"Vendor Ledger Entry");
        MockVendorLedgerEntry(VendorLedgerEntry, AppliesToID);
        MockPaymentSlipWithPaymentLine(
          PaymentHeader, PaymentLine."Account Type"::Vendor, AppliesToID,
          VendorLedgerEntry."Document No.", VendorLedgerEntry."Document Type");
        PaymentLine.SetRange("No.", PaymentHeader."No.");
        PaymentLine.FindFirst();

        // [WHEN] Codeunit "Payment-Apply" is run for Payment Line.
        CODEUNIT.Run(CODEUNIT::"Payment-Apply FR", PaymentLine);

        // [THEN] "Applies-to Doc. No." and "Applies-to Doc. Type" are the same as before.
        Assert.AreEqual(VendorLedgerEntry."Document No.", PaymentLine."Applies-to Doc. No.", '');
        Assert.AreEqual(VendorLedgerEntry."Document Type", PaymentLine."Applies-to Doc. Type", '');
    end;

    [Test]
    [HandlerFunctions('ApplyCustomerEntriesModalPageHandler')]
    procedure PaymentApplyKeepsAppliesToDocNoAndDocTypeWhenAccTypeCustomerAndCustLedEntryDoesntExist()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
        AppliesToID: Code[20];
        DocNo: Code[20];
        DocType: Enum "Gen. Journal Document Type";
    begin
        // [FEATURE] [UT]
        // [SCENARIO 315612] Codeunit "Payment-Apply" doesn't delete "Applies-to Doc. No." and "Applies-to Doc. Type".
        Initialize();


        // [GIVEN] Payment Line with "Account Type"::Customer and no existing Customer Ledger entry.
        AppliesToID := LibraryUtility.GenerateRandomCode(PaymentLine.FieldNo("Applies-to ID"), DATABASE::"Cust. Ledger Entry");
        DocNo := LibraryUtility.GenerateRandomCode(CustLedgerEntry.FieldNo("Document No."), DATABASE::"Cust. Ledger Entry");
        DocType := "Gen. Journal Document Type".FromInteger(LibraryRandom.RandInt(7));
        MockPaymentSlipWithPaymentLine(PaymentHeader, PaymentLine."Account Type"::Customer, AppliesToID, DocNo, DocType);
        PaymentLine.SetRange("No.", PaymentHeader."No.");
        PaymentLine.FindFirst();

        // [WHEN] Codeunit "Payment-Apply" is run for Payment Line.
        CODEUNIT.Run(CODEUNIT::"Payment-Apply FR", PaymentLine);

        // [THEN] "Applies-to Doc. No." and "Applies-to Doc. Type" are the same as before.
        Assert.AreEqual(DocNo, PaymentLine."Applies-to Doc. No.", '');
        Assert.AreEqual(DocType, PaymentLine."Applies-to Doc. Type", '');
    end;

    [Test]
    [HandlerFunctions('ApplyVendorEntriesModalPageHandler')]
    procedure PaymentApplyKeepsAppliesToDocNoAndDocTypeWhenAccTypeVendorAndVendLedEntryDoesntExist()
    var
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        AppliesToID: Code[20];
        DocNo: Code[20];
        DocType: Enum "Gen. Journal Document Type";
    begin
        // [FEATURE] [UT]
        // [SCENARIO 315612] Codeunit "Payment-Apply" doesn't delete "Applies-to Doc. No." and "Applies-to Doc. Type".
        Initialize();


        // [GIVEN] Payment Line with "Account Type"::Vendor and no existing Vendor Ledger entry.
        AppliesToID := LibraryUtility.GenerateRandomCode(PaymentLine.FieldNo("Applies-to ID"), DATABASE::"Vendor Ledger Entry");
        DocNo := LibraryUtility.GenerateRandomCode(VendorLedgerEntry.FieldNo("Document No."), DATABASE::"Vendor Ledger Entry");
        DocType := "Gen. Journal Document Type".FromInteger(LibraryRandom.RandInt(7));
        MockPaymentSlipWithPaymentLine(PaymentHeader, PaymentLine."Account Type"::Vendor, AppliesToID, DocNo, DocType);
        PaymentLine.SetRange("No.", PaymentHeader."No.");
        PaymentLine.FindFirst();

        // [WHEN] Codeunit "Payment-Apply" is run for Payment Line.
        CODEUNIT.Run(CODEUNIT::"Payment-Apply FR", PaymentLine);

        // [THEN] "Applies-to Doc. No." and "Applies-to Doc. Type" are the same as before.
        Assert.AreEqual(DocNo, PaymentLine."Applies-to Doc. No.", '');
        Assert.AreEqual(DocType, PaymentLine."Applies-to Doc. Type", '');
    end;

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear();
    end;

    local procedure CreateCustomerWithDefaultDimension(var DimensionValue: Record "Dimension Value") CustomerNo: Code[20]
    var
        DefaultDimension: Record "Default Dimension";
    begin
        CustomerNo := LibrarySales.CreateCustomerNo();
        LibraryDimension.CreateDimWithDimValue(DimensionValue);
        LibraryDimension.CreateDefaultDimensionCustomer(DefaultDimension, CustomerNo, DimensionValue."Dimension Code", DimensionValue.Code);
    end;

    local procedure OnValidateAccountNoErrorInPaymentLine(AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; ErrorCode: Text)
    var
        PaymentLine: Record "Payment Line FR";
    begin
        // Setup: Create Payment Slip.
        CreatePaymentSlip(PaymentLine, AccountType);

        // Exercise.
        asserterror PaymentLine.Validate("Account No.", AccountNo);

        // Verify: Verify expected error code.
        Assert.ExpectedErrorCode(ErrorCode);
    end;

    local procedure OnValidateAccountNoInPaymentLine(AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20])
    var
        PaymentLine: Record "Payment Line FR";
        PaymentSlip: TestPage "Payment Slip FR";
    begin
        // Setup: Create Payment Slip.
        CreatePaymentSlip(PaymentLine, AccountType);

        // Exercise.
        PaymentLine.Validate("Account No.", AccountNo);
        PaymentLine.Modify();

        // Verify: Verify Account No. in Payment Line.
        PaymentSlip.OpenEdit();
        PaymentSlip.FILTER.SetFilter("No.", PaymentLine."No.");
        PaymentSlip.Lines."Account No.".AssertEquals(PaymentLine."Account No.");
        PaymentSlip.Close();
    end;

    local procedure CreateBlockedCustomer(Blocked: Enum "Customer Blocked"): Code[20]
    var
        Customer: Record Customer;
    begin
        Customer."No." := LibraryUTUtility.GetNewCode();
        Customer.Blocked := Blocked;
        Customer.Insert();
        exit(Customer."No.");
    end;

    local procedure CreateBlockedVendor(Blocked: Enum "Vendor Blocked"): Code[20]
    var
        Vendor: Record Vendor;
    begin
        Vendor."No." := LibraryUTUtility.GetNewCode();
        Vendor.Blocked := Blocked;
        Vendor.Insert();
        exit(Vendor."No.");
    end;

    local procedure CreatePaymentClass(var PaymentClass: Record "Payment Class FR")
    begin
        PaymentClass.Code := LibraryUTUtility.GetNewCode();
        PaymentClass."Unrealized VAT Reversal" := PaymentClass."Unrealized VAT Reversal"::Delayed;
        PaymentClass.Insert();
    end;

    local procedure CreatePaymentSlip(var PaymentLine: Record "Payment Line FR"; AccountType: Enum "Gen. Journal Account Type")
    var
        PaymentClass: Record "Payment Class FR";
        PaymentHeader: Record "Payment Header FR";
    begin
        PaymentClass.FindFirst();
        PaymentHeader."No." := LibraryUTUtility.GetNewCode();
        PaymentHeader."Payment Class" := PaymentClass.Code;
        PaymentHeader.Insert();
        PaymentLine."No." := PaymentHeader."No.";
        PaymentLine."Line No." := LibraryRandom.RandInt(10);
        PaymentLine."Account Type" := AccountType;
        PaymentLine.Insert();
    end;

    local procedure CreatePaymentStatus(var PaymentStatus: Record "Payment Status FR"; PaymentClass: Text[30])
    begin
        PaymentStatus."Payment Class" := PaymentClass;
        PaymentStatus.Name := LibraryUTUtility.GetNewCode();
        PaymentStatus.Insert();
    end;

    local procedure CreatePaymentStep(var PaymentStep: Record "Payment Step FR"; PaymentClass: Text[30])
    begin
        PaymentStep."Payment Class" := PaymentClass;
        PaymentStep.Name := LibraryUTUtility.GetNewCode();
        PaymentStep."Realize VAT" := true;
        PaymentStep.Insert();
    end;

    local procedure CreatePaymentStepLedger(var PaymentStepLedger: Record "Payment Step Ledger FR"; PaymentClass: Text[30])
    begin
        PaymentStepLedger."Payment Class" := PaymentClass;
        PaymentStepLedger.Insert();
    end;

    local procedure MockCustomerLedgerEntry(var CustLedgerEntry: Record "Cust. Ledger Entry"; AppliesToID: Code[50])
    var
        EntryNo: Integer;
    begin
        if CustLedgerEntry.FindLast() then
            EntryNo := CustLedgerEntry."Entry No." + 1
        else
            EntryNo := 1;

        CustLedgerEntry.Init();
        CustLedgerEntry."Entry No." := EntryNo;
        CustLedgerEntry."Applies-to ID" := AppliesToID;
        CustLedgerEntry."Document No." := LibraryUtility.GenerateRandomCode(CustLedgerEntry.FieldNo("Document No."), DATABASE::"Cust. Ledger Entry");
        CustLedgerEntry."Document Type" := "Gen. Journal Document Type".FromInteger(LibraryRandom.RandInt(7));
        CustLedgerEntry.Open := true;
        CustLedgerEntry.Insert();
    end;

    local procedure MockPaymentSlipWithPaymentLine(var PaymentHeader: Record "Payment Header FR"; AccountType: Enum "Gen. Journal Account Type"; AppliesToID: Code[50]; AppliesToDocNo: Code[20]; AppliesToDocType: Enum "Gen. Journal Document Type")
    var
        PaymentLine: Record "Payment Line FR";
    begin
        PaymentHeader.Init();
        PaymentHeader."No." := LibraryUTUtility.GetNewCode();
        PaymentHeader.Insert();

        PaymentLine.Init();
        PaymentLine."No." := PaymentHeader."No.";
        PaymentLine."Line No." := LibraryRandom.RandInt(10);
        PaymentLine."Document No." := CopyStr(AppliesToID, 1, MaxStrLen(PaymentLine."Document No."));
        PaymentLine."Applies-to ID" := AppliesToID;
        PaymentLine."Applies-to Doc. No." := AppliesToDocNo;
        PaymentLine."Applies-to Doc. Type" := AppliesToDocType;
        PaymentLine."Account Type" := AccountType;
        PaymentLine.Insert();
    end;

    local procedure MockVendorLedgerEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; AppliesToID: Code[50])
    var
        EntryNo: Integer;
    begin
        if VendorLedgerEntry.FindLast() then
            EntryNo := VendorLedgerEntry."Entry No." + 1
        else
            EntryNo := 1;

        VendorLedgerEntry.Init();
        VendorLedgerEntry."Entry No." := EntryNo;
        VendorLedgerEntry."Applies-to ID" := AppliesToID;
        VendorLedgerEntry."Document No." := LibraryUtility.GenerateRandomCode(VendorLedgerEntry.FieldNo("Document No."), DATABASE::"Vendor Ledger Entry");
        VendorLedgerEntry."Document Type" := "Gen. Journal Document Type".FromInteger(LibraryRandom.RandInt(7));
        VendorLedgerEntry.Open := true;
        VendorLedgerEntry.Insert();
    end;

    local procedure PaymentLineSetAccountNo(var PaymentLine: Record "Payment Line FR"; AccountNo: Code[20])
    begin
        PaymentLine.Validate("Account No.", AccountNo);
        PaymentLine.Modify(true);
    end;

    local procedure UnrealizedVATReversalTypePaymentClass(UnrealizedVATReversal: Option; ErrorCode: Text)
    var
        PaymentClass: Record "Payment Class FR";
        PaymentStep: Record "Payment Step FR";
    begin
        // Setup: Update General Ledger Setup, Create Payment Step and Create Payment Class.
        CreatePaymentClass(PaymentClass);
        CreatePaymentStep(PaymentStep, PaymentClass.Code);

        // Exercise.
        asserterror PaymentClass.Validate("Unrealized VAT Reversal", UnrealizedVATReversal);

        // Verify: Verify expected error code.
        Assert.ExpectedErrorCode(ErrorCode);
    end;

    local procedure UnrealizedVATReversalOnPaymentClass(UnrealizedVATReversal: Option; RealizeVAT: Boolean)
    var
        PaymentClass: Record "Payment Class FR";
        PaymentStep: Record "Payment Step FR";
        PaymentStepCard: TestPage "Payment Step Card FR";
    begin
        // Setup: Create Payment Class with Unrealized VAT Reversal, create Payment Step.
        CreatePaymentClass(PaymentClass);
        PaymentClass."Unrealized VAT Reversal" := UnrealizedVATReversal;
        PaymentClass.Modify();
        CreatePaymentStep(PaymentStep, PaymentClass.Code);
        PaymentStepCard.OpenEdit();
        PaymentStepCard.FILTER.SetFilter("Payment Class", PaymentClass.Code);

        // Exercise: Update Payment Step card with Action Type is Ledger.
        PaymentStepCard."Action Type".SetValue(PaymentStep."Action Type"::Ledger);

        // Verify: Verify Realize VAT control on Payment Step Card.
        Assert.AreEqual(RealizeVAT, PaymentStepCard."Realize VAT".Enabled(), UnexpectedErr);
        PaymentStepCard.Close();
    end;

    local procedure VerifyPaymentLineDimSetID(PaymentLine: Record "Payment Line FR"; DimensionSetID: Integer)
    begin
        PaymentLine.Find();
        PaymentLine.TestField("Dimension Set ID", DimensionSetID);
    end;

    local procedure VerifyDimensionCountByDimSetID(var DimensionSetEntry: Record "Dimension Set Entry"; DimSetId: Integer; "Count": Integer)
    begin
        LibraryDimension.FindDimensionSetEntry(DimensionSetEntry, DimSetId);
        Assert.RecordCount(DimensionSetEntry, Count);
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [ModalPageHandler]
    procedure DimensionValueListModalPageHandler(var DimensionValueList: Page "Dimension Value List"; var Response: Action)
    var
        DimensionValue: Record "Dimension Value";
        DimensionCodeVar: Variant;
        DimensionValueCodVar: Variant;
    begin
        LibraryVariableStorage.Dequeue(DimensionCodeVar);
        LibraryVariableStorage.Dequeue(DimensionValueCodVar);
        DimensionValue.SetRange("Dimension Code", DimensionCodeVar);
        DimensionValue.SetRange(Code, DimensionValueCodVar);
        DimensionValue.FindFirst();
        DimensionValueList.SetRecord(DimensionValue);
        Response := ACTION::LookupOK;
    end;

    [ModalPageHandler]
    procedure ApplyCustomerEntriesModalPageHandler(var ApplyCustomerEntries: Page "Apply Customer Entries"; var Response: Action)
    begin
        Response := ACTION::LookupOK;
    end;

    [ModalPageHandler]
    procedure ApplyVendorEntriesModalPageHandler(var ApplyVendorEntries: Page "Apply Vendor Entries"; var Response: Action)
    begin
        Response := ACTION::LookupOK;
    end;

#if not CLEAN28
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Payment Management Feature FR", OnAfterCheckFeatureEnabled, '', false, false)]
    local procedure OnAfterCheckFeatureEnabled(var IsEnabled: Boolean)
    begin
        IsEnabled := true;
    end;
#endif
}

