codeunit 5118 "Create Job Demo Items"
{
    Permissions = tabledata Item = rim,
        tabledata "Item Unit of Measure" = rim;

    var
        JobsDemoDataSetup: Record "Jobs Demo Data Setup";
        AdjustJobsDemoData: Codeunit "Adjust Jobs Demo Data";
        JobsDemoDataFiles: Codeunit "Jobs Demo Data Files";
        PCSTok: Label 'PCS', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';
        MachineDescTok: Label 'S-210 Semi-Automatic', MaxLength = 100;
        ConsumableDescTok: Label '100-Pack Filters', MaxLength = 100;

    trigger OnRun()
    begin
        JobsDemoDataSetup.Get();

        CreateItems();
    end;

    local procedure CreateItems()
    begin
        // Create two Items using the JobsDemoDataSetup Item values
        InsertItem(JobsDemoDataSetup."Item Machine No.", MachineDescTok, AdjustJobsDemoData.AdjustPrice(17900), AdjustJobsDemoData.AdjustPrice(15500),
            JobsDemoDataSetup."Retail Code", JobsDemoDataSetup."Resale Code", Enum::"Costing Method"::FIFO, PCSTok, 0.75, JobsDemoDataFiles.GetMachinePicture(), '');
        InsertItem(JobsDemoDataSetup."Item Consumable No.", ConsumableDescTok, AdjustJobsDemoData.AdjustPrice(65), AdjustJobsDemoData.AdjustPrice(100),
            JobsDemoDataSetup."Retail Code", JobsDemoDataSetup."Resale Code", Enum::"Costing Method"::FIFO, PCSTok, 0.75, JobsDemoDataFiles.GetConsumablePicture(), '');
    end;

    local procedure InsertItem("No.": Code[20]; Description: Text[100]; UnitPrice: Decimal; LastDirectCost: Decimal; GenProdPostingGr: Code[20];
                                InventoryPostingGroup: Code[20]; CostingMethod: Enum "Costing Method"; BaseUnitOfMeasure: Code[10]; NetWeight: Decimal;
                                ItempPicTempBlob: Codeunit "Temp Blob"; ItemPictureDescription: Text)
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
            Item."Inventory Posting Group" := JobsDemoDataSetup."Resale Code";

        if GenProdPostingGr <> '' then
            Item.Validate("Gen. Prod. Posting Group", GenProdPostingGr)
        else
            Item.Validate("Gen. Prod. Posting Group", JobsDemoDataSetup."Retail Code");

        Item."Costing Method" := CostingMethod;

        Item."Last Direct Cost" := LastDirectCost;
        if Item."Costing Method" = "Costing Method"::Standard then
            Item."Standard Cost" := Item."Last Direct Cost";
        Item."Unit Cost" := Item."Last Direct Cost";

        Item.Validate("Unit Price", UnitPrice);

        if ItempPicTempBlob.HasValue() then begin
            ItempPicTempBlob.CreateInStream(ObjInStream);
            Item.Picture.ImportStream(ObjInStream, ItemPictureDescription);
        end;

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
}