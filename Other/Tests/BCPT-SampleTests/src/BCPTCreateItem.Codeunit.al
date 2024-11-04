codeunit 149127 "BCPT Create Item"
{
    trigger OnRun()
    begin
        InitTest();
        CreateItem();
    end;

    local procedure InitTest();
    var
        InventorySetup: Record "Inventory Setup";
        NoSeriesLine: Record "No. Series Line";
    begin
        InventorySetup.Get();
        InventorySetup.TestField("Item Nos.");
        NoSeriesLine.SetRange("Series Code", InventorySetup."Item Nos.");
        NoSeriesLine.FindSet(true);
        repeat
            if NoSeriesLine."Ending No." <> '' then begin
                NoSeriesLine."Ending No." := '';
                NoSeriesLine.Validate("Allow Gaps in Nos.", true);
                NoSeriesLine.Modify(true);
            end;
        until NoSeriesLine.Next() = 0;
        Commit(); //Commit to avoid deadlocks
    end;

    procedure CreateItem()
    var
        Item: Record Item;
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        Clear(Item);
        Item.Insert(true);

        CreateItemUnitOfMeasureCode(Item."No.", ItemUnitOfMeasure);

        Item.Validate(Description, Item."No.");
        Item.Validate("Base Unit of Measure", ItemUnitOfMeasure.Code);
        Item.Validate("Gen. Prod. Posting Group", LookUpGenProdPostingGroup());
        Item.Validate("Inventory Posting Group", FindInventoryPostingSetup());
        Item.Validate("VAT Prod. Posting Group", FindVATPostingSetup());
        Item.Modify(true);
        Commit(); //Commit to avoid deadlocks

        OnAfterCreateItem(Item);
    end;

    local procedure CreateItemUnitOfMeasureCode(ItemNo: Code[20]; var ItemUnitOfMeasure: Record "Item Unit of Measure")
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        UnitOfMeasure.Reset();
        if UnitOfMeasure.FindFirst() then
            ItemUnitOfMeasure.Init();
        ItemUnitOfMeasure.Validate("Item No.", ItemNo);
        ItemUnitOfMeasure.Validate(Code, UnitOfMeasure.Code);
        ItemUnitOfMeasure.Validate("Qty. per Unit of Measure", 1);
        ItemUnitOfMeasure.Insert(true);
    end;

    local procedure LookUpGenProdPostingGroup(): Code[20]
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        GeneralPostingSetup.Reset();
        GeneralPostingSetup.SetFilter("Gen. Prod. Posting Group", '<>%1', '');
        GeneralPostingSetup.SetFilter("Purch. Account", '<>%1', '');
        if GeneralPostingSetup.FindFirst() then
            exit(GeneralPostingSetup."Gen. Prod. Posting Group");
    end;

    local procedure FindInventoryPostingSetup(): Code[20]
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
    begin
        InventoryPostingSetup.Reset();
        InventoryPostingSetup.SetFilter("Inventory Account", '<>%1', '');
        InventoryPostingSetup.SetFilter("Location Code", '%1', '');
        if InventoryPostingSetup.FindFirst() then
            exit(InventoryPostingSetup."Invt. Posting Group Code");
    end;

    local procedure FindVATPostingSetup(): Code[20]
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATPostingSetup.SetFilter("VAT Prod. Posting Group", '<>%1', '');
        VATPostingSetup.SetFilter("VAT %", '<>%1', 0);
        VATPostingSetup.SetRange("VAT Calculation Type", VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        if VATPostingSetup.FindFirst() then
            exit(VATPostingSetup."VAT Prod. Posting Group");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateItem(var Item: Record Item)
    begin
    end;
}
