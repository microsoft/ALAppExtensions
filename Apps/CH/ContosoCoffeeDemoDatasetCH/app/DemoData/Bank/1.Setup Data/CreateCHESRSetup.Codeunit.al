// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Bank;

using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Finance;
using Microsoft.Bank.Payment;

codeunit 11628 "Create CH ESR Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCHBank: Codeunit "Contoso CH Bank";
        CreateCHPaymentMethod: Codeunit "Create CH Payment Method";
        CreateCurrency: Codeunit "Create Currency";
        CreateCHGLAccounts: Codeunit "Create CH GL Accounts";
    begin
        ContosoCHBank.InsertESRSetup(GiroBankCode(), CreateCHGLAccounts.PostAcc(), ESRFilenameLbl, '00000000000', GiroESRAccountNoLbl, '', '', '', '', '', '', '', '', CreateCHPaymentMethod.ESRPost(), false);
        ContosoCHBank.InsertESRSetup(NBLBankCode(), CreateCHGLAccounts.BankCredit(), ESRFilenameLbl, '68705010000', NBLESRAccountNoLbl, CreateCurrency.EUR(), ZugerKantonalbankLbl, BahnhofstrasseLbl, Zug1Lbl, InFavorLbl, '', '', '', CreateCHPaymentMethod.ESR(), true);
    end;

    internal procedure UpdateESRSetup()
    begin
        ValidateRecordsFields(GiroBankCode());
        ValidateRecordsFields(NBLBankCode());
    end;

    local procedure ValidateRecordsFields(BankCode: Code[20])
    var
        ESRSetup: Record "ESR Setup";
    begin
        ESRSetup.Get(BankCode);
        if BankCode = GiroBankCode() then begin
            ESRSetup.Validate("ESR Member Name 1", CronusInternationalLtdLbl);
            ESRSetup.Validate("ESR Member Name 2", TheRingLbl);
            ESRSetup.Validate("ESR Member Name 3", ZugLbl);
            ESRSetup.Modify(true);
        end else begin
            ESRSetup.Validate(Beneficiary, CronusInternationalLtdLbl);
            ESRSetup.Validate("Beneficiary 2", TheRingLbl);
            ESRSetup.Validate("Beneficiary 3", ZugLbl);
            ESRSetup.Modify(true);
        end;
    end;

    procedure GiroBankCode(): Code[20]
    begin
        exit(GiroBankCodeTok);
    end;

    procedure NBLBankCode(): Code[20]
    begin
        exit(NBLBankCodeTok);
    end;

    var
        GiroBankCodeTok: Label 'GIRO', MaxLength = 20;
        NBLBankCodeTok: Label 'NBL', MaxLength = 20;
        NBLESRAccountNoLbl: Label '01-13980-3', MaxLength = 11;
        GiroESRAccountNoLbl: Label '60-9-9', MaxLength = 11;
        ESRFilenameLbl: Label 'c:\cronus.v11', MaxLength = 50;
        CronusInternationalLtdLbl: Label 'CRONUS International Ltd.', MaxLength = 30;
        TheRingLbl: Label '5 The Ring', MaxLength = 30;
        ZugLbl: Label '6300 Zug', MaxLength = 30;
        ZugerKantonalbankLbl: Label 'Zuger Kantonalbank', MaxLength = 30;
        BahnhofstrasseLbl: Label 'Bahnhofstrasse 1', MaxLength = 30;
        Zug1Lbl: Label '6301 Zug', MaxLength = 30;
        InFavorLbl: Label 'In favor:', MaxLength = 30;
}
