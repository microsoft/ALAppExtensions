// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Bank;

using Microsoft.DemoTool;
using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.CRM;
using Microsoft.DemoData.Foundation;
using Microsoft.Finance.GST.Base;
using Microsoft.Bank.BankAccount;

codeunit 19009 "Create IN Bank Account"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoBank: Codeunit "Contoso Bank";
        SalespersonPurchaser: Codeunit "Create Salesperson/Purchaser";
        CreateBankAccPostingGroup: Codeunit "Create Bank Acc. Posting Grp";
        CreateINState: Codeunit "Create IN State";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        ContosoBank.InsertBankAccount(Giro(), GiroLbl, GiroAccountAddressLbl, NewDelhiCityLbl, GiroAccountContactLbl, GiroBankAccountNoLbl, 0, CreateBankAccPostingGroup.Savings(), SalespersonPurchaser.OtisFalls(), ContosoCoffeeDemoDataSetup."Country/Region Code", '', '', NewDelhiPostCodeLbl, '', GiroBranchNoLbl, '');
        ContosoBank.InsertBankAccount(NBL(), NBLLbl, NBLAccountAddressLbl, NewDelhiCityLbl, NBLAccountContactLbl, NBLBankAccountNoLbl, 0, CreateBankAccPostingGroup.Checking(), SalespersonPurchaser.OtisFalls(), ContosoCoffeeDemoDataSetup."Country/Region Code", '4', '', NewDelhiPostCodeLbl, '', NBLBranchNoLbl, '');

        UpdateTaxInformationOnBankAccount(Giro(), 'GB 80 RBOS 161732 41116737', CreateINState.Delhi(), '07LOCAT1000R1Z1', Enum::"Bank Registration Status"::Registered);
        UpdateTaxInformationOnBankAccount(NBL(), '', CreateINState.Delhi(), '', Enum::"Bank Registration Status"::" ");
    end;

    local procedure UpdateTaxInformationOnBankAccount(BankAccountNo: Code[20]; IBAN: COde[50]; StateCode: Code[10]; GSTRegistrationNo: Code[20]; GSTRegistrationStatus: Enum "Bank Registration Status")
    var
        BankAccount: Record "Bank Account";
    begin
        if BankAccount.Get(BankAccountNo) then begin
            BankAccount.Validate(IBAN, IBAN);
            BankAccount.Validate("State Code", StateCode);
            BankAccount."GST Registration No." := GSTRegistrationNo;
            BankAccount."GST Registration Status" := GSTRegistrationStatus;
            BankAccount.Modify(true);
        end;
    end;

    procedure Giro(): Code[20]
    begin
        exit(GiroTok);
    end;

    procedure NBL(): Code[20]
    begin
        exit(NBLTok);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertBankAccount(var Rec: Record "Bank Account")
    var
        CreateBankAccount: Codeunit "Create Bank Account";
    begin
        case Rec."No." of
            CreateBankAccount.Checking():
                ValidateRecordFields(Rec, -64880000, CityLbl, PostCodeLbl);
            CreateBankAccount.Savings():
                ValidateRecordFields(Rec, 0, CityLbl, PostCodeLbl);
        end;
    end;

    local procedure ValidateRecordFields(var BankAccount: Record "Bank Account"; MinBalance: Decimal; City: Text[30]; PostCode: Code[20])
    begin
        BankAccount.Validate("Min. Balance", MinBalance);
        BankAccount.Validate(City, City);
        BankAccount.Validate("Post Code", PostCode);
    end;

    var
        CityLbl: Label 'London', MaxLength = 30, Locked = true;
        PostCodeLbl: Label 'GB-WC1 3DG', MaxLength = 20, Locked = true;
        GiroTok: Label 'GIRO', MaxLength = 20;
        NBLTok: Label 'NBL', MaxLength = 20;
        GiroLbl: Label 'Giro Bank', MaxLength = 100;
        NBLLbl: Label 'New Bank of London', MaxLength = 100;
        GiroAccountAddressLbl: Label '2 Bridge Street', MaxLength = 100, Locked = true;
        NBLAccountAddressLbl: Label '4 Baker Street', MaxLength = 100, Locked = true;
        NewDelhiCityLbl: Label 'New Delhi', MaxLength = 30, Locked = true;
        GiroAccountContactLbl: Label 'Paula Nartker', MaxLength = 100;
        NBLAccountContactLbl: Label 'Holly Dickson', MaxLength = 100;
        GiroBankAccountNoLbl: Label '14-55-678', Locked = true;
        NBLBankAccountNoLbl: Label '78-66-345', Locked = true;
        NewDelhiPostCodeLbl: Label '110001', Locked = true;
        GiroBranchNoLbl: Label 'GO284033', Locked = true;
        NBLBranchNoLbl: Label 'NB54366', Locked = true;
}
