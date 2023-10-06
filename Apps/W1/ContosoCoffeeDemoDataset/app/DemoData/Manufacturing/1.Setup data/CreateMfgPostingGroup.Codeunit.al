codeunit 4782 "Create Mfg Posting Group"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ManufacturingDemoDataSetup: Record "Manufacturing Module Setup";
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateContosoPostingGroup: Codeunit "Create Common Posting Group";
    begin
        ManufacturingDemoDataSetup.Get();

        ContosoPostingGroup.InsertGenProductPostingGroup(Manufacturing(), CapacitiesTok, CreateContosoPostingGroup.StandardVAT());

        ContosoPostingGroup.InsertInventoryPostingGroup(Finished(), FinishedItemsLbl);
    end;

    var
        ManufacturingTok: Label 'MANUFACT', MaxLength = 10;
        FinishedTok: Label 'FINISHED', MaxLength = 10;
        CapacitiesTok: Label 'Capacities', MaxLength = 50;
        FinishedItemsLbl: Label 'Finished Items', MaxLength = 50;

    procedure Manufacturing(): Code[20]
    begin
        exit(ManufacturingTok);
    end;

    procedure Finished(): Code[20]
    begin
        exit(FinishedTok);
    end;
}