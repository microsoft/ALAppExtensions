codeunit 5494 "Contoso Dimension"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata Dimension = rim,
        tabledata "Dimension Value" = rim,
        tabledata "Default Dimension" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertDimension(Code: Code[20]; Name: Text[100])
    var
        Dimension: Record Dimension;
        Exists: Boolean;
    begin
        if Dimension.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Dimension.Validate(Code, Code);
        Dimension.Validate(Name, Name);

        if Exists then
            Dimension.Modify(true)
        else
            Dimension.Insert(true);
    end;

    procedure InsertDimensionValue(DimensionCode: Code[20]; Code: Code[20]; Name: Text[50]; DimensionValueType: Integer; Totaling: Text[250])
    var
        DimensionValue: Record "Dimension Value";
        Exists: Boolean;
    begin
        if DimensionValue.Get(DimensionCode, Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        DimensionValue.Validate("Dimension Code", DimensionCode);
        DimensionValue.Validate(Code, Code);
        DimensionValue.Validate(Name, Name);
        DimensionValue.Validate("Dimension Value Type", DimensionValueType);
        DimensionValue.Validate(Totaling, Totaling);

        if Exists then
            DimensionValue.Modify(true)
        else
            DimensionValue.Insert(true);
    end;

    procedure InsertDefaultDimensionValue(TableID: Integer; "No.": Code[20]; DimensionCode: Code[20]; DimensionValueCode: Code[20]; ValuePosting: Enum "Default Dimension Value Posting Type")
    begin
        InsertDefaultDimensionValue(TableID, "No.", DimensionCode, DimensionValueCode, ValuePosting, '');
    end;

    procedure InsertDefaultDimensionValue(TableID: Integer; "No.": Code[20]; DimensionCode: Code[20]; DimensionValueCode: Code[20]; ValuePosting: Enum "Default Dimension Value Posting Type"; AllowedValuesFilter: Text[250])
    var
        DefaultDimension: Record "Default Dimension";
        Exists: Boolean;
    begin
        if DefaultDimension.Get(TableID, "No.", DimensionCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        DefaultDimension.Validate("Table ID", TableID);
        DefaultDimension.Validate("No.", "No.");
        DefaultDimension.Validate("Dimension Code", DimensionCode);
        DefaultDimension.Validate("Dimension Value Code", DimensionValueCode);
        DefaultDimension.Validate("Value Posting", ValuePosting);
        if AllowedValuesFilter <> '' then
            DefaultDimension.Validate("Allowed Values Filter", AllowedValuesFilter);

        if Exists then
            DefaultDimension.Modify(true)
        else
            DefaultDimension.Insert(true);
    end;
}