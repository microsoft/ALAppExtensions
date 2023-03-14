codeunit 4776 "Create Mfg Stop Codes"
{
    Permissions = tabledata "Stop" = ri;

    trigger OnRun()
    begin
        InserData(xMachineTok, xMachineFailureTok);
        InserData(xMaterialTok, xMaterialDefectsTok);
        InserData(xPersonnelTok, xLackOfPersonnelTok);
    end;

    var
        xMachineFailureTok: label 'Machine failure', MaxLength = 50;
        xMachineTok: label 'Machine', MaxLength = 10;
        xMaterialDefectsTok: Label 'Material defects', MaxLength = 50;
        xMaterialTok: Label 'Material', MaxLength = 10;
        xLackOfPersonnelTok: Label 'Lack of personnel', MaxLength = 50;
        xPersonnelTok: Label 'Personnel', MaxLength = 10;

    local procedure InserData("Code": Code[10]; Description: Text[50])
    var
        Stop: Record Stop;
    begin
        Stop.Validate(Code, Code);
        Stop.Validate(Description, Description);
        Stop.Insert();
    end;
}