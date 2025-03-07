codeunit 5242 "Create Emission Fee"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoSustainability: Codeunit "Contoso Sustainability";
        ContosoUtility: Codeunit "Contoso Utilities";
    begin
        ContosoSustainability.InsertEmissionFee(Enum::"Emission Type"::CO2, Enum::"Emission Scope"::" ", ContosoUtility.AdjustDate(19030101D), 0D, '', '', 0.12, 1);
        ContosoSustainability.InsertEmissionFee(Enum::"Emission Type"::CH4, Enum::"Emission Scope"::" ", ContosoUtility.AdjustDate(19030101D), 0D, '', '', 0, 0.04);
        ContosoSustainability.InsertEmissionFee(Enum::"Emission Type"::N2O, Enum::"Emission Scope"::" ", ContosoUtility.AdjustDate(19030101D), 0D, '', '', 0, 0.00336);
    end;
}