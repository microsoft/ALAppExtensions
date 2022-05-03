codeunit 4774 "Create Mfg Scrap Codes"
{
    Permissions = tabledata "Scrap" = ri;

    trigger OnRun()
    begin
        InsertData(xEquipmentTok, xConfigEquipmentLbl);
        InsertData(xMaterialTok, xDefectiveMaterialTok);
        InsertData(xOperatorTok, xOperatorErrorTok);
    end;

    var
        xConfigEquipmentLbl: label 'Incorrect configuration of the equipment', MaxLength = 50;
        xEquipmentTok: label 'Equipment', MaxLength = 10;
        xDefectiveMaterialTok: label 'Defective material', MaxLength = 50;
        xMaterialTok: label 'Material', MaxLength = 10;
        xOperatorErrorTok: label 'Operator error', MaxLength = 50;
        xOperatorTok: label 'Operator', MaxLength = 10;

    local procedure InsertData("Code": Code[10]; Description: Text[50])
    var
        Scrap: Record Scrap;
    begin
        Scrap.Validate(Code, Code);
        Scrap.Validate(Description, Description);
        Scrap.Insert();
    end;
}