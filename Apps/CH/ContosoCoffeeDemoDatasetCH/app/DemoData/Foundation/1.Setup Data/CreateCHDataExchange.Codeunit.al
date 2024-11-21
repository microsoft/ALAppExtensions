codeunit 11633 "Create CH Data Exchange"
{
    trigger OnRun()
    var
        ContosoDataExchange: Codeunit "Contoso Data Exchange";
        FolderNameLbl: Label 'PostingExchangeDefinitions', MaxLength = 100, Locked = true;
    begin
        ContosoDataExchange.ImportDataExchangeDefinition(FolderNameLbl + '/' + CEPACAMT054() + '.xml');
        ContosoDataExchange.ImportDataExchangeDefinition(FolderNameLbl + '/' + CEPACAMT05302() + '.xml');
        ContosoDataExchange.ImportDataExchangeDefinition(FolderNameLbl + '/' + CEPACAMT05304() + '.xml');
    end;

    procedure CEPACAMT054(): Code[20]
    begin
        exit('SEPA CAMT 054');
    end;

    procedure CEPACAMT05302(): Code[20]
    begin
        exit('SEPA CAMT 053-02');
    end;

    procedure CEPACAMT05304(): Code[20]
    begin
        exit('SEPA CAMT 053-04');
    end;
}