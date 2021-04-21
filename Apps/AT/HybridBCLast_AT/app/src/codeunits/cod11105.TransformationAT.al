codeunit 11105 "Transformation AT"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '17.0';

    var
        CountryCodeATTxt: Label 'AT', Locked = true;
        BaseAppExtensionIdTxt: Label '437dbf0e-84ff-417a-965d-ed2bb9650972', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Management", 'OnAfterPopulateW1TableMappingForVersion', '', false, false)]
    local procedure PopulateTableMappingAT_15x(CountryCode: Text; TargetVersion: Decimal)
    var
        SourceTableMapping: Record "Source Table Mapping";
        PhysInvtOrderHeader: Record "Phys. Invt. Order Header";
        PhysInvtOrderLine: Record "Phys. Invt. Order Line";
        PhysInvtRecordHeader: Record "Phys. Invt. Record Header";
        PhysInvtRecordLine: Record "Phys. Invt. Record Line";
        PstdPhysInvtOrderHdr: Record "Pstd. Phys. Invt. Order Hdr";
        PstdPhysInvtOrderLine: Record "Pstd. Phys. Invt. Order Line";
        PstdPhysInvtRecordHdr: Record "Pstd. Phys. Invt. Record Hdr";
        PstdPhysInvtRecordLine: Record "Pstd. Phys. Invt. Record Line";
        PhysInvtCommentLine: Record "Phys. Invt. Comment Line";
        PstdPhysInvtTracking: Record "Pstd. Phys. Invt. Tracking";
        PhysInvtTracking: Record "Phys. Invt. Tracking";
        ExpPhysInvtTracking: Record "Exp. Phys. Invt. Tracking";
        PstdExpPhysInvtTrack: Record "Pstd. Exp. Phys. Invt. Track";
        PhysInvtCountBuffer: Record "Phys. Invt. Count Buffer";
        HybridBCLastManagement: Codeunit "Hybrid BC Last Management";
        ExtensionInfo: ModuleInfo;
        W1AppId: Guid;
    begin
        if CountryCode <> CountryCodeATTxt then
            exit;

        if TargetVersion <> 15.0 then
            exit;

        NavApp.GetCurrentModuleInfo(ExtensionInfo);
        W1AppId := HybridBCLastManagement.GetAppId();
        with SourceTableMapping do begin
            // Map the staged tables for AT

            // Map the unstaged tables that have been moved to W1
            SetRange("Country Code", CountryCodeATTxt);
            DeleteAll();

            MapTable('Phys. Inventory Order Header', CountryCodeATTxt, PhysInvtOrderHeader.TableName(), false, BaseAppExtensionIdTxt);
            MapTable('Phys. Inventory Order Line', CountryCodeATTxt, PhysInvtOrderLine.TableName(), false, BaseAppExtensionIdTxt);
            MapTable('Phys. Invt. Recording Header', CountryCodeATTxt, PhysInvtRecordHeader.TableName(), false, BaseAppExtensionIdTxt);
            MapTable('Phys. Invt. Recording Line', CountryCodeATTxt, PhysInvtRecordLine.TableName(), false, BaseAppExtensionIdTxt);
            MapTable('Post. Phys. Invt. Order Header', CountryCodeATTxt, PstdPhysInvtOrderHdr.TableName(), false, BaseAppExtensionIdTxt);
            MapTable('Posted Phys. Invt. Order Line', CountryCodeATTxt, PstdPhysInvtOrderLine.TableName(), false, BaseAppExtensionIdTxt);
            MapTable('Posted Phys. Invt. Rec. Header', CountryCodeATTxt, PstdPhysInvtRecordHdr.TableName(), false, BaseAppExtensionIdTxt);
            MapTable('Posted Phys. Invt. Rec. Line', CountryCodeATTxt, PstdPhysInvtRecordLine.TableName(), false, BaseAppExtensionIdTxt);
            MapTable('Phys. Inventory Comment Line', CountryCodeATTxt, PhysInvtCommentLine.TableName(), false, BaseAppExtensionIdTxt);
            MapTable('Posted Phys. Invt. Track. Line', CountryCodeATTxt, PstdPhysInvtTracking.TableName(), false, BaseAppExtensionIdTxt);
            MapTable('Phys. Invt. Tracking Buffer', CountryCodeATTxt, PhysInvtTracking.TableName(), false, BaseAppExtensionIdTxt);
            MapTable('Expect. Phys. Inv. Track. Line', CountryCodeATTxt, ExpPhysInvtTracking.TableName(), false, BaseAppExtensionIdTxt);
            MapTable('Post. Exp. Ph. In. Track. Line', CountryCodeATTxt, PstdExpPhysInvtTrack.TableName(), false, BaseAppExtensionIdTxt);
            MapTable('Phys. Invt. Diff. List Buffer', CountryCodeATTxt, PhysInvtCountBuffer.TableName(), false, BaseAppExtensionIdTxt);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Transformation", 'OnAfterW1TransformationForVersion', '', false, false)]
    local procedure TransformTablesForAT_15x(CountryCode: Text; TargetVersion: Decimal)
    begin
        if CountryCode <> CountryCodeATTxt then
            exit;

        if TargetVersion <> 15.0 then
            exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Transformation", 'OnAfterW1TransformationForVersion', '', false, false)]
    local procedure TransformTablesForAT_16x(CountryCode: Text; TargetVersion: Decimal)
    begin
        if CountryCode <> CountryCodeATTxt then
            exit;

        if TargetVersion <> 16.0 then
            exit;
    end;
}