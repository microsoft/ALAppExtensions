// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Bank.BankAccount;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using System.Utilities;

codeunit 5285 "Audit Data Check SAF-T" implements "Audit File Export Data Check"
{
    Access = Internal;

    var
        FieldValueIsNotSpecifiedErr: label '%1 is not specified', Comment = '%1 - missed field caption';

    procedure CheckDataToExport(var AuditFileExportHeader: Record "Audit File Export Header") DataCheckStatus: enum "Audit Data Check status"
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
        DataCheckMgtSAFT: Codeunit "Data Check Mgt. SAF-T";
        DataCheckSAFT: Interface DataCheckSAFT;
        DataCheckStatusForModification: Enum "Audit Data Check Status";
    begin
        DataCheckMgtSAFT.Run(AuditFileExportHeader);

        AuditFileExportSetup.Get();
        DataCheckSAFT := AuditFileExportSetup."SAF-T Modification";
        DataCheckStatusForModification := DataCheckSAFT.CheckAuditDocReadyToExport(AuditFileExportHeader);

        AuditFileExportHeader.Get(AuditFileExportHeader.ID);
        if (AuditFileExportHeader."Data check status" = Enum::"Audit Data Check Status"::Failed) or
           (DataCheckStatusForModification = Enum::"Audit Data Check Status"::Failed)
        then
            exit(Enum::"Audit Data Check Status"::Failed);

        DataCheckStatus := Enum::"Audit Data Check Status"::Passed;
    end;

    procedure CheckAuditDocReadyToExport(var AuditFileExportHeader: Record "Audit File Export Header") DataCheckStatus: enum "Audit Data Check Status"
    var
        CompanyInformation: Record "Company Information";
        AuditFileExportSetup: Record "Audit File Export Setup";
        GLAccountMappingHeader: Codeunit "Audit Mapping Helper";
        DataCheckMgtSAFT: Codeunit "Data Check Mgt. SAF-T";
        ErrorMessageManagement: Codeunit "Error Message Management";
        DataCheckSAFT: Interface DataCheckSAFT;
        DataCheckStatusForModification: Enum "Audit Data Check Status";
    begin
        AuditFileExportHeader.TestField("G/L Account Mapping Code");
        AuditFileExportHeader.TestField("Starting Date");
        AuditFileExportHeader.TestField("Ending Date");
        GLAccountMappingHeader.VerifyMappingIsDone(AuditFileExportHeader."G/L Account Mapping Code");
        DataCheckMgtSAFT.VerifyDimensionsHaveAnalysisCode();
        DataCheckMgtSAFT.VerifySourceCodesHasSAFTCodes();
        CompanyInformation.Get();
        if CompanyInformation."Contact No. SAF-T" = '' then
            ErrorMessageManagement.LogErrorMessage(
                0, StrSubstNo(FieldValueIsNotSpecifiedErr, CompanyInformation.FieldCaption("Contact No. SAF-T")),
                CompanyInformation, CompanyInformation.FieldNo("Contact No. SAF-T"), '');

        AuditFileExportSetup.Get();
        DataCheckSAFT := AuditFileExportSetup."SAF-T Modification";
        DataCheckStatusForModification := DataCheckSAFT.CheckAuditDocReadyToExport(AuditFileExportHeader);

        if (ErrorMessageManagement.GetLastErrorID() <> 0) or
           (DataCheckStatusForModification = Enum::"Audit Data Check Status"::Failed)
        then
            exit(Enum::"Audit Data Check Status"::Failed);

        DataCheckStatus := Enum::"Audit Data Check Status"::Passed;
    end;

    procedure TestRequiredFields(var RecRef: RecordRef): enum "Audit Data Check status"
    var
        CompanyInformation: Record "Company Information";
        Customer: Record Customer;
        Vendor: Record Vendor;
        BankAccount: Record "Bank Account";
        CustomerBankAccount: Record "Customer Bank Account";
        VendorBankAccount: Record "Vendor Bank Account";
        DataCheckMgtSAFT: Codeunit "Data Check Mgt. SAF-T";
        ErrorsFound: Boolean;
    begin
        if RecRef.IsEmpty() then
            exit(Enum::"Audit Data Check Status"::" ");

        case RecRef.Number of
            Database::"Company Information":
                begin
                    RecRef.SetTable(CompanyInformation);
                    ErrorsFound := DataCheckMgtSAFT.ThrowNotificationIfCompanyInformationDataMissed(CompanyInformation);
                end;
            Database::Customer:
                begin
                    RecRef.SetTable(Customer);
                    ErrorsFound := DataCheckMgtSAFT.ThrowNotificationIfCustomerDataMissed(Customer);
                end;
            Database::Vendor:
                begin
                    RecRef.SetTable(Vendor);
                    ErrorsFound := DataCheckMgtSAFT.ThrowNotificationIfVendorDataMissed(Vendor);
                end;
            Database::"Bank Account":
                begin
                    RecRef.SetTable(BankAccount);
                    ErrorsFound := DataCheckMgtSAFT.ThrowNotificationIfBankAccountDataMissed(BankAccount);
                end;
            Database::"Customer Bank Account":
                begin
                    RecRef.SetTable(BankAccount);
                    ErrorsFound := DataCheckMgtSAFT.ThrowNotificationIfCustomerBankAccountDataMissed(CustomerBankAccount);
                end;
            Database::"Vendor Bank Account":
                begin
                    RecRef.SetTable(BankAccount);
                    ErrorsFound := DataCheckMgtSAFT.ThrowNotificationIfVendorBankAccountDataMissed(VendorBankAccount);
                end;
        end;

        if ErrorsFound then
            exit(Enum::"Audit Data Check Status"::Failed);

        exit(Enum::"Audit Data Check Status"::Passed);
    end;
}
