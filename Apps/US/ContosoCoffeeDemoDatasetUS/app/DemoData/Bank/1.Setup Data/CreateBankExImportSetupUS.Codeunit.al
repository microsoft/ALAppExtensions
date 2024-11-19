codeunit 10502 "Create Bank Ex/Import SetupUS"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoBank: Codeunit "Contoso Bank";
        CreateDataExchangeDefUS: Codeunit "Create Data Exchange Def US";
    begin
        ContosoBank.ContosoBankExportImportSetup(BankOfAmericaPp(), BankOfAmericaPositivePayLbl, 2, Codeunit::"Exp. Launcher Pos. Pay", 0, CreateDataExchangeDefUS.BANKOFAMERICAPP(), true, 0);
        ContosoBank.ContosoBankExportImportSetup(CaEftDefault(), CaEftDefaultLbl, 3, Codeunit::"Exp. Launcher EFT", 0, CreateDataExchangeDefUS.CAEFTDEFAULT(), true, 0);
        ContosoBank.ContosoBankExportImportSetup(CitiBankPp(), CitiBankPositivePayLbl, 2, Codeunit::"Exp. Launcher Pos. Pay", 0, CreateDataExchangeDefUS.CITIBANKPP(), true, 0);
        ContosoBank.ContosoBankExportImportSetup(MxEftDefault(), MxEftDefaultLbl, 3, Codeunit::"Exp. Launcher EFT", 0, CreateDataExchangeDefUS.MXEFTDEFAULT(), true, 0);
        ContosoBank.ContosoBankExportImportSetup(UsEftCcd(), UsEftCcdTok, 3, Codeunit::"Exp. Launcher EFT", 0, CreateDataExchangeDefUS.USEFTCCD(), true, 0);
        ContosoBank.ContosoBankExportImportSetup(UsEftDefault(), UsEftDefaultTok, 3, Codeunit::"Exp. Launcher EFT", 0, CreateDataExchangeDefUS.USEFTDEFAULT(), true, 0);
        ContosoBank.ContosoBankExportImportSetup(UsEftIatDefault(), UsEftIatDefaultTok, 3, Codeunit::"Exp. Launcher EFT", 0, CreateDataExchangeDefUS.USEFTIATDEFAULT(), true, 0);
    end;

    procedure BankOfAmericaPp(): Code[20]
    begin
        exit(BankOfAmericaPpTok)
    end;

    procedure CaEftDefault(): Code[20]
    begin
        exit(CaEftDefaultTok)
    end;

    procedure CitiBankPp(): Code[20]
    begin
        exit(CitiBankPpTok)
    end;

    procedure MxEftDefault(): Code[20]
    begin
        exit(MxEftDefaultTok)
    end;

    procedure UsEftCcd(): Code[20]
    begin
        exit(UsEftCcdTok)
    end;

    procedure UsEftDefault(): Code[20]
    begin
        exit(UsEftDefaultTok)
    end;

    procedure UsEftIatDefault(): Code[20]
    begin
        exit(UsEftIatDefaultTok)
    end;

    var
        BankOfAmericaPpTok: Label 'BANKOFAMERICA-PP', MaxLength = 20;
        CaEftDefaultTok: Label 'CA EFT DEFAULT', MaxLength = 20;
        CitiBankPpTok: Label 'CITIBANK-PP', MaxLength = 20;
        MxEftDefaultTok: Label 'MX EFT DEFAULT', MaxLength = 20;
        UsEftCcdTok: Label 'US EFT CCD', MaxLength = 20;
        UsEftDefaultTok: Label 'US EFT Default', MaxLength = 20;
        UsEftIatDefaultTok: Label 'US EFT IAT Default', MaxLength = 20;
        BankOfAmericaPositivePayLbl: Label 'BANKOFAMERICA-Positive Pay', MaxLength = 100;
        CaEftDefaultLbl: Label 'CA EFT DEFAULT', MaxLength = 100;
        CitiBankPositivePayLbl: Label 'CITIBANK-Positive Pay', MaxLength = 100;
        MxEftDefaultLbl: Label 'MX EFT Default', MaxLength = 100;
}