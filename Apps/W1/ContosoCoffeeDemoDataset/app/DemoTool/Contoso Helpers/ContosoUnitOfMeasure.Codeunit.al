codeunit 5129 "Contoso Unit of Measure"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Unit of Measure" = rim,
        tabledata "Item Unit of Measure" = rim,
        tabledata "Capacity Unit of Measure" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertUnitOfMeasure(UnitOfMeasureCode: Code[10]; Description: Text[10]; InternationalStandardCode: Code[10])
    var
        UnitOfMeasure: Record "Unit of Measure";
        Exists: Boolean;
    begin
        if UnitOfMeasure.Get(UnitOfMeasureCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        UnitOfMeasure.Validate(Code, UnitOfMeasureCode);
        UnitOfMeasure.Validate(Description, Description);
        UnitOfMeasure.Validate("International Standard Code", InternationalStandardCode);

        if Exists then
            UnitOfMeasure.Modify(true)
        else
            UnitOfMeasure.Insert(true);
    end;

    procedure InsertItemUnitOfMeasure(ItemNo: Code[20]; Code: Code[10]; QtyPerUnitOfMeasure: Decimal; QtyRoundingPrecision: Decimal; Length: Decimal; Width: Decimal; Height: Decimal)
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        Exists: Boolean;
    begin
        if ItemUnitOfMeasure.Get(ItemNo, Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ItemUnitOfMeasure.Validate("Item No.", ItemNo);
        ItemUnitOfMeasure.Validate("Code", Code);
        ItemUnitOfMeasure.Validate("Qty. per Unit of Measure", QtyPerUnitOfMeasure);
        ItemUnitOfMeasure.Validate("Qty. Rounding Precision", QtyRoundingPrecision);
        ItemUnitOfMeasure.Validate("Length", Length);
        ItemUnitOfMeasure.Validate("Width", Width);
        ItemUnitOfMeasure.Validate("Height", Height);

        if Exists then
            ItemUnitOfMeasure.Modify(true)
        else
            ItemUnitOfMeasure.Insert(true);
    end;

    procedure InsertCapacityUnitOfMeasure(CapacityCode: Text[10]; Description: Text[50]; Type: Enum "Capacity Unit of Measure")
    var
        CapacityUnitOfMeasure: Record "Capacity Unit of Measure";
        Exists: Boolean;
    begin
        if CapacityUnitOfMeasure.Get(CapacityCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        CapacityUnitOfMeasure.Validate(Code, CapacityCode);
        CapacityUnitOfMeasure.Validate(Description, Description);
        CapacityUnitOfMeasure.Validate(Type, Type);

        if Exists then
            CapacityUnitOfMeasure.Modify(true)
        else
            CapacityUnitOfMeasure.Insert(true);
    end;
}