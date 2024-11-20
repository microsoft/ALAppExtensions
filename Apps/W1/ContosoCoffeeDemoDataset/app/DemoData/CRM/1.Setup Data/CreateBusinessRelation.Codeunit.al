codeunit 5329 "Create Business Relation"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCRM: Codeunit "Contoso CRM";
    begin
        ContosoCRM.InsertBusinessRelation(BankBusinessRelation(), BankAccountLbl);
        ContosoCRM.InsertBusinessRelation(CustBusinessRelation(), CustomerLbl);
        ContosoCRM.InsertBusinessRelation(EmpBusinessRelation(), EmployeeLbl);
        ContosoCRM.InsertBusinessRelation(VendBusinessRelation(), VendorLbl);
    end;

    procedure CustBusinessRelation(): Code[10]
    begin
        exit(CustBusinessRelationTok);
    end;

    procedure VendBusinessRelation(): Code[10]
    begin
        exit(VendBusinessRelationTok);
    end;

    procedure EmpBusinessRelation(): Code[10]
    begin
        exit(EmpBusinessRelationTok);
    end;

    procedure BankBusinessRelation(): Code[10]
    begin
        exit(BankBusinessRelationTok);
    end;


    var
        CustBusinessRelationTok: Label 'CUST', MaxLength = 10;
        VendBusinessRelationTok: Label 'VEND', MaxLength = 10;
        EmpBusinessRelationTok: Label 'EMP', MaxLength = 10;
        BankBusinessRelationTok: Label 'BANK', MaxLength = 10;
        BankAccountLbl: Label 'Bank Account', MaxLength = 100;
        CustomerLbl: Label 'Customer', MaxLength = 100;
        EmployeeLbl: Label 'Employee', MaxLength = 100;
        VendorLbl: Label 'Vendor', MaxLength = 100;
}