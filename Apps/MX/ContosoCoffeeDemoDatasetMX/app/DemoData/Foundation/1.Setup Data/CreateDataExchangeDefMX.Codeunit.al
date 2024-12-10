codeunit 14114 "Create Data Exchange Def MX"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    var
        ContosoDataExchange: Codeunit "Contoso Data Exchange";
        FolderNameLbl: Label 'PostingExchangeDefinitions', MaxLength = 100, Locked = true;
    begin
        ContosoDataExchange.ImportDataExchangeDefinition(FolderNameLbl + '/' + BANKOFAMERICAPP() + '.xml');
        ContosoDataExchange.ImportDataExchangeDefinition(FolderNameLbl + '/' + CAEFTDEFAULT() + '.xml');
        ContosoDataExchange.ImportDataExchangeDefinition(FolderNameLbl + '/' + CITIBANKPP() + '.xml');
        ContosoDataExchange.ImportDataExchangeDefinition(FolderNameLbl + '/' + MXEFTDEFAULT() + '.xml');
        ContosoDataExchange.ImportDataExchangeDefinition(FolderNameLbl + '/' + USEFTCCD() + '.xml');
        ContosoDataExchange.ImportDataExchangeDefinition(FolderNameLbl + '/' + USEFTDEFAULT() + '.xml');
        ContosoDataExchange.ImportDataExchangeDefinition(FolderNameLbl + '/' + USEFTIATDEFAULT() + '.xml');
    end;

    procedure BANKOFAMERICAPP(): Code[20]
    begin
        exit('BANKOFAMERICA-PP');
    end;

    procedure CAEFTDEFAULT(): Code[20]
    begin
        exit('CA EFT DEFAULT');
    end;

    procedure CITIBANKPP(): Code[20]
    begin
        exit('CITIBANK-PP');
    end;

    procedure MXEFTDEFAULT(): Code[20]
    begin
        exit('MX EFT DEFAULT');
    end;

    procedure USEFTCCD(): Code[20]
    begin
        exit('US EFT CCD');
    end;

    procedure USEFTDEFAULT(): Code[20]
    begin
        exit('US EFT DEFAULT');
    end;

    procedure USEFTIATDEFAULT(): Code[20]
    begin
        exit('US EFT IAT DEFAULT');
    end;
}