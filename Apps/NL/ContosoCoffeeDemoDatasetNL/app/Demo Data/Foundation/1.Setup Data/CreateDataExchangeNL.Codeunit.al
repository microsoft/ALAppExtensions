codeunit 11548 "Create Data Exchange NL"
{
    trigger OnRun()
    var
        ContosoDataExchange: Codeunit "Contoso Data Exchange";
        FolderNameLbl: Label 'PostingExchangeDefinitions', MaxLength = 100, Locked = true;
    begin
        ContosoDataExchange.ImportDataExchangeDefinition(FolderNameLbl + '/' + SEPACAMTNL() + '.xml');
    end;

    procedure SEPACAMTNL(): Code[20]
    begin
        exit('SEPA CAMT-NL')
    end;
}