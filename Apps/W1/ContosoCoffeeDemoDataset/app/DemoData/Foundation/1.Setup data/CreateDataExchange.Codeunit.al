codeunit 5307 "Create Data Exchange"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoDataExchange: Codeunit "Contoso Data Exchange";
        FolderNameLbl: Label 'PostingExchangeDefinitions', MaxLength = 100, Locked = true;
    begin
        ContosoDataExchange.ImportDataExchangeDefinition(FolderNameLbl + '/' + OCRCreditMemo() + '.xml');
        ContosoDataExchange.ImportDataExchangeDefinition(FolderNameLbl + '/' + OCRInvoice() + '.xml');
        ContosoDataExchange.ImportDataExchangeDefinition(FolderNameLbl + '/' + PeppolCreditMemo() + '.xml');
        ContosoDataExchange.ImportDataExchangeDefinition(FolderNameLbl + '/' + PeppolInvoice() + '.xml');
        ContosoDataExchange.ImportDataExchangeDefinition(FolderNameLbl + '/' + SEPACAMT() + '.xml');
        ContosoDataExchange.ImportDataExchangeDefinition(FolderNameLbl + '/' + ECBExchangeRate() + '.xml');
    end;

    procedure OCRCreditMemo(): Code[20]
    begin
        exit('OCRCREDITMEMO');
    end;

    procedure OCRInvoice(): Code[20]
    begin
        exit('OCRINVOICE');
    end;

    procedure PeppolCreditMemo(): Code[20]
    begin
        exit('PEPPOLCREDITMEMO');
    end;

    procedure PeppolInvoice(): Code[20]
    begin
        exit('PEPPOLINVOICE');
    end;

    procedure SEPACAMT(): Code[20]
    begin
        exit('SEPA CAMT');
    end;

    procedure ECBExchangeRate(): Code[20]
    begin
        exit('ECB-EXCHANGE-RATES');
    end;
}
