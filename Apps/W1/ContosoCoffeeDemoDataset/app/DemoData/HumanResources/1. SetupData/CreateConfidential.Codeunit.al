codeunit 5178 "Create Confidential"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoHumanResources: Codeunit "Contoso Human Resources";
    begin
        ContosoHumanResources.InsertConfidential(Insurance(), InsuranceLbl);
        ContosoHumanResources.InsertConfidential(Retire(), RetireLbl);
        ContosoHumanResources.InsertConfidential(Salary(), SalaryLbl);
        ContosoHumanResources.InsertConfidential(Stock(), StockLbl);
    end;

    procedure Insurance(): Code[10]
    begin
        exit(InsuranceTok);
    end;

    procedure Retire(): Code[10]
    begin
        exit(RetireTok);
    end;

    procedure Salary(): Code[10]
    begin
        exit(SalaryTok);
    end;

    procedure Stock(): Code[10]
    begin
        exit(StockTok);
    end;

    var
        InsuranceTok: Label 'INSURANCE', MaxLength = 10;
        InsuranceLbl: Label 'Insurance Premiums Paid', MaxLength = 100;
        RetireTok: Label 'RETIRE', MaxLength = 10;
        RetireLbl: Label 'Company Pension Plan', MaxLength = 100;
        SalaryTok: Label 'SALARY', MaxLength = 10;
        SalaryLbl: Label 'Monthly Salary', MaxLength = 100;
        StockTok: Label 'STOCK', MaxLength = 10;
        StockLbl: Label 'Employee Stock Options', MaxLength = 100;

}