// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.TestLibraries.DynamicsFieldService;

using Microsoft.Integration.DynamicsFieldService;
using Microsoft.Service.Document;
using Microsoft.Service.Archive;

codeunit 139205 "FS Integration Test Library"
{
    procedure RegisterConnection(var FSConnectionSetup: Record "FS Connection Setup")
    begin
        FSConnectionSetup.RegisterConnection();
    end;

    procedure UnregisterConnection(var FSConnectionSetup: Record "FS Connection Setup")
    begin
        FSConnectionSetup.UnregisterConnection();
    end;

    procedure SetPassword(var FSConnectionSetup: Record "FS Connection Setup"; Password: SecretText)
    begin
        FSConnectionSetup.SetPassword(Password);
    end;

    procedure PerformTestConnection(var FSConnectionSetup: Record "FS Connection Setup")
    begin
        FSConnectionSetup.PerformTestConnection();
    end;

    procedure ResetConfiguration(var FSConnectionSetup: Record "FS Connection Setup")
    var
        FSSetupDefaults: Codeunit "FS Setup Defaults";
    begin
        FSSetupDefaults.ResetConfiguration(FSConnectionSetup);
    end;

    procedure UpdateQuantities(FSWorkOrderProduct: Record "FS Work Order Product"; var ServiceLine: Record "Service Line"; ToFieldService: Boolean)
    var
        FSIntTableSubscriber: Codeunit "FS Int. Table Subscriber";
    begin
        FSIntTableSubscriber.UpdateQuantities(FSWorkOrderProduct, ServiceLine, ToFieldService);
    end;

    procedure UpdateQuantities(FSWorkOrderService: Record "FS Work Order Service"; var ServiceLine: Record "Service Line"; ToFieldService: Boolean)
    var
        FSIntTableSubscriber: Codeunit "FS Int. Table Subscriber";
    begin
        FSIntTableSubscriber.UpdateQuantities(FSWorkOrderService, ServiceLine, ToFieldService);
    end;

    procedure UpdateQuantities(FSBookableResourceBooking: Record "FS Bookable Resource Booking"; var ServiceLine: Record "Service Line")
    var
        FSIntTableSubscriber: Codeunit "FS Int. Table Subscriber";
    begin
        FSIntTableSubscriber.UpdateQuantities(FSBookableResourceBooking, ServiceLine);
    end;

    procedure IgnorePostedJobJournalLinesOnQueryPostFilterIgnoreRecord(SourceRecordRef: RecordRef; var IgnoreRecord: Boolean)
    var
        FSIntTableSubscriber: Codeunit "FS Int. Table Subscriber";
    begin
        FSIntTableSubscriber.IgnorePostedJobJournalLinesOnQueryPostFilterIgnoreRecord(SourceRecordRef, IgnoreRecord);
    end;

    procedure IgnoreArchievedServiceOrdersOnQueryPostFilterIgnoreRecord(SourceRecordRef: RecordRef; var IgnoreRecord: Boolean)
    var
        FSIntTableSubscriber: Codeunit "FS Int. Table Subscriber";
    begin
        FSIntTableSubscriber.IgnoreArchievedServiceOrdersOnQueryPostFilterIgnoreRecord(SourceRecordRef, IgnoreRecord);
    end;

    procedure IgnoreArchievedCRMWorkOrdersOnQueryPostFilterIgnoreRecord(SourceRecordRef: RecordRef; var IgnoreRecord: Boolean)
    var
        FSIntTableSubscriber: Codeunit "FS Int. Table Subscriber";
    begin
        FSIntTableSubscriber.IgnoreArchievedCRMWorkOrdersOnQueryPostFilterIgnoreRecord(SourceRecordRef, IgnoreRecord);
    end;

    procedure MarkArchivedServiceOrder(ServiceHeader: Record "Service Header")
    var
        FSIntTableSubscriber: Codeunit "FS Int. Table Subscriber";
    begin
        FSIntTableSubscriber.MarkArchivedServiceOrder(ServiceHeader);
    end;

    procedure MarkArchivedServiceOrderLine(var ServiceLine: Record "Service Line"; var ServiceLineArchive: Record "Service Line Archive")
    var
        FSIntTableSubscriber: Codeunit "FS Int. Table Subscriber";
    begin
        FSIntTableSubscriber.MarkArchivedServiceOrderLine(ServiceLine, ServiceLineArchive);
    end;

    procedure ArchiveServiceOrder(ServiceHeader: Record "Service Header"; ArchivedServiceOrders: List of [Code[20]])
    var
        FSIntTableSubscriber: Codeunit "FS Int. Table Subscriber";
    begin
        FSIntTableSubscriber.ArchiveServiceOrder(ServiceHeader, ArchivedServiceOrders);
    end;

    procedure UpdateWorkOrderProduct(SalesLineArchive: Record "Service Line Archive"; var FSWorkOrderProduct: Record "FS Work Order Product")
    var
        FSArchivedServiceOrdersJob: Codeunit "FS Archived Service Orders Job";
    begin
        FSArchivedServiceOrdersJob.UpdateWorkOrderProduct(SalesLineArchive, FSWorkOrderProduct);
    end;

    procedure UpdateWorkOrderService(SalesLineArchive: Record "Service Line Archive"; var FSWorkOrderService: Record "FS Work Order Service")
    var
        FSArchivedServiceOrdersJob: Codeunit "FS Archived Service Orders Job";
    begin
        FSArchivedServiceOrdersJob.UpdateWorkOrderService(SalesLineArchive, FSWorkOrderService);
    end;
}