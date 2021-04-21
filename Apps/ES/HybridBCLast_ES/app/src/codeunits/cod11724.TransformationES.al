codeunit 11724 "Transformation ES"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '17.0';

    var
        CountryCodeESTxt: Label 'ES', Locked = true;
        BaseAppExtensionIdTxt: Label '437dbf0e-84ff-417a-965d-ed2bb9650972', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Management", 'OnAfterPopulateW1TableMappingForVersion', '', false, false)]
    local procedure PopulateTableMappingsES_16x(CountryCode: Text; TargetVersion: Decimal)
    var
        ReportSelections: Record "Report Selections";
        StgReportSelections: Record "Stg Report Selections";
        SIISetup: Record "SII Setup";
        StgSIISetup: Record "Stg SII Setup";
        SourceTableMapping: Record "Source Table Mapping";
        HybridBCLastManagement: Codeunit "Hybrid BC Last Management";
        ExtensionInfo: ModuleInfo;
        W1AppId: Guid;
    begin
        if CountryCode <> CountryCodeESTxt then
            exit;

        if TargetVersion <> 16.0 then
            exit;

        NavApp.GetCurrentModuleInfo(ExtensionInfo);
        W1AppId := HybridBCLastManagement.GetAppId();
        with SourceTableMapping do begin
            SetRange("Country Code", CountryCodeESTxt);
            DeleteAll();

            MapTable(ReportSelections.TableName(), CountryCodeESTxt, StgReportSelections.TableName(), true, BaseAppExtensionIdTxt, ExtensionInfo.Id());
            MapTable(ReportSelections.TableName(), CountryCodeESTxt, ReportSelections.TableName(), false, BaseAppExtensionIdTxt, BaseAppExtensionIdTxt);
            MapTable(SIISetup.TableName(), CountryCodeESTxt, StgSIISetup.TableName(), true, BaseAppExtensionIdTxt, ExtensionInfo.Id());
            MapTable(SIISetup.TableName(), CountryCodeESTxt, SIISetup.TableName(), false, BaseAppExtensionIdTxt, BaseAppExtensionIdTxt);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Transformation", 'OnAfterW1TransformationForVersion', '', false, false)]
    local procedure TransformTablesForES_16x(CountryCode: Text; TargetVersion: Decimal)
    begin
        if CountryCode <> CountryCodeESTxt then
            exit;

        if TargetVersion <> 16.0 then
            exit;

        // Logic for transforming data in staging tables for 16x
        TransformReportSelections();
    end;

    local procedure TransformReportSelections()
    var
        StgReportSelections: Record "Stg Report Selections";
        TempStgReportSelections: Record "Stg Report Selections" temporary;
    begin
        // This code is based on app upgrade logic for ES.
        // Matching file: .\App\Layers\ES\BaseApp\Upgrade\UPGReportSelections.Codeunit.al
        // Based on commit: 2c1c901e
        StgReportSelections.SetRange(Usage, 58);
        if StgReportSelections.FindSet() then
            repeat
                TempStgReportSelections := StgReportSelections;
                TempStgReportSelections.Insert();
            until StgReportSelections.Next() = 0;

        if TempStgReportSelections.FindSet() then
            repeat
                StgReportSelections.SetRange(Sequence, TempStgReportSelections.Sequence);
                if StgReportSelections.FindFirst() then
                    StgReportSelections.Rename(100, StgReportSelections.Sequence);
            until TempStgReportSelections.Next() = 0;
        TempStgReportSelections.DeleteAll();

        StgReportSelections.Reset();
        StgReportSelections.SetRange(Usage, 59);
        if StgReportSelections.FindSet() then
            repeat
                TempStgReportSelections := StgReportSelections;
                TempStgReportSelections.Insert();
            until StgReportSelections.Next() = 0;

        if TempStgReportSelections.FindSet() then
            repeat
                StgReportSelections.SetRange(Sequence, TempStgReportSelections.Sequence);
                if StgReportSelections.FindFirst() then
                    StgReportSelections.Rename(101, StgReportSelections.Sequence);
            until TempStgReportSelections.Next() = 0;
        TempStgReportSelections.DeleteAll();
    end;
}