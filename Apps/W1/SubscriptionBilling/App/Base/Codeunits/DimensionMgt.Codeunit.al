namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.Dimension;

codeunit 8022 "Dimension Mgt."
{
    Access = Internal;
    procedure CreateDimValue(DimCode: Code[20]; DimValueCode: Code[20]; DimValueName: Text)
    var
        DimValue: Record "Dimension Value";
    begin
        if (DimCode = '') or (DimValueCode = '') then
            exit;
        if not DimValue.Get(DimCode, DimValueCode) then begin
            DimValue.Init();
            DimValue.Validate("Dimension Code", DimCode);
            DimValue.Validate(Code, DimValueCode);
            if DimValueName <> '' then
                DimValue.Name := CopyStr(DimValueName, 1, MaxStrLen(DimValue.Name))
            else
                DimValue.Name := DimValueCode;
            DimValue.Insert(true);
        end else
            if DimValueName <> '' then
                if DimValue.Name <> DimValueName then begin
                    DimValue.Name := CopyStr(DimValueName, 1, MaxStrLen(DimValue.Name));
                    DimValue.Modify(true);
                end;
    end;

    procedure AppendDimValue(DimCode: Code[20]; DimValueCode: Code[20]; var DimSetID: Integer)
    var
        DimVal: Record "Dimension Value";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimMgt: Codeunit DimensionManagement;
    begin
        DimVal."Dimension Code" := DimCode;
        if DimValueCode <> '' then
            DimVal.Get(DimVal."Dimension Code", DimValueCode);
        DimMgt.GetDimensionSet(TempDimSetEntry, DimSetID);
        if TempDimSetEntry.Get(TempDimSetEntry."Dimension Set ID", DimVal."Dimension Code") then
            if TempDimSetEntry."Dimension Value Code" <> DimValueCode then
                TempDimSetEntry.Delete(false);
        if DimValueCode <> '' then begin
            TempDimSetEntry."Dimension Code" := DimVal."Dimension Code";
            TempDimSetEntry."Dimension Value Code" := DimVal.Code;
            TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
            if TempDimSetEntry.Insert(false) then;
        end;
        DimSetID := DimMgt.GetDimensionSetID(TempDimSetEntry);
    end;
}