// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using System.TestLibraries.Utilities;

codeunit 144008 "ERM FR Feature Bugs"
{
    //  1. Test to verify Dimension on Payment Slip flow form Vendor.
    //  2. Test to verify Dimension on Payment Slip flow form Customer.
    //
    //   Covers Test Cases for WI - 344026
    //   ----------------------------------------------------------------------------------
    //   Test Function Name                                                       TFS ID
    //   ----------------------------------------------------------------------------------
    //   BookValueAfterPostDepreciationAndDerogatoryFAJnl                         343466
    //   DerogatoryAmountAfterPostDepreciationAndDerogatoryFAJnl                  342860
    //   DerogatoryEntriesAfterPostDepreciationAndDerogatoryFAJnl                 342818
    //   PostingDatesAfterPostDepreciationAndDerogatoryFAJnl                      342877
    //   PostedSalesInvoiceWithDecimalLotTrackingAndProdBOM                       341056
    //   SalesInvoiceWithShipmentOnSalesInvoiceReport                             152143
    //   SalesInvoiceWithoutShipmentOnSalesInvoiceReport                          152602
    //   ShipmentInvoicedForPostedSalesInvoiceGetShipmentLine                     152142
    //   ShipmentInvoicedForMultiLinePostedSalesInvoice                           152141
    //   ShipmentInvoicedForSingleLinePostedSalesInvoice                          152140
    //
    //   Covers Test Cases for WI - 344431.
    //   ----------------------------------------------------------------------------------
    //   Test Function Name                                                       TFS ID
    //   ----------------------------------------------------------------------------------
    //   VATProdPostingGroupVATRateChangePurchaseLine                             300903
    //   DefaultDimensionCodeForVendorOnPaymentSlip                               291748
    //   DefaultDimensionCodeForCustomerOnPaymentSlip                             291748

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
        LibraryDimension: Codeunit "Library - Dimension";
        LibraryFRLocalization: Codeunit "Library - Localization FR";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";

    [Test]
    [HandlerFunctions('PaymentClassListPageHandler')]
    procedure DefaultDimensionCodeForVendorOnPaymentSlip()
    var
        DefaultDimension: Record "Default Dimension";
        PaymentStepLedger: Record "Payment Step Ledger FR";
        PaymentLine: Record "Payment Line FR";
    begin
        // Test to verify Dimension on Payment Slip flow form Vendor.

        // Setup: Create Vendor with dimension,Default dimension code on Payment Slip for Vendor.
        Initialize();
        CreateAndUpdateVendorWithDimension(DefaultDimension);
        DefaultDimensionCodeOnPaymentSlip(
          PaymentStepLedger.Sign::Credit, PaymentLine."Account Type"::Vendor, DefaultDimension."No.", DefaultDimension."Dimension Code");
    end;

    [Test]
    [HandlerFunctions('PaymentClassListPageHandler')]
    procedure DefaultDimensionCodeForCustomerOnPaymentSlip()
    var
        DefaultDimension: Record "Default Dimension";
        PaymentStepLedger: Record "Payment Step Ledger FR";
        PaymentLine: Record "Payment Line FR";
    begin
        // Test to verify Dimension on Payment Slip flow form Cusotmer.

        // Setup: Create Customer with dimension,Default dimension code on Payment Slip for Customer.
        Initialize();

        CreateAndUpdateCustomerWithDimension(DefaultDimension);
        DefaultDimensionCodeOnPaymentSlip(
          PaymentStepLedger.Sign::Debit, PaymentLine."Account Type"::Customer, DefaultDimension."No.", DefaultDimension."Dimension Code");
    end;

    [Test]
    [HandlerFunctions('PaymentClassListPageHandler')]
    procedure CreateAndPostPaymentSlipForIncompleteDimension()
    var
        DefaultDimension: Record "Default Dimension";
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
    begin
        // [SCENARIO 308571] Creating 'Payment Line' for Vendor with empty 'Dimension Value Code' in 'Default Dimension' doesn't throw error
        Initialize();


        // [GIVEN] Created Vendor with 'Default Dimension' with empty 'Dimension Value Code'
        CreateAndUpdateVendorWithIncompleteDimension(DefaultDimension);

        // [WHEN] Create 'Payment Line' for that Vendor
        LibraryFRLocalization.CreatePaymentHeader(PaymentHeader);
        LibraryFRLocalization.CreatePaymentLine(PaymentLine, PaymentHeader."No.");
        PaymentLine.Validate("Account Type", PaymentLine."Account Type"::Vendor);
        PaymentLine.Validate("Account No.", DefaultDimension."No.");
        PaymentLine.Modify(true);

        // [THEN] No error thrown, and invalid Dimension Set Entry is not created
        PaymentLine.TestField("Dimension Set ID", 0);
    end;

    local procedure DefaultDimensionCodeOnPaymentSlip(Sign: Option; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; DimensionCode: Code[20])
    var
        DimensionSetEntry: Record "Dimension Set Entry";
        DimensionSetID: Integer;
    begin

        CreatePaymentStatus(CreatePaymentClass(), Sign);

        // Exercise: Create Payment Slip.
        DimensionSetID := CreatePaymentSlip(AccountType, AccountNo);

        // Verify: Verify Dimension Code on Dimension Set Entry.
        DimensionSetEntry.SetRange("Dimension Set ID", DimensionSetID);
        DimensionSetEntry.FindFirst();
        DimensionSetEntry.TestField("Dimension Code", DimensionCode);
    end;

    local procedure Initialize()
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.DeleteAll();
        LibraryVariableStorage.Clear();
    end;

    local procedure CreateAndUpdateCustomerWithDimension(var DefaultDimension: Record "Default Dimension")
    var
        Customer: Record Customer;
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
    begin
        LibrarySales.CreateCustomer(Customer);
        LibraryDimension.FindDimension(Dimension);
        LibraryDimension.FindDimensionValue(DimensionValue, Dimension.Code);
        LibraryDimension.CreateDefaultDimensionCustomer(DefaultDimension, Customer."No.", Dimension.Code, DimensionValue.Code);
    end;

    local procedure CreatePaymentClass(): Text[30]
    var
        PaymentClass: Record "Payment Class FR";
    begin
        LibraryFRLocalization.CreatePaymentClass(PaymentClass);
        PaymentClass.Validate("Header No. Series", LibraryUtility.GetGlobalNoSeriesCode());
        PaymentClass.Validate(Suggestions, PaymentClass.Suggestions::Vendor);
        PaymentClass.Modify(true);
        exit(PaymentClass.Code);
    end;

    local procedure CreatePaymentStatus(PaymentClass: Text[30]; Sign: Option)
    var
        PaymentStatus: Record "Payment Status FR";
        PaymentStep: Record "Payment Step FR";
        PaymentStepLedger: Record "Payment Step Ledger FR";
    begin
        LibraryFRLocalization.CreatePaymentStatus(PaymentStatus, PaymentClass);
        PaymentStatus.Validate(RIB, true);
        PaymentStatus.Validate(Look, true);
        PaymentStatus.Validate(ReportMenu, true);
        PaymentStatus.Validate("Acceptation Code", true);
        PaymentStatus.Validate(Debit, true);
        PaymentStatus.Validate(Credit, true);
        PaymentStatus.Validate("Bank Account", true);
        PaymentStatus.Modify(true);
        LibraryFRLocalization.CreatePaymentStep(PaymentStep, PaymentClass);
        LibraryFRLocalization.CreatePaymentStepLedger(PaymentStepLedger, PaymentClass, Sign, PaymentStep.Line);
    end;

    local procedure CreatePaymentSlip(AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]): Integer
    var
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
    begin
        LibraryFRLocalization.CreatePaymentHeader(PaymentHeader);
        LibraryFRLocalization.CreatePaymentLine(PaymentLine, PaymentHeader."No.");
        PaymentLine.Validate("Account Type", AccountType);
        PaymentLine.Validate("Account No.", AccountNo);
        PaymentLine.Modify(true);
        exit(PaymentLine."Dimension Set ID");
    end;

    local procedure CreateAndUpdateVendorWithDimension(var DefaultDimension: Record "Default Dimension")
    var
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
        Vendor: Record Vendor;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        LibraryDimension.FindDimension(Dimension);
        LibraryDimension.FindDimensionValue(DimensionValue, Dimension.Code);
        LibraryDimension.CreateDefaultDimensionVendor(DefaultDimension, Vendor."No.", Dimension.Code, DimensionValue.Code);
    end;

    local procedure CreateAndUpdateVendorWithIncompleteDimension(var DefaultDimension: Record "Default Dimension")
    var
        Dimension: Record Dimension;
        Vendor: Record Vendor;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        LibraryDimension.CreateDimension(Dimension);
        LibraryDimension.CreateDefaultDimensionVendor(DefaultDimension, Vendor."No.", Dimension.Code, '');
    end;

    [ModalPageHandler]
    procedure PaymentClassListPageHandler(var PaymentClassList: TestPage "Payment Class List FR")
    begin
        PaymentClassList.OK().Invoke();
    end;

#if not CLEAN28
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Payment Management Feature FR", OnAfterCheckFeatureEnabled, '', false, false)]
    local procedure OnAfterCheckFeatureEnabled(var IsEnabled: Boolean)
    begin
        IsEnabled := true;
    end;
#endif
}
