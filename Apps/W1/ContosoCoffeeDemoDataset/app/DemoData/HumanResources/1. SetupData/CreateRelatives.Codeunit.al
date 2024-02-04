codeunit 5163 "Create Relatives"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoHumanResource: Codeunit "Contoso Human Resources";
    begin
        ContosoHumanResource.InsertRelative(Wife(), WifeLbl);
        ContosoHumanResource.InsertRelative(Husband(), HusbandLbl);
        ContosoHumanResource.InsertRelative(Mother(), MotherLbl);
        ContosoHumanResource.InsertRelative(Father(), FatherLbl);
        ContosoHumanResource.InsertRelative(Child1(), Child1Lbl);
        ContosoHumanResource.InsertRelative(Child2(), Child2Lbl);
        ContosoHumanResource.InsertRelative(Child3(), Child3Lbl);
        ContosoHumanResource.InsertRelative(NextOfKin(), NextOfKinLbl);
    end;

    procedure Wife(): Code[10]
    begin
        exit(WifeTok);
    end;

    procedure Husband(): Code[10]
    begin
        exit(HusbandTok);
    end;

    procedure Mother(): Code[10]
    begin
        exit(MotherTok);
    end;

    procedure Father(): Code[10]
    begin
        exit(FatherTok);
    end;

    procedure Child1(): Code[10]
    begin
        exit(Child1Tok);
    end;

    procedure Child2(): Code[10]
    begin
        exit(Child2Tok);
    end;

    procedure Child3(): Code[10]
    begin
        exit(Child3Tok);
    end;

    procedure NextOfKin(): Code[10]
    begin
        exit(NextOfKinTok);
    end;


    var
        WifeTok: Label 'WIFE', MaxLength = 10;
        WifeLbl: Label 'Wife', MaxLength = 100;
        HusbandTok: Label 'HUSBAND', MaxLength = 10;
        HusbandLbl: Label 'Husband', MaxLength = 100;
        MotherTok: Label 'MOTHER', MaxLength = 10;
        MotherLbl: Label 'Mother', MaxLength = 100;
        FatherTok: Label 'FATHER', MaxLength = 10;
        FatherLbl: Label 'Father', MaxLength = 100;
        Child1Tok: Label 'CHILD1', MaxLength = 10;
        Child1Lbl: Label 'First Child', MaxLength = 100;
        Child2Tok: Label 'CHILD2', MaxLength = 10;
        Child2Lbl: Label 'Second Child', MaxLength = 100;
        Child3Tok: Label 'CHILD3', MaxLength = 10;
        Child3Lbl: Label 'Third Child', MaxLength = 100;
        NextOfKinTok: Label 'NEXT', MaxLength = 10;
        NextOfKinLbl: Label 'Next of Kin', MaxLength = 100;
}