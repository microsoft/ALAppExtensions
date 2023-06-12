codeunit 5104 "Create Svc Item Demo Data"
{
    Permissions = tabledata Item = rim,
        tabledata "Item Unit of Measure" = rim,
        tabledata "Resource Skill" = rim;

    var
        SvcDemoDataSetup: Record "Svc Demo Data Setup";
        AdjustSvcDemoData: Codeunit "Adjust Svc Demo Data";
        SvcDemoDataFiles: Codeunit "Svc Demo Data Files";
        CreateSvcSetup: Codeunit "Create Svc Setup";
        PCSTok: Label 'PCS', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';
        MachineDesc1Tok: Label 'S-100 Semi-Automatic', MaxLength = 100;
        MachineDesc2Tok: Label 'S-200 Semi-Automatic', MaxLength = 100;
        ServiceItemGroupCodeTok: Label 'COMMERCIAL', MaxLength = 10;

    trigger OnRun()
    begin
        SvcDemoDataSetup.Get();

        CreateItems();
        OnAfterCreatedItems();

        CreateItemSkills();
        OnAfterCreatedItemSkills();
    end;

    local procedure CreateItems()
    begin
        // Create two Items using the SvcDemoDataSetup Item values
        InsertItem(SvcDemoDataSetup."Item 1 No.", MachineDesc1Tok, AdjustSvcDemoData.AdjustPrice(17900), AdjustSvcDemoData.AdjustPrice(15500),
            SvcDemoDataSetup."Retail Code", SvcDemoDataSetup."Resale Code", Enum::"Costing Method"::FIFO, PCSTok, 0.75, ServiceItemGroupCodeTok, SvcDemoDataFiles.GetMachine1Picture(), '');
        InsertItem(SvcDemoDataSetup."Item 2 No.", MachineDesc2Tok, AdjustSvcDemoData.AdjustPrice(19900), AdjustSvcDemoData.AdjustPrice(16500),
            SvcDemoDataSetup."Retail Code", SvcDemoDataSetup."Resale Code", Enum::"Costing Method"::FIFO, PCSTok, 0.75, ServiceItemGroupCodeTok, SvcDemoDataFiles.GetMachine2Picture(), '');
    end;

    local procedure InsertItem("No.": Code[20]; Description: Text[100]; UnitPrice: Decimal; LastDirectCost: Decimal; GenProdPostingGr: Code[20];
                                InventoryPostingGroup: Code[20]; CostingMethod: Enum "Costing Method"; BaseUnitOfMeasure: Code[10]; NetWeight: Decimal;
                                ServiceItemGroupCode: Code[10]; ItempPicTempBlob: Codeunit "Temp Blob"; ItemPictureDescription: Text)
    var
        Item: Record Item;
        ObjInStream: InStream;
    begin
        if Item.Get("No.") then
            exit;
        Item.Init();
        Item.Validate("No.", "No.");

        Item.Validate(Description, Description);

        if BaseUnitOfMeasure <> '' then
            Item."Base Unit of Measure" := BaseUnitOfMeasure
        else
            Item."Base Unit of Measure" := PCSTok;

        Item."Net Weight" := NetWeight;

        Item."Sales Unit of Measure" := Item."Base Unit of Measure";
        Item."Purch. Unit of Measure" := Item."Base Unit of Measure";

        if InventoryPostingGroup <> '' then
            Item."Inventory Posting Group" := InventoryPostingGroup
        else
            Item."Inventory Posting Group" := SvcDemoDataSetup."Resale Code";

        if GenProdPostingGr <> '' then
            Item.Validate("Gen. Prod. Posting Group", GenProdPostingGr)
        else
            Item.Validate("Gen. Prod. Posting Group", SvcDemoDataSetup."Retail Code");

        Item."Costing Method" := CostingMethod;

        Item."Last Direct Cost" := LastDirectCost;
        if Item."Costing Method" = "Costing Method"::Standard then
            Item."Standard Cost" := Item."Last Direct Cost";
        Item."Unit Cost" := Item."Last Direct Cost";

        Item.Validate("Unit Price", UnitPrice);

        if ServiceItemGroupCode <> '' then
            Item.Validate("Service Item Group", ServiceItemGroupCode);

        if ItempPicTempBlob.HasValue() then begin
            ItempPicTempBlob.CreateInStream(ObjInStream);
            Item.Picture.ImportStream(ObjInStream, ItemPictureDescription);
        end;

        OnBeforeItemInsert(Item);
        Item.Insert(true);

        // Create the Item Unit of Measure
        CreateBaseItemUnitOfMeasure(Item);
    end;

    local procedure CreateBaseItemUnitOfMeasure(Item: Record Item)
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        ItemUnitOfMeasure.Init();
        ItemUnitOfMeasure.Validate("Item No.", Item."No.");
        ItemUnitOfMeasure.Validate(Code, Item."Base Unit of Measure");
        ItemUnitOfMeasure."Qty. per Unit of Measure" := 1;
        ItemUnitOfMeasure.Insert();
    end;

    local procedure CreateItemSkills()
    var
        ResourceSkill: Record "Resource Skill";
    begin
        if not ResourceSkill.Get(ResourceSkill.Type::Item, SvcDemoDataSetup."Item 1 No.", CreateSvcSetup.GetSkillCodeSmallTok()) then begin
            ResourceSkill.Type := ResourceSkill.Type::Item;
            ResourceSkill."No." := SvcDemoDataSetup."Item 1 No.";
            ResourceSkill."Skill Code" := CreateSvcSetup.GetSkillCodeSmallTok();
            ResourceSkill.Insert(true);
        end;
        if not ResourceSkill.Get(ResourceSkill.Type::Item, SvcDemoDataSetup."Item 2 No.", CreateSvcSetup.GetSkillCodeLargeTok()) then begin
            ResourceSkill.Type := ResourceSkill.Type::Item;
            ResourceSkill."No." := SvcDemoDataSetup."Item 2 No.";
            ResourceSkill."Skill Code" := CreateSvcSetup.GetSkillCodeLargeTok();
            ResourceSkill.Insert(true);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeItemInsert(var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreatedItems()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreatedItemSkills()
    begin
    end;
}