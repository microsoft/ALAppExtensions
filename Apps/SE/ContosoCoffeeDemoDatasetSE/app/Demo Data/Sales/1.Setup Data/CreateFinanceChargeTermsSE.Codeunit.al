
codeunit 11245 "Create Finance Charge Terms SE"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoFinanceCharge: Codeunit "Contoso Finance Charge";
    begin
        ContosoFinanceCharge.InsertFinanceChargeTerms(Domestic(), 1.5, DomesticCustomersLbl, Enum::"Interest Calculation Method"::"Average Daily Balance", 30, '<5D>', '<1M>', true, true, LineWiseFinanceChargeLbl, SumFinanceChargeLbl);
    end;

    procedure Domestic(): Code[10]
    begin
        exit(DomesticTok);
    end;

    var
        DomesticTok: Label '2.0 DOM.', MaxLength = 10;
        DomesticCustomersLbl: Label '2.0 % for Domestic Customers', MaxLength = 100;
        LineWiseFinanceChargeLbl: Label '%4% finance charge of %6', MaxLength = 100, Comment = '%4 Line Description, %6 Line Description';
        SumFinanceChargeLbl: Label 'Sum finance charge of %5', MaxLength = 100, Comment = '%5 Detailed Lines Description';
}