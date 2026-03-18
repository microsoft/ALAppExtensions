// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;
using Microsoft.Bank.BankAccount;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

codeunit 144032 "UT BANKACC"
{
    // 1. Purpose of the test is to validate test RIB Checked is True by filling Bank Branch No.,Agency Code,Bank Account No. and RIB Key. on Bank Account Table.
    // 2. Purpose of the test is to validate test RIB Checked is False by non - filling of  Bank Branch No. on Bank Account Table.
    // 3. Purpose of the test is to validate test 5 digit Agency Code on Bank Account Table.
    // 4. Purpose of the test is to validate test RIB Checked is True by filling Bank Branch No.,Agency Code,Bank Account No. and RIB Key. on Customer Bank Account Table.
    // 5. Purpose of the test is to validate test RIB Checked is False by non - filling of  Bank Branch No. on Customer Bank Account Table.
    // 6. Purpose of the test is to validate test RIB Checked is True by filling Bank Branch No.,Agency Code,Bank Account No. and RIB Key. on Vendor Bank Account Table.
    // 7. Purpose of the test is to validate test RIB Checked is False by non - filling of  Bank Branch No. on Vendor Bank Account Table.
    // 8. Purpose of the test is to validate test Default Bank Account Code on Customer Bank Account Card page.
    // 9. Purpose of the test is to validate test Default Bank Account Code on Vendor Bank Account Card page.
    // 
    // Covers Test Cases for WI - 344162
    // ------------------------------------------------------------------------------------------------------------
    // Test Function Name                                                                                  TFS ID
    // ------------------------------------------------------------------------------------------------------------
    // OnValidateBankAccountNoRIBTrueBankAccount,OnValidateBankAccountNoRIBFalseBankAccount                151138
    // OnValidateAgencyCodeBankAccount                                                                     151144
    // OnValidateBankAccountNoRIBTrueCustomerBankAccount,OnValidateBankAccountNoRIBFalseCustomerBankAccount151136
    // OnValidateBankAccountNoRIBTrueVendorBankAccount,OnValidateBankAccountNoRIBFalseVendorBankAccount    151137
    // OnValidateDefaultBankAccountCustomerCard                                                            151145
    // OnValidateDefaultBankAccountVendorCard                                                              151146

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
        LibraryUTUtility: Codeunit "Library UT Utility";
        LibraryRandom: Codeunit "Library - Random";
        BankBranchNoTxt: Label '12000';
        AgencyCodeTxt: Label '03100';
#pragma warning disable AA0240
        BankAccountNoTxt: Label '00012123003';
#pragma warning restore AA0240

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnValidateBankAccountNoRIBTrueBankAccount()
    begin
        // Purpose of the test is to validate test RIB Checked is True by filling Bank Branch No.,Agency Code,Bank Account No. and RIB Key. on Bank Account Table.
        OnValidateBankAccountNoRIBBankAccount(BankBranchNoTxt, true);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnValidateBankAccountNoRIBFalseBankAccount()
    begin
        // Purpose of the test is to validate test RIB Checked is False by non - filling of  Bank Branch No. on Bank Account Table.
        OnValidateBankAccountNoRIBBankAccount('', false);  // Using Blank for Bank Account No.
    end;

    local procedure OnValidateBankAccountNoRIBBankAccount(BankAccountNo: Code[20]; RIBChecked: Boolean)
    var
        BankAccount: Record "Bank Account";
    begin
        // Setup: Create Bank Account.
        CreateBankAccount(BankAccount);

        // Exercise: Validate fields due to feature RIB Checked and Using hardcode for Agency Code,Bank Account No. and RIB Key due to fixed nature to return 0.
        UpdateBankAccount(BankAccount, BankAccountNo, AgencyCodeTxt, BankAccountNoTxt, 7);  // Using blank for Bank Branch No.

        // Verify.
        BankAccount.Get(BankAccount."No.");
        BankAccount.TestField("RIB Checked FR", RIBChecked);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnValidateAgencyCodeBankAccount()
    var
        BankAccount: Record "Bank Account";
        AgencyCode: Text[5];
    begin
        // Purpose of the test is to validate test 5 digit Agency Code on Bank Account Table.

        // Setup: Create Bank Account and Agency Code.
        AgencyCode := Format(LibraryRandom.RandIntInRange(1, 4));  // Using Random for Agency Code.
        CreateBankAccount(BankAccount);

        // Validate fields due to feature RIB Checked.Using hardcode for Bank Branch No.,Agency Code,Bank Account No. and RIB Key due to fixed nature to return 0.
        UpdateBankAccount(
          BankAccount, BankBranchNoTxt, AgencyCode, BankAccountNoTxt, LibraryRandom.RandInt(10));  // Using Random for Agency Code and RIB Key.

        // Exercise: Checking field length is 5 and if less than 5, Zero will added in prefix.
        if StrLen(AgencyCode) < 5 then
            AgencyCode := PadStr('', 5 - StrLen(AgencyCode), '0') + AgencyCode;

        // Verify.
        BankAccount.Get(BankAccount."No.");
        BankAccount.TestField("Agency Code FR", AgencyCode);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnValidateBankAccountNoRIBTrueCustomerBankAccount()
    var
        CustomerBankAccount: Record "Customer Bank Account";
    begin
        // Purpose of the test is to validate test RIB Checked is True by filling Bank Branch No.,Agency Code,Bank Account No. and RIB Key. on Customer Bank Account Table.

        // Setup: Create Customer Bank Account.
        CreateCustomerBankAccount(CustomerBankAccount);

        // Exercise: Validate fields due to feature RIB Checked.Using hardcode for Bank Branch No.,Agency Code,Bank Account No. and RIB Key due to fixed nature to return 0.
        UpdateCustomerBankAccount(CustomerBankAccount, BankBranchNoTxt, AgencyCodeTxt, BankAccountNoTxt, 7);

        // Verify.
        CustomerBankAccount.Get(CustomerBankAccount."Customer No.", CustomerBankAccount.Code);
        CustomerBankAccount.TestField("RIB Checked FR", true);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnValidateBankAccountNoRIBFalseCustomerBankAccount()
    var
        CustomerBankAccount: Record "Customer Bank Account";
    begin
        // Purpose of the test is to validate test RIB Checked is False by non - filling of  Bank Branch No. on Customer Bank Account Table.

        // Setup: Create Customer Bank Account.
        CreateCustomerBankAccount(CustomerBankAccount);

        // Exercise: Validate fields due to feature RIB Checked.Using hardcode for Agency Code,Bank Account No. and RIB Key due to fixed nature to return 0.
        UpdateCustomerBankAccount(CustomerBankAccount, '', AgencyCodeTxt, BankAccountNoTxt, 7);  // Using blank for Bank Branch No.

        // Verify.
        CustomerBankAccount.Get(CustomerBankAccount."Customer No.", CustomerBankAccount.Code);
        CustomerBankAccount.TestField("RIB Checked FR", false);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnValidateBankAccountNoRIBTrueVendorBankAccount()
    var
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        // Purpose of the test is to validate test RIB Checked is True by filling Bank Branch No.,Agency Code,Bank Account No. and RIB Key. on Vendor Bank Account Table.

        // Setup: Create Vendor Bank Account.
        CreateVendorBankAccount(VendorBankAccount);

        // Exercise: Validate fields due to feature RIB Checked.Using hardcode for Agency Code,Bank Account No. and RIB Key due to fixed nature to return 0.
        UpdateVendorBankAccount(VendorBankAccount, BankBranchNoTxt, AgencyCodeTxt, BankAccountNoTxt, 7);

        // Verify.
        VendorBankAccount.Get(VendorBankAccount."Vendor No.", VendorBankAccount.Code);
        VendorBankAccount.TestField("RIB Checked FR", true);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnValidateBankAccountNoRIBFalseVendorBankAccount()
    var
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        // Purpose of the test is to validate test RIB Checked is False by non - filling of  Bank Branch No. on Vendor Bank Account Table.

        // Setup: Create Vendor Bank Account.
        CreateVendorBankAccount(VendorBankAccount);

        // Exercise: Validate fields due to feature RIB Checked.Using hardcode for Agency Code,Bank Account No. and RIB Key due to fixed nature to return 0.
        UpdateVendorBankAccount(VendorBankAccount, '', AgencyCodeTxt, BankAccountNoTxt, 7);  // Using blank for Bank Branch No.

        // Verify.
        VendorBankAccount.Get(VendorBankAccount."Vendor No.", VendorBankAccount.Code);
        VendorBankAccount.TestField("RIB Checked FR", false);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnValidateDefaultBankAccountCustomerCard()
    var
        CustomerBankAccount: Record "Customer Bank Account";
        CustomerCard: TestPage "Customer Card";
    begin
        // Purpose of the test is to validate test Default Bank Account Code on Customer Bank Account Card page.

        // Setup: Create Vendor Bank Account.
        CreateCustomerBankAccount(CustomerBankAccount);
        CustomerCard.OpenEdit();

        // Exercise.
        CustomerCard.FILTER.SetFilter("No.", CustomerBankAccount."Customer No.");

        // Verify.
        CustomerCard."Preferred Bank Account Code".AssertEquals(CustomerBankAccount.Code);
        CustomerCard.Close();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnValidateDefaultBankAccountVendorCard()
    var
        VendorBankAccount: Record "Vendor Bank Account";
        VendorCard: TestPage "Vendor Card";
    begin
        // Purpose of the test is to validate test Default Bank Account Code on Vendor Bank Account Card page.

        // Setup: Create Vendor Bank Account.
        CreateVendorBankAccount(VendorBankAccount);
        VendorCard.OpenEdit();

        // Exercise.
        VendorCard.FILTER.SetFilter("No.", VendorBankAccount."Vendor No.");

        // Verify.
        VendorCard."Preferred Bank Account Code".AssertEquals(VendorBankAccount.Code);
        VendorCard.Close();
    end;

    local procedure CreateBankAccount(var BankAccount: Record "Bank Account")
    begin
        BankAccount."No." := LibraryUTUtility.GetNewCode();
        BankAccount.Insert();
    end;

    local procedure CreateCustomerBankAccount(var CustomerBankAccount: Record "Customer Bank Account")
    var
        Customer: Record Customer;
    begin
        Customer."No." := LibraryUTUtility.GetNewCode();
        Customer.Insert(true);
        CustomerBankAccount."Customer No." := Customer."No.";
        CustomerBankAccount.Code := LibraryUTUtility.GetNewCode10();
        CustomerBankAccount.Insert();
        Customer."Preferred Bank Account Code" := CustomerBankAccount.Code;
        Customer.Modify();
    end;

    local procedure CreateVendorBankAccount(var VendorBankAccount: Record "Vendor Bank Account")
    var
        Vendor: Record Vendor;
    begin
        Vendor."No." := LibraryUTUtility.GetNewCode();
        Vendor.Insert(true);
        VendorBankAccount."Vendor No." := Vendor."No.";
        VendorBankAccount.Code := LibraryUTUtility.GetNewCode10();
        VendorBankAccount.Insert();
        Vendor."Preferred Bank Account Code" := VendorBankAccount.Code;
        Vendor.Modify();
    end;

    local procedure UpdateBankAccount(BankAccount: Record "Bank Account"; BankBranchNo: Text[20]; AgencyCode: Text[5]; BankAccountNo: Text[30]; RIBKey: Integer)
    begin
        // Validate fields due to feature RIB Checked.
        BankAccount.Validate("Bank Branch No.", BankBranchNo);
        BankAccount.Validate("Agency Code FR", AgencyCode);
        BankAccount.Validate("Bank Account No.", BankAccountNo);
        BankAccount.Validate("RIB Key FR", RIBKey);
        BankAccount.Modify();
    end;

    local procedure UpdateCustomerBankAccount(CustomerBankAccount: Record "Customer Bank Account"; BankBranchNo: Text[20]; AgencyCode: Text[5]; BankAccountNo: Text[30]; RIBKey: Integer)
    begin
        // Validate fields due to feature RIB Checked.
        CustomerBankAccount.Validate("Bank Branch No.", BankBranchNo);
        CustomerBankAccount.Validate("Agency Code FR", AgencyCode);
        CustomerBankAccount.Validate("Bank Account No.", BankAccountNo);
        CustomerBankAccount.Validate("RIB Key FR", RIBKey);
        CustomerBankAccount.Modify();
    end;

    local procedure UpdateVendorBankAccount(VendorBankAccount: Record "Vendor Bank Account"; BankBranchNo: Text[20]; AgencyCode: Text[5]; BankAccountNo: Text[30]; RIBKey: Integer)
    begin
        // Validate fields due to feature RIB Checked.
        VendorBankAccount.Validate("Bank Branch No.", BankBranchNo);
        VendorBankAccount.Validate("Agency Code FR", AgencyCode);
        VendorBankAccount.Validate("Bank Account No.", BankAccountNo);
        VendorBankAccount.Validate("RIB Key FR", RIBKey);
        VendorBankAccount.Modify();
    end;

#if not CLEAN28
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Payment Management Feature FR", OnAfterCheckFeatureEnabled, '', false, false)]
    local procedure OnAfterCheckFeatureEnabled(var IsEnabled: Boolean)
    begin
        IsEnabled := true;
    end;
#endif
}
