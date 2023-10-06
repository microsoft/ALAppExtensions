codeunit 4764 "Create Mfg Location"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ManufacturingDemoDataSetup: Record "Manufacturing Module Setup";
        CommonLocation: Codeunit "Create Common Location";
    begin
        ManufacturingDemoDataSetup.Get();

        if ManufacturingDemoDataSetup."Manufacturing Location" = '' then
            ManufacturingDemoDataSetup.Validate("Manufacturing Location", CommonLocation.MainLocation());

        ManufacturingDemoDataSetup.Modify();
    end;
}