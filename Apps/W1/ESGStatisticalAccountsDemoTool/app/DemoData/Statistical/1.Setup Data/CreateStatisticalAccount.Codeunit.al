#pragma warning disable AA0247
codeunit 5238 "Create Statistical Account"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoStatistical: Codeunit "Contoso Statistical Account";
    begin
        ContosoStatistical.InsertStatisticalAccount(DivAge25(), DivAge25Lbl);
        ContosoStatistical.InsertStatisticalAccount(DivAge40(), DivAge40Lbl);
        ContosoStatistical.InsertStatisticalAccount(DivAge55(), DivAge55Lbl);
        ContosoStatistical.InsertStatisticalAccount(DivAge55Plus(), DivAge55PlusLbl);
        ContosoStatistical.InsertStatisticalAccount(DivGenFemale(), DivGenFemaleLbl);
        ContosoStatistical.InsertStatisticalAccount(DivGenMale(), DivGenMaleLbl);
    end;

    procedure DivAge25(): Code[20]
    begin
        exit(DivAge25Tok);
    end;

    procedure DivAge40(): Code[20]
    begin
        exit(DivAge40Tok);
    end;

    procedure DivAge55(): Code[20]
    begin
        exit(DivAge55Tok);
    end;

    procedure DivAge55Plus(): Code[20]
    begin
        exit(DivAge55PlusTok);
    end;

    procedure DivGenFemale(): Code[20]
    begin
        exit(DivGenFemaleTok);
    end;

    procedure DivGenMale(): Code[20]
    begin
        exit(DivGenMaleTok);
    end;

    var
        DivAge25Tok: Label 'DIV-AGE-25', MaxLength = 20, Locked = true;
        DivAge40Tok: Label 'DIV-AGE-40', MaxLength = 20, Locked = true;
        DivAge55Tok: Label 'DIV-AGE-55', MaxLength = 20, Locked = true;
        DivAge55PlusTok: Label 'DIV-AGE-55+', MaxLength = 20, Locked = true;
        DivGenFemaleTok: Label 'DIV-GEND-FEM', MaxLength = 20, Locked = true;
        DivGenMaleTok: Label 'DIV-GEND-MAL', MaxLength = 20, Locked = true;
        DivAge25Lbl: Label 'Diversity: Employees Age <25', MaxLength = 100;
        DivAge40Lbl: Label 'Diversity: Employees Age 25-40', MaxLength = 100;
        DivAge55Lbl: Label 'Diversity: Employees Age 40-55', MaxLength = 100;
        DivAge55PlusLbl: Label 'Diversity: Employees Age 55+', MaxLength = 100;
        DivGenFemaleLbl: Label 'Diversity: Employees Gender - Female', MaxLength = 100;
        DivGenMaleLbl: Label 'Diversity: Employees Gender - Male', MaxLength = 100;
}
