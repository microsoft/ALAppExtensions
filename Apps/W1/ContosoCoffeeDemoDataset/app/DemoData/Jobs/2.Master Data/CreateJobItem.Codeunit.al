codeunit 5192 "Create Job Item"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        MachineDescTok: Label 'S-210 Semi-Automatic', MaxLength = 100;
        ConsumableDescTok: Label 'Remote pump', MaxLength = 100;
        SupplyDescTok: Label 'Paper Coffee Cups', MaxLength = 100;
        ServiceDescLbl: Label 'Project Fee', MaxLength = 100;
        MachineTok: Label 'S-210', MaxLength = 20;
        ConsumableTok: Label 'F-100', MaxLength = 20;
        SupplyTok: Label 'F-101', MaxLength = 20;
        ServiceItemTok: Label 'SER203', MaxLength = 20;

    trigger OnRun()
    var
        JobsDemoDataSetup: Record "Jobs Module Setup";
        ContosoItem: Codeunit "Contoso Item";
        CommonUoM: Codeunit "Create Common Unit Of Measure";
        CommonPostingGroup: Codeunit "Create Common Posting Group";
        ContosoUtilities: Codeunit "Contoso Utilities";
        JobsMedia: Codeunit "Jobs Media";
    begin
        JobsDemoDataSetup.Get();

        if JobsDemoDataSetup."Item Machine No." = '' then begin
            ContosoItem.InsertInventoryItem(ItemMachine(), MachineDescTok, ContosoUtilities.AdjustPrice(2400), ContosoUtilities.AdjustPrice(1800), CommonPostingGroup.Retail(), CommonPostingGroup.NonTaxable(), CommonPostingGroup.Resale(), Enum::"Costing Method"::FIFO, CommonUoM.Piece(), '', 0.75, '', JobsMedia.GetMachine1Picture());
            JobsDemoDataSetup.Validate("Item Machine No.", ItemMachine());
        end;

        if JobsDemoDataSetup."Item Consumable No." = '' then begin
            ContosoItem.InsertInventoryItem(ItemConsumable(), ConsumableDescTok, ContosoUtilities.AdjustPrice(100), ContosoUtilities.AdjustPrice(65), CommonPostingGroup.Retail(), CommonPostingGroup.NonTaxable(), CommonPostingGroup.Resale(), Enum::"Costing Method"::FIFO, CommonUoM.Piece(), '', 0.75, '', ContosoUtilities.EmptyPicture());
            JobsDemoDataSetup.Validate("Item Consumable No.", ItemConsumable());
        end;

        if JobsDemoDataSetup."Item Supply No." = '' then begin
            ContosoItem.InsertInventoryItem(ItemSupply(), SupplyDescTok, ContosoUtilities.AdjustPrice(2400), ContosoUtilities.AdjustPrice(1800), CommonPostingGroup.Retail(), CommonPostingGroup.NonTaxable(), CommonPostingGroup.Resale(), Enum::"Costing Method"::FIFO, CommonUoM.Piece(), '', 0.75, '', ContosoUtilities.EmptyPicture());
            JobsDemoDataSetup.Validate("Item Supply No.", ItemSupply());
        end;

        if JobsDemoDataSetup."Item Service No." = '' then begin
            ContosoItem.InsertServiceItem(ItemService(), ServiceDescLbl, ContosoUtilities.AdjustPrice(100), ContosoUtilities.AdjustPrice(65), CommonPostingGroup.Service(), CommonPostingGroup.NonTaxable(), CommonUoM.Hour(), '', ContosoUtilities.EmptyPicture());
            JobsDemoDataSetup.Validate("Item Service No.", ItemService());
        end;

        JobsDemoDataSetup.Modify(true);
    end;

    procedure ItemMachine(): Code[20]
    begin
        exit(MachineTok);
    end;

    procedure ItemConsumable(): Code[20]
    begin
        exit(ConsumableTok);
    end;

    procedure ItemSupply(): Code[20]
    begin
        exit(SupplyTok);
    end;

    procedure ItemService(): Code[20]
    begin
        exit(ServiceItemTok);
    end;

}