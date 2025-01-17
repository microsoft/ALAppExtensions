codeunit 5396 "Create Salutations"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCRM: Codeunit "Contoso CRM";
    begin
        ContosoCRM.InsertSalutations(Company(), CompanyLbl);
        ContosoCRM.InsertSalutations(Female(), FemaleMarriedUnmarriedLbl);
        ContosoCRM.InsertSalutations(FemaleJob(), FemaleJobTitleLbl);
        ContosoCRM.InsertSalutations(FemaleMarried(), FemaleMarriedLbl);
        ContosoCRM.InsertSalutations(FemaleUnMarried(), FemaleUnMarriedLbl);
        ContosoCRM.InsertSalutations(Male(), maleMarriedUnmarriedLbl);
        ContosoCRM.InsertSalutations(MaleJob(), MaleJobTitleLbl);
        ContosoCRM.InsertSalutations(Unisex(), UnisexLbl);
    end;

    procedure Company(): Code[10]
    begin
        exit(CompanyTok)
    end;

    procedure Female(): Code[10]
    begin
        exit(FemaleTok)
    end;

    procedure FemaleJob(): Code[10]
    begin
        exit(FemaleJobTok)
    end;

    procedure FemaleMarried(): Code[10]
    begin
        exit(FemaleMarriedTok)
    end;

    procedure FemaleUnMarried(): Code[10]
    begin
        exit(FemaleUnMarriedTok)
    end;

    procedure Male(): Code[10]
    begin
        exit(MaleTok)
    end;

    procedure MaleJob(): Code[10]
    begin
        exit(MaleJobTok)
    end;

    procedure Unisex(): Code[10]
    begin
        exit(UnisexTok)
    end;

    var
        CompanyTok: Label 'COMPANY', MaxLength = 10;
        FemaleTok: Label 'F', MaxLength = 10;
        FemaleJobTok: Label 'F-JOB', MaxLength = 10;
        FemaleMarriedTok: Label 'F-MAR', MaxLength = 10;
        FemaleUnMarriedTok: Label 'F-UMAR', MaxLength = 10;
        MaleTok: Label 'M', MaxLength = 10;
        MaleJobTok: Label 'M-JOB', MaxLength = 10;
        UnisexTok: Label 'UNISEX', MaxLength = 10;
        CompanyLbl: Label 'Company', MaxLength = 100;
        FemaleMarriedUnmarriedLbl: Label 'Female Married or Unmarried', MaxLength = 100;
        FemaleJobTitleLbl: Label 'Female - Job title', MaxLength = 100;
        FemaleMarriedLbl: Label 'Female - Married', MaxLength = 100;
        FemaleUnMarriedLbl: Label 'Female - Unmarried', MaxLength = 100;
        maleMarriedUnmarriedLbl: Label 'Male Married or Unmarried', MaxLength = 100;
        MaleJobTitleLbl: Label 'Male - Jobtitle', MaxLength = 100;
        UnisexLbl: Label 'Unisex', MaxLength = 100;
}