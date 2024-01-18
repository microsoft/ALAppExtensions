// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.Core;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using System.Environment;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Foundation.Company;
using System.Environment.Configuration;
using System.IO;
using System.Security.AccessControl;

codeunit 13601 "DK Core Event Subscribers"
{
    Permissions = TableData "Company Information" = r;

    var
        CannotPostWithoutCVRNumberErr: Label 'You cannot post without a valid CVR number filled in. Open the Company Information page and enter a CVR number in the Registration No. field.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade User Groups", 'OnBeforeUpgradeUserGroups', '', false, false)]
    local procedure TransferCustomPermissionsPerPlan()
    var
        UpgradeLocalPermissionSet: Codeunit "Upgrade Local Permission Set";
    begin
        UpgradeLocalPermissionSet.RunUpgrade();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnValidateBankAccount', '', false, false)]
    local procedure ValidateBankAccount(var BankAccount: Record "Bank Account"; FieldToValidate: Text);
    begin
        ValidateBankAcc(BankAccount."Bank Account No.", BankAccount."Bank Branch No.", FieldToValidate);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnGetBankAccount', '', false, false)]
    local procedure GetBankAccountNo(var Handled: Boolean; BankAccount: Record "Bank Account"; var ResultBankAccountNo: Text);
    begin
        if not Handled then begin
            Handled := true;

            GetBankAccNo(BankAccount."Bank Account No.", BankAccount."Bank Branch No.", BankAccount.IBAN, ResultBankAccountNo);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer Bank Account", 'OnValidateBankAccount', '', false, false)]
    local procedure ValidateCustomerBankAccount(var CustomerBankAccount: Record "Customer Bank Account"; FieldToValidate: Text);
    begin
        ValidateBankAcc(CustomerBankAccount."Bank Account No.", CustomerBankAccount."Bank Branch No.", FieldToValidate);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer Bank Account", 'OnGetBankAccount', '', false, false)]
    local procedure GetCustomerBankAccountNo(var Handled: Boolean; CustomerBankAccount: Record "Customer Bank Account"; var ResultBankAccountNo: Text);
    begin
        if not Handled then begin
            Handled := true;

            GetBankAccNo(CustomerBankAccount."Bank Account No.", CustomerBankAccount."Bank Branch No.", CustomerBankAccount.IBAN, ResultBankAccountNo);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Bank Account", 'OnValidateBankAccount', '', false, false)]
    local procedure ValidateVendorBankAccount(var VendorBankAccount: Record "Vendor Bank Account"; FieldToValidate: Text);
    begin
        ValidateBankAcc(VendorBankAccount."Bank Account No.", VendorBankAccount."Bank Branch No.", FieldToValidate);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Bank Account", 'OnGetBankAccount', '', false, false)]
    local procedure GetVendorBankAccountNo(var Handled: Boolean; VendorBankAccount: Record "Vendor Bank Account"; var ResultBankAccountNo: Text);
    begin
        if not Handled then begin
            Handled := true;

            GetBankAccNo(VendorBankAccount."Bank Account No.", VendorBankAccount."Bank Branch No.", VendorBankAccount.IBAN, ResultBankAccountNo);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt.", 'OnGetBasicExperienceAppAreas', '', false, false)]
    local procedure OnGetBasicExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary);
    begin
        TempApplicationAreaSetup."Basic DK" := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Pre & Post Process XML Import", 'OnCheckBankAccNo', '', false, false)]
    local procedure OnCheckBankAccNo(var Handled: Boolean; var CheckedResult: Boolean; DataExchFieldDetails: Query "Data Exch. Field Details"; BankAccount: Record "Bank Account");
    begin
        if not Handled then begin
            Handled := true;

            if (DelChr(DataExchFieldDetails.FieldValue, '=', '- ') <> DelChr(BankAccount."Bank Account No." + BankAccount."Bank Branch No.", '=', '- ')) then
                CheckedResult := true
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Setup Posting Groups", 'OnInitWithStandardValues', '', false, false)]
    local procedure OnInitWithStandardValuesOnInitWithStandardValues(var Handled: Boolean; VATSetupPostingGroups: Record "VAT Setup Posting Groups");
    begin
        if not Handled then begin
            Handled := true;

            VATSetupPostingGroups.AddOrUpdateProdPostingGrp(VATSetupPostingGroups.GetLabelTok('FULLNORMTok'), VATSetupPostingGroups.GetLabelTxt('FULLNORMTxt'), 100, '', '', false, true);
            VATSetupPostingGroups.AddOrUpdateProdPostingGrp(VATSetupPostingGroups.GetLabelTok('FULLREDTok'), VATSetupPostingGroups.GetLabelTxt('FULLREDTxt'), 100, '', '', false, true);
            VATSetupPostingGroups.AddOrUpdateProdPostingGrp(VATSetupPostingGroups.GetLabelTok('SERVNORMTok'), VATSetupPostingGroups.GetLabelTxt('SERVNORMTxt'), 25, '24010', '24020', true, true);
            VATSetupPostingGroups.AddOrUpdateProdPostingGrp(VATSetupPostingGroups.GetLabelTok('STANDARDTok'), VATSetupPostingGroups.GetLabelTxt('STANDARDTxt'), 25, '24010', '24020', false, true);
            VATSetupPostingGroups.AddOrUpdateProdPostingGrp(VATSetupPostingGroups.GetLabelTok('ZEROTok'), VATSetupPostingGroups.GetLabelTxt('ZEROTxt'), 0, '24010', '24020', false, true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeStartOrContinuePosting', '', false, false)]
    local procedure CheckCVRNumberOnBeforeStartOrContinuePosting()
    var
        CompanyInformation: Record "Company Information";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if not EnvironmentInformation.IsSaaSInfrastructure() then
            exit;
        if EnvironmentInformation.IsSandbox() then
            exit;

        CompanyInformation.Get();
        if CompanyInformation."Registration No." = '' then
            Error(CannotPostWithoutCVRNumberErr);
    end;

    local procedure ValidateBankAcc(var BankAccountNo: Text[30]; var BankBranchNo: Text[20]; FieldToValidate: Text)
    begin
        case FieldToValidate of
            'Bank Account No.':
                if (BankAccountNo <> '') and (StrLen(BankAccountNo) < 10) then
                    BankAccountNo := PadStr('', 10 - StrLen(BankAccountNo), '0') + BankAccountNo;
            'Bank Branch No.':
                if (BankBranchNo <> '') and (StrLen(BankBranchNo) < 4) then
                    BankBranchNo := PadStr('', 4 - StrLen(BankBranchNo), '0') + BankBranchNo;
        end;
    end;

    local procedure GetBankAccNo(BankAccountNo: Text[30]; BankBranchNo: Text[20]; IBAN: Code[50]; var ResultAccountNo: Text)
    begin
        if (BankBranchNo = '') or (BankAccountNo = '') then
            ResultAccountNo := DelChr(IBAN, '=<>')
        else
            ResultAccountNo := BankBranchNo + BankAccountNo;
    end;
}
