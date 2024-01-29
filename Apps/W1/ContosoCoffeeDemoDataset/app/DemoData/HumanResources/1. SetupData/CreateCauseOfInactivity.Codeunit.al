codeunit 5157 "Create Cause Of Inactivity"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoHumanResources: Codeunit "Contoso Human Resources";
    begin
        ContosoHumanResources.InsertCauseOfInactivity(AttendingCourse(), AttendingCourseLbl);
        ContosoHumanResources.InsertCauseOfInactivity(OnLeave(), OnLeaveLbl);
        ContosoHumanResources.InsertCauseOfInactivity(Maternity(), MaternityLbl);
    end;

    procedure AttendingCourse(): Code[10]
    begin
        exit(AttendingCourseTok);
    end;

    procedure OnLeave(): Code[10]
    begin
        exit(OnLeaveTok);
    end;

    procedure Maternity(): Code[10]
    begin
        exit(MaternityTok);
    end;

    var
        AttendingCourseTok: Label 'COURSE', MaxLength = 10;
        AttendingCourseLbl: Label 'Attending a Course', MaxLength = 100;
        OnLeaveTok: Label 'LEAVE', MaxLength = 10;
        OnLeaveLbl: Label 'On Leave', MaxLength = 100;
        MaternityTok: Label 'MATERNITY', MaxLength = 10;
        MaternityLbl: Label 'Maternity Leave', MaxLength = 100;

}