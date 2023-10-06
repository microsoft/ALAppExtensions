codeunit 4789 "Create Mfg Stop Scrap"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoManufacturing: Codeunit "Contoso Manufacturing";
    begin
        ContosoManufacturing.InsertScrap(EquipmentTok, ConfigEquipmentLbl);
        ContosoManufacturing.InsertScrap(MaterialTok, DefectiveMaterialTok);
        ContosoManufacturing.InsertScrap(OperatorTok, OperatorErrorTok);

        ContosoManufacturing.InsertStop(MachineTok, MachineFailureTok);
        ContosoManufacturing.InsertStop(MaterialTok, MaterialDefectsTok);
        ContosoManufacturing.InsertStop(PersonnelTok, LackOfPersonnelTok);
    end;


    var
        MachineFailureTok: label 'Machine failure', MaxLength = 100;
        MachineTok: label 'Machine', MaxLength = 10;
        MaterialDefectsTok: Label 'Material defects', MaxLength = 100;
        LackOfPersonnelTok: Label 'Lack of personnel', MaxLength = 100;
        PersonnelTok: Label 'Personnel', MaxLength = 10;
        ConfigEquipmentLbl: label 'Incorrect configuration of the equipment', MaxLength = 50;
        EquipmentTok: label 'Equipment', MaxLength = 10;
        DefectiveMaterialTok: label 'Defective material', MaxLength = 50;
        MaterialTok: label 'Material', MaxLength = 10;
        OperatorErrorTok: label 'Operator error', MaxLength = 50;
        OperatorTok: label 'Operator', MaxLength = 10;
}