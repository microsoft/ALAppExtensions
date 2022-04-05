/// <summary>
/// Codeunit Shpfy Item Reference Mgt. (ID 30175).
/// </summary>
codeunit 30175 "Shpfy Item Reference Mgt."
{
    Access = Internal;

    var
        ProductEvents: Codeunit "Shpfy Product Events";

    internal procedure CreateItemBarCode(ItemNo: Code[20]; VariantCode: Code[10]; UnitOfMeasure: Code[10]; BarCode: Text)
    begin
        CreateItemReference(ItemNo, VariantCode, UnitOfMeasure, "Item Reference Type"::"Bar Code", '', CopyStr(Barcode, 1, 50));
    end;

    internal procedure CreateItemReference(ItemNo: Code[20]; VariantCode: Code[10]; UnitOfMeasure: Code[10]; ReferenceType: Enum "Item Reference Type"; ReferenceTypeNo: Code[20]; ReferenceNo: Code[50])
    var
        ItemReference: Record "Item Reference";
    begin
        Clear(ItemReference);
        ItemReference."Item No." := ItemNo;
        ItemReference."Variant Code" := VariantCode;
        ItemReference."Unit of Measure" := UnitOfMeasure;
        ItemReference."Reference Type" := ReferenceType;
        ItemReference."Reference Type No." := ReferenceTypeNo;
        ItemReference."Reference No." := ReferenceNo;
        if not ItemReference.Insert() then
            ItemReference.Modify();

        if VariantCode <> '' then begin
            ItemReference.SetRange("Item No.", ItemNo);
            ItemReference.SetRange("Variant Code", '');
            ItemReference.SetRAnge("Unit of Measure", UnitOfMeasure);
            ItemReference.SetRange("Reference Type", ReferenceType);
            ItemReference.SetRange("Reference Type No.", ReferenceTypeNo);
            ItemReference.SetRange("Reference No.", ReferenceNo);
            if not ItemReference.IsEmpty then
                ItemReference.DeleteAll();
        end;
    end;

    internal procedure FindByBarCode(BarCode: Code[50]; UnitOfMeasure: Code[10]; var ItemNo: Code[20]; var VariantCode: Code[10]): Boolean
    begin
        exit(FindByReference(BarCode, "Item Reference Type"::"Bar Code", UnitOfMeasure, ItemNo, VariantCode));
    end;

    internal procedure FindByReference(ReferenceNo: Code[50]; ReferenceType: enum "Item Reference Type"; UnitOfMeasure: Code[10]; var ItemNo: Code[20]; var VariantCode: Code[10]): Boolean
    var
        ItemReference: Record "Item Reference";
    begin
        ItemReference.SetRange("Reference Type", ReferenceType);
        ItemReference.SetRange("Reference No.", ReferenceNo);
        ItemReference.SetFilter("Unit of Measure", '%1|%2', UnitOfMeasure, '');
        if ItemReference.FindLast() then begin
            ItemNo := ItemReference."Item No.";
            VariantCode := ItemReference."Variant Code";
            exit(true);
        end;
    end;

    internal procedure GetItemBarcode(ItemNo: Code[20]; VariantCode: Code[10]; UnitOfMeasure: Code[10]) Barcode: Text
    var
        IsHandled: Boolean;
    begin
        ProductEvents.OnBeforGetBarcode(ItemNo, VariantCode, UnitOfMeasure, Barcode, IsHandled);
        if not IsHandled then begin
            Barcode := GetItemReference(ItemNo, VariantCode, UnitOfMeasure, "Item Reference Type"::"Bar Code", '');
            ProductEvents.OnAfterGetBarcode(ItemNo, VariantCode, UnitOfMeasure, Barcode);
        end;
    end;

    internal procedure GetItemReference(ItemNo: Code[20]; VariantCode: Code[10]; UnitOfMeasure: Code[10]; ReferenceType: Enum "Item Reference Type"; ReferenceTypeNo: Code[20]): Code[50]
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
    begin
        if UnitOfMeasure = '' then
            if Item.Get(ITemNo) then
                UnitOfMeasure := Item."Sales Unit of Measure";
        ItemReference.SetRange("Item No.", ItemNo);
        ItemReference.SetRange("Reference Type", ReferenceType);
        ItemReference.SetRange("Reference Type No.", ReferenceTypeNo);
        ItemReference.SetFilter("Variant Code", '%1|%2', VariantCode, '');
        ItemReference.SetFilter("Unit of Measure", '%1|%2', UnitOfMeasure, '');
        if ItemReference.FindLast() then
            exit(ItemReference."Reference No.");
    end;


}
