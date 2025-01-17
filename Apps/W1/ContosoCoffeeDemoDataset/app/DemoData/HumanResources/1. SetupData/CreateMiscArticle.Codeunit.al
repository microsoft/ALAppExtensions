codeunit 5159 "Create Misc. Article"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoHumanResources: Codeunit "Contoso Human Resources";
    begin
        ContosoHumanResources.InsertMiscellaneousArticle(CompanyCar(), CompanyCarLbl);
        ContosoHumanResources.InsertMiscellaneousArticle(Computer(), ComputerLbl);
        ContosoHumanResources.InsertMiscellaneousArticle(CreditCard(), CreditCardLbl);
        ContosoHumanResources.InsertMiscellaneousArticle(CompanyKey(), CompanyKeyLbl);
    end;

    procedure CompanyCar(): Code[10]
    begin
        exit(CompanyCarTok);
    end;

    procedure Computer(): Code[10]
    begin
        exit(ComputerTok);
    end;

    procedure CreditCard(): Code[10]
    begin
        exit(CreditCardTok);
    end;

    procedure CompanyKey(): Code[10]
    begin
        exit(CompanyKeyTok);
    end;

    var
        CompanyCarTok: Label 'CAR', MaxLength = 10;
        CompanyCarLbl: Label 'Company Car', MaxLength = 100;
        ComputerTok: Label 'COMPUTER', MaxLength = 10;
        ComputerLbl: Label 'Computer', MaxLength = 100;
        CreditCardTok: Label 'CREDITCARD', MaxLength = 10;
        CreditCardLbl: Label 'Credit Card', MaxLength = 100;
        CompanyKeyTok: Label 'KEY', MaxLength = 10;
        CompanyKeyLbl: Label 'Key to Company', MaxLength = 100;
}