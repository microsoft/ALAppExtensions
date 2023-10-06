codeunit 5104 "Create Svc Item"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        SvcDemoDataSetup: Record "Service Module Setup";
        SvcSetup: Codeunit "Create Svc Setup";
        MachineLbl: Label 'S-100 Semi-Automatic', MaxLength = 100;
        ServiceDesc1Lbl: Label 'Equipment Fee', MaxLength = 100;
        ServiceDesc2Lbl: Label 'Repair', MaxLength = 100;
        ITEM1Tok: Label 'S-100', MaxLength = 20;
        ServiceItem1Tok: Label 'SER101', MaxLength = 20;
        ServiceItem2Tok: Label 'SER102', MaxLength = 20;

    trigger OnRun()

    begin
        SvcDemoDataSetup.Get();

        CreateItems();

        CreateResourceSkills();

        CreateServiceCodes();
    end;

    local procedure CreateItems()
    var
        ContosoItem: Codeunit "Contoso Item";
        CommonPostingGroup: Codeunit "Create Common Posting Group";
        SvcItemCategory: Codeunit "Create Svc Item Category";
        CommonUoM: Codeunit "Create Common Unit Of Measure";
        ContosoUtilities: Codeunit "Contoso Utilities";
        ServiceMedia: Codeunit "Service Media";
    begin
        if SvcDemoDataSetup."Item 1 No." = '' then begin
            ContosoItem.InsertInventoryItem(ItemS100(), MachineLbl, ContosoUtilities.AdjustPrice(2400), ContosoUtilities.AdjustPrice(1800), CommonPostingGroup.Retail(), CommonPostingGroup.NonTaxable(), CommonPostingGroup.Resale(), Enum::"Costing Method"::FIFO, CommonUoM.Piece(), SvcItemCategory.EMCommercial(), 0.75, SvcSetup.DefaultServiceItemGroup(), ServiceMedia.GetMachine1Picture());
            SvcDemoDataSetup.Validate("Item 1 No.", ItemS100());
        end;

        if SvcDemoDataSetup."Service Item 1 No." = '' then begin
            ContosoItem.InsertServiceItem(ServiceItem1(), ServiceDesc1Lbl, ContosoUtilities.AdjustPrice(10), 0, CommonPostingGroup.Retail(), CommonPostingGroup.NonTaxable(), CommonUoM.Day(), SvcItemCategory.Service(), ContosoUtilities.EmptyPicture());
            SvcDemoDataSetup.Validate("Service Item 1 No.", ServiceItem1());
        end;

        if SvcDemoDataSetup."Service Item 2 No." = '' then begin
            ContosoItem.InsertServiceItem(ServiceItem2(), ServiceDesc2Lbl, ContosoUtilities.AdjustPrice(100), 0, CommonPostingGroup.Retail(), CommonPostingGroup.NonTaxable(), CommonUoM.Hour(), SvcItemCategory.Service(), ContosoUtilities.EmptyPicture());
            SvcDemoDataSetup.Validate("Service Item 2 No.", ServiceItem2());
        end;

        SvcDemoDataSetup.Modify(true);
    end;

    local procedure CreateResourceSkills()
    var
        ContosoResource: Codeunit "Contoso Resource";
    begin
        ContosoResource.InsertResourceSkill(Enum::"Resource Skill Type"::Item, SvcDemoDataSetup."Item 1 No.", SvcSetup.SkillPlumbing());
    end;

    local procedure CreateServiceCodes()
    var
        SvcLoaner: Codeunit "Create Svc Loaner";
        ContosoService: Codeunit "Contoso Service";
        StandardServiceCode: Code[10];
    begin
        StandardServiceCode := SvcLoaner.Loaner();
        ContosoService.InsertStandardServiceCode(StandardServiceCode, StandardServiceCode);
        ContosoService.InsertStandardServiceLine(StandardServiceCode, Enum::"Service Line Type"::Item, SvcDemoDataSetup."Service Item 1 No.", 1);
        ContosoService.InsertStandardServiceItemGroup(SvcSetup.DefaultServiceItemGroup(), StandardServiceCode);
    end;

    procedure ItemS100(): Code[20]
    begin
        exit(ITEM1Tok);
    end;

    procedure ServiceItem1(): Code[20]
    begin
        exit(ServiceItem1Tok);
    end;

    procedure ServiceItem2(): Code[20]
    begin
        exit(ServiceItem2Tok);
    end;
}