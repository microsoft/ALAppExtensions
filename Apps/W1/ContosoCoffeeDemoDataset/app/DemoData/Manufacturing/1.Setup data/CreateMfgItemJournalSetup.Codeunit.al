codeunit 4765 "Create Mfg Item Journal Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Source Code Setup" = r;

    trigger OnRun()
    var
        SourceCodeSetup: Record "Source Code Setup";
        ManufacturingDemoDataSetup: Record "Manufacturing Module Setup";
        ContosoItem: Codeunit "Contoso Item";
        ContosoUtilities: Codeunit "Contoso Utilities";
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CommonGLAccount: Codeunit "Create Common GL Account";
        CommonPostingGroup: Codeunit "Create Common Posting Group";
    begin
        SourceCodeSetup.Get();
        ManufacturingDemoDataSetup.Get();

        ContosoItem.InsertItemJournalTemplate(ItemTemplateName(), ItemJournalLbl, "Item Journal Template Type"::Item, false, SourceCodeSetup."Item Journal");
        ContosoItem.InsertItemJournalTemplate(ConsumptionTemplateName(), ConsumptionJournalLbl, "Item Journal Template Type"::Consumption, false, SourceCodeSetup."Consumption Journal");
        ContosoItem.InsertItemJournalTemplate(OutputTemplateName(), OutputJournalLbl, "Item Journal Template Type"::Output, false, SourceCodeSetup."Output Journal");
        ContosoItem.InsertItemJournalTemplate(CapacityTemplateName(), CapacityJournalLbl, "Item Journal Template Type"::Capacity, false, SourceCodeSetup."Capacity Journal");

        ContosoItem.InsertItemJournalBatch(ItemTemplateName(), ContosoUtilities.GetDefaultBatchNameLbl(), '');
        ContosoPostingSetup.InsertInventoryPostingSetup(ManufacturingDemoDataSetup."Manufacturing Location", CommonPostingGroup.Resale(), CommonGLAccount.Resale(), CommonGLAccount.ResaleInterim());
    end;

    var
        ItemTok: Label 'ITEM', MaxLength = 10;
        ItemJournalLbl: Label 'Item Journal', MaxLength = 80;
        StartManufacturingTok: Label 'START-MANF', MaxLength = 10;
        ConsumptionTok: Label 'CONSUMP', MaxLength = 10;
        ConsumptionJournalLbl: Label 'Consumption Journal', MaxLength = 80;
        OUTPUTTok: Label 'OUTPUT', MaxLength = 10;
        OutputJournalLbl: Label 'Output Journal', MaxLength = 80;
        CapacityTok: Label 'CAPACITY', MaxLength = 10;
        CapacityJournalLbl: Label 'Capacity Journal', MaxLength = 80;

    procedure ItemTemplateName(): Code[10]
    begin
        exit(ItemTok);
    end;

    procedure StartManufacturingBatchName(): Code[10]
    begin
        exit(StartManufacturingTok);
    end;

    procedure ConsumptionTemplateName(): Code[10]
    begin
        exit(ConsumptionTok);
    end;

    procedure OutputTemplateName(): Code[10]
    begin
        exit(OUTPUTTok);
    end;

    procedure CapacityTemplateName(): Code[10]
    begin
        exit(CapacityTok);
    end;
}