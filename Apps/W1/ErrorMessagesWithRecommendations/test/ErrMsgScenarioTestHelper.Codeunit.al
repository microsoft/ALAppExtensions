// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Test.Shared.Error;

using System.Utilities;
using Microsoft.Purchases.Document;
using Microsoft.Finance.Dimension;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;

codeunit 139620 ErrMsgScenarioTestHelper
{
    Access = Internal;

    var
        LibraryRandom: Codeunit "Library - Random";
        LibraryDimension: Codeunit "Library - Dimension";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryERM: Codeunit "Library - ERM";
        Assert: Codeunit Assert;
        ErrScenarioOption: Option DimMustBeBlank,DimMustBeSame,ErrFixNotImplemented,DimMustBeSameButMissing;

    // Use LibraryVariableStorage before calling this procedure to post receipt, invoice or both
    internal procedure GetErrMsgTestPageFromPostingPO(var PurchaseHeader: Record "Purchase Header"; var ErrorMessagesTestPage: TestPage "Error Messages"; ErrScenario: Option DimMustBeBlank,DimMustBeSame,ErrFixNotImplemented,DimMustBeSameButMissing)
    var
        PurchaseOrderPage: TestPage "Purchase Order";
    begin
        // [GIVEN] A purchase order with the expected error scenario
        case ErrScenario of
            ErrScenario::DimMustBeBlank:
                SetupPurchaseOrderForDimMustBeBlankError(PurchaseHeader);
            ErrScenario::DimMustBeSame:
                SetupPurchaseOrderForDimMustBeSameError(PurchaseHeader);
            ErrScenario::ErrFixNotImplemented:
                SetupPurchaseOrderForErrorWithoutFix(PurchaseHeader);
            ErrScenario::DimMustBeSameButMissing:
                SetupPurchaseOrderForDimMustBeSameButMissingDimError(PurchaseHeader);
        end;

        // [WHEN] User posts the purchase order form UI
        PurchaseOrderPage.OpenEdit();
        PurchaseOrderPage.GoToRecord(PurchaseHeader);

        ErrorMessagesTestPage.Trap();
        PurchaseOrderPage.Post.Invoke(); // LibraryVariableStorage.Enqueue(3); //Receive and Invoice

        // [THEN] Error message page opens with corresponding error message
        ErrorMessagesTestPage.First();
    end;

    local procedure InitializeDimensionSetup(var DimensionCodeList: List of [Code[20]])
    var
        Dimension: Record "Dimension";
        DimensionValue: Record "Dimension Value";
        i: Integer;
        j: Integer;
    begin
        for i := 1 to 3 do begin
            LibraryDimension.CreateDimension(Dimension);
            DimensionCodeList.Add(Dimension.Code);
            for j := 1 to 2 do
                LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        end;
    end;

    local procedure CreateGLAccountDefaultDimensionWithSameCode(GLAccountNo: Code[20]; var DefaultDimension: Record "Default Dimension"; var DimensionValue: Record "Dimension Value")
    begin
        LibraryDimension.CreateDefaultDimensionGLAcc(DefaultDimension, GLAccountNo, DimensionValue."Dimension Code", DimensionValue.Code);
        DefaultDimension.Validate("Value Posting", DefaultDimension."Value Posting"::"Same Code");
        DefaultDimension.Modify();
    end;

    internal procedure SetupPurchaseOrderForDimMustBeBlankError(var PurchaseHeader: Record "Purchase Header")
    var
        Vendor: Record Vendor;
        DefaultDimension: Record "Default Dimension";
        DimensionValue: Record "Dimension Value";
        DimensionSetEntry: Record "Dimension Set Entry";
        DimensionCodeList: List of [Code[20]];
    begin
        // Create a vendor with a default dimension value posting code
        // Create a purchase order for the vendor which uses the default dimension form the vendor
        // Update the default dimension value posting code to "No Code"
        // Posting of the purchase order should result in an error message "Dimension must be blank"

        LibraryPurchase.CreateVendor(Vendor);
        InitializeDimensionSetup(DimensionCodeList);
        LibraryDimension.FindDimensionValue(DimensionValue, DimensionCodeList.Get(1));
        LibraryDimension.CreateDefaultDimensionVendor(DefaultDimension, Vendor."No.", DimensionValue."Dimension Code", DimensionValue.Code);
        DefaultDimension.Validate("Value Posting", DefaultDimension."Value Posting"::"Same Code");
        DefaultDimension.Modify();

        LibraryPurchase.CreatePurchaseOrderForVendorNo(PurchaseHeader, Vendor."No.");
        LibraryDimension.FindDimensionSetEntry(DimensionSetEntry, PurchaseHeader."Dimension Set ID");

        DefaultDimension.Validate("Dimension Value Code", '');
        DefaultDimension.Validate("Value Posting", DefaultDimension."Value Posting"::"No Code");
        DefaultDimension.Modify();
        Commit();
    end;

    internal procedure SetupPurchaseOrderForDimMustBeSameError(var PurchaseHeader: Record "Purchase Header")
    var
        Vendor: Record Vendor;
        DefaultDimension: Record "Default Dimension";
        DimensionValue: Record "Dimension Value";
        DimensionCodeList: List of [Code[20]];
    begin
        // Create a vendor with a default dimension value posting code
        // Create a purchase order for the vendor which uses the default dimension form the vendor
        // Update the default dimension value code
        // Posting of the purchase order should result in an error message "Dimension code must be same"
        LibraryPurchase.CreateVendor(Vendor);
        InitializeDimensionSetup(DimensionCodeList);
        LibraryDimension.FindDimensionValue(DimensionValue, DimensionCodeList.Get(1));
        LibraryDimension.CreateDefaultDimensionVendor(DefaultDimension, Vendor."No.", DimensionValue."Dimension Code", DimensionValue.Code);
        DefaultDimension.Validate("Value Posting", DefaultDimension."Value Posting"::"Same Code");
        DefaultDimension.Modify();

        DimensionValue.Next(); //Get the next dimension value
        LibraryPurchase.CreatePurchaseOrderForVendorNo(PurchaseHeader, Vendor."No.");

        DefaultDimension.Validate("Dimension Value Code", DimensionValue.Code);
        DefaultDimension.Modify();
        Commit();
    end;

    internal procedure SetupForDimensionMustBeSameError(var Customer: Record Customer; var DimensionValue: Record "Dimension Value")
    var
        DefaultDimension: Record "Default Dimension";
        Currency: Record Currency;
        LibrarySales: Codeunit "Library - Sales";
        CurrencyCode: Code[10];
    begin
        // Create a new currency with GL account setup and two exchange rates for the currency
        CurrencyCode := LibraryERM.CreateCurrencyWithGLAccountSetup();
        LibraryERM.CreateExchangeRate(CurrencyCode, Today() - 1, 100, 100);
        LibraryERM.CreateExchangeRate(CurrencyCode, Today() + 5, 101, 101);

        // Create a customer with new currency
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Currency Code", CurrencyCode);
        Customer.Modify();

        // Create dimension value for dimension code 1
        LibraryDimension.CreateDimensionValue(DimensionValue, LibraryERM.GetGlobalDimensionCode(1));

        // Set default dimension 1 with same code setup for G/L accounts used on the currency 
        Currency.Get(CurrencyCode);
        CreateGLAccountDefaultDimensionWithSameCode(Currency."Unrealized Gains Acc.", DefaultDimension, DimensionValue);
        CreateGLAccountDefaultDimensionWithSameCode(Currency."Realized Gains Acc.", DefaultDimension, DimensionValue);
    end;

    internal procedure SetupPurchaseOrderForDimMustBeSameButMissingDimError(var PurchaseHeader: Record "Purchase Header")
    var
        Vendor: Record Vendor;
        DefaultDimension: Record "Default Dimension";
        DimensionValue: Record "Dimension Value";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimensionManagement: Codeunit DimensionManagement;
        DimensionCodeList: List of [Code[20]];
    begin
        // Create a vendor with a default dimension value posting code
        // Create a purchase order for the vendor which uses the default dimension form the vendor
        // Delete dimension value from the purchase order dimension set entry.
        // Posting of the purchase order should result in an error message "Dimension code is missing from the dimension set entry"
        LibraryPurchase.CreateVendor(Vendor);
        InitializeDimensionSetup(DimensionCodeList);
        LibraryDimension.FindDimensionValue(DimensionValue, DimensionCodeList.Get(1));
        LibraryDimension.CreateDefaultDimensionVendor(DefaultDimension, Vendor."No.", DimensionValue."Dimension Code", DimensionValue.Code);
        DefaultDimension.Validate("Value Posting", DefaultDimension."Value Posting"::"Same Code");
        DefaultDimension.Modify();

        LibraryDimension.CreateDefaultDimensionWithNewDimValue(DefaultDimension, Database::Vendor, Vendor."No.", DefaultDimension."Value Posting"::"Code Mandatory");
        LibraryPurchase.CreatePurchaseOrderForVendorNo(PurchaseHeader, Vendor."No.");

        DimensionManagement.GetDimensionSet(TempDimSetEntry, PurchaseHeader."Dimension Set ID");
        TempDimSetEntry.SetRange("Dimension Code", DimensionValue."Dimension Code");
        if TempDimSetEntry.FindFirst() then
            TempDimSetEntry.Delete();

        PurchaseHeader.Validate("Dimension Set ID", DimensionManagement.GetDimensionSetID(TempDimSetEntry));
        PurchaseHeader.Modify();
        Commit();
    end;

    internal procedure SetupPurchaseOrderForErrorWithoutFix(var PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        // Create a purchase line with negative quantity
        // Posting of the purchase order should result in an error message without fix implementation
        LibraryPurchase.CreatePurchaseOrder(PurchaseHeader);
        LibraryPurchase.CreatePurchaseLineSimple(PurchaseLine, PurchaseHeader);

        PurchaseLine.Validate(Quantity, -1);
        PurchaseLine.Modify();
        Commit();
    end;

    // Use LibraryVariableStorage before calling this procedure to post receipt, invoice or both
    internal procedure PickRandomDimensionErrorScenarioForPO(var PurchaseHeader: Record "Purchase Header"; var ErrorMessagesTestPage: TestPage "Error Messages")
    begin
        case
            LibraryRandom.RandIntInRange(1, 3) of
            1:
                GetErrMsgTestPageFromPostingPO(PurchaseHeader, ErrorMessagesTestPage, ErrScenarioOption::DimMustBeBlank);
            2:
                GetErrMsgTestPageFromPostingPO(PurchaseHeader, ErrorMessagesTestPage, ErrScenarioOption::DimMustBeSame);
            3:
                GetErrMsgTestPageFromPostingPO(PurchaseHeader, ErrorMessagesTestPage, ErrScenarioOption::DimMustBeSameButMissing);
        end;
    end;

    internal procedure SetupGenJnlLineForDimMustBeBlankError(var GenJournalLine: Record "Gen. Journal Line"; GenJournalBatch: Record "Gen. Journal Batch")
    var
        Vendor: Record Vendor;
        DefaultDimension: Record "Default Dimension";
        DimensionValue: Record "Dimension Value";
        DimensionSetEntry: Record "Dimension Set Entry";
        DimensionCodeList: List of [Code[20]];
    begin
        // Create a vendor with a default dimension value posting code
        // Create a general journal line of type payment for the vendor which uses the default dimension form the vendor
        // Update the default dimension value posting code to "No Code"
        // Posting of the general journal should result in an error message "Dimension must be blank"

        LibraryPurchase.CreateVendor(Vendor);
        InitializeDimensionSetup(DimensionCodeList);
        LibraryDimension.FindDimensionValue(DimensionValue, DimensionCodeList.Get(1));
        LibraryDimension.CreateDefaultDimensionVendor(DefaultDimension, Vendor."No.", DimensionValue."Dimension Code", DimensionValue.Code);
        DefaultDimension.Validate("Value Posting", DefaultDimension."Value Posting"::"Same Code");
        DefaultDimension.Modify();

        LibraryERM.CreateGeneralJnlLineWithBalAcc(GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::Vendor, Vendor."No.", "Gen. Journal Account Type"::"G/L Account", LibraryERM.CreateGLAccountNo(), 100);

        LibraryDimension.FindDimensionSetEntry(DimensionSetEntry, GenJournalLine."Dimension Set ID");

        DefaultDimension.Validate("Dimension Value Code", '');
        DefaultDimension.Validate("Value Posting", DefaultDimension."Value Posting"::"No Code");
        DefaultDimension.Modify();
    end;

    internal procedure SetupGenJnlLineForDimMustBeSameError(var GenJournalLine: Record "Gen. Journal Line"; GenJournalBatch: Record "Gen. Journal Batch")
    var
        Vendor: Record Vendor;
        DefaultDimension: Record "Default Dimension";
        DimensionValue: Record "Dimension Value";
        DimensionCodeList: List of [Code[20]];
    begin
        // Create a vendor with a default dimension value posting code
        // Create a general journal line of type payment for the vendor which uses the default dimension form the vendor
        // Update the default dimension value code
        // Posting of the general journal should result in an error message "Dimension code must be same"

        LibraryPurchase.CreateVendor(Vendor);
        InitializeDimensionSetup(DimensionCodeList);
        LibraryDimension.FindDimensionValue(DimensionValue, DimensionCodeList.Get(1));
        LibraryDimension.CreateDefaultDimensionVendor(DefaultDimension, Vendor."No.", DimensionValue."Dimension Code", DimensionValue.Code);
        DefaultDimension.Validate("Value Posting", DefaultDimension."Value Posting"::"Same Code");
        DefaultDimension.Modify();

        DimensionValue.Next(); //Get the next dimension value
        LibraryERM.CreateGeneralJnlLineWithBalAcc(GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::Vendor, Vendor."No.", "Gen. Journal Account Type"::"G/L Account", LibraryERM.CreateGLAccountNo(), 100);

        DefaultDimension.Validate("Dimension Value Code", DimensionValue.Code);
        DefaultDimension.Modify();
    end;

    internal procedure SetupGenJnlLineForErrorWithoutFix(var GenJournalLine: Record "Gen. Journal Line"; GenJournalBatch: Record "Gen. Journal Batch")
    begin
        // Create a general journal line with negative quantity
        // Posting of the general journal should result in an error message without fix implementation
        LibraryERM.CreateGeneralJnlLineWithBalAcc(GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::Vendor, LibraryPurchase.CreateVendorNo(), "Gen. Journal Account Type"::"G/L Account", LibraryERM.CreateGLAccountNo(), -100);
    end;

    internal procedure FindRegisteredErrorMessage(var ErrorMessagesTestPage: TestPage "Error Messages"; var ErrorMessageRec: Record "Error Message")
    var
        DateTimeVar1: DateTime;
        DateTimeVar2: DateTime;
    begin
        ErrorMessageRec.SetRange(Message, ErrorMessagesTestPage.Description.Value);
        ErrorMessageRec.SetRange("Recommended Action Caption", ErrorMessagesTestPage."Recommended Action".Value);
        ErrorMessageRec.SetRange("Message Status", ErrorMessagesTestPage."Message Status".AsInteger());

        ErrorMessageRec.SetRange("Additional Information", ErrorMessagesTestPage."Error Messages Card Part"."Additional Information".Value);
        ErrorMessageRec.SetRange("Field Name", ErrorMessagesTestPage."Error Messages Card Part"."Field Name".Value);
        ErrorMessageRec.SetRange("Context Field Name", ErrorMessagesTestPage."Error Messages Card Part"."Context Field Name".Value);

        DateTimeVar1 := ErrorMessagesTestPage."Error Messages Card Part".TimeOfError.AsDateTime() - 1000;
        DateTimeVar2 := ErrorMessagesTestPage."Error Messages Card Part".TimeOfError.AsDateTime() + 1000;
        ErrorMessageRec.SetRange("Created On", DateTimeVar1, DateTimeVar2); //There is a discrepancy between the DateTime stored in the memory vs DateTime returned from the TestPage.

        ErrorMessageRec.FindFirst();

        Assert.AreEqual(ErrorMessageRec."Record ID".GetRecord().Caption, ErrorMessagesTestPage."Error Messages Card Part".Source.Value, 'Source in the error message does not match');
        Assert.AreEqual(Format(ErrorMessageRec."Context Record ID"), ErrorMessagesTestPage."Error Messages Card Part".Context.Value, 'Context in the error message does not match');
    end;

}