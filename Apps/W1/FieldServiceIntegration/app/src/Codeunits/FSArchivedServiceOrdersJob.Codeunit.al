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

codeunit 6617 "FS Archived Service Orders Job"
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
                    if UpdateFromSalesHeader(FSWorkOrder) then begin
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
    local procedure UpdateFromSalesHeader(var FSWorkOrder: Record "FS Work Order")
    begin
        ResetFSWorkOrderLineFromServiceOrderLine(FSWorkOrder);
    end;

    local procedure ResetFSWorkOrderLineFromServiceOrderLine(var FSWorkOrder: Record "FS Work Order")
    var
        SalesLineArchive: Record "Service Line Archive";
        FSWorkOrderProduct: Record "FS Work Order Product";
        FSWorkOrderService: Record "FS Work Order Service";
        CRMIntegrationRecord: Record "CRM Integration Record";
    begin
        FSWorkOrderProduct.SetRange(WorkOrder, FSWorkOrder.WorkOrderId);
        if FSWorkOrderProduct.FindSet() then
            repeat
                if CRMIntegrationRecord.FindByCRMID(FSWorkOrderProduct.WorkOrderProductId) then
                    if SalesLineArchive.GetBySystemId(CRMIntegrationRecord."Archived Service Line Id") then
                        UpdateWorkOrderProduct(SalesLineArchive, FSWorkOrderProduct);
            until FSWorkOrderProduct.Next() = 0;

        FSWorkOrderService.SetRange(WorkOrder, FSWorkOrder.WorkOrderId);
        if FSWorkOrderService.FindSet() then
            repeat
                if CRMIntegrationRecord.FindByCRMID(FSWorkOrderService.WorkOrderServiceId) then
                    if SalesLineArchive.GetBySystemId(CRMIntegrationRecord."Archived Service Line Id") then
                        UpdateWorkOrderService(SalesLineArchive, FSWorkOrderService);
            until FSWorkOrderService.Next() = 0;
    end;

    local procedure UpdateWorkOrderProduct(SalesLineArchive: Record "Service Line Archive"; var FSWorkOrderProduct: Record "FS Work Order Product")
    var
        Modified: Boolean;
    begin
        // TODO! Add Quantity Shipped
        // if FSWorkOrderProduct.QuantityShipped <> (SalesLineArchive."Quantity Shipped" + SalesLineArchive."Qty. to Ship") then begin
        //     FSWorkOrderProduct.QuantityShipped := SalesLineArchive."Quantity Shipped" + SalesLineArchive."Qty. to Ship";
        //     Modified := true;
        // end;

        if FSWorkOrderProduct.QuantityInvoiced <> (SalesLineArchive."Quantity Invoiced" + SalesLineArchive."Qty. to Ship") then begin
            FSWorkOrderProduct.QuantityInvoiced := SalesLineArchive."Quantity Invoiced" + SalesLineArchive."Qty. to Ship";
            Modified := true;
        end;

        if FSWorkOrderProduct.QuantityConsumed <> SalesLineArchive."Quantity Consumed" + SalesLineArchive."Qty. to Consume" then begin
            FSWorkOrderProduct.QuantityConsumed := SalesLineArchive."Quantity Consumed" + SalesLineArchive."Qty. to Consume";
            Modified := true;
        end;

        if Modified then
            FSWorkOrderProduct.Modify();
    end;

    local procedure UpdateWorkOrderService(SalesLineArchive: Record "Service Line Archive"; var FSWorkOrderService: Record "FS Work Order Service")
    var
        Modified: Boolean;
    begin
        // TODO! Add Quantity Shipped
        // if FSWorkOrderService.QuantityShipped <> (SalesLineArchive."Quantity Shipped" + SalesLineArchive."Qty. to Ship") then begin
        //     FSWorkOrderService.QuantityShipped := SalesLineArchive."Quantity Shipped" + SalesLineArchive."Qty. to Ship";
        //     Modified := true;
        // end;

        if FSWorkOrderService.DurationInvoiced <> (SalesLineArchive."Quantity Invoiced" + SalesLineArchive."Qty. to Ship") then begin
            FSWorkOrderService.DurationInvoiced := (SalesLineArchive."Quantity Invoiced" + SalesLineArchive."Qty. to Ship") * 60;
            Modified := true;
        end;

        if FSWorkOrderService.DurationConsumed <> SalesLineArchive."Quantity Consumed" + SalesLineArchive."Qty. to Consume" then begin
            FSWorkOrderService.DurationConsumed := (SalesLineArchive."Quantity Consumed" + SalesLineArchive."Qty. to Consume") * 60;
            Modified := true;
        end;

        if Modified then
            FSWorkOrderService.Modify();
    end;
}

