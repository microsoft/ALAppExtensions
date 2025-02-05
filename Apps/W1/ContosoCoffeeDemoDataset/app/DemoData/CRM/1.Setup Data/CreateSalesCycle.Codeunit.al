codeunit 5384 "Create Sales Cycle"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCRM: Codeunit "Contoso CRM";
    begin
        ContosoCRM.InsertSalesCycle(ExistingSalesCycle(), ExistingCustomerLbl, 3);
        ContosoCRM.InsertSalesCycle(NewSalesCycle(), NewCustomerLbl, 2);
    end;

    procedure ExistingSalesCycle(): Code[10]
    begin
        exit(ExistingSalesCycleTok);
    end;

    procedure NewSalesCycle(): Code[10]
    begin
        exit(NewSalesCycleTok);
    end;


    var
        ExistingSalesCycleTok: Label 'EXISTING', MaxLength = 10;
        NewSalesCycleTok: Label 'NEW', MaxLength = 10;
        NewCustomerLbl: Label 'New customer', MaxLength = 100;
        ExistingCustomerLbl: Label 'Existing customer', MaxLength = 100;
}