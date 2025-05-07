#pragma warning disable AA0247
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
        CreateUnitofMeasure: Codeunit "Create Unit of Measure";
    begin
        SustainabilitySetup.Get();

        SustainabilitySetup.Validate("Emission Unit of Measure Code", CreateUnitofMeasure.KG());
        SustainabilitySetup.Validate("Emission Decimal Places", '2:05');

        SustainabilitySetup.Validate("Fuel/El. Decimal Places", '2:05');
        SustainabilitySetup.Validate("Distance Decimal Places", '2:05');
        SustainabilitySetup.Validate("Custom Amt. Decimal Places", '2:05');
        SustainabilitySetup.Validate("Use Emissions In Purch. Doc.", true);

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
