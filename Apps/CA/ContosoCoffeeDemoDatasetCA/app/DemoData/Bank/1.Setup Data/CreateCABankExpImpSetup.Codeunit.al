codeunit 27016 "Create CA Bank Exp/Imp Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoBank: Codeunit "Contoso Bank";
        CreateCADataExchange: Codeunit "Create CA Data Exchange";
    begin
        ContosoBank.ContosoBankExportImportSetup(CaEftDefault(), CaEftDefaultLbl, 3, Codeunit::"Exp. Launcher EFT", 0, CreateCADataExchange.CAEFTDEFAULT(), true, 0);
        ContosoBank.ContosoBankExportImportSetup(MxEftDefault(), MxEftDefaultLbl, 3, Codeunit::"Exp. Launcher EFT", 0, CreateCADataExchange.MXEFTDEFAULT(), true, 0);
        ContosoBank.ContosoBankExportImportSetup(UsEftCcd(), UsEftCcdTok, 3, Codeunit::"Exp. Launcher EFT", 0, CreateCADataExchange.USEFTCCD(), true, 0);
        ContosoBank.ContosoBankExportImportSetup(UsEftDefault(), UsEftDefaultTok, 3, Codeunit::"Exp. Launcher EFT", 0, CreateCADataExchange.USEFTDEFAULT(), true, 0);
        ContosoBank.ContosoBankExportImportSetup(UsEftIatDefault(), UsEftIatDefaultTok, 3, Codeunit::"Exp. Launcher EFT", 0, CreateCADataExchange.USEFTIATDEFAULT(), true, 0);
    end;

    procedure CaEftDefault(): Code[20]
    begin
        exit(CaEftDefaultTok)
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
        CaEftDefaultTok: Label 'CA EFT DEFAULT', MaxLength = 20;
        MxEftDefaultTok: Label 'MX EFT DEFAULT', MaxLength = 20;
        UsEftCcdTok: Label 'US EFT CCD', MaxLength = 20;
        UsEftDefaultTok: Label 'US EFT Default', MaxLength = 20;
        UsEftIatDefaultTok: Label 'US EFT IAT Default', MaxLength = 20;
        CaEftDefaultLbl: Label 'CA EFT DEFAULT', MaxLength = 100;
        MxEftDefaultLbl: Label 'MX EFT Default', MaxLength = 100;
}