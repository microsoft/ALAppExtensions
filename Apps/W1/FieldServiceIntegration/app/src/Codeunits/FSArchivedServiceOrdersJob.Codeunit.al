// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Integration.Dataverse;
using Microsoft.Integration.SyncEngine;
using Microsoft.Service.Document;
using System.Threading;
using Microsoft.Service.Archive;

codeunit 6618 "FS Archived Service Orders Job"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        UpdateOrders(Rec.GetLastLogEntryNo());
    end;

    var
        ArchivedOrdersUpdatedMsg: Label 'Archived service orders have been synchronized.';

    local procedure UpdateOrders(JobLogEntryNo: Integer)
    var
        FSConnectionSetup: Record "FS Connection Setup";
    begin
        if not FSConnectionSetup.IsEnabled() then
            exit;

        Codeunit.Run(Codeunit::"CRM Integration Management");
        UpdateArchivedOrders(JobLogEntryNo);
    end;

    local procedure UpdateArchivedOrders(JobLogEntryNo: Integer)
    var
        CRMIntegrationRecord: Record "CRM Integration Record";
        CRMIntegrationRecord2: Record "CRM Integration Record";
        FSWorkOrder: Record "FS Work Order";
        IntegrationTableSynch: Codeunit "Integration Table Synch.";
        SynchActionType: Option "None",Insert,Modify,ForceModify,IgnoreUnchanged,Fail,Skip,Delete;
        ModifyCounter: Integer;
    begin
        IntegrationTableSynch.BeginIntegrationSynchJobLoging(TableConnectionType::CRM, Codeunit::"FS Archived Service Orders Job", JobLogEntryNo, Database::"Service Header");

        CRMIntegrationRecord.SetRange("Archived Service Order", true);
        CRMIntegrationRecord.SetRange("Archived Service Order Updated", false);
        if CRMIntegrationRecord.FindSet() then
            repeat
                if FSWorkOrder.Get(CRMIntegrationRecord."CRM ID") then
                    if UpdateFromServiceHeader(FSWorkOrder) then begin
                        CRMIntegrationRecord2.GetBySystemId(CRMIntegrationRecord.SystemId);
                        CRMIntegrationRecord2."Archived Service Order Updated" := true;
                        CRMIntegrationRecord2.Modify();
                        ModifyCounter += 1;
                    end;
            until CRMIntegrationRecord.Next() = 0;

        IntegrationTableSynch.UpdateSynchJobCounters(SynchActionType::Modify, ModifyCounter);
        IntegrationTableSynch.EndIntegrationSynchJobWithMsg(ArchivedOrdersUpdatedMsg);
    end;

    [TryFunction]
    local procedure UpdateFromServiceHeader(var FSWorkOrder: Record "FS Work Order")
    begin
        ResetFSWorkOrderLineFromServiceOrderLine(FSWorkOrder);
        MarkPosted(FSWorkOrder);
    end;

    local procedure ResetFSWorkOrderLineFromServiceOrderLine(var FSWorkOrder: Record "FS Work Order")
    var
        ServiceLineArchive: Record "Service Line Archive";
        FSWorkOrderProduct: Record "FS Work Order Product";
        FSWorkOrderService: Record "FS Work Order Service";
        CRMIntegrationRecord: Record "CRM Integration Record";
    begin
        FSWorkOrderProduct.SetRange(WorkOrder, FSWorkOrder.WorkOrderId);
        if FSWorkOrderProduct.FindSet() then
            repeat
                if CRMIntegrationRecord.FindByCRMID(FSWorkOrderProduct.WorkOrderProductId) then
                    if ServiceLineArchive.GetBySystemId(CRMIntegrationRecord."Archived Service Line Id") then
                        UpdateWorkOrderProduct(ServiceLineArchive, FSWorkOrderProduct);
            until FSWorkOrderProduct.Next() = 0;

        FSWorkOrderService.SetRange(WorkOrder, FSWorkOrder.WorkOrderId);
        if FSWorkOrderService.FindSet() then
            repeat
                if CRMIntegrationRecord.FindByCRMID(FSWorkOrderService.WorkOrderServiceId) then
                    if ServiceLineArchive.GetBySystemId(CRMIntegrationRecord."Archived Service Line Id") then
                        UpdateWorkOrderService(ServiceLineArchive, FSWorkOrderService);
            until FSWorkOrderService.Next() = 0;
    end;

    local procedure MarkPosted(var FSWorkOrder: Record "FS Work Order")
    begin
        FSWorkOrder.SystemStatus := FSWorkOrder.SystemStatus::Posted;
        FSWorkOrder.Modify();
    end;

    internal procedure UpdateWorkOrderProduct(ServiceLineArchive: Record "Service Line Archive"; var FSWorkOrderProduct: Record "FS Work Order Product")
    var
        Modified: Boolean;
    begin
        if FSWorkOrderProduct.QuantityShipped <> (ServiceLineArchive."Quantity Shipped" + ServiceLineArchive."Qty. to Ship") then begin
            FSWorkOrderProduct.QuantityShipped := ServiceLineArchive."Quantity Shipped" + ServiceLineArchive."Qty. to Ship";
            Modified := true;
        end;

        if FSWorkOrderProduct.QuantityInvoiced <> (ServiceLineArchive."Quantity Invoiced" + ServiceLineArchive."Qty. to Invoice") then begin
            FSWorkOrderProduct.QuantityInvoiced := ServiceLineArchive."Quantity Invoiced" + ServiceLineArchive."Qty. to Invoice";
            Modified := true;
        end;

        if FSWorkOrderProduct.QuantityConsumed <> ServiceLineArchive."Quantity Consumed" + ServiceLineArchive."Qty. to Consume" then begin
            FSWorkOrderProduct.QuantityConsumed := ServiceLineArchive."Quantity Consumed" + ServiceLineArchive."Qty. to Consume";
            Modified := true;
        end;

        if Modified then
            FSWorkOrderProduct.Modify();
    end;

    internal procedure UpdateWorkOrderService(ServiceLineArchive: Record "Service Line Archive"; var FSWorkOrderService: Record "FS Work Order Service")
    var
        Modified: Boolean;
    begin
        if FSWorkOrderService.DurationShipped <> (ServiceLineArchive."Quantity Shipped" + ServiceLineArchive."Qty. to Ship") then begin
            FSWorkOrderService.DurationShipped := (ServiceLineArchive."Quantity Shipped" + ServiceLineArchive."Qty. to Ship") * 60;
            Modified := true;
        end;

        if FSWorkOrderService.DurationInvoiced <> (ServiceLineArchive."Quantity Invoiced" + ServiceLineArchive."Qty. to Invoice") then begin
            FSWorkOrderService.DurationInvoiced := (ServiceLineArchive."Quantity Invoiced" + ServiceLineArchive."Qty. to Invoice") * 60;
            Modified := true;
        end;

        if FSWorkOrderService.DurationConsumed <> ServiceLineArchive."Quantity Consumed" + ServiceLineArchive."Qty. to Consume" then begin
            FSWorkOrderService.DurationConsumed := (ServiceLineArchive."Quantity Consumed" + ServiceLineArchive."Qty. to Consume") * 60;
            Modified := true;
        end;

        if Modified then
            FSWorkOrderService.Modify();
    end;
}

