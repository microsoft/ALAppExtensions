codeunit 5212 "Create Sustainability Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateSetupTable();
        CreateSourceCode();
    end;

    local procedure CreateSetupTable()
    var
        SustainabilitySetup: Record "Sustainability Setup";
        CommonUoM: Codeunit "Create Common Unit Of Measure";
    begin
        SustainabilitySetup.Get();

        SustainabilitySetup.Validate("Emission Unit of Measure Code", CommonUoM.KG());
        SustainabilitySetup.Validate("Emission Decimal Places", '2:5');

        SustainabilitySetup.Validate("Fuel/El. Decimal Places", '2:5');
        SustainabilitySetup.Validate("Distance Decimal Places", '2:5');
        SustainabilitySetup.Validate("Custom Amt. Decimal Places", '2:5');

        SustainabilitySetup.Modify(true);
    end;

    local procedure CreateSourceCode()
    var
        ContosoAuditCode: Codeunit "Contoso Audit Code";
    begin
        ContosoAuditCode.InsertSourceCode(SustainabilitySourceCode(), SustainabilityDescriptionTok);
    end;

    procedure SustainabilitySourceCode(): Code[10]
    begin
        exit(SustainabilityTok);
    end;

    var
        SustainabilityTok: Label 'SUSTAIN', MaxLength = 10;
        SustainabilityDescriptionTok: Label 'Sustainability Emissions', MaxLength = 100;
}