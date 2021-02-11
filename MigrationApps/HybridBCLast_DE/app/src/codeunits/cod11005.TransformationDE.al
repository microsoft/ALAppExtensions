codeunit 11005 "Transformation DE"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '17.0';

    var
        CountryCodeDETxt: Label 'DE', Locked = true;
        BaseAppExtensionIdTxt: Label '437dbf0e-84ff-417a-965d-ed2bb9650972', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Management", 'OnAfterPopulateW1TableMappingForVersion', '', false, false)]
    local procedure PopulateTableMappingsDE_15x(CountryCode: Text; TargetVersion: Decimal)
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
        if CountryCode <> CountryCodeDETxt then
            exit;

        if TargetVersion <> 15.0 then
            exit;

        NavApp.GetCurrentModuleInfo(ExtensionInfo);
        W1AppId := HybridBCLastManagement.GetAppId();
        with SourceTableMapping do begin
            // Map the staged tables for DE

            // Map the unstaged tables that have been moved to W1
            SetRange("Country Code", CountryCodeDETxt);
            DeleteAll();

            MapTable('Phys. Inventory Order Header', CountryCodeDETxt, PhysInvtOrderHeader.TableName(), false, BaseAppExtensionIdTxt);
            MapTable('Phys. Inventory Order Line', CountryCodeDETxt, PhysInvtOrderLine.TableName(), false, BaseAppExtensionIdTxt);
            MapTable('Phys. Invt. Recording Header', CountryCodeDETxt, PhysInvtRecordHeader.TableName(), false, BaseAppExtensionIdTxt);
            MapTable('Phys. Invt. Recording Line', CountryCodeDETxt, PhysInvtRecordLine.TableName(), false, BaseAppExtensionIdTxt);
            MapTable('Post. Phys. Invt. Order Header', CountryCodeDETxt, PstdPhysInvtOrderHdr.TableName(), false, BaseAppExtensionIdTxt);
            MapTable('Posted Phys. Invt. Order Line', CountryCodeDETxt, PstdPhysInvtOrderLine.TableName(), false, BaseAppExtensionIdTxt);
            MapTable('Posted Phys. Invt. Rec. Header', CountryCodeDETxt, PstdPhysInvtRecordHdr.TableName(), false, BaseAppExtensionIdTxt);
            MapTable('Posted Phys. Invt. Rec. Line', CountryCodeDETxt, PstdPhysInvtRecordLine.TableName(), false, BaseAppExtensionIdTxt);
            MapTable('Phys. Inventory Comment Line', CountryCodeDETxt, PhysInvtCommentLine.TableName(), false, BaseAppExtensionIdTxt);
            MapTable('Posted Phys. Invt. Track. Line', CountryCodeDETxt, PstdPhysInvtTracking.TableName(), false, BaseAppExtensionIdTxt);
            MapTable('Phys. Invt. Tracking Buffer', CountryCodeDETxt, PhysInvtTracking.TableName(), false, BaseAppExtensionIdTxt);
            MapTable('Expect. Phys. Inv. Track. Line', CountryCodeDETxt, ExpPhysInvtTracking.TableName(), false, BaseAppExtensionIdTxt);
            MapTable('Post. Exp. Ph. In. Track. Line', CountryCodeDETxt, PstdExpPhysInvtTrack.TableName(), false, BaseAppExtensionIdTxt);
            MapTable('Phys. Invt. Diff. List Buffer', CountryCodeDETxt, PhysInvtCountBuffer.TableName(), false, BaseAppExtensionIdTxt);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Transformation", 'OnAfterW1TransformationForVersion', '', false, false)]
    local procedure TransformTablesForDE_15x(CountryCode: Text; TargetVersion: Decimal)
    begin
        if CountryCode <> CountryCodeDETxt then
            exit;

        if TargetVersion <> 15.0 then
            exit;
    end;
}