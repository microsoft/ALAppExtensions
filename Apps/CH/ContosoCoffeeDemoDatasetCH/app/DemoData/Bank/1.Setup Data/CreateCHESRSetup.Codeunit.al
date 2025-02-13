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
        ContosoCHBank.InsertESRSetup(GiroBankCode(), CreateCHGLAccounts.PostAcc(), ESRFilenameLbl, '00000000000', GiroESRAccountNoLbl, '', CronusInternationalLtdLbl, TheRingLbl, ZugLbl, '', '', '', '', CreateCHPaymentMethod.ESRPost(), false);
        ContosoCHBank.InsertESRSetup(NBLBankCode(), CreateCHGLAccounts.BankCredit(), ESRFilenameLbl, '68705010000', NBLESRAccountNoLbl, CreateCurrency.EUR(), ZugerKantonalbankLbl, BahnhofstrasseLbl, Zug1Lbl, InFavorLbl, CronusInternationalLtdLbl, TheRingLbl, ZugLbl, CreateCHPaymentMethod.ESR(), true);
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