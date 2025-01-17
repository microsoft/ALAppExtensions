codeunit 5257 "Create CRM Dimension"
{
    trigger OnRun()
    var
        ContosoDimension: Codeunit "Contoso Dimension";
    begin
        ContosoDimension.InsertDimension(Purchaser(), PurchaserLbl);
        ContosoDimension.InsertDimension(SalesPerson(), SalesPersonLbl);
    end;

    procedure Purchaser(): Code[20]
    begin
        exit(PurchaserTok);
    end;

    procedure SalesPerson(): Code[20]
    begin
        exit(SalesPersonTok);
    end;

    var
        PurchaserTok: Label 'PURCHASER', MaxLength = 20;
        PurchaserLbl: Label 'Purchaser', MaxLength = 100;
        SalesPersonTok: Label 'SALESPERSON', MaxLength = 20;
        SalesPersonLbl: Label 'Salesperson', MaxLength = 100;
}