// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Integration.Dataverse;

codeunit 6612 "FS Lookup FS Tables"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Lookup CRM Tables", 'OnLookupCRMTables', '', false, false)]
    local procedure HandleOnLookupCRMTables(CRMTableID: Integer; NAVTableId: Integer; SavedCRMId: Guid; var CRMId: Guid; IntTableFilter: Text; var Handled: Boolean)
    var
        FSConnectionSetup: Record "FS Connection Setup";
    begin
        if Handled then
            exit;

        if not FSConnectionSetup.IsEnabled() then
            exit;

        case CRMTableID of
            Database::"FS Bookable Resource":
                if LookupFSBookableResource(SavedCRMId, CRMId, IntTableFilter) then
                    Handled := true;
            Database::"FS Customer Asset":
                if LookupFSCustomerAsset(SavedCRMId, CRMId, IntTableFilter) then
                    Handled := true;
            Database::"FS Work Order":
                if LookupFSWorkOrder(SavedCRMId, CRMId, IntTableFilter) then
                    Handled := true;
            Database::"FS Work Order Type":
                if LookupFSWorkOrderType(SavedCRMId, CRMId, IntTableFilter) then
                    Handled := true;
        end;
    end;

    local procedure LookupFSCustomerAsset(SavedCRMId: Guid; var CRMId: Guid; IntTableFilter: Text): Boolean
    var
        FSCustomerAsset: Record "FS Customer Asset";
        OriginalFSCustomerAsset: Record "FS Customer Asset";
        FSCustomerAssetList: Page "FS Customer Asset List";
    begin
        if not IsNullGuid(CRMId) then begin
            if FSCustomerAsset.Get(CRMId) then
                FSCustomerAssetList.SetRecord(FSCustomerAsset);
            if not IsNullGuid(SavedCRMId) then
                if OriginalFSCustomerAsset.Get(SavedCRMId) then
                    FSCustomerAssetList.SetCurrentlyCoupledFSCustomerAsset(OriginalFSCustomerAsset);
        end;
        FSCustomerAsset.SetView(IntTableFilter);
        FSCustomerAssetList.SetTableView(FSCustomerAsset);
        FSCustomerAssetList.LookupMode(true);
        Commit();
        if FSCustomerAssetList.RunModal() = Action::LookupOK then begin
            FSCustomerAssetList.GetRecord(FSCustomerAsset);
            CRMId := FSCustomerAsset.CustomerAssetId;
            exit(true);
        end;
        exit(false);
    end;

    local procedure LookupFSBookableResource(SavedCRMId: Guid; var CRMId: Guid; IntTableFilter: Text): Boolean
    var
        FSBookableResource: Record "FS Bookable Resource";
        OriginalFSBookableResource: Record "FS Bookable Resource";
        FSBookableResourceList: Page "FS Bookable Resource List";
    begin
        if not IsNullGuid(CRMId) then begin
            if FSBookableResource.Get(CRMId) then
                FSBookableResourceList.SetRecord(FSBookableResource);
            if not IsNullGuid(SavedCRMId) then
                if OriginalFSBookableResource.Get(SavedCRMId) then
                    FSBookableResourceList.SetCurrentlyCoupledFSBookableResource(OriginalFSBookableResource);
        end;
        FSBookableResource.SetView(IntTableFilter);
        FSBookableResourceList.SetTableView(FSBookableResource);
        FSBookableResourceList.LookupMode(true);
        Commit();
        if FSBookableResourceList.RunModal() = Action::LookupOK then begin
            FSBookableResourceList.GetRecord(FSBookableResource);
            CRMId := FSBookableResource.BookableResourceId;
            exit(true);
        end;
        exit(false);
    end;

    local procedure LookupFSWorkOrderType(SavedCRMId: Guid; var CRMId: Guid; IntTableFilter: Text): Boolean
    var
        FSWorkOrderType: Record "FS Work Order Type";
        OriginalFSWorkOrderType: Record "FS Work Order Type";
        FSWorkOrderTypes: Page "FS Work Order Types";
    begin
        if not IsNullGuid(CRMId) then begin
            if FSWorkOrderType.Get(CRMId) then
                FSWorkOrderTypes.SetRecord(FSWorkOrderType);
            if not IsNullGuid(SavedCRMId) then
                if OriginalFSWorkOrderType.Get(SavedCRMId) then
                    FSWorkOrderTypes.SetCurrentlyCoupledFSWorkOrderType(OriginalFSWorkOrderType);
        end;
        FSWorkOrderType.SetView(IntTableFilter);
        FSWorkOrderTypes.SetTableView(FSWorkOrderType);
        FSWorkOrderTypes.LookupMode(true);
        Commit();
        if FSWorkOrderTypes.RunModal() = Action::LookupOK then begin
            FSWorkOrderTypes.GetRecord(FSWorkOrderType);
            CRMId := FSWorkOrderType.WorkOrderTypeId;
            exit(true);
        end;
        exit(false);
    end;

    local procedure LookupFSWorkOrder(SavedCRMId: Guid; var CRMId: Guid; IntTableFilter: Text): Boolean
    var
        FSWorkOrderType: Record "FS Work Order";
        OriginalFSWorkOrder: Record "FS Work Order";
        FSWorkOrders: Page "FS Work Orders";
    begin
        if not IsNullGuid(CRMId) then begin
            if FSWorkOrderType.Get(CRMId) then
                FSWorkOrders.SetRecord(FSWorkOrderType);
            if not IsNullGuid(SavedCRMId) then
                if OriginalFSWorkOrder.Get(SavedCRMId) then
                    FSWorkOrders.SetCurrentlyCoupledFSWorkOrder(OriginalFSWorkOrder);
        end;
        FSWorkOrderType.SetView(IntTableFilter);
        FSWorkOrders.SetTableView(FSWorkOrderType);
        FSWorkOrders.LookupMode(true);
        Commit();
        if FSWorkOrders.RunModal() = Action::LookupOK then begin
            FSWorkOrders.GetRecord(FSWorkOrderType);
            CRMId := FSWorkOrderType.WorkOrderId;
            exit(true);
        end;
        exit(false);
    end;
}