// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Company;
using Microsoft.HumanResources.Employee;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;
using System.Reflection;
using System.Utilities;

codeunit 5286 "Data Check Mgt. SAF-T"
{
    Access = Internal;
    TableNo = "Audit File Export Header";

    var
        ErrorMessageMgt: Codeunit "Error Message Management";
        ErrorMessageHandler: Codeunit "Error Message Handler";
        SAFTDataMgt: Codeunit "SAF-T Data Mgt.";
        MissedValueErr: label 'A field value missed';
        MultipleValuesMissedErr: label 'At least one of the following values must not be blank: %1', Comment = '%1 = list of field captions';
        SourceCodeWithoutSAFTCodeErr: label 'One or more source codes do not have a SAF-T source code. Open the Source Codes page and specify a SAF-T source code for each source code.';
        DimensionWithoutAnalysisCodeErr: label 'One or more dimensions do not have a SAF-T analysis code. Open the Dimensions page and specify a SAF-T analysis code for each dimension.';
        OrTok: label ' or ';
        DKCountryCodeTxt: label 'DK', Locked = true;

    trigger OnRun()
    var
        TypeHelper: Codeunit "Type Helper";
        ErrorContextElement: Codeunit "Error Context Element";
    begin
        ErrorMessageMgt.Activate(ErrorMessageHandler);
        ErrorMessageMgt.PushContext(ErrorContextElement, Rec.RecordId(), 0, '');
        CheckCompanyInformation();
        CheckGLSetup();
        CheckGLAccounts();
        CheckCustomers(Rec);
        CheckVendors();
        CheckVATPostingSetup();
        CheckDimensions();
        OnCollectErrors(ErrorMessageMgt);
        if ErrorMessageHandler.HasErrors() then begin
            Rec."Data check status" := Rec."Data check status"::Failed;
            ErrorMessageHandler.ShowErrors()
        end else
            Rec."Data check status" := Rec."Data check status"::Passed;
        Rec."Latest Data Check Date/Time" := TypeHelper.GetCurrentDateTimeInUserTimeZone();
        Rec.Modify();
    end;

    procedure ThrowNotificationIfCustomerDataMissed(Rec: Record Customer): Boolean
    var
        TempMissingFieldSAFT: Record "Missing Field SAF-T" temporary;
    begin
        GetMissedValueFieldsForCustomer(TempMissingFieldSAFT, Rec);
        exit(IsAllowClosePage(TempMissingFieldSAFT));
    end;

    procedure ThrowNotificationIfVendorDataMissed(Rec: Record Vendor): Boolean
    var
        TempMissingFieldSAFT: Record "Missing Field SAF-T" temporary;
    begin
        GetMissedValueFieldsForVendor(TempMissingFieldSAFT, Rec);
        exit(IsAllowClosePage(TempMissingFieldSAFT));
    end;

    procedure ThrowNotificationIfCompanyInformationDataMissed(Rec: Record "Company Information"): Boolean
    var
        TempMissingFieldSAFT: Record "Missing Field SAF-T" temporary;
    begin
        GetMissedValueFieldsForCompanyInformation(TempMissingFieldSAFT, Rec);
        exit(IsAllowClosePage(TempMissingFieldSAFT));
    end;

    procedure ThrowNotificationIfBankAccountDataMissed(Rec: Record "Bank Account"): Boolean
    var
        TempMissingFieldSAFT: Record "Missing Field SAF-T" temporary;
    begin
        GetMissedValueFiedsForBankAccount(TempMissingFieldSAFT, Rec);
        exit(IsAllowClosePage(TempMissingFieldSAFT));
    end;

    procedure ThrowNotificationIfCustomerBankAccountDataMissed(Rec: Record "Customer Bank Account"): Boolean
    var
        TempMissingFieldSAFT: Record "Missing Field SAF-T" temporary;
    begin
        GetMissedValueFiedsForCustomerBankAccount(TempMissingFieldSAFT, Rec);
        exit(IsAllowClosePage(TempMissingFieldSAFT));
    end;

    procedure ThrowNotificationIfVendorBankAccountDataMissed(Rec: Record "Vendor Bank Account"): Boolean
    var
        TempMissingFieldSAFT: Record "Missing Field SAF-T" temporary;
    begin
        GetMissedValueFiedsForVendorBankAccount(TempMissingFieldSAFT, Rec);
        exit(IsAllowClosePage(TempMissingFieldSAFT));
    end;

    local procedure CheckCompanyInformation()
    var
        TempMissingFieldSAFT: Record "Missing Field SAF-T" temporary;
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        GetMissedValueFieldsForCompanyInformation(TempMissingFieldSAFT, CompanyInformation);
        LogErrorsGivenSAFTMissingFieldSource(TempMissingFieldSAFT);

        CheckBankAccounts();
    end;

    local procedure CheckBankAccounts()
    var
        BankAccount: Record "Bank Account";
        TempMissingFieldSAFT: Record "Missing Field SAF-T" temporary;
    begin
        if not BankAccount.FindSet() then
            exit;
        repeat
            GetMissedValueFiedsForBankAccount(TempMissingFieldSAFT, BankAccount);
            LogErrorsGivenSAFTMissingFieldSource(TempMissingFieldSAFT);
        until BankAccount.Next() = 0;
    end;

    local procedure CheckGLSetup()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."LCY Code" = '' then
            LogMissedValueError(GeneralLedgerSetup.RecordId(), GeneralLedgerSetup.FieldNo("LCY Code"));
    end;

    local procedure CheckGLAccounts()
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.FindSet();
        repeat
            if GLAccount.Name = '' then
                LogMissedValueError(GLAccount.RecordId(), GLAccount.FieldNo(Name));
        until GLAccount.Next() = 0;
    end;

    local procedure CheckCustomers(var AuditFileExportHeader: Record "Audit File Export Header")
    var
        Customer: Record Customer;
        TempMissingFieldSAFT: Record "Missing Field SAF-T" temporary;
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        Customer.SetLoadFields(Name, Address, City, "Post Code");
        if not Customer.FindSet() then
            exit;

        repeat
            CustLedgerEntry.SetCurrentKey("Customer No.", "Posting Date");
            CustLedgerEntry.SetRange("Customer No.", Customer."No.");
            CustLedgerEntry.SetRange("Posting Date", AuditFileExportHeader."Starting Date", ClosingDate(AuditFileExportHeader."Ending Date"));
            if not CustLedgerEntry.IsEmpty() then begin
                GetMissedValueFieldsForCustomer(TempMissingFieldSAFT, Customer);
                LogErrorsGivenSAFTMissingFieldSource(TempMissingFieldSAFT);
            end;
        until Customer.Next() = 0;
        CheckCustomerBankAccounts();
    end;

    local procedure CheckCustomerBankAccounts()
    var
        CustomerBankAccount: Record "Customer Bank Account";
        TempMissingFieldSAFT: Record "Missing Field SAF-T" temporary;
    begin
        if not CustomerBankAccount.FindSet() then
            exit;

        repeat
            GetMissedValueFiedsForCustomerBankAccount(TempMissingFieldSAFT, CustomerBankAccount);
            LogErrorsGivenSAFTMissingFieldSource(TempMissingFieldSAFT);
        until CustomerBankAccount.Next() = 0;
    end;

    local procedure CheckVendors()
    var
        Vendor: Record Vendor;
        TempMissingFieldSAFT: Record "Missing Field SAF-T" temporary;
    begin
        if not Vendor.FindSet() then
            exit;

        repeat
            GetMissedValueFieldsForVendor(TempMissingFieldSAFT, Vendor);
            LogErrorsGivenSAFTMissingFieldSource(TempMissingFieldSAFT);
        until Vendor.Next() = 0;
        CheckVendorBankAccounts();
    end;

    local procedure CheckVendorBankAccounts()
    var
        VendorBankAccount: Record "Vendor Bank Account";
        TempMissingFieldSAFT: Record "Missing Field SAF-T" temporary;
    begin
        if not VendorBankAccount.FindSet() then
            exit;

        repeat
            GetMissedValueFiedsForVendorBankAccount(TempMissingFieldSAFT, VendorBankAccount);
            LogErrorsGivenSAFTMissingFieldSource(TempMissingFieldSAFT);
        until VendorBankAccount.Next() = 0;
    end;

    local procedure CheckVATPostingSetup()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        CountryCode: Text;
    begin
        if not VATPostingSetup.FindSet() then
            exit;

        CountryCode := SAFTDataMgt.GetEnvironmentCountryCode();

        repeat
            if VATPostingSetup."Sales Tax Code SAF-T" = '' then
                LogMissedValueError(VATPostingSetup.RecordId(), VATPostingSetup.FieldNo("Sales Tax Code SAF-T"));
            if VATPostingSetup."Purchase Tax Code SAF-T" = '' then
                LogMissedValueError(VATPostingSetup.RecordId(), VATPostingSetup.FieldNo("Purchase Tax Code SAF-T"));

            if CountryCode = DKCountryCodeTxt then
                if VATPostingSetup."Starting Date" = 0D then
                    LogMissedValueError(VATPostingSetup.RecordId(), VATPostingSetup.FieldNo("Starting Date"));
        until VATPostingSetup.Next() = 0;
    end;

    local procedure CheckDimensions()
    var
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
    begin
        if not Dimension.FindSet() then
            exit;

        repeat
            if Dimension."Analysis Type SAF-T" = '' then
                LogMissedValueError(Dimension.RecordId(), Dimension.FieldNo("Analysis Type SAF-T"));
            if Dimension.Name = '' then
                LogMissedValueError(Dimension.RecordId(), Dimension.FieldNo(Name));
        until Dimension.Next() = 0;

        if not DimensionValue.FindSet() then
            exit;

        repeat
            if DimensionValue.Name = '' then
                LogMissedValueError(DimensionValue.RecordId(), DimensionValue.FieldNo(Name));
        until DimensionValue.Next() = 0;
    end;

    local procedure GetMissedValueFieldsForCompanyInformation(var TempMissingFieldSAFT: Record "Missing Field SAF-T" temporary; CompanyInformation: Record "Company Information")
    var
        Employee: Record Employee;
        FieldList: List of [Integer];
    begin
        TempMissingFieldSAFT.Reset();
        TempMissingFieldSAFT.DeleteAll();
        CompanyInformation.Get();
        if CompanyInformation."VAT Registration No." = '' then
            AddBasicSAFTMissingField(TempMissingFieldSAFT, CompanyInformation, CompanyInformation.FieldNo("VAT Registration No."));
        if CompanyInformation."Country/Region Code" = '' then
            AddBasicSAFTMissingField(TempMissingFieldSAFT, CompanyInformation, CompanyInformation.FieldNo("Country/Region Code"));
        if CompanyInformation.Name = '' then
            AddBasicSAFTMissingField(TempMissingFieldSAFT, CompanyInformation, CompanyInformation.FieldNo(Name));
        if CheckAddress() and (CompanyInformation.Address = '') then
            AddBasicSAFTMissingField(TempMissingFieldSAFT, CompanyInformation, CompanyInformation.FieldNo(Address));
        if CompanyInformation.City = '' then
            AddBasicSAFTMissingField(TempMissingFieldSAFT, CompanyInformation, CompanyInformation.FieldNo(City));
        if CheckPostCode() and (CompanyInformation."Post Code" = '') then
            AddBasicSAFTMissingField(TempMissingFieldSAFT, CompanyInformation, CompanyInformation.FieldNo("Post Code"));
        if CompanyInformation."Contact No. SAF-T" = '' then
            AddBasicSAFTMissingField(TempMissingFieldSAFT, CompanyInformation, CompanyInformation.FieldNo("Contact No. SAF-T"))
        else begin
            Employee.Get(CompanyInformation."Contact No. SAF-T");
            if Employee."First Name" = '' then
                AddBasicSAFTMissingField(TempMissingFieldSAFT, Employee, Employee.FieldNo("First Name"));
        end;
        if (CompanyInformation.IBAN = '') and (CompanyInformation."Bank Account No." = '') and
           (CompanyInformation."Bank Name" = '') and (CompanyInformation."Bank Branch No." = '')
        then begin
            FieldList.Add(CompanyInformation.FieldNo(IBAN));
            FieldList.Add(CompanyInformation.FieldNo("Bank Account No."));
            FieldList.Add(CompanyInformation.FieldNo("Bank Name"));
            FieldList.Add(CompanyInformation.FieldNo("Bank Branch No."));
            AddSAFTMissingFieldGroup(TempMissingFieldSAFT, CompanyInformation, FieldList);
        end;
    end;

    local procedure GetMissedValueFiedsForBankAccount(var TempMissingFieldSAFT: Record "Missing Field SAF-T" temporary; BankAccount: Record "Bank Account")
    var
        FieldList: List of [Integer];
    begin
        TempMissingFieldSAFT.Reset();
        TempMissingFieldSAFT.DeleteAll();
        if (BankAccount.IBAN = '') and (BankAccount."Bank Account No." = '') and
            (BankAccount.Name + BankAccount."Name 2" = '') and (BankAccount."Bank Branch No." = '')
        then begin
            FieldList.Add(BankAccount.FieldNo(IBAN));
            FieldList.Add(BankAccount.FieldNo("Bank Account No."));
            FieldList.Add(BankAccount.FieldNo(Name));
            FieldList.Add(BankAccount.FieldNo("Bank Branch No."));
            AddSAFTMissingFieldGroup(TempMissingFieldSAFT, BankAccount, FieldList);
        end;
    end;

    local procedure GetMissedValueFiedsForCustomerBankAccount(var TempMissingFieldSAFT: Record "Missing Field SAF-T" temporary; CustomerBankAccount: Record "Customer Bank Account")
    var
        FieldList: List of [Integer];
    begin
        TempMissingFieldSAFT.Reset();
        TempMissingFieldSAFT.DeleteAll();
        if (CustomerBankAccount.IBAN = '') and (CustomerBankAccount."Bank Account No." = '') and
            (CustomerBankAccount.Name + CustomerBankAccount."Name 2" = '') and (CustomerBankAccount."Bank Branch No." = '')
        then begin
            FieldList.Add(CustomerBankAccount.FieldNo(IBAN));
            FieldList.Add(CustomerBankAccount.FieldNo("Bank Account No."));
            FieldList.Add(CustomerBankAccount.FieldNo(Name));
            FieldList.Add(CustomerBankAccount.FieldNo("Bank Branch No."));
            AddSAFTMissingFieldGroup(TempMissingFieldSAFT, CustomerBankAccount, FieldList);
        end;
    end;

    local procedure GetMissedValueFiedsForVendorBankAccount(var TempMissingFieldSAFT: Record "Missing Field SAF-T" temporary; VendorBankAccount: Record "Vendor Bank Account")
    var
        FieldList: List of [Integer];
    begin
        TempMissingFieldSAFT.Reset();
        TempMissingFieldSAFT.DeleteAll();
        if (VendorBankAccount.IBAN = '') and (VendorBankAccount."Bank Account No." = '') and
            (VendorBankAccount.Name + VendorBankAccount."Name 2" = '') and (VendorBankAccount."Bank Branch No." = '')
        then begin
            FieldList.Add(VendorBankAccount.FieldNo(IBAN));
            FieldList.Add(VendorBankAccount.FieldNo("Bank Account No."));
            FieldList.Add(VendorBankAccount.FieldNo(Name));
            FieldList.Add(VendorBankAccount.FieldNo("Bank Branch No."));
            AddSAFTMissingFieldGroup(TempMissingFieldSAFT, VendorBankAccount, FieldList);
        end;
    end;

    local procedure GetMissedValueFieldsForCustomer(var TempMissingFieldSAFT: Record "Missing Field SAF-T" temporary; Customer: Record Customer)
    begin
        TempMissingFieldSAFT.Reset();
        TempMissingFieldSAFT.DeleteAll();
        if Customer.Name = '' then
            AddBasicSAFTMissingField(TempMissingFieldSAFT, Customer, Customer.FieldNo(Name));
        if CheckAddress() and (Customer.Address = '') then
            AddBasicSAFTMissingField(TempMissingFieldSAFT, Customer, Customer.FieldNo(Address));
        if Customer.City = '' then
            AddBasicSAFTMissingField(TempMissingFieldSAFT, Customer, Customer.FieldNo(City));
        if CheckPostCode() and (Customer."Post Code" = '') then
            AddBasicSAFTMissingField(TempMissingFieldSAFT, Customer, Customer.FieldNo("Post Code"));
    end;

    local procedure GetMissedValueFieldsForVendor(var TempMissingFieldSAFT: Record "Missing Field SAF-T" temporary; Vendor: Record Vendor)
    begin
        TempMissingFieldSAFT.Reset();
        TempMissingFieldSAFT.DeleteAll();
        if Vendor.Name = '' then
            AddBasicSAFTMissingField(TempMissingFieldSAFT, Vendor, Vendor.FieldNo(Name));
        if CheckAddress() and (Vendor.Address = '') then
            AddBasicSAFTMissingField(TempMissingFieldSAFT, Vendor, Vendor.FieldNo(Address));
        if Vendor.City = '' then
            AddBasicSAFTMissingField(TempMissingFieldSAFT, Vendor, Vendor.FieldNo(City));
        if CheckPostCode() and (Vendor."Post Code" = '') then
            AddBasicSAFTMissingField(TempMissingFieldSAFT, Vendor, Vendor.FieldNo("Post Code"));
    end;

    local procedure LogErrorsGivenSAFTMissingFieldSource(var TempMissingFieldSAFT: Record "Missing Field SAF-T" temporary)
    var
        FieldList: Text;
    begin
        TempMissingFieldSAFT.Reset();
        TempMissingFieldSAFT.SetRange("Group No.", 0);
        if TempMissingFieldSAFT.FindSet() then
            repeat
                LogMissedValueError(TempMissingFieldSAFT."Record ID", TempMissingFieldSAFT."Field No.");
            until TempMissingFieldSAFT.Next() = 0;
        TempMissingFieldSAFT.SetFilter("Group No.", '<>%1', 0);
        if TempMissingFieldSAFT.FindSet() then
            repeat
                TempMissingFieldSAFT.SetRange("Group No.", TempMissingFieldSAFT."Group No.");
                FieldList := '';
                repeat
                    FieldList += (TempMissingFieldSAFT."Field Caption" + ' / ');
                until TempMissingFieldSAFT.Next() = 0;
                FieldList := FieldList.TrimEnd(' /');
                LogContextError(StrSubstNo(MultipleValuesMissedErr, FieldList), TempMissingFieldSAFT."Record ID");
                TempMissingFieldSAFT.SetFilter("Group No.", '<>%1', 0);
            until TempMissingFieldSAFT.Next() = 0;
    end;

    local procedure AddBasicSAFTMissingField(var TempMissingFieldSAFT: Record "Missing Field SAF-T" temporary; RecordVar: Variant; FieldNo: Integer)
    begin
        AddSAFTMissingField(TempMissingFieldSAFT, RecordVar, FieldNo, 0);
    end;

    local procedure AddSAFTMissingFieldGroup(var TempMissingFieldSAFT: Record "Missing Field SAF-T" temporary; RecordVar: Variant; FieldNos: List of [Integer])
    var
        RecRef: RecordRef;
        GroupNo: Integer;
        i: Integer;
        FieldNo: Integer;
    begin
        RecRef.GetTable(RecordVar);
        TempMissingFieldSAFT.Reset();
        TempMissingFieldSAFT.SetCurrentKey("Table No.", "Group No.");
        TempMissingFieldSAFT.SetRange("Table No.", RecRef.Number());
        TempMissingFieldSAFT.SetFilter("Group No.", '<>%1', 0);
        if TempMissingFieldSAFT.FindLast() then
            GroupNo := TempMissingFieldSAFT."Group No.";
        GroupNo += 1;
        for i := 1 to FieldNos.Count() do begin
            FieldNos.Get(i, FieldNo);
            AddSAFTMissingField(TempMissingFieldSAFT, RecordVar, FieldNo, GroupNo);
        end;
    end;

    local procedure AddSAFTMissingField(var TempMissingFieldSAFT: Record "Missing Field SAF-T" temporary; RecordVar: Variant; FieldNo: Integer; GroupNo: Integer)
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        RecRef.GetTable(RecordVar);
        TempMissingFieldSAFT."Table No." := RecRef.Number();
        TempMissingFieldSAFT."Field No." := FieldNo;
        if TempMissingFieldSAFT.Find() then
            exit;
        TempMissingFieldSAFT."Record ID" := RecRef.RecordId();
        FldRef := RecRef.Field(FieldNo);
        TempMissingFieldSAFT."Field Caption" := CopyStr(FldRef.Caption(), 1, MaxStrLen(TempMissingFieldSAFT."Field Caption"));
        TempMissingFieldSAFT."Group No." := GroupNo;
        TempMissingFieldSAFT.Insert();
    end;

    local procedure ShowError(SourceVariant: Variant; ErrorMessage: Text)
    var
        ErrorMessageManagement: Codeunit "Error Message Management";
    begin
        if not GuiAllowed() then
            Error(ErrorMessage);
        ErrorMessageManagement.LogError(SourceVariant, ErrorMessage, '');
    end;

    local procedure LogMissedValueError(SourceVariant: Variant; SourceFieldNo: Integer)
    begin
        LogError(MissedValueErr, SourceVariant, SourceFieldNo);
    end;

    local procedure LogContextError(ErrorMessage: Text; SourceVariant: Variant)
    begin
        LogError(ErrorMessage, SourceVariant, 0);
    end;

    local procedure LogError(ErrorMessage: Text; SourceVariant: Variant; SourceFieldNo: Integer)
    begin
        ErrorMessageMgt.LogContextFieldError(0, ErrorMessage, SourceVariant, SourceFieldNo, '');
    end;

    local procedure AddText(var ResultedText: Text; TextToAdd: Text)
    begin
        if TextToAdd = '' then
            exit;
        if ResultedText <> '' then
            ResultedText += ',';
        ResultedText += TextToAdd;
    end;

    local procedure IsAllowClosePage(var TempMissingFieldSAFT: Record "Missing Field SAF-T" temporary): Boolean
    var
        DataCheckSAFT: Page "Data Check SAF-T";
        MissedValuesList: Text;
        FieldList: Text;
    begin
        TempMissingFieldSAFT.Reset();
        TempMissingFieldSAFT.SetRange("Group No.", 0);
        if TempMissingFieldSAFT.FindSet() then
            repeat
                AddText(MissedValuesList, TempMissingFieldSAFT."Field Caption");
            until TempMissingFieldSAFT.Next() = 0;
        TempMissingFieldSAFT.SetFilter("Group No.", '<>%1', 0);
        if TempMissingFieldSAFT.FindSet() then
            repeat
                FieldList := '';
                TempMissingFieldSAFT.SetRange("Group No.", TempMissingFieldSAFT."Group No.");
                repeat
                    if FieldList <> '' then
                        FieldList += OrTok;
                    FieldList += TempMissingFieldSAFT."Field Caption";
                until TempMissingFieldSAFT.Next() = 0;
                AddText(MissedValuesList, FieldList);
                TempMissingFieldSAFT.SetFilter("Group No.", '<>%1', 0);
            until TempMissingFieldSAFT.Next() = 0;
        if MissedValuesList = '' then
            exit(true);
        DataCheckSAFT.SetMissedValuesList(MissedValuesList);
        DataCheckSAFT.LookupMode(true);
        exit(Action::No = DataCheckSAFT.RunModal());
    end;

    local procedure CheckPostCode(): Boolean
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
    begin
        AuditFileExportSetup.Get();
        exit(AuditFileExportSetup."Check Post Code");
    end;

    local procedure CheckAddress(): Boolean
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
    begin
        AuditFileExportSetup.Get();
        exit(AuditFileExportSetup."Check Address");
    end;

    procedure VerifySourceCodesHasSAFTCodes()
    var
        SourceCode: Record "Source Code";
    begin
        SourceCode.SetRange("Source Code SAF-T", '');
        if not SourceCode.IsEmpty() then
            ShowError(SourceCode, SourceCodeWithoutSAFTCodeErr);
    end;

    procedure VerifyDimensionsHaveAnalysisCode()
    var
        Dimension: Record Dimension;
    begin
        if Dimension.IsEmpty() then
            exit;
        Dimension.SetRange("Analysis Type SAF-T", '');
        if not Dimension.IsEmpty() then
            ShowError(Dimension, DimensionWithoutAnalysisCodeErr);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCollectErrors(var ErrorMessageMgt: Codeunit "Error Message Management")
    begin
    end;
}
