// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Bank;

using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Finance;
using Microsoft.Finance.GST.Base;

codeunit 19048 "Create IN Bank Charge"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoINTaxSetup: Codeunit "Contoso IN Tax Setup";
        CreateINGLAccounts: Codeunit "Create IN GL Accounts";
        CreateINGSTGroup: Codeunit "Create IN GST Group";
        CreateINHSNSAC: Codeunit "Create IN HSN/SAC";
    begin
        ContosoINTaxSetup.InsertBankCharge(BankCharge_01(), BankCharge_01Lbl, CreateINGLAccounts.OtherCharges(), false, CreateINGSTGroup.GSTGroup2089(), Enum::"GST Credit"::Availment, CreateINHSNSAC.HSNSACCode2089001(), false);
        ContosoINTaxSetup.InsertBankCharge(BankCharge_02(), BankCharge_02Lbl, CreateINGLAccounts.OtherCharges(), false, CreateINGSTGroup.GSTGroup2089(), Enum::"GST Credit"::"Non-Availment", CreateINHSNSAC.HSNSACCode2089001(), false);
        ContosoINTaxSetup.InsertBankCharge(BankCharge_03(), BankCharge_03Lbl, CreateINGLAccounts.OtherCharges(), false, CreateINGSTGroup.GSTGroup2089(), Enum::"GST Credit"::Availment, CreateINHSNSAC.HSNSACCode2089001(), true);
        ContosoINTaxSetup.InsertBankCharge(BankCharge_04(), BankCharge_04Lbl, CreateINGLAccounts.OtherCharges(), true, CreateINGSTGroup.GSTGroup2089(), Enum::"GST Credit"::Availment, CreateINHSNSAC.HSNSACCode2089001(), false);
        ContosoINTaxSetup.InsertBankCharge(BankCharge_05(), BankCharge_04Lbl, CreateINGLAccounts.OtherCharges(), true, CreateINGSTGroup.GSTGroup2089(), Enum::"GST Credit"::"Non-Availment", CreateINHSNSAC.HSNSACCode2089001(), false);
        ContosoINTaxSetup.InsertBankCharge(BankCharge_06(), BankCharge_04Lbl, CreateINGLAccounts.OtherCharges(), true, CreateINGSTGroup.GSTGroup2089(), Enum::"GST Credit"::Availment, CreateINHSNSAC.HSNSACCode2089001(), true);
    end;

    procedure BankCharge_01(): Code[10]
    begin
        exit(BankCharge_01Tok);
    end;

    procedure BankCharge_02(): Code[10]
    begin
        exit(BankCharge_02Tok);
    end;

    procedure BankCharge_03(): Code[10]
    begin
        exit(BankCharge_03Tok);
    end;

    procedure BankCharge_04(): Code[10]
    begin
        exit(BankCharge_04Tok);
    end;

    procedure BankCharge_05(): Code[10]
    begin
        exit(BankCharge_05Tok);
    end;

    procedure BankCharge_06(): Code[10]
    begin
        exit(BankCharge_06Tok);
    end;

    var
        BankCharge_01Tok: Label 'BKCHG_01', MaxLength = 10;
        BankCharge_02Tok: Label 'BKCHG_02', MaxLength = 10;
        BankCharge_03Tok: Label 'BKCHG_03', MaxLength = 10;
        BankCharge_04Tok: Label 'BKCHG_04', MaxLength = 10;
        BankCharge_05Tok: Label 'BKCHG_05', MaxLength = 10;
        BankCharge_06Tok: Label 'BKCHG_06', MaxLength = 10;
        BankCharge_01Lbl: Label 'Bank Charge', MaxLength = 50;
        BankCharge_02Lbl: Label 'Commission', MaxLength = 50;
        BankCharge_03Lbl: Label 'Exempted', MaxLength = 50;
        BankCharge_04Lbl: Label 'Bank Charge', MaxLength = 50;
}
