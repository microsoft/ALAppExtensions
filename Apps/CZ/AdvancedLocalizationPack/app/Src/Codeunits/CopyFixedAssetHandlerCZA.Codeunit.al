namespace Microsoft.FixedAssets.FixedAsset;

using Microsoft.Finance.Dimension;

codeunit 31474 "Copy Fixed Asset Handler CZA"
{
    Permissions = TableData "Default Dimension" = rd;
    SingleInstance = true;
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Dimension Auto.Create Mgt. CZA", 'OnBeforeAutoCreateDimension', '', false, false)]
    local procedure DimensionAutoCreateMgtOnBeforeAutoCreateDimension(var IsHandled: Boolean)
    begin
        if SetIsHandled then begin
            IsHandled := true;
            SetIsHandled := false;
        end;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Copy Fixed Asset", 'OnAfterFixedAssetCopied', '', false, false)]
    local procedure CopyFixedAssetOnAfterFixedAssetCopied(var FixedAsset2: Record "Fixed Asset"; var FixedAsset: Record "Fixed Asset")
    var
        DefaultDimension: Record "Default Dimension";
        AutoDefaultDimension: Record "Default Dimension";
        DimensionAutoCreateMgtCZA: Codeunit "Dimension Auto.Create Mgt. CZA";
    begin
        AutoDefaultDimension.SetLoadFields("Dimension Code");
        AutoDefaultDimension.SetRange("Table ID", Database::"Fixed Asset");
        AutoDefaultDimension.SetRange("No.", '');
        AutoDefaultDimension.SetRange("Automatic Create CZA", true);
        if AutoDefaultDimension.IsEmpty() then
            exit;

        if AutoDefaultDimension.FindSet() then
            repeat
                if DefaultDimension.Get(Database::"Fixed Asset", FixedAsset2."No.", AutoDefaultDimension."Dimension Code") then
                    if DefaultDimension."Dimension Value Code" = FixedAsset."No." then
                        DefaultDimension.Delete(true);
            until AutoDefaultDimension.Next() = 0;

        DimensionAutoCreateMgtCZA.AutoCreateDimension(Database::"Fixed Asset", FixedAsset2."No.");
        FixedAsset2."Last Date Modified" := 0D;
        FixedAsset2.modify();
    end;

    [EventSubscriber(ObjectType::Report, Report::"Copy Fixed Asset", 'OnOnPreReportOnBeforeFA2Insert', '', false, false)]
    local procedure EmployeeOnOnPreReportOnBeforeFA2Insert()
    begin
        SetIsHandled := true;
    end;

    var
        SetIsHandled: Boolean;
}

