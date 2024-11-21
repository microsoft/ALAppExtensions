codeunit 17172 "Create AU Data Exchange"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoDataExchange: Codeunit "Contoso Data Exchange";
        FolderNameLbl: Label 'PostingExchangeDefinitions', MaxLength = 100, Locked = true;
    begin
        ContosoDataExchange.ImportDataExchangeDefinition(FolderNameLbl + '/' + OCRInvoiceAU() + '.xml');
        ContosoDataExchange.ImportDataExchangeDefinition(FolderNameLbl + '/' + OCRCreditMemoAU() + '.xml');
        ContosoDataExchange.ImportDataExchangeDefinition(FolderNameLbl + '/' + PeppolCreditMemoAU() + '.xml');
        ContosoDataExchange.ImportDataExchangeDefinition(FolderNameLbl + '/' + PeppolInvoiceAU() + '.xml');
    end;

    procedure OCRInvoiceAU(): Code[20]
    begin
        exit('OCRINVOICE-AU');
    end;

    procedure OCRCreditMemoAU(): Code[20]
    begin
        exit('OCRCREDITMEMO-AU');
    end;

    procedure PeppolCreditMemoAU(): Code[20]
    begin
        exit('PEPPOLCREDITMEMO-AU');
    end;

    procedure PeppolInvoiceAU(): Code[20]
    begin
        exit('PEPPOLINVOICE-AU');
    end;
}
