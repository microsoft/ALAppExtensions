codeunit 19043 "Create IN Tax Type"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        TaxType: Record "Tax Type";
        TaxEngineAssistedSetup: Codeunit "Tax Engine Assisted Setup";
        CreateINTaxAccPeriod: Codeunit "Create IN Tax Acc. Period";
    begin
        if TaxType.IsEmpty() then begin
            TaxEngineAssistedSetup.SetupTaxEngine();
            CreateINTaxAccPeriod.CreateTaxTypeSetup();
        end;
    end;
}