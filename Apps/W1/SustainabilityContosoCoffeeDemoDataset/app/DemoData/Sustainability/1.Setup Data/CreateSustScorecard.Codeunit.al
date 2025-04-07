#pragma warning disable AA0247
codeunit 5251 "Create Sust. Scorecard"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoSustainability: Codeunit "Contoso Sustainability";
    begin
        ContosoSustainability.InsertScorecard(Main(), MainGoalLbl, '');
    end;

    procedure Main(): Code[20]
    begin
        exit(MainTok);
    end;

    var
        MainTok: Label 'MAIN', MaxLength = 20;
        MainGoalLbl: Label 'Main Goal', MaxLength = 100;
}
