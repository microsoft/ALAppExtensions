codeunit 5191 "Create Job Resource"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        Resource3Tok: Label 'RESOURCE3', MaxLength = 20;

    trigger OnRun()
    var
        JobsDemoDataSetup: Record "Jobs Module Setup";
        ContosoUoM: Codeunit "Create Common Unit Of Measure";
        CommonPostingGroup: Codeunit "Create Common Posting Group";
        ContosoUtilities: Codeunit "Contoso Utilities";
        ContosoResource: Codeunit "Contoso Resource";
    begin
        JobsDemoDataSetup.Get();

        if JobsDemoDataSetup."Resource Installer No." = '' then begin
            ContosoResource.InsertResource(ResourceInstaller(), ResourceInstaller(), ContosoUoM.Hour(), CommonPostingGroup.Service(), ContosoUtilities.AdjustPrice(70), ContosoUtilities.AdjustPrice(100), CommonPostingGroup.NonTaxable());
            JobsDemoDataSetup.Validate("Resource Installer No.", ResourceInstaller());
        end;

        JobsDemoDataSetup.Modify(true);
    end;

    procedure ResourceInstaller(): Code[20]
    begin
        exit(Resource3Tok);
    end;
}