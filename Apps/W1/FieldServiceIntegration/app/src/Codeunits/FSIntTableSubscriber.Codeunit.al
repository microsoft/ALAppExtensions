// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Integration.Dataverse;
using Microsoft.Projects.Project.Job;
using Microsoft.Foundation.NoSeries;
using Microsoft.Foundation.UOM;
using Microsoft.Projects.Project.Setup;
using Microsoft.Service.Item;
using Microsoft.Integration.SyncEngine;
using Microsoft.Inventory.Setup;
using Microsoft.Sales.Customer;
using Microsoft.Projects.Project.Posting;
using Microsoft.Projects.Project.Journal;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Integration.D365Sales;
using Microsoft.Inventory.Item;
using Microsoft.Service.Archive;
using Microsoft.Service.Document;
using Microsoft.Projects.Project.Planning;
using Microsoft.Projects.Project.Ledger;
using Microsoft.Sales.History;
using Microsoft.Service.Setup;
using System.Security.User;
using System.Telemetry;

codeunit 6610 "FS Int. Table Subscriber"
{
    SingleInstance = true;

    var
        TempFSWorkOrderProduct: Record "FS Work Order Product" temporary;
        TempFSWorkOrderService: Record "FS Work Order Service" temporary;
        CDSIntegrationMgt: Codeunit "CDS Integration Mgt.";
        CDSIntegrationImpl: Codeunit "CDS Integration Impl.";
        CRMSynchHelper: Codeunit "CRM Synch. Helper";
        RecordMustBeCoupledErr: Label '%1 %2 must be coupled to %3.', Comment = '%1 = table caption, %2 = primary key value, %3 - service name';
        RecordCoupledToDeletedErr: Label '%1 %2 is coupled to a deleted record.', Comment = '%1 = table caption, %2 = primary key value';
        JobJournalIncorrectSetupErr: Label 'You must set up %1 correctly on %2.', Comment = '%1 = a table name, %2 = a table name';
        CategoryTok: Label 'AL Field Service Integration', Locked = true;
        MustBeCoupledErr: Label '%1 %2 must be coupled to a Business Central %3', Comment = '%1 = a table name, %2 - a guid, %3 = a table name';
        DoesntExistErr: Label '%1 %2 doesn''t exist in %3', Comment = '%1 = a table name, %2 - a guid, %3 = Field Service service name';
        CoupledToDeletedErr: Label '%1 %2 is coupled to a deleted Business Central %3. You must re-couple it.', Comment = '%1 = a table name, %2 - a guid, %3 = a table name';
        CoupledToNonServiceErr: Label 'To synchronize this work order service, %1 %2 must be coupled to an item whose type is not set to Inventory. It is curretly coupled to item %3.', Comment = '%1 = a table name, %2 - a guid, %3 = an item name';
        CoupledToBlockedItemErr: Label 'To synchronize this work order service, %1 %2 must be coupled to an item that is not blocked. It is curretly coupled to item %3.', Comment = '%1 = a table name, %2 - a guid, %3 = an item name';
        CoupledToItemWithWrongUOMErr: Label 'To synchronize this work order service, %1 %2 must be coupled to an item that has base unit of measure set to %4. It is curretly coupled to item %3.', Comment = '%1 = a table name, %2 - a guid, %3 = an item name, %4 - unit of measure name';
        UnableToModifyWOSTxt: Label 'Unable to update work order service.', Locked = true;
        UnableToModifyWOPTxt: Label 'Unable to update work order product.', Locked = true;
        TestServerAddressTok: Label '@@test@@', Locked = true;
        FSConnEnabledTelemetryErr: Label 'User is trying to set up the connection with Dataverse, while the existing connections with Field Service is enabled.', Locked = true;
        FSConnEnabledErr: Label 'To set up the connection with Dataverse, you must first disable the existing connection with Field Service.';
        ShowFSConnectionSetupLbl: Label 'Field Service Integration Setup';
        ShowFSConnectionSetupDescLbl: Label 'Shows Field Service Integration Setup page where you can disable the connection.';
        CompanyFilterStrengthenedQst: Label 'This will make the synchronization engine process only %1 entities that correspond to the current company. Do you want to continue?', Comment = '%1 - a table caption';
        CompanyFilterStrengthenedFSMsg: Label 'The synchronization will consider only %1 entities whose work order in %3 has an External Project that belongs to company %2.', Comment = '%1 - a table caption; %2 - current company name; %3 - Dynamics 365 service name';
        InsufficientPermissionsTxt: Label 'Insufficient permissions.', Locked = true;
        NoProjectUsageLinkTxt: Label 'Unable to find Project Usage Link.', Locked = true;
        NoProjectPlanningLineTxt: Label 'Unable to find Project Planning Line.', Locked = true;
        FSEntitySynchTxt: Label 'Synching a field service entity.', Locked = true;


    [EventSubscriber(ObjectType::Table, Database::"CDS Connection Setup", 'OnEnsureConnectionSetupIsDisabled', '', false, false)]
    local procedure OnEnsureConnectionSetupIsDisabled()
    var
        FSConnectionSetup: Record "FS Connection Setup";
        ErrorInfo: ErrorInfo;
    begin
        if FSConnectionSetup.Get() then
            if FSConnectionSetup.IsEnabled() then
                if FSConnectionSetup."Server Address" <> TestServerAddressTok then begin
                    Session.LogMessage('0000MQW', FSConnEnabledTelemetryErr, Verbosity::Warning, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                    ErrorInfo.Message := FSConnEnabledErr;
                    ErrorInfo.AddNavigationAction(ShowFSConnectionSetupLbl, ShowFSConnectionSetupDescLbl);
                    ErrorInfo.PageNo(Page::"FS Connection Setup");
                    Error(ErrorInfo);
                end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Integration Table Mapping", 'OnEnableMultiCompanySynchronization', '', false, false)]
    local procedure OnEnableMultiCompanySynchronization(var IntegrationTableMapping: Record "Integration Table Mapping"; var IsHandled: Boolean)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        CDSCompany: Record "CDS Company";
        FSSetupDefaults: Codeunit "FS Setup Defaults";
        CRMProductName: Codeunit "CRM Product Name";
        IntegrationRecordRef: RecordRef;
        CompanyIdFieldRef: FieldRef;
        MessageTxt: Text;
    begin
        if IsHandled then
            exit;

        if IntegrationTableMapping.Type <> IntegrationTableMapping.Type::Dataverse then
            exit;

        if not FSConnectionSetup.IsEnabled() then
            exit;

        if IntegrationTableMapping."Table ID" = Database::"Job Journal Line" then begin
            IsHandled := true;
            IntegrationRecordRef.Open(IntegrationTableMapping."Integration Table ID");

            if not CDSIntegrationMgt.FindCompanyIdField(IntegrationRecordRef, CompanyIdFieldRef) then
                exit;

            if not CDSIntegrationMgt.GetCDSCompany(CDSCompany) then
                exit;

            if GuiAllowed() then
                if not Confirm(StrSubstNo(CompanyFilterStrengthenedQst, IntegrationRecordRef.Caption())) then
                    Error('');

            IntegrationRecordRef.SetView(IntegrationTableMapping.GetIntegrationTableFilter());
            CompanyIdFieldRef.SetRange(CDSCompany.CompanyId);
            IntegrationTableMapping.SetIntegrationTableFilter(FSSetupDefaults.GetTableFilterFromView(IntegrationTableMapping."Integration Table ID", IntegrationRecordRef.Caption(), IntegrationRecordRef.GetView()));
            MessageTxt := StrSubstNo(CompanyFilterStrengthenedFSMsg, IntegrationRecordRef.Caption(), CompanyName(), CRMProductName.FSServiceName());
            if IntegrationTableMapping.Modify() then
                if GuiAllowed() then
                    if MessageTxt <> '' then
                        Message(MessageTxt);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Integration Table Mapping", 'OnAfterModifyEvent', '', true, false)]
    local procedure IntegrationTableMappingOnAfterModifyEvent(var Rec: Record "Integration Table Mapping"; RunTrigger: Boolean)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        ServiceItem: Record "Service Item";
        MandatoryFilterErr: Label '"%1" must be included in the filter. If you need this behavior, please contact your partner for assistance.', Comment = '%1 = a field caption';
    begin
        if not FSConnectionSetup.IsEnabled() then
            exit;
        if not RunTrigger then
            exit;
        if Rec.IsTemporary() then
            exit;

        if Rec."Table ID" <> Database::"Service Item" then
            exit;

        ServiceItem.SetView(Rec.GetTableFilter());
        if ServiceItem.GetFilter(SystemId) <> '' then
            exit;
        if ServiceItem.GetFilter("Service Item Components") = '' then
            Error(MandatoryFilterErr, ServiceItem.FieldCaption("Service Item Components"));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnBeforeTransferRecordFields', '', true, false)]
    local procedure OnBeforeTransferRecordFields(SourceRecordRef: RecordRef; var DestinationRecordRef: RecordRef)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        FSProjectTask: Record "FS Project Task";
        FSWorkOrderProduct: Record "FS Work Order Product";
        FSWorkOrderService: Record "FS Work Order Service";
        FSBookableResourceBooking: Record "FS Bookable Resource Booking";
        CRMIntegrationRecord: Record "CRM Integration Record";
        FSWorkOrderIncident: Record "FS Work Order Incident";
        FSIncident: Record "FS Incident Type";
        JobJournalLine: Record "Job Journal Line";
        JobTask: Record "Job Task";
        ServiceHeader: Record "Service Header";
        ServiceItemLine: Record "Service Item Line";
        ServiceLine: Record "Service Line";
        DefaultIncidentLbl: Label 'Service Order Incident';
        SourceDestCode: Text;
    begin
        if not FSConnectionSetup.IsEnabled() then
            exit;

        SourceDestCode := GetSourceDestCode(SourceRecordRef, DestinationRecordRef);

        case SourceDestCode of
            'FS Work Order Product-Job Journal Line',
            'FS Work Order Service-Job Journal Line':
                begin
                    if SourceRecordRef.Number = Database::"FS Work Order Product" then begin
                        SourceRecordRef.SetTable(FSWorkOrderProduct);
                        FSProjectTask.Get(FSWorkOrderProduct.ProjectTask);
                    end
                    else begin
                        SourceRecordRef.SetTable(FSWorkOrderService);
                        FSProjectTask.Get(FSWorkOrderService.ProjectTask);
                    end;

                    if not CRMIntegrationRecord.FindByCRMID(FSProjectTask.ProjectTaskId) then
                        Error(RecordMustBeCoupledErr, FSProjectTask.TableCaption, Format(FSProjectTask.ProjectTaskId), 'Business Central');

                    if not JobTask.GetBySystemId(CRMIntegrationRecord."Integration ID") then
                        Error(RecordCoupledToDeletedErr, FSProjectTask.TableCaption, Format(FSProjectTask.ProjectTaskId));

                    DestinationRecordRef.SetTable(JobJournalLine);
                    JobJournalLine."Job No." := JobTask."Job No.";
                    JobJournalLine."Job Task No." := JobTask."Job Task No.";
                    DestinationRecordRef.GetTable(JobJournalLine);
                end;
            'FS Work Order Incident-Service Item Line':
                begin
                    SourceRecordRef.SetTable(FSWorkOrderIncident);
                    DestinationRecordRef.SetTable(ServiceItemLine);

                    if ServiceItemLine."Document No." <> '' then
                        exit;

                    if CRMIntegrationRecord.FindByCRMID(FSWorkOrderIncident.WorkOrder) then
                        ServiceHeader.GetBySystemId(CRMIntegrationRecord."Integration ID");

                    ServiceItemLine."Document Type" := ServiceItemLine."Document Type"::Order;
                    ServiceItemLine."Document No." := ServiceHeader."No.";
                    ServiceItemLine."Line No." := GetNextLineNo(ServiceItemLine);

                    if IsNullGuid(FSWorkOrderIncident.CustomerAsset) then
                        if FSIncident.Get(FSWorkOrderIncident.IncidentType) then
                            ServiceItemLine.Description := FSIncident.Name
                        else
                            ServiceItemLine.Description := DefaultIncidentLbl;

                    DestinationRecordRef.GetTable(ServiceItemLine);
                end;
            'FS Work Order Product-Service Line':
                begin
                    SourceRecordRef.SetTable(FSWorkOrderProduct);
                    DestinationRecordRef.SetTable(ServiceLine);

                    if ServiceLine."Document No." <> '' then
                        exit;

                    if CRMIntegrationRecord.FindByCRMID(FSWorkOrderProduct.WorkOrder) then
                        ServiceHeader.GetBySystemId(CRMIntegrationRecord."Integration ID");

                    ServiceLine."Document Type" := ServiceLine."Document Type"::Order;
                    ServiceLine."Document No." := ServiceHeader."No.";
                    ServiceLine."Line No." := GetNextLineNo(ServiceLine);
                    ServiceLine."Service Item Line No." := ServiceItemLine."Line No.";
                    ServiceLine."Service Item No." := ServiceItemLine."Service Item No.";
                    ServiceLine.Type := ServiceLine.Type::Item;

                    DestinationRecordRef.GetTable(ServiceLine);
                end;
            'FS Work Order Service-Service Line':
                begin
                    SourceRecordRef.SetTable(FSWorkOrderService);
                    DestinationRecordRef.SetTable(ServiceLine);

                    if ServiceLine."Document No." <> '' then
                        exit;

                    if CRMIntegrationRecord.FindByCRMID(FSWorkOrderService.WorkOrder) then
                        ServiceHeader.GetBySystemId(CRMIntegrationRecord."Integration ID");

                    ServiceLine."Document Type" := ServiceLine."Document Type"::Order;
                    ServiceLine."Document No." := ServiceHeader."No.";
                    ServiceLine."Line No." := GetNextLineNo(ServiceLine);
                    ServiceLine."Service Item Line No." := ServiceItemLine."Line No.";
                    ServiceLine."Service Item No." := ServiceItemLine."Service Item No.";
                    ServiceLine.Type := ServiceLine.Type::Item;

                    DestinationRecordRef.GetTable(ServiceLine);
                end;
            'FS Bookable Resource Booking-Service Line':
                begin
                    SourceRecordRef.SetTable(FSBookableResourceBooking);
                    DestinationRecordRef.SetTable(ServiceLine);

                    if ServiceLine."Document No." <> '' then
                        exit;

                    if CRMIntegrationRecord.FindByCRMID(FSBookableResourceBooking.WorkOrder) then
                        ServiceHeader.GetBySystemId(CRMIntegrationRecord."Integration ID");

                    ServiceLine."Document Type" := ServiceLine."Document Type"::Order;
                    ServiceLine."Document No." := ServiceHeader."No.";
                    ServiceLine."Line No." := GetNextLineNo(ServiceLine);
                    ServiceLine.Type := ServiceLine.Type::Resource;

                    DestinationRecordRef.GetTable(ServiceLine);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnAfterTransferRecordFields', '', true, false)]
    local procedure OnAfterTransferRecordFields(SourceRecordRef: RecordRef; var DestinationRecordRef: RecordRef; var AdditionalFieldsWereModified: Boolean)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        FSWorkOrderProduct: Record "FS Work Order Product";
        FSWorkOrderService: Record "FS Work Order Service";
        FSBookableResourceBooking: Record "FS Bookable Resource Booking";
        ServiceLine: Record "Service Line";
        SourceDestCode: Text;
    begin
        if not FSConnectionSetup.IsEnabled() then
            exit;

        SourceDestCode := GetSourceDestCode(SourceRecordRef, DestinationRecordRef);

        case SourceDestCode of
            'FS Work Order Product-Service Line':
                begin
                    SourceRecordRef.SetTable(FSWorkOrderProduct);
                    DestinationRecordRef.SetTable(ServiceLine);

                    UpdateQuantities(FSWorkOrderProduct, ServiceLine, false);
                    AdditionalFieldsWereModified := true;

                    SourceRecordRef.GetTable(FSWorkOrderProduct);
                    DestinationRecordRef.GetTable(ServiceLine);
                end;
            'Service Line-FS Work Order Product':
                begin
                    SourceRecordRef.SetTable(ServiceLine);
                    DestinationRecordRef.SetTable(FSWorkOrderProduct);

                    UpdateQuantities(FSWorkOrderProduct, ServiceLine, true);
                    AdditionalFieldsWereModified := true;

                    SourceRecordRef.GetTable(ServiceLine);
                    DestinationRecordRef.GetTable(FSWorkOrderProduct);
                end;

            'FS Work Order Service-Service Line':
                begin
                    SourceRecordRef.SetTable(FSWorkOrderService);
                    DestinationRecordRef.SetTable(ServiceLine);

                    UpdateQuantities(FSWorkOrderService, ServiceLine, false);
                    AdditionalFieldsWereModified := true;

                    SourceRecordRef.GetTable(FSWorkOrderService);
                    DestinationRecordRef.GetTable(ServiceLine);
                end;
            'Service Line-FS Work Order Service':
                begin
                    SourceRecordRef.SetTable(ServiceLine);
                    DestinationRecordRef.SetTable(FSWorkOrderService);

                    UpdateQuantities(FSWorkOrderService, ServiceLine, true);
                    AdditionalFieldsWereModified := true;

                    SourceRecordRef.GetTable(ServiceLine);
                    DestinationRecordRef.GetTable(FSWorkOrderService);
                end;

            'FS Bookable Resource Booking-Service Line':
                begin
                    SourceRecordRef.SetTable(FSBookableResourceBooking);
                    DestinationRecordRef.SetTable(ServiceLine);

                    UpdateQuantities(FSBookableResourceBooking, ServiceLine);
                    AdditionalFieldsWereModified := true;

                    DestinationRecordRef.GetTable(ServiceLine);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Record Synch.", 'OnTransferFieldData', '', true, false)]
    local procedure OnTransferFieldData(SourceFieldRef: FieldRef; DestinationFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        CRMIntegrationRecord: Record "CRM Integration Record";
        FSWorkOrder: Record "FS Work Order";
        FSWorkOrderService: Record "FS Work Order Service";
        FSWorkOrderProduct: Record "FS Work Order Product";
        FSBookableResourceBooking: Record "FS Bookable Resource Booking";
        JobJournalLine: Record "Job Journal Line";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        SourceRecordRef: RecordRef;
        DestinationRecordRef: RecordRef;
        NAVItemUomRecordId: RecordId;
        DurationInHours: Decimal;
        DurationInMinutes: Decimal;
        Quantity: Decimal;
        QuantityToTransferToInvoice: Decimal;
        QuantityCurrentlyConsumed: Decimal;
        QuantityCurrentlyInvoiced: Decimal;
        NotCoupledCRMUomErr: Label 'The unit is not coupled to a unit of measure.';
    begin
        if not FSConnectionSetup.IsEnabled() then
            exit;

        if IsValueFound then
            exit;

        if SourceFieldRef.Number() = DestinationFieldRef.Number() then
            if SourceFieldRef.Record().Number() = DestinationFieldRef.Record().Number() then
                exit;

        if (SourceFieldRef.Record().Number = Database::"Service Header") and
            (DestinationFieldRef.Record().Number = Database::"FS Work Order") then
            case DestinationFieldRef.Name() of
                FSWorkOrder.FieldName(SystemStatus):
                    begin
                        SourceFieldRef.Record().SetTable(ServiceHeader);
                        DestinationFieldRef.Record().SetTable(FSWorkOrder);
                        NewValue := FSWorkOrder.SystemStatus; // default -> no update
                        IsValueFound := true;
                        NeedsConversion := false;
                    end;
            end;
        if (SourceFieldRef.Record().Number = Database::"FS Work Order") and
            (DestinationFieldRef.Record().Number = Database::"Service Header") then
            case DestinationFieldRef.Name() of
                ServiceHeader.FieldName(Status):
                    begin
                        SourceFieldRef.Record().SetTable(FSWorkOrder);
                        DestinationFieldRef.Record().SetTable(ServiceHeader);

                        case FSWorkOrder.SystemStatus of
                            FSWorkOrder.SystemStatus::Unscheduled,
                            FSWorkOrder.SystemStatus::Scheduled:
                                NewValue := ServiceHeader.Status::Pending;
                            FSWorkOrder.SystemStatus::InProgress:
                                NewValue := ServiceHeader.Status::"In Process";
                            FSWorkOrder.SystemStatus::Completed:
                                NewValue := ServiceHeader.Status::Finished;
                            else
                                NewValue := ServiceHeader.Status; // default -> no update
                        end;

                        IsValueFound := true;
                        NeedsConversion := false;
                    end;
            end;

        if (SourceFieldRef.Record().Number = Database::"Service Line") and
            (DestinationFieldRef.Record().Number = Database::"FS Work Order Service") then
            case DestinationFieldRef.Name() of
                FSWorkOrderService.FieldName(DurationShipped):
                    begin
                        SourceRecordRef := SourceFieldRef.Record();
                        SourceRecordRef.SetTable(ServiceLine);
                        DurationInHours := ServiceLine."Quantity Shipped";
                        DurationInMinutes := DurationInHours * 60;
                        NewValue := DurationInMinutes;
                        IsValueFound := true;
                        NeedsConversion := false;
                    end;
                FSWorkOrderService.FieldName(DurationInvoiced):
                    begin
                        SourceRecordRef := SourceFieldRef.Record();
                        SourceRecordRef.SetTable(ServiceLine);
                        DurationInHours := ServiceLine."Quantity Invoiced";
                        DurationInMinutes := DurationInHours * 60;
                        NewValue := DurationInMinutes;
                        IsValueFound := true;
                        NeedsConversion := false;
                    end;
                FSWorkOrderService.FieldName(DurationConsumed):
                    begin
                        SourceRecordRef := SourceFieldRef.Record();
                        SourceRecordRef.SetTable(ServiceLine);
                        DurationInHours := ServiceLine."Quantity Consumed";
                        DurationInMinutes := DurationInHours * 60;
                        NewValue := DurationInMinutes;
                        IsValueFound := true;
                        NeedsConversion := false;
                    end;
            end;

        if (SourceFieldRef.Record().Number = Database::"FS Work Order") then
            case SourceFieldRef.Name() of
                FSWorkOrder.FieldName(CreatedOn):
                    begin
                        SourceRecordRef := SourceFieldRef.Record();
                        SourceRecordRef.SetTable(FSWorkOrder);
                        NewValue := DT2Date(FSWorkOrder.CreatedOn);
                        IsValueFound := true;
                        NeedsConversion := false;
                    end;
            end;

        if (SourceFieldRef.Record().Number = Database::"FS Work Order Service") then
            case SourceFieldRef.Name() of
                FSWorkOrderService.FieldName(EstimateDuration):
                    begin
                        SourceRecordRef := SourceFieldRef.Record();
                        SourceRecordRef.SetTable(FSWorkOrderService);
                        DurationInMinutes := FSWorkOrderService.EstimateDuration;
                        DurationInHours := (DurationInMinutes / 60);
                        NewValue := DurationInHours;
                        IsValueFound := true;
                        NeedsConversion := false;
                    end;
                FSWorkOrderService.FieldName(Duration),
                FSWorkOrderService.FieldName(DurationToBill):
                    begin
                        SourceRecordRef := SourceFieldRef.Record();
                        SourceRecordRef.SetTable(FSWorkOrderService);
                        if DestinationFieldRef.Record().Number = Database::"Job Journal Line" then
                            SetCurrentProjectPlanningQuantities(SourceRecordRef, QuantityCurrentlyConsumed, QuantityCurrentlyInvoiced);
                        if SourceFieldRef.Name() in [FSWorkOrderService.FieldName(Duration)] then begin
                            DurationInMinutes := FSWorkOrderService.Duration;
                            DurationInHours := (DurationInMinutes / 60);
                            NewValue := DurationInHours - QuantityCurrentlyConsumed;
                        end;
                        if SourceFieldRef.Name() = FSWorkOrderService.FieldName(DurationToBill) then begin
                            DurationInMinutes := FSWorkOrderService.DurationToBill;
                            DurationInHours := (DurationInMinutes / 60);
                            NewValue := DurationInHours - QuantityCurrentlyInvoiced;

                            if (DestinationFieldRef.Record().Number = Database::"Job Journal Line") then begin
                                DestinationRecordRef := DestinationFieldRef.Record();
                                DestinationRecordRef.SetTable(JobJournalLine);
                                if JobJournalLine."Line Type" in [JobJournalLine."Line Type"::Budget, JobJournalLine."Line Type"::" "] then
                                    NewValue := 0;
                            end;
                        end;
                        IsValueFound := true;
                        NeedsConversion := false;
                        exit;
                    end;
                FSWorkOrderService.FieldName(Description):
                    begin
                        if (DestinationFieldRef.Record().Number <> Database::"Job Journal Line") then
                            exit;

                        SourceRecordRef := SourceFieldRef.Record();
                        SourceRecordRef.SetTable(FSWorkOrderService);
                        DestinationRecordRef := DestinationFieldRef.Record();
                        DestinationRecordRef.SetTable(JobJournalLine);

                        if JobJournalLine.Type = JobJournalLine.Type::Resource then
                            if FSBookableResourceBooking.Get(FSWorkOrderService.Booking) then
                                if SourceFieldRef.Name() = FSWorkOrderService.FieldName(Description) then begin
                                    NewValue := FSBookableResourceBooking.Name;
                                    IsValueFound := true;
                                    NeedsConversion := false;
                                    exit;
                                end;

                        if JobJournalLine.Type = JobJournalLine.Type::Item then
                            if SourceFieldRef.Name() = FSWorkOrderService.FieldName(Description) then begin
                                NewValue := FSWorkOrderService.Name;
                                IsValueFound := true;
                                NeedsConversion := false;
                                exit;
                            end;
                    end;
            end;

        if (SourceFieldRef.Record().Number = Database::"FS Work Order Product") then
            case SourceFieldRef.Name() of
                FSWorkOrderProduct.FieldName(Quantity),
                FSWorkOrderProduct.FieldName(QtyToBill):
                    begin
                        SourceRecordRef := SourceFieldRef.Record();
                        SourceRecordRef.SetTable(FSWorkOrderProduct);
                        if DestinationFieldRef.Record().Number = Database::"Job Journal Line" then
                            SetCurrentProjectPlanningQuantities(SourceRecordRef, QuantityCurrentlyConsumed, QuantityCurrentlyInvoiced);
                        if SourceFieldRef.Name() = FSWorkOrderProduct.FieldName(Quantity) then begin
                            Quantity := FSWorkOrderProduct.Quantity - QuantityCurrentlyConsumed;
                            NewValue := Quantity;
                        end;
                        if SourceFieldRef.Name() = FSWorkOrderProduct.FieldName(QtyToBill) then begin
                            QuantityToTransferToInvoice := FSWorkOrderProduct.QtyToBill - QuantityCurrentlyInvoiced;
                            NewValue := QuantityToTransferToInvoice;
                        end;
                        IsValueFound := true;
                        NeedsConversion := false;
                        exit;
                    end;
                FSWorkOrderProduct.FieldName(Description):
                    begin
                        SourceRecordRef := SourceFieldRef.Record();
                        SourceRecordRef.SetTable(FSWorkOrderProduct);

                        NewValue := FSWorkOrderProduct.Name;
                        IsValueFound := true;
                        NeedsConversion := false;
                        exit;
                    end;
                FSWorkOrderProduct.FieldName(Unit):
                    begin
                        SourceRecordRef := SourceFieldRef.Record();
                        SourceRecordRef.SetTable(FSWorkOrderProduct);

                        if not CRMIntegrationRecord.FindRecordIDFromID(FSWorkOrderProduct.Unit, Database::"Item Unit of Measure", NAVItemUomRecordId) then
                            Error(NotCoupledCRMUomErr);

                        if not ItemUnitOfMeasure.Get(NAVItemUomRecordId) then
                            Error(NotCoupledCRMUomErr);

                        NewValue := ItemUnitOfMeasure.Code;
                        IsValueFound := true;
                        NeedsConversion := false;
                        exit;
                    end;
            end;
    end;

    internal procedure UpdateQuantities(var FSWorkOrderProduct: Record "FS Work Order Product"; var ServiceLine: Record "Service Line"; ToFieldService: Boolean)
    begin
        if FSWorkOrderProduct.LineStatus = FSWorkOrderProduct.LineStatus::Estimated then begin
            if ToFieldService then
                FSWorkOrderProduct.EstimateQuantity := ServiceLine.Quantity
            else
                ServiceLine.Validate(Quantity, FSWorkOrderProduct.EstimateQuantity);

            ServiceLine.Validate("Qty. to Ship", 0);
            ServiceLine.Validate("Qty. to Invoice", 0);
            ServiceLine.Validate("Qty. to Consume", 0);

            if ToFieldService then
                ServiceLine.Modify(true);
        end else begin
            ServiceLine.Validate(Quantity, GetMaxQuantity(FSWorkOrderProduct.Quantity, FSWorkOrderProduct.QtyToBill));
            ServiceLine.Validate("Qty. to Ship", GetMaxQuantity(FSWorkOrderProduct.Quantity, FSWorkOrderProduct.QtyToBill) - ServiceLine."Quantity Shipped");
            ServiceLine.Validate("Qty. to Invoice", FSWorkOrderProduct.QtyToBill - ServiceLine."Quantity Invoiced");
        end;
    end;

    internal procedure UpdateQuantities(var FSWorkOrderService: Record "FS Work Order Service"; var ServiceLine: Record "Service Line"; ToFieldService: Boolean)
    begin
        if FSWorkOrderService.LineStatus = FSWorkOrderService.LineStatus::Estimated then begin
            if ToFieldService then
                FSWorkOrderService.EstimateDuration := ServiceLine.Quantity * 60
            else
                ServiceLine.Validate(Quantity, FSWorkOrderService.EstimateDuration / 60);

            ServiceLine.Validate("Qty. to Ship", 0);
            ServiceLine.Validate("Qty. to Invoice", 0);
            ServiceLine.Validate("Qty. to Consume", 0);

            if ToFieldService then
                ServiceLine.Modify(true);
        end else begin
            ServiceLine.Validate(Quantity, GetMaxQuantity(FSWorkOrderService.Duration, FSWorkOrderService.DurationToBill) / 60);
            ServiceLine.Validate("Qty. to Ship", GetMaxQuantity(FSWorkOrderService.Duration, FSWorkOrderService.DurationToBill) / 60 - ServiceLine."Quantity Shipped");
            ServiceLine.Validate("Qty. to Invoice", FSWorkOrderService.DurationToBill / 60 - ServiceLine."Quantity Invoiced");
        end;
    end;

    internal procedure UpdateQuantities(FSBookableResourceBooking: Record "FS Bookable Resource Booking"; var ServiceLine: Record "Service Line")
    begin
        if ServiceLine."Qty. to Consume" <> 0 then
            ServiceLine.Validate("Qty. to Consume", 0);
        ServiceLine.Validate(Quantity, FSBookableResourceBooking.Duration / 60);
        ServiceLine.Validate("Qty. to Consume", ServiceLine.Quantity - ServiceLine."Quantity Consumed");
    end;

    procedure GetMaxQuantity(Quantity1: Decimal; Quantity2: Decimal): Decimal
    var
        MaxQuantity: Decimal;
    begin
        MaxQuantity := Quantity1;

        if Quantity2 > MaxQuantity then
            MaxQuantity := Quantity2;

        exit(MaxQuantity);
    end;

    procedure GetMaxQuantity(Quantity1: Decimal; Quantity2: Decimal; Quantity3: Decimal): Decimal
    var
        MaxQuantity: Decimal;
    begin
        MaxQuantity := Quantity1;

        if Quantity2 > MaxQuantity then
            MaxQuantity := Quantity2;

        if Quantity3 > MaxQuantity then
            MaxQuantity := Quantity3;

        exit(MaxQuantity);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CRM Int. Table. Subscriber", 'OnFindNewValueForCoupledRecordPK', '', true, false)]
    local procedure OnFindNewValueForCoupledRecordPK(IntegrationTableMapping: Record "Integration Table Mapping"; SourceFieldRef: FieldRef; DestinationFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        CRMIntegrationRecord: Record "CRM Integration Record";
        FSWorkOrderService: Record "FS Work Order Service";
        FSWorkOrderProduct: Record "FS Work Order Product";
        ServiceItemLine: Record "Service Item Line";
        ServiceLine: Record "Service Line";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        CRMUom: Record "CRM Uom";
        SourceRecordRef: RecordRef;
        NAVItemUomRecordId: RecordId;
        WorkOrderIncidentId: Guid;
        NAVItemUomId: Guid;
        NotCoupledCRMUomErr: Label 'The unit is not coupled to a unit of measure.';
    begin
        if not FSConnectionSetup.IsEnabled() then
            exit;

        if (SourceFieldRef.Record().Number = Database::"FS Work Order Product") and
            (DestinationFieldRef.Record().Number = Database::"Service Line") then
            case SourceFieldRef.Name() of
                FSWorkOrderProduct.FieldName(WorkOrderIncident):
                    begin
                        SourceFieldRef.Record().SetTable(FSWorkOrderProduct);
                        DestinationFieldRef.Record().SetTable(ServiceLine);
                        if CRMIntegrationRecord.FindByCRMID(FSWorkOrderProduct.WorkOrderIncident) then begin
                            ServiceItemLine.GetBySystemId(CRMIntegrationRecord."Integration ID");
                            NewValue := ServiceItemLine."Line No.";
                            IsValueFound := true;
                        end;
                    end;

                FSWorkOrderProduct.FieldName(Unit):
                    begin
                        SourceRecordRef := SourceFieldRef.Record();
                        SourceRecordRef.SetTable(FSWorkOrderProduct);

                        if not CRMIntegrationRecord.FindRecordIDFromID(FSWorkOrderProduct.Unit, Database::"Item Unit of Measure", NAVItemUomRecordId) then
                            Error(NotCoupledCRMUomErr);

                        if not ItemUnitOfMeasure.Get(NAVItemUomRecordId) then
                            Error(NotCoupledCRMUomErr);

                        NewValue := ItemUnitOfMeasure.Code;
                        IsValueFound := true;
                        exit;
                    end;
            end;
        if (SourceFieldRef.Record().Number = Database::"FS Work Order Service") and
            (DestinationFieldRef.Record().Number = Database::"Service Line") then
            case SourceFieldRef.Name() of
                FSWorkOrderProduct.FieldName(WorkOrderIncident):
                    begin
                        SourceFieldRef.Record().SetTable(FSWorkOrderService);
                        DestinationFieldRef.Record().SetTable(ServiceLine);
                        if CRMIntegrationRecord.FindByCRMID(FSWorkOrderService.WorkOrderIncident) then begin
                            ServiceItemLine.GetBySystemId(CRMIntegrationRecord."Integration ID");
                            NewValue := ServiceItemLine."Line No.";
                            IsValueFound := true;
                        end;
                    end;

                FSWorkOrderService.FieldName(Unit):
                    begin
                        SourceRecordRef := SourceFieldRef.Record();
                        SourceRecordRef.SetTable(FSWorkOrderService);

                        if not CRMIntegrationRecord.FindRecordIDFromID(FSWorkOrderService.Unit, Database::"Item Unit of Measure", NAVItemUomRecordId) then
                            Error(NotCoupledCRMUomErr);

                        if not ItemUnitOfMeasure.Get(NAVItemUomRecordId) then
                            Error(NotCoupledCRMUomErr);

                        NewValue := ItemUnitOfMeasure.Code;
                        IsValueFound := true;
                        exit;
                    end;
            end;

        if (SourceFieldRef.Record().Number = Database::"Service Line") and
            (DestinationFieldRef.Record().Number = Database::"FS Work Order Product") then
            case SourceFieldRef.Name() of
                ServiceLine.FieldName("Service Item Line No."):
                    begin
                        SourceFieldRef.Record().SetTable(ServiceLine);
                        if CRMIntegrationRecord.FindIDFromRecordID(GetServiceOrderItemLineRecordId(ServiceLine."Document No.", ServiceLine."Service Item Line No."), WorkOrderIncidentId) then begin
                            NewValue := WorkOrderIncidentId;
                            IsValueFound := true;
                        end;
                    end;
            end;

        if (SourceFieldRef.Record().Number = Database::"Service Line") and
            (DestinationFieldRef.Record().Number = Database::"FS Work Order Service") then
            case SourceFieldRef.Name() of
                ServiceLine.FieldName("Service Item Line No."):
                    begin
                        SourceFieldRef.Record().SetTable(ServiceLine);
                        if CRMIntegrationRecord.FindIDFromRecordID(GetServiceOrderItemLineRecordId(ServiceLine."Document No.", ServiceLine."Service Item Line No."), WorkOrderIncidentId) then begin
                            NewValue := WorkOrderIncidentId;
                            IsValueFound := true;
                        end;
                    end;
            end;

        if (SourceFieldRef.Record().Number = Database::"Service Line") and
            (DestinationFieldRef.Record().Number in [Database::"FS Work Order Product", Database::"FS Work Order Service"]) then
            case SourceFieldRef.Name() of
                ServiceLine.FieldName("Service Item Line No."):
                    begin
                        SourceFieldRef.Record().SetTable(ServiceLine);
                        if CRMIntegrationRecord.FindByCRMID(FSWorkOrderProduct.WorkOrderIncident) then begin
                            ServiceItemLine.GetBySystemId(CRMIntegrationRecord."Integration ID");
                            NewValue := ServiceItemLine."Line No.";
                            IsValueFound := true;
                        end;
                    end;
                ServiceLine.FieldName("Unit of Measure Code"):
                    begin
                        SourceRecordRef := SourceFieldRef.Record();
                        SourceRecordRef.SetTable(ServiceLine);

                        if not ItemUnitOfMeasure.Get(ServiceLine."No.", ServiceLine."Unit of Measure Code") then
                            Error(NotCoupledCRMUomErr);

                        if not CRMIntegrationRecord.FindIDFromRecordID(ItemUnitOfMeasure.RecordId, NAVItemUomId) then
                            Error(NotCoupledCRMUomErr);

                        if not CRMUom.Get(NAVItemUomId) then
                            Error(NotCoupledCRMUomErr);

                        NewValue := CRMUom.UoMId;
                        IsValueFound := true;
                        exit;
                    end;
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnAfterInsertRecord', '', true, false)]
    local procedure HandleOnAfterInsertRecord(SourceRecordRef: RecordRef; DestinationRecordRef: RecordRef)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        JobJournalLine: Record "Job Journal Line";
        BudgetJobJournalLine: Record "Job Journal Line";
        FSWorkOrderProduct: Record "FS Work Order Product";
        FSWorkOrderService: Record "FS Work Order Service";
        CRMIntegrationRecord: Record "CRM Integration Record";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
        JobUsageLink: Record "Job Usage Link";
        ArchivedServiceOrders: List of [Code[20]];
        SourceDestCode: Text;
    begin
        if not FSConnectionSetup.IsEnabled() then
            exit;

        SourceDestCode := GetSourceDestCode(SourceRecordRef, DestinationRecordRef);

        case SourceDestCode of
            'FS Work Order Product-Job Journal Line':
                begin
                    SourceRecordRef.SetTable(FSWorkOrderProduct);
                    DestinationRecordRef.SetTable(JobJournalLine);
                    ConditionallyPostJobJournalLine(FSConnectionSetup, FSWorkOrderProduct, JobJournalLine);
                end;
            'FS Work Order Service-Job Journal Line':
                begin
                    SourceRecordRef.SetTable(FSWorkOrderService);
                    DestinationRecordRef.SetTable(JobJournalLine);
                    BudgetJobJournalLine.ReadIsolation(IsolationLevel::ReadCommitted);
                    if BudgetJobJournalLine.Get(JobJournalLine."Journal Template Name", JobJournalLine."Journal Batch Name", JobJournalLine."Line No." - BudgetJobJournalLineNoOffset()) then
                        if BudgetJobJournalLine."Line Type" = BudgetJobJournalLine."Line Type"::Budget then
                            if not CRMIntegrationRecord.Get(FSWorkOrderService.WorkOrderServiceId, BudgetJobJournalLine.SystemId) then begin
                                // Budget job journal line is created in the OnBeforeInsertRecord subscriber. We must couple it here.
                                // If we try to couple it in the OnBeforeInsert subscriber, the synch engine will find it and just update the Integration Id with the other journal line's system id.
                                // We want to commit the coupling of the budget journal line before we attempt posting, because posting could fail and roll back the coupling of the budget line
                                CRMIntegrationRecord.InsertRecord(FSWorkOrderService.WorkOrderServiceId, BudgetJobJournalLine.SystemId, Database::"Job Journal Line");
                                Commit();
                            end;
                    ConditionallyPostJobJournalLine(FSConnectionSetup, FSWorkOrderService, JobJournalLine);
                end;
            'Sales Invoice Header-CRM Invoice':
                begin
                    SourceRecordRef.SetTable(SalesInvoiceHeader);
                    JobPlanningLineInvoice.ReadIsolation := JobPlanningLineInvoice.ReadIsolation::ReadCommitted;
                    JobPlanningLineInvoice.SetRange("Document Type", JobPlanningLineInvoice."Document Type"::"Posted Invoice");
                    JobPlanningLineInvoice.SetRange("Document No.", SalesInvoiceHeader."No.");
                    if JobPlanningLineInvoice.FindSet() then
                        repeat
                            JobUsageLink.SetRange("Job No.", JobPlanningLineInvoice."Job No.");
                            JobUsageLink.SetRange("Job Task No.", JobPlanningLineInvoice."Job Task No.");
                            JobUsageLink.SetRange("Line No.", JobPlanningLineInvoice."Job Planning Line No.");
                            if JobUsageLink.FindFirst() then
                                if not IsNullGuid(JobUsageLink."External Id") then
                                    if FSWorkorderProduct.Get(JobUsageLink."External Id") then begin
                                        FSWorkOrderProduct.QuantityInvoiced += JobPlanningLineInvoice."Quantity Transferred";
                                        if not FSWorkOrderProduct.Modify() then begin
                                            Session.LogMessage('0000MMV', UnableToModifyWOPTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                                            ClearLastError();
                                        end;
                                    end
                                    else
                                        if FSWorkorderService.Get(JobUsageLink."External Id") then begin
                                            FSWorkorderService.DurationInvoiced += (JobPlanningLineInvoice."Quantity Transferred" * 60);
                                            if not FSWorkOrderService.Modify() then begin
                                                Session.LogMessage('0000MMW', UnableToModifyWOSTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                                                ClearLastError();
                                            end;
                                        end;
                        until JobPlanningLineInvoice.Next() = 0;
                end;
            'FS Work Order-Service Header':
                begin
                    ValidateServiceHeaderAfterInsert(DestinationRecordRef);
                    ResetServiceOrderItemLineFromFSWorkOrderIncident(SourceRecordRef, DestinationRecordRef, ArchivedServiceOrders);
                    ResetServiceOrderLineFromFSWorkOrderProduct(SourceRecordRef, DestinationRecordRef, ArchivedServiceOrders);
                    ResetServiceOrderLineFromFSWorkOrderService(SourceRecordRef, DestinationRecordRef, ArchivedServiceOrders);
                    ResetServiceOrderLineFromFSBookableResourceBooking(SourceRecordRef, DestinationRecordRef, ArchivedServiceOrders);
                end;
            'Service Header-FS Work Order':
                begin
                    ResetFSWorkOrderIncidentFromServiceOrderItemLine(SourceRecordRef, DestinationRecordRef);
                    ResetFSWorkOrderProductFromServiceOrderLine(SourceRecordRef, DestinationRecordRef);
                    ResetFSWorkOrderServiceFromServiceOrderLine(SourceRecordRef, DestinationRecordRef);
                end;
        end;
    end;

    local procedure BudgetJobJournalLineNoOffset(): Integer
    begin
        // When a Work Order Service that has a coupled bookable resource is synchronized to BC
        // Two project journal lines are coupled: one billable line for the service item and one budget line for the resource
        // This is the offset number of the second line no. from the first line no.
        exit(37);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnBeforeIgnoreUnchangedRecordHandled', '', true, false)]
    local procedure HandleOnBeforeIgnoreUnchangedRecordHandled(SourceRecordRef: RecordRef; DestinationRecordRef: RecordRef)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        JobJournalLine: Record "Job Journal Line";
        FSWorkOrderProduct: Record "FS Work Order Product";
        FSWorkOrderService: Record "FS Work Order Service";
        ServiceHeader: Record "Service Header";
        ArchivedServiceOrders: List of [Code[20]];
        SourceDestCode: Text;
    begin
        if not FSConnectionSetup.IsEnabled() then
            exit;

        SourceDestCode := GetSourceDestCode(SourceRecordRef, DestinationRecordRef);

        case SourceDestCode of
            'FS Work Order Product-Job Journal Line':
                begin
                    SourceRecordRef.SetTable(FSWorkOrderProduct);
                    DestinationRecordRef.SetTable(JobJournalLine);
                    ConditionallyPostJobJournalLine(FSConnectionSetup, FSWorkOrderProduct, JobJournalLine);
                end;
            'FS Work Order Service-Job Journal Line':
                begin
                    SourceRecordRef.SetTable(FSWorkOrderService);
                    DestinationRecordRef.SetTable(JobJournalLine);
                    UpdateCorrelatedJobJournalLine(SourceRecordRef, DestinationRecordRef);
                    ConditionallyPostJobJournalLine(FSConnectionSetup, FSWorkOrderService, JobJournalLine);
                end;
            'FS Work Order-Service Header':
                begin
                    ResetServiceOrderItemLineFromFSWorkOrderIncident(SourceRecordRef, DestinationRecordRef, ArchivedServiceOrders);
                    ResetServiceOrderLineFromFSWorkOrderProduct(SourceRecordRef, DestinationRecordRef, ArchivedServiceOrders);
                    ResetServiceOrderLineFromFSWorkOrderService(SourceRecordRef, DestinationRecordRef, ArchivedServiceOrders);
                    ResetServiceOrderLineFromFSBookableResourceBooking(SourceRecordRef, DestinationRecordRef, ArchivedServiceOrders);
                end;
            'Service Header-FS Work Order':
                begin
                    ProofAllServiceItemLinesAssigned(ServiceHeader);
                    ResetFSWorkOrderIncidentFromServiceOrderItemLine(SourceRecordRef, DestinationRecordRef);
                    ResetFSWorkOrderProductFromServiceOrderLine(SourceRecordRef, DestinationRecordRef);
                    ResetFSWorkOrderServiceFromServiceOrderLine(SourceRecordRef, DestinationRecordRef);
                end;
        end;
    end;

    local procedure ProofAllServiceItemLinesAssigned(ServiceHeader: Record "Service Header")
    var
        ServiceLine: Record "Service Line";
    begin
        ServiceLine.SetRange("Document Type", ServiceLine."Document Type"::Order);
        ServiceLine.SetRange("Document No.", ServiceHeader."No.");
        ServiceLine.SetRange("Service Item Line No.", 0);
        if ServiceLine.FindFirst() then
            ServiceLine.TestField("Service Item Line No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnAfterUnchangedRecordHandled', '', true, false)]
    local procedure HandleOnAfterUnchangedRecordHandled(SourceRecordRef: RecordRef; DestinationRecordRef: RecordRef)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        ArchivedServiceOrders: List of [Code[20]];
        SourceDestCode: Text;
    begin
        if not FSConnectionSetup.IsEnabled() then
            exit;

        SourceDestCode := GetSourceDestCode(SourceRecordRef, DestinationRecordRef);

        case SourceDestCode of
            'FS Work Order-Service Header':
                begin
                    ResetServiceOrderItemLineFromFSWorkOrderIncident(SourceRecordRef, DestinationRecordRef, ArchivedServiceOrders);
                    ResetServiceOrderLineFromFSWorkOrderProduct(SourceRecordRef, DestinationRecordRef, ArchivedServiceOrders);
                    ResetServiceOrderLineFromFSWorkOrderService(SourceRecordRef, DestinationRecordRef, ArchivedServiceOrders);
                    ResetServiceOrderLineFromFSBookableResourceBooking(SourceRecordRef, DestinationRecordRef, ArchivedServiceOrders);
                end;
            'Service Header-FS Work Order':
                begin
                    ResetFSWorkOrderIncidentFromServiceOrderItemLine(SourceRecordRef, DestinationRecordRef);
                    ResetFSWorkOrderProductFromServiceOrderLine(SourceRecordRef, DestinationRecordRef);
                    ResetFSWorkOrderServiceFromServiceOrderLine(SourceRecordRef, DestinationRecordRef);
                end;
        end;
    end;

    local procedure ValidateServiceHeaderAfterInsert(DestinationRecordRef: RecordRef)
    var
        ServiceHeader: Record "Service Header";
    begin
        DestinationRecordRef.SetTable(ServiceHeader);
        ServiceHeader.Validate("Customer No."); // explicit recalculation, as InitRecord() was called after setting the customer
        ServiceHeader.Modify(true);
        DestinationRecordRef.GetTable(ServiceHeader);
    end;

    local procedure ResetServiceOrderItemLineFromFSWorkOrderIncident(SourceRecordRef: RecordRef; DestinationRecordRef: RecordRef; var ArchivedServiceOrders: List of [Code[20]])
    var
        ServiceHeader: Record "Service Header";
        ServiceItemLine: Record "Service Item Line";
        ServiceItemLineToDelete: Record "Service Item Line";
        CRMIntegrationRecord: Record "CRM Integration Record";
        FSWorkOrder: Record "FS Work Order";
        FSWorkOrderIncident: Record "FS Work Order Incident";
        FSWorkOrderIncident2: Record "FS Work Order Incident";
        CRMIntegrationTableSynch: Codeunit "CRM Integration Table Synch.";
        CRMSalesorderdetailRecordRef: RecordRef;
        CRMSalesorderdetailId: Guid;
        FSWorkOrderIncidentIdList: List of [Guid];
        FSWorkOrderIncidentIdFilter: Text;
    begin
        SourceRecordRef.SetTable(FSWorkOrder);
        DestinationRecordRef.SetTable(ServiceHeader);

        ServiceItemLine.SetRange("Document Type", ServiceItemLine."Document Type"::Order);
        ServiceItemLine.SetRange("Document No.", ServiceHeader."No.");
        if ServiceItemLine.FindSet() then
            repeat
                CRMIntegrationRecord.SetRange("Integration ID", ServiceItemLine.SystemId);
                CRMIntegrationRecord.SetRange("Table ID", Database::"Service Item Line");
                if CRMIntegrationRecord.FindFirst() then begin
                    FSWorkOrderIncident.SetRange(WorkOrderIncidentId, CRMIntegrationRecord."CRM ID");
                    if FSWorkOrderIncident.IsEmpty() then begin
                        CRMIntegrationRecord.Delete();
                        ArchiveServiceOrder(ServiceHeader, ArchivedServiceOrders);
                        if ServiceItemLineToDelete.GetBySystemId(ServiceItemLine.SystemId) then begin
                            DeleteServiceLines(ServiceItemLine);
                            ServiceItemLineToDelete.Delete(true);
                        end;
                    end;
                end;
            until ServiceItemLine.Next() = 0;

        FSWorkOrderIncident.Reset();
        FSWorkOrderIncident.SetRange(WorkOrder, FSWorkOrder.WorkOrderId);
        if FSWorkOrderIncident.FindSet() then begin
            repeat
                if not SkipReimport(FSWorkOrderIncident.WorkOrderIncidentId, FSWorkOrderIncident.ModifiedOn) then
                    FSWorkOrderIncidentIdList.Add(FSWorkOrderIncident.WorkOrderIncidentId)
            until FSWorkOrderIncident.Next() = 0;

            foreach CRMSalesorderdetailId in FSWorkOrderIncidentIdList do
                FSWorkOrderIncidentIdFilter += CRMSalesorderdetailId + '|';
            FSWorkOrderIncidentIdFilter := FSWorkOrderIncidentIdFilter.TrimEnd('|');

            FSWorkOrderIncident2.SetFilter(WorkOrderIncidentId, FSWorkOrderIncidentIdFilter);
            CRMSalesorderdetailRecordRef.GetTable(FSWorkOrderIncident2);
            CRMIntegrationTableSynch.SynchRecordsFromIntegrationTable(CRMSalesorderdetailRecordRef, Database::"Service Item Line", false, false);
        end;
    end;

    local procedure DeleteServiceLines(ServiceItemLine: Record "Service Item Line")
    var
        ServiceLine: Record "Service Line";
    begin
        ServiceLine.SetRange("Document Type", ServiceItemLine."Document Type");
        ServiceLine.SetRange("Document No.", ServiceItemLine."Document No.");
        ServiceLine.SetRange("Service Item Line No.", ServiceItemLine."Line No.");
        if not ServiceLine.IsEmpty() then
            ServiceLine.DeleteAll(true);
    end;

    local procedure ResetServiceOrderLineFromFSWorkOrderProduct(SourceRecordRef: RecordRef; DestinationRecordRef: RecordRef; var ArchivedServiceOrders: List of [Code[20]])
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        ServiceLineToDelete: Record "Service Line";
        CRMIntegrationRecord: Record "CRM Integration Record";
        FSWorkOrder: Record "FS Work Order";
        FSWorkOrderProduct: Record "FS Work Order Product";
        FSWorkOrderProduct2: Record "FS Work Order Product";
        CRMIntegrationTableSynch: Codeunit "CRM Integration Table Synch.";
        FSWorkOrderProductRecordRef: RecordRef;
        FSWorkOrderProductId: Guid;
        FSWorkOrderProductIdList: List of [Guid];
        FSWorkOrderProductIdFilter: Text;
    begin
        SourceRecordRef.SetTable(FSWorkOrder);
        DestinationRecordRef.SetTable(ServiceHeader);

        ServiceLine.SetRange("Document Type", ServiceLine."Document Type"::Order);
        ServiceLine.SetRange("Document No.", ServiceHeader."No.");
        ServiceLine.SetRange(Type, ServiceLine.Type::Item);
        ServiceLine.SetFilter("Item Type", '%1|%2', ServiceLine."Item Type"::Inventory, ServiceLine."Item Type"::"Non-Inventory");
        if ServiceLine.FindSet() then
            repeat
                CRMIntegrationRecord.SetRange("Integration ID", ServiceLine.SystemId);
                CRMIntegrationRecord.SetRange("Table ID", Database::"Service Line");
                if CRMIntegrationRecord.FindFirst() then begin
                    FSWorkOrderProduct.SetRange(WorkOrderProductId, CRMIntegrationRecord."CRM ID");
                    if FSWorkOrderProduct.IsEmpty() then begin
                        CRMIntegrationRecord.Delete();
                        ArchiveServiceOrder(ServiceHeader, ArchivedServiceOrders);
                        if ServiceLineToDelete.GetBySystemId(ServiceLine.SystemId) then
                            ServiceLineToDelete.Delete(true);
                    end;
                end;
            until ServiceLine.Next() = 0;

        FSWorkOrderProduct.Reset();
        FSWorkOrderProduct.SetRange(WorkOrder, FSWorkOrder.WorkOrderId);
        if FSWorkOrderProduct.FindSet() then begin
            repeat
                if not SkipReimport(FSWorkOrderProduct.WorkOrderProductId, FSWorkOrderProduct.ModifiedOn) then
                    FSWorkOrderProductIdList.Add(FSWorkOrderProduct.WorkOrderProductId);
            until FSWorkOrderProduct.Next() = 0;

            foreach FSWorkOrderProductId in FSWorkOrderProductIdList do
                FSWorkOrderProductIdFilter += FSWorkOrderProductId + '|';
            FSWorkOrderProductIdFilter := FSWorkOrderProductIdFilter.TrimEnd('|');

            FSWorkOrderProduct2.SetFilter(WorkOrderProductId, FSWorkOrderProductIdFilter);
            FSWorkOrderProductRecordRef.GetTable(FSWorkOrderProduct2);
            CRMIntegrationTableSynch.SynchRecordsFromIntegrationTable(FSWorkOrderProductRecordRef, Database::"Service Line", false, false);
        end;
    end;

    local procedure ResetServiceOrderLineFromFSWorkOrderService(SourceRecordRef: RecordRef; DestinationRecordRef: RecordRef; var ArchivedServiceOrders: List of [Code[20]])
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        ServiceLineToDelete: Record "Service Line";
        CRMIntegrationRecord: Record "CRM Integration Record";
        FSWorkOrder: Record "FS Work Order";
        FSWorkOrderService: Record "FS Work Order Service";
        FSWorkOrderService2: Record "FS Work Order Service";
        CRMIntegrationTableSynch: Codeunit "CRM Integration Table Synch.";
        FSWorkOrderServiceRecordRef: RecordRef;
        FSWorkOrderServiceId: Guid;
        FSWorkOrderServiceIdList: List of [Guid];
        FSWorkOrderServiceIdFilter: Text;
    begin
        SourceRecordRef.SetTable(FSWorkOrder);
        DestinationRecordRef.SetTable(ServiceHeader);

        ServiceLine.SetRange("Document Type", ServiceLine."Document Type"::Order);
        ServiceLine.SetRange("Document No.", ServiceHeader."No.");
        ServiceLine.SetRange(Type, ServiceLine.Type::Item);
        ServiceLine.SetRange("Item Type", ServiceLine."Item Type"::Service);
        if ServiceLine.FindSet() then
            repeat
                CRMIntegrationRecord.SetRange("Integration ID", ServiceLine.SystemId);
                CRMIntegrationRecord.SetRange("Table ID", Database::"Service Line");
                if CRMIntegrationRecord.FindFirst() then begin
                    FSWorkOrderService.SetRange(WorkOrderServiceId, CRMIntegrationRecord."CRM ID");
                    if FSWorkOrderService.IsEmpty() then begin
                        CRMIntegrationRecord.Delete();
                        ArchiveServiceOrder(ServiceHeader, ArchivedServiceOrders);
                        if ServiceLineToDelete.GetBySystemId(ServiceLine.SystemId) then
                            ServiceLineToDelete.Delete(true);
                    end;
                end;
            until ServiceLine.Next() = 0;

        FSWorkOrderService.Reset();
        FSWorkOrderService.SetRange(WorkOrder, FSWorkOrder.WorkOrderId);
        if FSWorkOrderService.FindSet() then begin
            repeat
                if not SkipReimport(FSWorkOrderService.WorkOrderServiceId, FSWorkOrderService.ModifiedOn) then
                    FSWorkOrderServiceIdList.Add(FSWorkOrderService.WorkOrderServiceId);
            until FSWorkOrderService.Next() = 0;

            foreach FSWorkOrderServiceId in FSWorkOrderServiceIdList do
                FSWorkOrderServiceIdFilter += FSWorkOrderServiceId + '|';
            FSWorkOrderServiceIdFilter := FSWorkOrderServiceIdFilter.TrimEnd('|');

            FSWorkOrderService2.SetFilter(WorkOrderServiceId, FSWorkOrderServiceIdFilter);
            FSWorkOrderServiceRecordRef.GetTable(FSWorkOrderService2);
            CRMIntegrationTableSynch.SynchRecordsFromIntegrationTable(FSWorkOrderServiceRecordRef, Database::"Service Line", false, false);
        end;
    end;

    local procedure ResetServiceOrderLineFromFSBookableResourceBooking(SourceRecordRef: RecordRef; DestinationRecordRef: RecordRef; var ArchivedServiceOrders: List of [Code[20]])
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        ServiceLineToDelete: Record "Service Line";
        CRMIntegrationRecord: Record "CRM Integration Record";
        FSWorkOrder: Record "FS Work Order";
        FSBookableResourceBooking: Record "FS Bookable Resource Booking";
        FSBookableResourceBooking2: Record "FS Bookable Resource Booking";
        CRMIntegrationTableSynch: Codeunit "CRM Integration Table Synch.";
        FSIntegrationMgt: Codeunit "FS Integration Mgt.";
        FSBookableResourceBookingRecordRef: RecordRef;
        FSBookableResourceBookingId: Guid;
        FSBookableResourceBookingIdList: List of [Guid];
        FSBookableResourceBookingIdFilter: Text;
    begin
        SourceRecordRef.SetTable(FSWorkOrder);
        DestinationRecordRef.SetTable(ServiceHeader);

        ServiceLine.SetRange("Document Type", ServiceLine."Document Type"::Order);
        ServiceLine.SetRange("Document No.", ServiceHeader."No.");
        ServiceLine.SetRange(Type, ServiceLine.Type::Resource);
        if ServiceLine.FindSet() then
            repeat
                CRMIntegrationRecord.SetRange("Integration ID", ServiceLine.SystemId);
                CRMIntegrationRecord.SetRange("Table ID", Database::"Service Line");
                if CRMIntegrationRecord.FindFirst() then begin
                    FSBookableResourceBooking.SetRange(BookableResourceBookingId, CRMIntegrationRecord."CRM ID");
                    if FSBookableResourceBooking.IsEmpty() then begin
                        CRMIntegrationRecord.Delete();
                        ArchiveServiceOrder(ServiceHeader, ArchivedServiceOrders);
                        if ServiceLineToDelete.GetBySystemId(ServiceLine.SystemId) then begin
                            DeleteServiceItemLineForBooking(ServiceLine);
                            ServiceLineToDelete.Delete(true);
                        end;
                    end;
                end;
            until ServiceLine.Next() = 0;

        FSBookableResourceBooking.Reset();
        FSBookableResourceBooking.SetRange(WorkOrder, FSWorkOrder.WorkOrderId);
        FSBookableResourceBooking.SetRange(BookingStatus, FSIntegrationMgt.GetBookingStatusCompleted());
        if FSBookableResourceBooking.FindSet() then begin
            repeat
                if not SkipReimport(FSBookableResourceBooking.BookableResourceBookingId, FSBookableResourceBooking.ModifiedOn) then
                    FSBookableResourceBookingIdList.Add(FSBookableResourceBooking.BookableResourceBookingId);
            until FSBookableResourceBooking.Next() = 0;

            foreach FSBookableResourceBookingId in FSBookableResourceBookingIdList do
                FSBookableResourceBookingIdFilter += FSBookableResourceBookingId + '|';
            FSBookableResourceBookingIdFilter := FSBookableResourceBookingIdFilter.TrimEnd('|');

            FSBookableResourceBooking2.SetFilter(BookableResourceBookingId, FSBookableResourceBookingIdFilter);
            FSBookableResourceBookingRecordRef.GetTable(FSBookableResourceBooking2);
            CRMIntegrationTableSynch.SynchRecordsFromIntegrationTable(FSBookableResourceBookingRecordRef, Database::"Service Line", false, false);
        end;
    end;

    local procedure SkipReimport(CRMId: Guid; CurrentModifyTimeStamp: DateTime): Boolean
    var
        CRMIntegrationRecord: Record "CRM Integration Record";
    begin
        // check if skipped (because of deletion)
        CRMIntegrationRecord.SetRange("CRM ID", CRMId);
        if not CRMIntegrationRecord.FindFirst() then
            exit(false);
        if not CRMIntegrationRecord."Skip Reimport" then
            exit(false);
        if (CRMIntegrationRecord."Skip Reimport") and (CRMIntegrationRecord."Last Synch. Modified On" > CurrentModifyTimeStamp) then
            exit(true);

        CRMIntegrationRecord.Delete(); // there was an update in field service -> start import again with new coupling
        exit(false);
    end;

    local procedure ResetFSWorkOrderIncidentFromServiceOrderItemLine(SourceRecordRef: RecordRef; DestinationRecordRef: RecordRef)
    var
        ServiceHeader: Record "Service Header";
        FSWorkOrder: Record "FS Work Order";
        ServiceItemLine: Record "Service Item Line";
        CRMIntegrationTableSynch: Codeunit "CRM Integration Table Synch.";
        ServiceItemLineRecordRef: RecordRef;
    begin
        SourceRecordRef.SetTable(ServiceHeader);
        DestinationRecordRef.SetTable(FSWorkOrder);

        ServiceItemLine.SetRange("Document Type", ServiceHeader."Document Type");
        ServiceItemLine.SetRange("Document No.", ServiceHeader."No.");
        ServiceItemLine.SetRange("FS Bookings", false);
        if not ServiceItemLine.IsEmpty() then begin
            ServiceItemLineRecordRef.GetTable(ServiceItemLine);
            CRMIntegrationTableSynch.SynchRecordsToIntegrationTable(ServiceItemLineRecordRef, false, false);
        end;
    end;

    local procedure ResetFSWorkOrderProductFromServiceOrderLine(SourceRecordRef: RecordRef; DestinationRecordRef: RecordRef)
    var
        ServiceHeader: Record "Service Header";
        FSWorkOrder: Record "FS Work Order";
        ServiceLine: Record "Service Line";
        ServiceLineRecordRef: RecordRef;
    begin
        SourceRecordRef.SetTable(ServiceHeader);
        DestinationRecordRef.SetTable(FSWorkOrder);

        ServiceLine.Reset();
        ServiceLine.SetRange("Document Type", ServiceHeader."Document Type");
        ServiceLine.SetRange("Document No.", ServiceHeader."No.");
        ServiceLine.SetRange("Type", ServiceLine.Type::Item);
        ServiceLine.SetFilter("Item Type", '%1|%2', ServiceLine."Item Type"::Inventory, ServiceLine."Item Type"::"Non-Inventory");
        if not ServiceLine.IsEmpty() then begin
            ServiceLineRecordRef.GetTable(ServiceLine);
            SynchRecordsToIntegrationTable(ServiceLineRecordRef, Database::"FS Work Order Product", false, false);
        end;
    end;

    local procedure ResetFSWorkOrderServiceFromServiceOrderLine(SourceRecordRef: RecordRef; DestinationRecordRef: RecordRef)
    var
        ServiceHeader: Record "Service Header";
        FSWorkOrder: Record "FS Work Order";
        ServiceLine: Record "Service Line";
        ServiceLineRecordRef: RecordRef;
    begin
        SourceRecordRef.SetTable(ServiceHeader);
        DestinationRecordRef.SetTable(FSWorkOrder);

        ServiceLine.Reset();
        ServiceLine.SetRange("Document Type", ServiceHeader."Document Type");
        ServiceLine.SetRange("Document No.", ServiceHeader."No.");
        ServiceLine.SetRange("Type", ServiceLine.Type::Item);
        ServiceLine.SetRange("Item Type", ServiceLine."Item Type"::Service);
        if not ServiceLine.IsEmpty() then begin
            ServiceLineRecordRef.GetTable(ServiceLine);
            SynchRecordsToIntegrationTable(ServiceLineRecordRef, Database::"FS Work Order Service", false, false);
        end;
    end;

    procedure SynchRecordsToIntegrationTable(var RecordsToSynchRecordRef: RecordRef; TargetTable: Integer; IgnoreChanges: Boolean; IgnoreSynchOnlyCoupledRecords: Boolean) JobID: Guid
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationTableSynch: Codeunit "Integration Table Synch.";
        IntegrationRecordRef: RecordRef;
        SynchronizeEmptySetErr: Label 'Attempted to synchronize an empty set of records.';
    begin
        IntegrationTableMapping.SetRange("Table ID", RecordsToSynchRecordRef.Number);
        IntegrationTableMapping.SetRange("Integration Table ID", TargetTable);
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        if not IntegrationTableMapping.FindFirst() then
            Error(SynchronizeEmptySetErr);

        RecordsToSynchRecordRef.Ascending(false);
        if not RecordsToSynchRecordRef.FindSet() then
            Error(SynchronizeEmptySetErr);

        JobID :=
          IntegrationTableSynch.BeginIntegrationSynchJob(
            TableConnectionType::CRM, IntegrationTableMapping, RecordsToSynchRecordRef.Number);
        if not IsNullGuid(JobID) then begin
            repeat
                IntegrationTableSynch.Synchronize(RecordsToSynchRecordRef, IntegrationRecordRef, IgnoreChanges, IgnoreSynchOnlyCoupledRecords)
            until RecordsToSynchRecordRef.Next() = 0;
            IntegrationTableSynch.EndIntegrationSynchJob();
        end;
    end;

    internal procedure ArchiveServiceOrder(ServiceHeader: Record "Service Header"; ArchivedServiceOrders: List of [Code[20]])
    var
        ServiceMgtSetup: Record "Service Mgt. Setup";
        ServiceDocumentArchiveMgmt: Codeunit "Service Document Archive Mgmt.";
    begin
        if ArchivedServiceOrders.Contains(ServiceHeader."No.") then
            exit;

        ServiceMgtSetup.Get();
        if not ServiceMgtSetup."Archive Orders" then
            exit;

        ArchivedServiceOrders.Add(ServiceHeader."No.");
        ServiceDocumentArchiveMgmt.ArchServiceDocumentNoConfirm(ServiceHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnBeforeModifyRecord', '', true, false)]
    local procedure HandleOnBeforeModifyRecord(IntegrationTableMapping: Record "Integration Table Mapping"; SourceRecordRef: RecordRef; var DestinationRecordRef: RecordRef)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        ServiceHeader: Record "Service Header";
        SourceDestCode: Text;
    begin
        if not FSConnectionSetup.IsEnabled() then
            exit;

        SourceDestCode := GetSourceDestCode(SourceRecordRef, DestinationRecordRef);

        case SourceDestCode of
            'FS Work Order Service-Job Journal Line':
                UpdateCorrelatedJobJournalLine(SourceRecordRef, DestinationRecordRef);
            'Service Header-FS Work Order':
                begin
                    SourceRecordRef.SetTable(ServiceHeader);
                    ProofAllServiceItemLinesAssigned(ServiceHeader);
                    SetCompanyId(DestinationRecordRef);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnUpdateIntegrationRecordCoupling', '', true, false)]
    local procedure HandleOnUpdateIntegrationRecordCoupling(IntegrationTableMapping: Record "Integration Table Mapping"; SourceRecordRef: RecordRef; var DestinationRecordRef: RecordRef)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        ServiceHeader: Record "Service Header";
        SourceDestCode: Text;
    begin
        if not FSConnectionSetup.IsEnabled() then
            exit;

        SourceDestCode := GetSourceDestCode(SourceRecordRef, DestinationRecordRef);

        case SourceDestCode of
            'Service Header-FS Work Order':
                begin
                    SourceRecordRef.SetTable(ServiceHeader);
                    ProofAllServiceItemLinesAssigned(ServiceHeader);
                    SetCompanyId(DestinationRecordRef);
                end;
        end;
    end;


    [EventSubscriber(ObjectType::Table, Database::"Inventory Setup", 'OnAfterValidateEvent', 'Location Mandatory', false, false)]
    local procedure AfterValidateLocationMandatory(var Rec: Record "Inventory Setup"; var xRec: Record "Inventory Setup"; CurrFieldNo: Integer)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        ProjectJournalLine: Record "Job Journal Line";
        FSSetupDefaults: Codeunit "FS Setup Defaults";
    begin
        if not Rec."Location Mandatory" then
            exit;

        if not FSConnectionSetup.IsEnabled() then
            exit;

        if not IntegrationTableMapping.Get('LOCATION') then
            FSSetupDefaults.ResetLocationMapping(FSConnectionSetup, 'LOCATION', true, true);

        IntegrationFieldMapping.SetFilter("Integration Table Mapping Name", 'PJLINE-WORDERPRODUCT');
        IntegrationFieldMapping.SetRange("Field No.", ProjectJournalLine.FieldNo("Location Code"));
        if IntegrationFieldMapping.IsEmpty() then begin
            FSSetupDefaults.SetLocationFieldMapping(true);
            FSSetupDefaults.ResetProjectJournalLineWOProductMapping(FSConnectionSetup, 'PJLINE-WORDERPRODUCT', true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CRM Setup Defaults", 'OnResetItemProductMappingOnAfterInsertFieldsMapping', '', false, false)]
    local procedure AddFieldServiceProductTypeFieldMapping(var Sender: Codeunit "CRM Setup Defaults"; IntegrationTableMappingName: Code[20])
    var
        FSConnectionSetup: Record "FS Connection Setup";
        Item: Record Item;
        CRMProduct: Record "CRM Product";
        IntegrationFieldMapping: Record "Integration Field Mapping";
    begin
        if not FSConnectionSetup.IsEnabled() then
            exit;

        // Type > Field Service Product Type
        Sender.InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          Item.FieldNo(Type),
          CRMProduct.FieldNo(FieldServiceProductType),
          IntegrationFieldMapping.Direction::ToIntegrationTable,
          '', false, false);
    end;

    local procedure UpdateCorrelatedJobJournalLine(var SourceRecordRef: RecordRef; var DestinationRecordRef: RecordRef)
    var
        JobJournalLine: Record "Job Journal Line";
        FSWorkOrderService: Record "FS Work Order Service";
        CorrelatedJobJournalLine: Record "Job Journal Line";
        CRMIntegrationRecord: Record "CRM Integration Record";
        CorrelatedJobJournalLineId: Guid;
        QuantityCurrentlyConsumed: Decimal;
        QuantityCurrentlyInvoiced: Decimal;
        DurationInHours: Decimal;
    begin
        // Work Order Services with coupled bookable resources couple to two Project Journal Lines: one budget (for the resource) and the other billable (for the item of type service)
        // Scheduled delta synch updates only one of them (that is how it is designed, it finds the first coupled one)
        // Therefore, we must find the other correlated line and update it here 
        SourceRecordRef.SetTable(FSWorkOrderService);
        DestinationRecordRef.SetTable(JobJournalLine);
        SetCurrentProjectPlanningQuantities(SourceRecordRef, QuantityCurrentlyConsumed, QuantityCurrentlyInvoiced);
        CRMIntegrationRecord.SetRange("Table ID", Database::"Job Journal Line");
        CRMIntegrationRecord.SetRange("CRM ID", FSWorkOrderService.WorkOrderServiceId);
        if CRMIntegrationRecord.FindSet() then
            repeat
                if CRMIntegrationRecord."Integration ID" <> JobJournalLine.SystemId then
                    CorrelatedJobJournalLineId := CRMIntegrationRecord."Integration ID";
            until CRMIntegrationRecord.Next() = 0;

        if IsNullGuid(CorrelatedJobJournalLineId) then
            exit;

        if not CorrelatedJobJournalLine.GetBySystemId(CorrelatedJobJournalLineId) then
            exit;

        DurationInHours := FSWorkOrderService.Duration;
        DurationInHours := (DurationInHours / 60);
        DurationInHours := DurationInHours - QuantityCurrentlyConsumed;
        if (CorrelatedJobJournalLine.Quantity <> DurationInHours) then begin
            CorrelatedJobJournalLine.Quantity := DurationInHours;
            CorrelatedJobJournalLine.Modify();
        end;

        case CorrelatedJobJournalLine."Line Type" of
            CorrelatedJobJournalLine."Line Type"::Budget,
            CorrelatedJobJournalLine."Line Type"::" ":
                if CorrelatedJobJournalLine."Qty. to Transfer to Invoice" <> 0 then begin
                    CorrelatedJobJournalLine."Qty. to Transfer to Invoice" := 0;
                    CorrelatedJobJournalLine.Modify();
                end;
            CorrelatedJobJournalLine."Line Type"::Billable,
            CorrelatedJobJournalLine."Line Type"::"Both Budget and Billable":
                begin
                    DurationInHours := FSWorkOrderService.DurationToBill;
                    DurationInHours := (DurationInHours / 60);
                    DurationInHours := DurationInHours - QuantityCurrentlyInvoiced;
                    if CorrelatedJobJournalLine."Qty. to Transfer to Invoice" <> DurationInHours then begin
                        CorrelatedJobJournalLine."Qty. to Transfer to Invoice" := DurationInHours;
                        CorrelatedJobJournalLine.Modify();
                    end;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnAfterModifyRecord', '', true, false)]
    local procedure HandleOnAfterModifyRecord(IntegrationTableMapping: Record "Integration Table Mapping"; var SourceRecordRef: RecordRef; var DestinationRecordRef: RecordRef)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        JobJournalLine: Record "Job Journal Line";
        FSWorkOrderProduct: Record "FS Work Order Product";
        FSWorkOrderService: Record "FS Work Order Service";
        ArchivedServiceOrders: List of [Code[20]];
        SourceDestCode: Text;
    begin
        if not FSConnectionSetup.IsEnabled() then
            exit;

        SourceDestCode := GetSourceDestCode(SourceRecordRef, DestinationRecordRef);

        case SourceDestCode of
            'FS Work Order Product-Job Journal Line':
                begin
                    SourceRecordRef.SetTable(FSWorkOrderProduct);
                    DestinationRecordRef.SetTable(JobJournalLine);
                    ConditionallyPostJobJournalLine(FSConnectionSetup, FSWorkOrderProduct, JobJournalLine);
                end;
            'FS Work Order Service-Job Journal Line':
                begin
                    SourceRecordRef.SetTable(FSWorkOrderService);
                    DestinationRecordRef.SetTable(JobJournalLine);
                    ConditionallyPostJobJournalLine(FSConnectionSetup, FSWorkOrderService, JobJournalLine);
                end;
            'FS Work Order-Service Header':
                begin
                    ResetServiceOrderItemLineFromFSWorkOrderIncident(SourceRecordRef, DestinationRecordRef, ArchivedServiceOrders);
                    ResetServiceOrderLineFromFSWorkOrderProduct(SourceRecordRef, DestinationRecordRef, ArchivedServiceOrders);
                    ResetServiceOrderLineFromFSWorkOrderService(SourceRecordRef, DestinationRecordRef, ArchivedServiceOrders);
                    ResetServiceOrderLineFromFSBookableResourceBooking(SourceRecordRef, DestinationRecordRef, ArchivedServiceOrders);
                end;
            'Service Header-FS Work Order':
                begin
                    ResetFSWorkOrderIncidentFromServiceOrderItemLine(SourceRecordRef, DestinationRecordRef);
                    ResetFSWorkOrderProductFromServiceOrderLine(SourceRecordRef, DestinationRecordRef);
                    ResetFSWorkOrderServiceFromServiceOrderLine(SourceRecordRef, DestinationRecordRef);
                end;
        end;
    end;

    local procedure ConditionallyPostJobJournalLine(var FSConnectionSetup: Record "FS Connection Setup"; var FSWorkOrderProduct: Record "FS Work Order Product"; var JobJournalLine: Record "Job Journal Line")
    var
        JobJnlPostLine: Codeunit "Job Jnl.-Post Line";
    begin
        case FSConnectionSetup."Line Post Rule" of
            "FS Work Order Line Post Rule"::LineUsed:
                if FSWorkOrderProduct.LineStatus = FSWorkOrderProduct.LineStatus::Used then begin
                    JobJnlPostLine.RunWithCheck(JobJournalLine);
                    JobJournalLine.Delete(true);
                end;
            "FS Work Order Line Post Rule"::WorkOrderCompleted:
                if FSWorkOrderProduct.WorkOrderStatus in [FSWorkOrderProduct.WorkOrderStatus::Completed] then begin
                    JobJnlPostLine.RunWithCheck(JobJournalLine);
                    JobJournalLine.Delete(true);
                end;
            else
                exit;
        end;
    end;

    local procedure ConditionallyPostJobJournalLine(var FSConnectionSetup: Record "FS Connection Setup"; var FSWorkOrderService: Record "FS Work Order Service"; var JobJournalLine: Record "Job Journal Line")
    begin
        case FSConnectionSetup."Line Post Rule" of
            "FS Work Order Line Post Rule"::LineUsed:
                if FSWorkOrderService.LineStatus = FSWorkOrderService.LineStatus::Used then
                    PostJobJournalLine(FSWorkOrderService, JobJournalLine);
            "FS Work Order Line Post Rule"::WorkOrderCompleted:
                if FSWorkOrderService.WorkOrderStatus in [FSWorkOrderService.WorkOrderStatus::Completed] then
                    PostJobJournalLine(FSWorkOrderService, JobJournalLine);
            else
                exit;
        end;
    end;

    local procedure PostJobJournalLine(var FSWorkOrderService: Record "FS Work Order Service"; var JobJournalLine: Record "Job Journal Line")
    var
        CRMIntegrationRecord: Record "CRM Integration Record";
        CorrelatedJobJournalLine: Record "Job Journal Line";
        JobJnlPostLine: Codeunit "Job Jnl.-Post Line";
        JobJournalLineId: Guid;
    begin
        JobJournalLineId := JobJournalLine.SystemId;
        JobJnlPostLine.RunWithCheck(JobJournalLine);
        JobJournalLine.Delete(true);

        // Work Order Services couple to two Project Journal Lines (one budget line for the resource and one billable line for the item of type service)
        // we must find the other coupled lines and post them as well.
        CRMIntegrationRecord.SetRange("Table ID", Database::"Job Journal Line");
        CRMIntegrationRecord.SetRange("CRM ID", FSWorkOrderService.WorkOrderServiceId);
        if CRMIntegrationRecord.FindSet() then
            repeat
                if CRMIntegrationRecord."Integration ID" <> JobJournalLineId then
                    if CorrelatedJobJournalLine.GetBySystemId(CRMIntegrationRecord."Integration ID") then begin
                        JobJnlPostLine.RunWithCheck(CorrelatedJobJournalLine);
                        CorrelatedJobJournalLine.Delete(true);
                    end;
            until CRMIntegrationRecord.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnBeforeInsertRecord', '', true, false)]
    local procedure HandleOnBeforeInsertRecord(SourceRecordRef: RecordRef; DestinationRecordRef: RecordRef)
    var
        FSProjectTask: Record "FS Project Task";
        Customer: Record Customer;
        CRMIntegrationRecord: Record "CRM Integration Record";
        Job: Record Job;
        JobTask: Record "Job Task";
        JobJournalLine: Record "Job Journal Line";
        FSConnectionSetup: Record "FS Connection Setup";
        JobJournalBatch: Record "Job Journal Batch";
        JobJournalTemplate: Record "Job Journal Template";
        Resource: Record Resource;
        FSBookableResource: Record "FS Bookable Resource";
        LastJobJournalLine: Record "Job Journal Line";
        FSWorkOrderIncident: Record "FS Work Order Incident";
        FSWorkOrderProduct: Record "FS Work Order Product";
        FSWorkOrderService: Record "FS Work Order Service";
        ServiceHeader: Record "Service Header";
        ServiceItemLine: Record "Service Item Line";
        ServiceLine: Record "Service Line";
        CRMProductName: Codeunit "CRM Product Name";
        FSIntegrationMgt: Codeunit "FS Integration Mgt.";
        RecID: RecordId;
        SourceDestCode: Text;
        BillingAccId: Guid;
        ServiceAccId: Guid;
        WorkOrderId: Guid;
        Handled: Boolean;
    begin
        if not FSConnectionSetup.IsEnabled() then
            exit;

        SourceDestCode := GetSourceDestCode(SourceRecordRef, DestinationRecordRef);

        case SourceDestCode of
            'Location-FS Warehouse':
                SetCompanyId(DestinationRecordRef);
            'Service Item-FS Customer Asset':
                SetCompanyId(DestinationRecordRef);
            'FS Customer Asset-Service Item':
                begin
                    SetCompanyId(SourceRecordRef);
                    SourceRecordRef.Modify()
                end;
            'Resource-FS Bookable Resource':
                begin
                    SetCompanyId(DestinationRecordRef);
                    SourceRecordRef.SetTable(Resource);
                    DestinationRecordRef.SetTable(FSBookableResource);
                    FSBookableResource.TimeZone := 92;
                    case Resource.Type of
                        Resource.Type::Machine:
                            FSBookableResource.ResourceType := FSBookableResource.ResourceType::Equipment;
                        Resource.Type::Person:
                            if Resource."Vendor No." <> '' then
                                FSBookableResource.ResourceType := FSBookableResource.ResourceType::Account
                            else
                                if Resource."Time Sheet Owner User ID" <> '' then
                                    FSBookableResource.ResourceType := FSBookableResource.ResourceType::User
                                else
                                    FSBookableResource.ResourceType := FSBookableResource.ResourceType::Generic;
                    end;
                    FSBookableResource.UserId := ReturnCRMUserGuidForResource(Resource);
                    DestinationRecordRef.GetTable(FSBookableResource);
                end;
            'FS Bookable Resource-Resource':
                begin
                    SetCompanyId(SourceRecordRef);
                    SourceRecordRef.SetTable(FSBookableResource);
                    DestinationRecordRef.SetTable(Resource);
                    case FSBookableResource.ResourceType of
                        FSBookableResource.ResourceType::Equipment:
                            Resource.Type := Resource.Type::Machine;
                        FSBookableResource.ResourceType::Account,
                        FSBookableResource.ResourceType::User,
                        FSBookableResource.ResourceType::Generic:
                            Resource.Type := Resource.Type::Person;
                    end;
                    Resource."Base Unit of Measure" := FSConnectionSetup."Hour Unit of Measure";
                    Resource."Time Sheet Owner User ID" := SetUserIDFromFSBookableResource(FSBookableResource);
                    DestinationRecordRef.GetTable(Resource);
                    SourceRecordRef.Modify();
                end;
            'Job Task-FS Project Task':
                begin
                    SetCompanyId(DestinationRecordRef);
                    SourceRecordRef.SetTable(JobTask);
                    if Job.Get(JobTask."Job No.") then begin
                        DestinationRecordRef.Field(FSProjectTask.FieldNo(ProjectDescription)).Value := Job.Description;
                        if Job."Bill-to Customer No." <> '' then
                            if CRMSynchHelper.FindRecordIDByPK(Database::Customer, Job."Bill-to Customer No.", RecID) then
                                if CRMIntegrationRecord.FindIDFromRecordID(RecID, BillingAccId) then
                                    DestinationRecordRef.Field(FSProjectTask.FieldNo(BillingAccountId)).Value := BillingAccId
                                else
                                    Error(RecordMustBeCoupledErr, Customer.TableCaption(), Job."Bill-to Customer No.", CRMProductName.CDSServiceName());
                        if Job."Sell-to Customer No." <> '' then
                            if CRMSynchHelper.FindRecordIDByPK(Database::Customer, Job."Sell-to Customer No.", RecID) then
                                if CRMIntegrationRecord.FindIDFromRecordID(RecID, ServiceAccId) then
                                    DestinationRecordRef.Field(FSProjectTask.FieldNo(ServiceAccountId)).Value := ServiceAccId
                                else
                                    Error(RecordMustBeCoupledErr, Customer.TableCaption(), Job."Bill-to Customer No.", CRMProductName.CDSServiceName())
                            else
                                DestinationRecordRef.Field(FSProjectTask.FieldNo(ServiceAccountId)).Value := BillingAccId;
                    end;
                end;
            'FS Work Order Product-Job Journal Line',
            'FS Work Order Service-Job Journal Line':
                begin
                    DestinationRecordRef.SetTable(JobJournalLine);
                    OnSetUpNewLineOnNewLine(JobJournalLine, JobJournalTemplate, JobJournalBatch, Handled);
                    if not Handled then begin
                        FSConnectionSetup.Get();
                        Job.Get(JobJournalLine."Job No.");
                        if not JobJournalTemplate.Get(FSConnectionSetup."Job Journal Template") then
                            Error(JobJournalIncorrectSetupErr, JobJournalTemplate.TableCaption(), FSConnectionSetup.TableCaption());
                        if not JobJournalBatch.Get(FSConnectionSetup."Job Journal Template", FSConnectionSetup."Job Journal Batch") then
                            Error(JobJournalIncorrectSetupErr, JobJournalBatch.TableCaption(), FSConnectionSetup.TableCaption());
                        JobJournalLine."Journal Template Name" := JobJournalTemplate.Name;
                        JobJournalLine."Journal Batch Name" := JobJournalBatch.Name;
                        LastJobJournalLine.SetRange("Journal Template Name", JobJournalTemplate.Name);
                        LastJobJournalLine.SetRange("Journal Batch Name", JobJournalBatch.Name);
                        CheckPostingRuleAndSetDocumentNo(JobJournalLine, LastJobJournalLine, JobJournalBatch, SourceRecordRef);
                        JobJournalLine."Line No." := LastJobJournalLine."Line No." + 10000;
                        JobJournalLine."Source Code" := JobJournalTemplate."Source Code";
                        JobJournalLine."Reason Code" := JobJournalBatch."Reason Code";
                        JobJournalLine."Posting No. Series" := JobJournalBatch."Posting No. Series";
                        JobJournalLine."Price Calculation Method" := Job.GetPriceCalculationMethod();
                        JobJournalLine."Cost Calculation Method" := Job.GetCostCalculationMethod();
                        SetJobJournalLineTypesAndNo(FSConnectionSetup, SourceRecordRef, JobJournalLine);
                    end;
                    DestinationRecordRef.GetTable(JobJournalLine);
                end;
            'FS Bookable Resource Booking-Service Line':
                begin
                    DestinationRecordRef.SetTable(ServiceLine);
                    GenerateServiceItemLineForBooking(ServiceLine);
                    DestinationRecordRef.GetTable(ServiceLine);
                end;
            'Service Order Type-FS Work Order Type':
                SetCompanyId(DestinationRecordRef);
            'Service Header-FS Work Order':
                begin
                    SourceRecordRef.SetTable(ServiceHeader);
                    ProofAllServiceItemLinesAssigned(ServiceHeader);
                    SetCompanyId(DestinationRecordRef);
                end;
            'Service Item Line-FS Work Order Incident':
                begin
                    SetCompanyId(DestinationRecordRef);

                    SourceRecordRef.SetTable(ServiceItemLine);
                    DestinationRecordRef.SetTable(FSWorkOrderIncident);
                    if CRMIntegrationRecord.FindIDFromRecordID(GetServiceOrderRecordId(ServiceItemLine."Document No."), WorkOrderId) then
                        FSWorkOrderIncident.WorkOrder := WorkOrderId;
                    FSWorkOrderIncident.IncidentType := FSIntegrationMgt.GetDefaultWorkOrderIncident();
                    DestinationRecordRef.GetTable(FSWorkOrderIncident);
                end;
            'Service Line-FS Work Order Product':
                begin
                    SetCompanyId(DestinationRecordRef);

                    SourceRecordRef.SetTable(ServiceLine);
                    DestinationRecordRef.SetTable(FSWorkOrderProduct);
                    if CRMIntegrationRecord.FindIDFromRecordID(GetServiceOrderRecordId(ServiceLine."Document No."), WorkOrderId) then
                        FSWorkOrderProduct.WorkOrder := WorkOrderId;
                    DestinationRecordRef.GetTable(FSWorkOrderProduct);
                end;
            'Service Line-FS Work Order Service':
                begin
                    SetCompanyId(DestinationRecordRef);

                    SourceRecordRef.SetTable(ServiceLine);
                    DestinationRecordRef.SetTable(FSWorkOrderService);
                    if CRMIntegrationRecord.FindIDFromRecordID(GetServiceOrderRecordId(ServiceLine."Document No."), WorkOrderId) then
                        FSWorkOrderService.WorkOrder := WorkOrderId;
                    DestinationRecordRef.GetTable(FSWorkOrderService);
                end;
        end;
    end;

    local procedure SetUserIDFromFSBookableResource(BookableResource: Record "FS Bookable Resource"): Code[50]
    var
        UserSetup: Record "User Setup";
        CRMSystemUser: Record "CRM Systemuser";
    begin
        if BookableResource.ResourceType <> BookableResource.ResourceType::User then
            exit;

        if IsNullGuid(BookableResource.UserId) then
            exit;

        CRMSystemUser.SetRange(SystemUserId, BookableResource.UserId);
        if CRMSystemUser.IsEmpty() then
            exit;

        CRMSystemUser.FindFirst();
#pragma warning disable AA0210
        UserSetup.SetRange("E-Mail", CRMSystemUser.InternalEMailAddress);
#pragma warning restore AA0210
        if UserSetup.IsEmpty() then
            exit;

        UserSetup.FindFirst();
        exit(UserSetup."User ID");
    end;

    local procedure ReturnCRMUserGuidForResource(Resource: Record Resource): Guid
    var
        UserSetup: Record "User Setup";
        CRMSystemUser: Record "CRM Systemuser";
    begin
        if Resource."Time Sheet Owner User ID" = '' then
            exit;

        if not UserSetup.Get(Resource."Time Sheet Owner User ID") then
            exit;

        CRMSystemUser.SetRange(InternalEMailAddress, UserSetup."E-Mail");
        if CRMSystemUser.FindFirst() then
            exit(CRMSystemUser.SystemUserId);
    end;

    local procedure CheckPostingRuleAndSetDocumentNo(var JobJournalLine: Record "Job Journal Line"; var LastJobJournalLine: Record "Job Journal Line"; JobJournalBatch: Record "Job Journal Batch"; var SourceRecordRef: RecordRef)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        FSWorkOrderProduct: Record "FS Work Order Product";
        FSWorkOrderService: Record "FS Work Order Service";
    begin
        if JobJournalBatch."Posting No. Series" <> '' then begin
            FSConnectionSetup.Get();
            case FSConnectionSetup."Line Post Rule" of
                "FS Work Order Line Post Rule"::LineUsed,
                "FS Work Order Line Post Rule"::WorkOrderCompleted:
                    case SourceRecordRef.Number of
                        Database::"FS Work Order Product":
                            begin
                                SourceRecordRef.SetTable(FSWorkOrderProduct);
                                if (FSWorkOrderProduct.LineStatus = FSWorkOrderProduct.LineStatus::Used)
                                    or (FSWorkOrderProduct.WorkOrderStatus in [FSWorkOrderProduct.WorkOrderStatus::Completed]) then
                                    SetPostingDocumentNo(JobJournalLine, LastJobJournalLine, JobJournalBatch);
                            end;
                        Database::"FS Work Order Service":
                            begin
                                SourceRecordRef.SetTable(FSWorkOrderService);
                                if (FSWorkOrderService.LineStatus = FSWorkOrderService.LineStatus::Used)
                                    or (FSWorkOrderService.WorkOrderStatus in [FSWorkOrderService.WorkOrderStatus::Completed]) then
                                    SetPostingDocumentNo(JobJournalLine, LastJobJournalLine, JobJournalBatch);
                            end;
                    end;
                else
                    SetDocumentNo(JobJournalLine, LastJobJournalLine, JobJournalBatch);
            end;
        end else
            SetDocumentNo(JobJournalLine, LastJobJournalLine, JobJournalBatch);
    end;

    local procedure SetPostingDocumentNo(var JobJournalLine: Record "Job Journal Line"; var LastJobJournalLine: Record "Job Journal Line"; JobJournalBatch: Record "Job Journal Batch")
    var
        NoSeries: Codeunit "No. Series";
    begin
        if LastJobJournalLine.FindLast() then begin
            JobJournalLine."Posting Date" := LastJobJournalLine."Posting Date";
            JobJournalLine."Document Date" := LastJobJournalLine."Posting Date";
            if LastJobJournalLine."Document No." = NoSeries.GetLastNoUsed(JobJournalBatch."Posting No. Series") then
                JobJournalLine."Document No." := LastJobJournalLine."Document No."
            else
                JobJournalLine."Document No." := NoSeries.GetNextNo(JobJournalBatch."Posting No. Series", JobJournalLine."Posting Date");
        end else begin
            JobJournalLine."Posting Date" := WorkDate();
            JobJournalLine."Document Date" := WorkDate();
            JobJournalLine."Document No." := NoSeries.GetNextNo(JobJournalBatch."Posting No. Series", JobJournalLine."Posting Date");
        end;
    end;

    local procedure SetDocumentNo(var JobJournalLine: Record "Job Journal Line"; var LastJobJournalLine: Record "Job Journal Line"; JobJournalBatch: Record "Job Journal Batch")
    var
        JobsSetup: Record "Jobs Setup";
        NoSeries: Codeunit "No. Series";
    begin
        JobsSetup.Get();
        if LastJobJournalLine.FindLast() then begin
            JobJournalLine."Posting Date" := LastJobJournalLine."Posting Date";
            JobJournalLine."Document Date" := LastJobJournalLine."Posting Date";
            if JobsSetup."Document No. Is Job No." and (LastJobJournalLine."Document No." = '') then
                JobJournalLine."Document No." := JobJournalLine."Job No."
            else
                JobJournalLine."Document No." := LastJobJournalLine."Document No.";
        end else begin
            JobJournalLine."Posting Date" := WorkDate();
            JobJournalLine."Document Date" := WorkDate();
            if JobsSetup."Document No. Is Job No." then begin
                if JobJournalLine."Document No." = '' then
                    JobJournalLine."Document No." := JobJournalLine."Job No.";
            end else
                if JobJournalBatch."No. Series" <> '' then begin
                    Clear(NoSeries);
                    JobJournalLine."Document No." := NoSeries.GetNextNo(JobJournalBatch."No. Series", JobJournalLine."Posting Date");
                end;
        end;
    end;

    local procedure GenerateServiceItemLineForBooking(var ServiceLine: Record "Service Line")
    var
        ServiceItemLine: Record "Service Item Line";
        Resource: Record Resource;
    begin
        if not GetServiceItemLine(ServiceLine, ServiceItemLine) then begin
            ServiceItemLine.Validate("Document Type", ServiceLine."Document Type");
            ServiceItemLine.Validate("Document No.", ServiceLine."Document No.");
            ServiceItemLine.Validate("Line No.", GetNextLineNo(ServiceItemLine));
            ServiceItemLine.Validate(Description, Resource.TableCaption());
            ServiceItemLine.Validate("FS Bookings", true);
            ServiceItemLine.Insert(true);
        end;

        ServiceLine.Validate("Service Item Line No.", ServiceItemLine."Line No.");
    end;

    local procedure DeleteServiceItemLineForBooking(ServiceLineToDelete: Record "Service Line")
    var
        ServiceItemLine: Record "Service Item Line";
        ServiceLine: Record "Service Line";
    begin
        // other service line exists?
        ServiceLine.SetRange("Document Type", ServiceLineToDelete."Document Type");
        ServiceLine.SetRange("Document No.", ServiceLineToDelete."Document No.");
        ServiceLine.SetRange("Service Item Line No.", ServiceLineToDelete."Service Item Line No.");
        ServiceLine.SetFilter("Line No.", '<>%1', ServiceLineToDelete."Line No.");
        if not ServiceLine.IsEmpty() then
            exit;

        // delete service item line -> only if no other service line exists
        ServiceItemLine.SetRange("Document Type", ServiceLineToDelete."Document Type");
        ServiceItemLine.SetRange("Document No.", ServiceLineToDelete."Document No.");
        ServiceItemLine.SetRange("Line No.", ServiceLineToDelete."Service Item Line No.");
        if not ServiceItemLine.IsEmpty() then
            ServiceItemLine.DeleteAll()
    end;

    local procedure GetServiceItemLine(ServiceLine: Record "Service Line"; var ServiceItemLine: Record "Service Item Line"): Boolean
    begin
        ServiceItemLine.SetRange("Document Type", ServiceLine."Document Type");
        ServiceItemLine.SetRange("Document No.", ServiceLine."Document No.");
        ServiceItemLine.SetRange("FS Bookings", true);
        exit(ServiceItemLine.FindFirst());
    end;

    local procedure GetNextLineNo(ServiceItemLine: Record "Service Item Line"): Integer
    var
        ServiceItemLineSearch: Record "Service Item Line";
    begin
        ServiceItemLineSearch.SetRange("Document Type", ServiceItemLine."Document Type");
        ServiceItemLineSearch.SetRange("Document No.", ServiceItemLine."Document No.");
        if ServiceItemLineSearch.FindLast() then
            exit(ServiceItemLineSearch."Line No." + 10000);
        exit(10000);
    end;

    local procedure GetNextLineNo(ServiceLine: Record "Service Line"): Integer
    var
        ServiceLineSearch: Record "Service Line";
    begin
        ServiceLineSearch.SetRange("Document Type", ServiceLine."Document Type");
        ServiceLineSearch.SetRange("Document No.", ServiceLine."Document No.");
        if ServiceLineSearch.FindLast() then
            exit(ServiceLineSearch."Line No." + 10000);
        exit(10000);
    end;

    local procedure GetServiceOrderRecordId(DocumentNo: Code[20]): RecordId
    var
        ServiceHeader: Record "Service Header";
    begin
        if ServiceHeader.Get(ServiceHeader."Document Type"::Order, DocumentNo) then
            exit(ServiceHeader.RecordId);
    end;

    local procedure GetServiceOrderItemLineRecordId(DocumentNo: Code[20]; LineNo: Integer): RecordId
    var
        ServiceItemLine: Record "Service Item Line";
    begin
        if ServiceItemLine.Get(ServiceItemLine."Document Type"::Order, DocumentNo, LineNo) then
            exit(ServiceItemLine.RecordId);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CRM Integration Table Synch.", 'OnSynchNAVTableToCRMOnBeforeCheckLatestModifiedOn', '', true, false)]
    local procedure OnSynchNAVTableToCRMOnBeforeCheckLatestModifiedOn(var SourceRecordRef: RecordRef; IntegrationTableMapping: Record "Integration Table Mapping")
    var
        ServiceHeader: Record "Service Header";
        ServiceHeaderToSync: Record "Service Header";
        ServiceItemLine: Record "Service Item Line";
        ServiceLine: Record "Service Line";
        CRMIntegrationTableSynch: Codeunit "CRM Integration Table Synch.";
        ServiceOrderRecordRef: RecordRef;
        ServiceOrdersToIgnore: List of [Code[20]];
        ServiceOrdersToSync: List of [Code[20]];
        ServiceOrderNo: Code[20];
    begin
        if SourceRecordRef.Number() <> Database::"Service Header" then
            exit;

        // sync of service header should triggered by changes in service item lines and service lines:
        // search for modified service orders and start sync -> only if not already synced (via service header).

        // already synced service orders should not be triggered again
        SourceRecordRef.SetTable(ServiceHeader);
        if ServiceHeader.FindSet() then
            repeat
                ServiceOrdersToIgnore.Add(ServiceHeader."No.");
            until ServiceHeader.Next() = 0;

        // search for modified service (item) lines and start sync
        ServiceItemLine.SetRange("Document Type", ServiceItemLine."Document Type"::Order);
        ServiceItemLine.SetFilter(SystemModifiedAt, ServiceHeader.GetFilter(SystemModifiedAt));
        if ServiceItemLine.FindSet() then
            repeat
                if not ServiceOrdersToIgnore.Contains(ServiceItemLine."Document No.") then
                    if not ServiceOrdersToSync.Contains(ServiceItemLine."Document No.") then
                        ServiceOrdersToSync.Add(ServiceItemLine."Document No.");
            until ServiceItemLine.Next() = 0;

        ServiceLine.SetRange("Document Type", ServiceItemLine."Document Type"::Order);
        ServiceLine.SetFilter(SystemModifiedAt, ServiceHeader.GetFilter(SystemModifiedAt));
        if ServiceLine.FindSet() then
            repeat
                if not ServiceOrdersToIgnore.Contains(ServiceLine."Document No.") then
                    if not ServiceOrdersToSync.Contains(ServiceLine."Document No.") then
                        ServiceOrdersToSync.Add(ServiceLine."Document No.");
            until ServiceLine.Next() = 0;

        // start sync for found service orders
        foreach ServiceOrderNo in ServiceOrdersToSync do begin
            ServiceHeaderToSync.Reset();
            ServiceHeaderToSync.SetRange("Document Type", ServiceHeaderToSync."Document Type"::Order);
            ServiceHeaderToSync.SetRange("No.", ServiceOrderNo);
            ServiceOrderRecordRef.GetTable(ServiceHeaderToSync);
            CRMIntegrationTableSynch.SynchRecordsToIntegrationTable(ServiceOrderRecordRef, false, false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnDeletionConflictDetectedSetRecordStateAndSynchAction', '', true, false)]
    local procedure HandleOnDeletionConflictDetectedSetRecordStateAndSynchAction(var IntegrationTableMapping: Record "Integration Table Mapping"; var SourceRecordRef: RecordRef; var CoupledRecordRef: RecordRef; var RecordState: Option NotFound,Coupled,Decoupled; var SynchAction: Option "None",Insert,Modify,ForceModify,IgnoreUnchanged,Fail,Skip,Delete,Uncouple,Couple; var DeletionConflictHandled: Boolean)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        FSWorkOrderProduct: Record "FS Work Order Product";
        FSWorkOrderService: Record "FS Work Order Service";
        CRMIntegrationRecord: Record "CRM Integration Record";
        JobJournalLine: Record "Job Journal Line";
        IntegrationRecSynchInvoke: Codeunit "Integration Rec. Synch. Invoke";
        FSQuantityToBill: Decimal;
        FSQuantity: Decimal;
        QuantityCurrentlyConsumed: Decimal;
        QuantityCurrentlyInvoiced: Decimal;
        CRMId: Guid;
    begin
        if DeletionConflictHandled then
            exit;

        if not FSConnectionSetup.IsEnabled() then
            exit;

        if IntegrationTableMapping."Table ID" <> Database::"Job Journal Line" then
            exit;

        if ((IntegrationTableMapping."Integration Table ID" <> Database::"FS Work Order Service") and (IntegrationTableMapping."Integration Table ID" <> Database::"FS Work Order Product")) then
            exit;

        SetCurrentProjectPlanningQuantities(SourceRecordRef, QuantityCurrentlyConsumed, QuantityCurrentlyInvoiced);
        case SourceRecordRef.Number() of
            Database::"FS Work Order Product":
                begin
                    SourceRecordRef.SetTable(FSWorkOrderProduct);
                    CRMId := FSWorkOrderProduct.WorkOrderProductId;
                    FSQuantity := FSWorkOrderProduct.Quantity;
                    FSQuantityToBill := FSWorkOrderProduct.QtyToBill;
                end;
            Database::"FS Work Order Service":
                begin
                    SourceRecordRef.SetTable(FSWorkOrderService);
                    CRMId := FSWorkOrderService.WorkOrderServiceId;
                    FSQuantity := FSWorkOrderService.Duration;
                    FSQuantity := (FSQuantity / 60);
                    FSQuantityToBill := FSWorkOrderService.DurationToBill;
                    FSQuantityToBill := (FSQuantityToBill / 60);
                end;
            else
                exit;
        end;

        // if quantities are equal to the current quantities in Project Planning Lines, then there is no need to create a new Project Journal Line.
        // The Project Journal LIne has been deleted because of posting, and that is fine. Just tell the synch engine to do nothing (skip)
        if (FSQuantity = QuantityCurrentlyConsumed) and (FSQuantityToBill = QuantityCurrentlyInvoiced) then begin
            RecordState := RecordState::NotFound;
            SynchAction := SynchAction::Skip;
            DeletionConflictHandled := true;
            exit;
        end;

        // there is a difference between currently consumed/invoiced quantities and Quantity/Quantity to Bill
        // we must instruct the synch engine to insert a new Project Journal Line (like the "Restore Record" deletion conflict strategy)
        // The OnBeforeInsert subscriber will make sure that the Quantities on the new Project Journal Line take the current quantities in consideration
        IntegrationRecSynchInvoke.PrepareNewDestination(IntegrationTableMapping, SourceRecordRef, CoupledRecordRef);
        RecordState := RecordState::Coupled;
        SynchAction := SynchAction::Insert;

        // delete the broken couplings (those journal lines that are coupled to this CRM Id but they can't be found by SystemId)
        CRMIntegrationRecord.SetRange("CRM ID", CRMId);
        CRMIntegrationRecord.SetRange("Table ID", Database::"Job Journal Line");
        if CRMIntegrationRecord.FindSet() then
            repeat
                if not JobJournalLine.GetBySystemId(CRMIntegrationRecord."Integration ID") then
                    CRMIntegrationRecord.Delete();
            until CRMIntegrationRecord.Next() = 0;

        DeletionConflictHandled := true;
    end;

    local procedure SetCurrentProjectPlanningQuantities(var SourceRecordRef: RecordRef; var QuantityCurrentlyConsumed: Decimal; var QuantityCurrentlyInvoiced: Decimal)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        FSWorkOrderProduct: Record "FS Work Order Product";
        FSWorkOrderService: Record "FS Work Order Service";
        FSBookableResourceBooking: Record "FS Bookable Resource Booking";
        CRMIntegrationRecord: Record "CRM Integration Record";
        JobUsageLink: Record "Job Usage Link";
        JobPlanningLine: Record "Job Planning Line";
        ExternalId: Guid;
        ConsideronlyBudgetLineForConsumption: Boolean;
    begin
        QuantityCurrentlyConsumed := 0;
        QuantityCurrentlyInvoiced := 0;

        if not FSConnectionSetup.IsIntegrationTypeProjectEnabled() then
            exit;

        case SourceRecordRef.Number() of
            Database::"FS Work Order Product":
                begin
                    SourceRecordRef.SetTable(FSWorkOrderProduct);
                    ExternalId := FSWorkOrderProduct.WorkOrderProductId;
                end;
            Database::"FS Work Order Service":
                begin
                    SourceRecordRef.SetTable(FSWorkOrderService);
                    ExternalId := FSWorkOrderService.WorkOrderServiceId;
                    if not IsNullGuid(FSWorkOrderService.Booking) then
                        if FSBookableResourceBooking.Get(FSWorkOrderService.Booking) then
                            if CRMIntegrationRecord.FindByCRMID(FSBookableResourceBooking.Resource) then
                                ConsideronlyBudgetLineForConsumption := true;
                end;
            else
                exit;
        end;
        JobUsageLink.SetRange("External Id", ExternalId);
        if JobUsageLink.FindSet() then
            repeat
                if JobPlanningLine.Get(JobUsageLink."Job No.", JobUsageLink."Job Task No.", JobUsageLink."Line No.") then begin
                    JobPlanningLine.CalcFields("Qty. Invoiced", "Qty. Transferred to Invoice");
                    case ConsideronlyBudgetLineForConsumption of
                        true:
                            if JobPlanningLine."Line Type" = JobPlanningLine."Line Type"::Budget then
                                QuantityCurrentlyConsumed += JobPlanningLine.Quantity;
                        false:
                            QuantityCurrentlyConsumed += JobPlanningLine.Quantity;
                    end;
                    if JobPlanningLine."Qty. Invoiced" > 0 then
                        QuantityCurrentlyInvoiced += JobPlanningLine."Qty. Invoiced"
                    else begin
                        // try other invoicing quantities
                        ;
                        if JobPlanningLine."Qty. Transferred to Invoice" > 0 then
                            QuantityCurrentlyInvoiced += JobPlanningLine."Qty. Transferred to Invoice"
                        else
                            QuantityCurrentlyInvoiced += JobPlanningLine."Qty. to Transfer to Invoice";
                    end;
                end;
            until JobUsageLink.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Link Usage", 'OnAfterApplyUsage', '', false, false)]
    local procedure HandleOnAfterApplyUsage(var JobLedgerEntry: Record "Job Ledger Entry"; var JobJournalLine: Record "Job Journal Line")
    var
        FSConnectionSetup: Record "FS Connection Setup";
        FSWorkOrderProduct: Record "FS Work Order Product";
        FSWorkOrderService: Record "FS Work Order Service";
        FSBookableResourceBooking: Record "FS Bookable Resource Booking";
        CRMIntegrationRecord: Record "CRM Integration Record";
        JobPlanningLine: Record "Job Planning Line";
        JobUsageLink: Record "Job Usage Link";
    begin
        if not FSConnectionSetup.ReadPermission() then begin
            Session.LogMessage('0000MMX', InsufficientPermissionsTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit;
        end;

        if not FSConnectionSetup.IsEnabled() then
            exit;

        Codeunit.Run(Codeunit::"CRM Integration Management");

        JobUsageLink.SetRange("Entry No.", JobLedgerEntry."Entry No.");
        if not JobUsageLink.FindFirst() then begin
            Session.LogMessage('0000MN8', NoProjectUsageLinkTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit;
        end;

        if not JobPlanningLine.Get(JobUsageLink."Job No.", JobUsageLink."Job Task No.", JobUsageLink."Line No.") then begin
            Session.LogMessage('0000MN9', NoProjectPlanningLineTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit;
        end;

        // set "Qty. to Transfer to Invoice" on Job Planning Line
        if JobJournalLine."Qty. to Transfer to Invoice" <> 0 then begin
            JobPlanningLine."Qty. to Transfer to Invoice" := JobJournalLine."Qty. to Transfer to Invoice";
            JobPlanningLine.Modify();
        end;

        // in Project Usage Link, save the id of the entity coupled to the job journal line
        if not CRMIntegrationRecord.ReadPermission() then begin
            Session.LogMessage('0000MMY', InsufficientPermissionsTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit;
        end;
        if not CRMIntegrationRecord.FindByRecordID(JobJournalLine.RecordId()) then
            exit;
        JobUsageLink."External Id" := CRMIntegrationRecord."CRM ID";
        JobUsageLink.Modify();

        if FSWorkOrderProduct.Get(CRMIntegrationRecord."CRM ID") then begin
            TempFSWorkOrderProduct := FSWorkOrderProduct;
            TempFSWorkOrderProduct.QuantityConsumed += JobPlanningLine.Quantity;
            TempFSWorkOrderProduct.Insert();
            exit;
        end;
        if FSWorkOrderService.Get(CRMIntegrationRecord."CRM ID") then begin
            // if the work order service has a bookable resource that is coupled to a Business Central resource
            // then we only register consumption for the budget line
            // not for the Billable line, as this will lead to double consumption registering
            if not IsNullGuid(FSWorkOrderService.Booking) then
                if FSBookableResourceBooking.Get(FSWorkOrderService.Booking) then
                    if CRMIntegrationRecord.FindByCRMID(FSBookableResourceBooking.Resource) then
                        if JobPlanningLine."Line Type" <> JobPlanningLine."Line Type"::Budget then
                            exit;

            TempFSWorkOrderService := FSWorkOrderService;
            TempFSWorkOrderService.DurationConsumed += Round((60 * JobPlanningLine.Quantity), 1, '=');
            TempFSWorkOrderService.Insert();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Jnl.-Post Batch", 'OnAfterPostJnlLines', '', false, false)]
    local procedure HandleOnAfterPostJnlLines(var JobJournalBatch: Record "Job Journal Batch"; var JobJournalLine: Record "Job Journal Line"; JobRegNo: Integer; var SuppressCommit: Boolean)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        FSWorkOrderProduct: Record "FS Work Order Product";
        FSWorkOrderService: Record "FS Work Order Service";
    begin
        if not FSConnectionSetup.IsEnabled() then
            exit;

        if SuppressCommit then begin
            TempFSWorkOrderProduct.DeleteAll();
            TempFSWorkOrderService.DeleteAll();
            exit;
        end;

        // write back consumption data to Field Service
        if not FSWorkOrderProduct.WritePermission() then
            exit;
        if not FSWorkOrderService.WritePermission() then
            exit;

        if TempFSWorkOrderProduct.FindSet() then
            repeat
                if FSWorkOrderProduct.Get(TempFSWorkOrderProduct.WorkOrderProductId) then begin
                    FSWorkOrderProduct.QuantityConsumed += TempFSWorkOrderProduct.QuantityConsumed;
                    if not FSWorkOrderProduct.Modify() then begin
                        Session.LogMessage('0000MMZ', UnableToModifyWOPTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                        ClearLastError();
                    end;
                end;
            until TempFSWorkOrderProduct.Next() = 0;

        if TempFSWorkOrderService.FindSet() then
            repeat
                if FSWorkOrderService.Get(TempFSWorkOrderService.WorkOrderServiceId) then begin
                    FSWorkOrderService.DurationConsumed += TempFSWorkOrderService.DurationConsumed;
                    if not FSWorkOrderService.Modify() then begin
                        Session.LogMessage('0000MN0', UnableToModifyWOSTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                        ClearLastError();
                    end;
                end;
            until TempFSWorkOrderService.Next() = 0;

        TempFSWorkOrderProduct.DeleteAll();
        TempFSWorkOrderService.DeleteAll();
    end;

    local procedure SetJobJournalLineTypesAndNo(var FSConnectionSetup: Record "FS Connection Setup"; var SourceRecordRef: RecordRef; var JobJournalLine: Record "Job Journal Line")
    var
        CRMIntegrationRecord: Record "CRM Integration Record";
        FSBookableResourceBooking: Record "FS Bookable Resource Booking";
        FSBookableResource: Record "FS Bookable Resource";
        FSWorkOrderProduct: Record "FS Work Order Product";
        FSWorkOrderService: Record "FS Work Order Service";
        Resource: Record Resource;
        Item: Record Item;
        CRMProduct: Record "CRM Product";
        BudgetJobJournalLine: Record "Job Journal Line";
        CRMProductName: Codeunit "CRM Product Name";
        UOMMgt: Codeunit "Unit of Measure Management";
        BookableResourceCoupled: Boolean;
        BookableResourceCoupledToDeleted: Boolean;
        FSQuantity: Decimal;
        FSQuantityToBill: Decimal;
        QuantityCurrentlyConsumed: Decimal;
        QuantityCurrentlyInvoiced: Decimal;
        RoundedQtyToInvoice: Decimal;
    begin
        SetCurrentProjectPlanningQuantities(SourceRecordRef, QuantityCurrentlyConsumed, QuantityCurrentlyInvoiced);
        case SourceRecordRef.Number of
            Database::"FS Work Order Product":
                begin
                    JobJournalLine.Validate(Type, JobJournalLine.Type::Item);
                    SourceRecordRef.SetTable(FSWorkOrderProduct);
                    FSQuantity := FSWorkOrderProduct.Quantity;
                    FSQuantityToBill := FSWorkOrderProduct.QtyToBill;

                    if not CRMIntegrationRecord.FindByCRMID(FSWorkOrderProduct.Product) then
                        Error(MustBeCoupledErr, FSWorkOrderProduct.FieldCaption(Product), Format(FSWorkOrderProduct.Product), Item.TableCaption());

                    if not CRMProduct.Get(FSWorkOrderProduct.Product) then
                        Error(DoesntExistErr, CRMProduct.TableCaption(), Format(FSWorkOrderProduct.Product), CRMProductName.FSServiceName());

                    if not Item.GetBySystemId(CRMIntegrationRecord."Integration ID") then
                        Error(CoupledToDeletedErr, FSWorkOrderProduct.FieldCaption(Product), Format(FSWorkOrderProduct.Product), Item.TableCaption());

                    JobJournalLine.Validate("Entry Type", JobJournalLine."Entry Type"::Usage);
                    JobJournalLine.Validate("Line Type", JobJournalLine."Line Type"::Billable);
                    // set Item, but for work order products we must keep its Business Central Unit Cost
                    JobJournalLine.Validate("No.", Item."No.");
                    JobJournalLine.Validate(Description, CopyStr(FSWorkOrderProduct.Name, 1, MaxStrLen(JobJournalLine.Description)));
                    JobJournalLine.Validate("Unit Cost", Item."Unit Cost");
                    JobJournalLine.Validate(Quantity, FSQuantity - QuantityCurrentlyConsumed);
                    JobJournalLine.Validate("Unit Price", Item."Unit Price");
                    JobJournalLine.Validate("Qty. to Transfer to Invoice", FSQuantityToBill - QuantityCurrentlyInvoiced);
                end;
            Database::"FS Work Order Service":
                begin
                    SourceRecordRef.SetTable(FSWorkOrderService);
                    FSQuantity := FSWorkOrderService.Duration;
                    FSQuantityToBill := FSWorkOrderService.DurationToBill;
                    FSQuantity := (FSQuantity / 60);
                    FSQuantityToBill := (FSQuantityToBill / 60);

                    if not CRMProduct.Get(FSWorkOrderService.Service) then
                        Error(DoesntExistErr, FSWorkOrderService.FieldCaption(Service), Format(FSWorkOrderService.Service), FSConnectionSetup."Server Address");

                    if not CRMIntegrationRecord.FindByCRMID(FSWorkOrderService.Service) then
                        Error(MustBeCoupledErr, FSWorkOrderService.FieldCaption(Service), CRMProduct.ProductNumber, Item.TableCaption());

                    if not Item.GetBySystemId(CRMIntegrationRecord."Integration ID") then
                        Error(CoupledToDeletedErr, FSWorkOrderService.FieldCaption(Service), CRMProduct.ProductNumber, Item.TableCaption());

                    if Item.Type = Item.Type::Inventory then
                        Error(CoupledToNonServiceErr, FSWorkOrderService.FieldCaption(Service), CRMProduct.ProductNumber, Item."No.");

                    if Item.Blocked then
                        Error(CoupledToBlockedItemErr, FSWorkOrderService.FieldCaption(Service), CRMProduct.ProductNumber, Item."No.");

                    if Item.Type = Item.Type::Service then
                        if Item."Base Unit of Measure" <> FSConnectionSetup."Hour Unit of Measure" then
                            Error(CoupledToItemWithWrongUOMErr, FSWorkOrderService.FieldCaption(Service), CRMProduct.ProductNumber, Item."No.", FSConnectionSetup."Hour Unit of Measure");

                    JobJournalLine.Validate("Entry Type", JobJournalLine."Entry Type"::Usage);

                    // if the work order service has a booking with a resource that is coupled to Business Central resource
                    // in this case, make an extra Budget line for the resource
                    // the extra line will be coupled in OnAfterInsertRecord subscriber
                    if FSBookableResourceBooking.Get(FSWorkOrderService.Booking) then begin
                        Clear(CRMIntegrationRecord);
                        if CRMIntegrationRecord.FindByCRMID(FSBookableResourceBooking.Resource) then
                            BookableResourceCoupled := true;

                        if not Resource.GetBySystemId(CRMIntegrationRecord."Integration ID") then
                            BookableResourceCoupledToDeleted := true;

                        if not FSBookableResource.Get(FSBookableResourceBooking.Resource) then
                            BookableResourceCoupledToDeleted := true;

                        if Item.Type = Item.Type::Service then
                            if BookableResourceCoupled then
                                if not BookableResourceCoupledToDeleted then begin
                                    // insert and couple an additional budget Project Journal Line, for posting cost of the resource who is performing the service
                                    BudgetJobJournalLine.TransferFields(JobJournalLine, true);
                                    BudgetJobJournalLine."Line No." := JobJournalLine."Line No." - BudgetJobJournalLineNoOffset();
                                    BudgetJobJournalLine."Line Type" := JobJournalLine."Line Type"::Budget;
                                    BudgetJobJournalLine.Validate(Type, JobJournalLine.Type::Resource);
                                    BudgetJobJournalLine.Validate("No.", Resource."No.");
                                    BudgetJobJournalLine.Validate(Description, FSBookableResourceBooking.Name);
                                    BudgetJobJournalLine.Validate("Unit of Measure Code", FSConnectionSetup."Hour Unit of Measure");
                                    BudgetJobJournalLine.Validate("Unit Cost", Resource."Unit Cost");
                                    BudgetJobJournalLine.Validate(Quantity, FSQuantity - QuantityCurrentlyConsumed);
                                    BudgetJobJournalLine.Validate("Unit Price", 0);
                                    BudgetJobJournalLine.Validate("Qty. to Transfer to Invoice", 0);
                                    BudgetJobJournalLine.Insert(true);
                                end;
                    end;

                    if Item.Type = Item.Type::"Non-Inventory" then
                        JobJournalLine."Line Type" := JobJournalLine."Line Type"::" "
                    else
                        JobJournalLine.Validate("Line Type", JobJournalLine."Line Type"::Billable);
                    JobJournalLine.Validate(Type, JobJournalLine.Type::Item);
                    // set Item, but must keep its Business Central Unit Cost
                    JobJournalLine.Validate("No.", Item."No.");
                    JobJournalLine.Validate(Description, CopyStr(FSWorkOrderService.Name, 1, MaxStrLen(JobJournalLine.Description)));
                    JobJournalLine.Validate("Unit of Measure Code", Item."Base Unit of Measure");
                    JobJournalLine.Validate("Unit Cost", Item."Unit Cost");
                    JobJournalLine.Validate(Quantity, FSQuantity - QuantityCurrentlyConsumed);
                    JobJournalLine.Validate("Unit Price", Item."Unit Price");
                    RoundedQtyToInvoice := UOMMgt.RoundAndValidateQty(FSQuantityToBill - QuantityCurrentlyInvoiced, JobJournalLine."Qty. Rounding Precision", JobJournalLine.FieldCaption("Qty. to Transfer to Invoice"));
                    JobJournalLine.Validate("Qty. to Transfer to Invoice", RoundedQtyToInvoice);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CDS Integration Mgt.", 'OnHasCompanyIdField', '', false, false)]
    local procedure HandleOnHasCompanyIdField(TableId: Integer; var HasField: Boolean)
    var
        FSConnectionSetup: Record "FS Connection Setup";
    begin
        if not FSConnectionSetup.IsEnabled() then
            exit;

        case TableId of
            Database::"FS Work Order",
            Database::"FS Bookable Resource",
            Database::"FS Customer Asset",
            Database::"FS Work Order Product",
            Database::"FS Work Order Service",
            Database::"FS Resource Pay Type",
            Database::"FS Project Task",
            Database::"FS Warehouse":
                HasField := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Int. Rec. Uncouple Invoke", 'OnBeforeUncoupleRecord', '', false, false)]
    local procedure HandleOnBeforeUncoupleRecord(IntegrationTableMapping: Record "Integration Table Mapping"; var LocalRecordRef: RecordRef; var IntegrationRecordRef: RecordRef)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        HasField: Boolean;
    begin
        if not FSConnectionSetup.IsEnabled() then
            exit;

        CDSIntegrationMgt.OnHasCompanyIdField(IntegrationRecordRef.Number(), HasField);
        if not HasField then
            exit;

        if IntegrationRecordRef.IsEmpty() then
            exit;

        CDSIntegrationMgt.ResetCompanyId(IntegrationRecordRef);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CRM Integration Table Synch.", 'OnQueryPostFilterIgnoreRecord', '', false, false)]
    local procedure OnQueryPostFilterIgnoreRecord(SourceRecordRef: RecordRef; var IgnoreRecord: Boolean)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        FSBookableResource: Record "FS Bookable Resource";
        JobTask: Record "Job Task";
        Job: Record Job;
    begin
        if IgnoreRecord then
            exit;

        case SourceRecordRef.Number() of
            Database::"FS Work Order Product",
            Database::"FS Work Order Service":
                IgnorePostedJobJournalLinesOnQueryPostFilterIgnoreRecord(SourceRecordRef, IgnoreRecord);
            Database::"Service Header":
                IgnoreArchievedServiceOrdersOnQueryPostFilterIgnoreRecord(SourceRecordRef, IgnoreRecord);
            Database::"FS Work Order":
                IgnoreArchievedCRMWorkOrdersOnQueryPostFilterIgnoreRecord(SourceRecordRef, IgnoreRecord);
        end;

        if FSConnectionSetup.IsEnabled() then
            exit;

        case SourceRecordRef.Number() of
            Database::"FS Bookable Resource":
                begin
                    SourceRecordRef.SetTable(FSBookableResource);
                    IgnoreRecord := (FSBookableResource.ResourceType in [FSBookableResource.ResourceType::Contact, FSBookableResource.ResourceType::Crew, FSBookableResource.ResourceType::Facility, FSBookableResource.ResourceType::Pool]);
                end;
            Database::"Job Task":
                begin
                    SourceRecordRef.SetTable(JobTask);
                    if not Job.Get(JobTask."Job No.") then begin
                        IgnoreRecord := true;
                        exit;
                    end;

                    if Job.Blocked <> Job.Blocked::" " then begin
                        IgnoreRecord := true;
                        exit;
                    end;

                    if Job.Status <> Job.Status::Open then begin
                        IgnoreRecord := true;
                        exit;
                    end;

                    IgnoreRecord := (not Job."Apply Usage Link");
                end;
        end;
    end;

    internal procedure IgnorePostedJobJournalLinesOnQueryPostFilterIgnoreRecord(SourceRecordRef: RecordRef; var IgnoreRecord: Boolean)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        FSWorkOrder: Record "FS Work Order";
        FSWorkOrderProduct: Record "FS Work Order Product";
        FSWorkOrderService: Record "FS Work Order Service";
        QuantityCurrentlyConsumed: Decimal;
        QuantityCurrentlyInvoiced: Decimal;
        FSQuantityToConsume: Decimal;
        FSQuantityToInvoice: Decimal;
        IntegrateToService: Boolean;
    begin
        if not FSConnectionSetup.IsIntegrationTypeProjectEnabled() then
            exit;
        if IgnoreRecord then
            exit;
        if FSConnectionSetup."Line Synch. Rule" <> "FS Work Order Line Synch. Rule"::LineUsed then
            exit;

        case SourceRecordRef.Number() of
            Database::"FS Work Order Product":
                begin
                    SourceRecordRef.SetTable(FSWorkOrderProduct);
                    if FSWorkOrderProduct.LineStatus = FSWorkOrderProduct.LineStatus::Used then begin
                        FSQuantityToConsume := FSWorkOrderProduct.Quantity;
                        FSQuantityToInvoice := FSWorkOrderProduct.QtyToBill;
                    end;
                    if FSWorkOrder.Get(FSWorkOrderProduct.WorkOrder) then
                        IntegrateToService := FSWorkOrder.IntegrateToService;
                end;
            Database::"FS Work Order Service":
                begin
                    SourceRecordRef.SetTable(FSWorkOrderService);
                    if FSWorkOrderService.LineStatus = FSWorkOrderService.LineStatus::Used then begin
                        FSQuantityToConsume := FSWorkOrderService.Duration / 60;
                        FSQuantityToInvoice := FSWorkOrderService.DurationToBill / 60;
                    end;
                    if FSWorkOrder.Get(FSWorkOrderService.WorkOrder) then
                        IntegrateToService := FSWorkOrder.IntegrateToService;
                end;
        end;

        SetCurrentProjectPlanningQuantities(SourceRecordRef, QuantityCurrentlyConsumed, QuantityCurrentlyInvoiced);

        if IntegrateToService then
            IgnoreRecord := true;

        if (QuantityCurrentlyConsumed = FSQuantityToConsume) and (QuantityCurrentlyInvoiced = FSQuantityToInvoice) then
            IgnoreRecord := true;
    end;

    internal procedure IgnoreArchievedServiceOrdersOnQueryPostFilterIgnoreRecord(SourceRecordRef: RecordRef; var IgnoreRecord: Boolean)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        ServiceHeader: Record "Service Header";
        CRMIntegrationRecord: Record "CRM Integration Record";
    begin
        if not FSConnectionSetup.IsEnabled() then
            exit;

        if IgnoreRecord then
            exit;

        SourceRecordRef.SetTable(ServiceHeader);
        if not CRMIntegrationRecord.FindByRecordID(ServiceHeader.RecordId) then
            exit;

        if CRMIntegrationRecord."Archived Service Order" then
            IgnoreRecord := true;
    end;

    internal procedure IgnoreArchievedCRMWorkOrdersOnQueryPostFilterIgnoreRecord(SourceRecordRef: RecordRef; var IgnoreRecord: Boolean)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        FSWorkOrder: Record "FS Work Order";
        FSWorkOrderIncident: Record "FS Work Order Incident";
        CRMIntegrationRecord: Record "CRM Integration Record";
    begin
        if not FSConnectionSetup.IsEnabled() then
            exit;

        if IgnoreRecord then
            exit;

        SourceRecordRef.SetTable(FSWorkOrder);

        // at least one work order incident should exist
        FSWorkOrderIncident.SetRange(WorkOrder, FSWorkOrder.WorkOrderId);
        if FSWorkOrderIncident.IsEmpty() then
            IgnoreRecord := true;

        // skip archived work orders
        if CRMIntegrationRecord.FindByCRMID(FSWorkOrder.WorkOrderId) then
            if CRMIntegrationRecord."Archived Service Order" then
                IgnoreRecord := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Table Synch.", 'OnAfterInitSynchJob', '', true, true)]
    local procedure LogTelemetryOnAfterInitSynchJob(ConnectionType: TableConnectionType; IntegrationTableID: Integer)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        FSIntegrationMgt: Codeunit "FS Integration Mgt.";
        IntegrationRecordRef: RecordRef;
        TelemetryCategories: Dictionary of [Text, Text];
        IntegrationTableName: Text;
    begin
        if ConnectionType <> TableConnectionType::CRM then
            exit;

        if not FSConnectionSetup.IsEnabled() then
            exit;

        TelemetryCategories.Add('Category', CategoryTok);
        TelemetryCategories.Add('IntegrationTableID', Format(IntegrationTableID));
        if TryCalculateTableName(IntegrationRecordRef, IntegrationTableID, IntegrationTableName) then
            TelemetryCategories.Add('IntegrationTableName', IntegrationTableName);

        if IntegrationTableID in [
                Database::"FS Project Task",
                Database::"FS Work Order Product",
                Database::"FS Work Order Service",
                Database::"FS Work Order Incident",
                Database::"FS Customer Asset",
                Database::"FS Bookable Resource",
                Database::"FS Bookable Resource Booking",
                Database::"FS Incident Type",
                Database::"FS Resource Pay Type",
                Database::"FS Warehouse"] then begin
            Session.LogMessage('0000M9F', FSEntitySynchTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, TelemetryCategories);
            FeatureTelemetry.LogUsage('0000M9E', FSIntegrationMgt.ReturnIntegrationTypeLabel(FSConnectionSetup), 'Entity synch');
            FeatureTelemetry.LogUptake('0000M9D', FSIntegrationMgt.ReturnIntegrationTypeLabel(FSConnectionSetup), Enum::"Feature Uptake Status"::Used);
            exit;
        end;
    end;

    [TryFunction]
    local procedure TryCalculateTableName(var IntegrationRecordRef: RecordRef; TableId: Integer; var TableName: Text)
    begin
        IntegrationRecordRef.Open(TableId);
        TableName := IntegrationRecordRef.Name();
    end;

    local procedure SetCompanyId(DestinationRecordRef: RecordRef)
    begin
        if CDSIntegrationImpl.CheckCompanyIdNoTelemetry(DestinationRecordRef) then
            exit;

        CDSIntegrationMgt.SetCompanyId(DestinationRecordRef);
    end;

    local procedure GetSourceDestCode(SourceRecordRef: RecordRef; DestinationRecordRef: RecordRef): Text
    begin
        if (SourceRecordRef.Number() <> 0) and (DestinationRecordRef.Number() <> 0) then
            exit(SourceRecordRef.Name() + '-' + DestinationRecordRef.Name());
        exit('');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Mgt. Setup", 'OnBeforeValidateEvent', 'One Service Item Line/Order', true, false)]
    local procedure ServiceMgtSetupOnBeforeValidateOneServiceItemLinePerOrder(var Rec: Record "Service Mgt. Setup")
    var
        IntegrationMgt: Codeunit "FS Integration Mgt.";
    begin
        IntegrationMgt.TestOneServiceItemLinePerOrderModificationIsAllowed(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CRM Integration Management", 'OnIsCRMIntegrationRecord', '', true, false)]
    local procedure HandleOnIsCRMIntegrationRecord(TableID: Integer; var isIntegrationRecord: Boolean)
    begin
        if TableID = Database::"Service Header Archive" then
            isIntegrationRecord := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterDeleteEvent', '', false, false)]
    local procedure HandleOnAfterDeleteServiceHeader(var Rec: Record "Service Header")
    begin
        if Rec.IsTemporary() then
            exit;

        MarkArchivedServiceOrder(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service Document Archive Mgmt.", 'OnAfterStoreServiceLineArchive', '', false, false)]
    local procedure OnAfterStoreServiceLineArchive(var ServiceLine: Record "Service Line"; var ServiceLineArchive: Record "Service Line Archive")
    begin
        MarkArchivedServiceOrderLine(ServiceLine, ServiceLineArchive);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Item Line", 'OnAfterDeleteEvent', '', false, false)]
    local procedure HandleOnAfterDeleteServiceItemLine(var Rec: Record "Service Item Line")
    begin
        if Rec.IsTemporary() then
            exit;

        UncoupleRecord(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Line", 'OnAfterDeleteEvent', '', false, false)]
    local procedure HandleOnAfterDeleteServiceLine(var Rec: Record "Service Line")
    begin
        if Rec.IsTemporary() then
            exit;

        UncoupleRecord(Rec);
    end;

    local procedure UncoupleRecord(ServiceItemLine: Record "Service Item Line")
    var
        FSConnectionSetup: Record "FS Connection Setup";
        CRMIntegrationRecord: Record "CRM Integration Record";
    begin
        if not FSConnectionSetup.IsIntegrationTypeServiceEnabled() then
            exit;

        CRMIntegrationRecord.SetCurrentKey("Integration ID");
        CRMIntegrationRecord.SetRange("Integration ID", ServiceItemLine.SystemId);
        if not CRMIntegrationRecord.FindFirst() then
            exit;

        CRMIntegrationRecord."Last Synch. CRM Modified On" := CurrentDateTime();
        CRMIntegrationRecord."Last Synch. CRM Result" := CRMIntegrationRecord."Last Synch. CRM Result"::Success;
        CRMIntegrationRecord."Last Synch. Modified On" := CurrentDateTime();
        CRMIntegrationRecord."Last Synch. Result" := CRMIntegrationRecord."Last Synch. Result"::Success;
        CRMIntegrationRecord.Skipped := true;
        CRMIntegrationRecord."Skip Reimport" := true;
        CRMIntegrationRecord.Modify();
    end;

    local procedure UncoupleRecord(ServiceLine: Record "Service Line")
    var
        FSConnectionSetup: Record "FS Connection Setup";
        CRMIntegrationRecord: Record "CRM Integration Record";
    begin
        if not FSConnectionSetup.IsIntegrationTypeServiceEnabled() then
            exit;

        CRMIntegrationRecord.SetCurrentKey("Integration ID");
        CRMIntegrationRecord.SetRange("Integration ID", ServiceLine.SystemId);
        if not CRMIntegrationRecord.FindFirst() then
            exit;

        CRMIntegrationRecord."Last Synch. CRM Modified On" := CurrentDateTime();
        CRMIntegrationRecord."Last Synch. CRM Result" := CRMIntegrationRecord."Last Synch. CRM Result"::Success;
        CRMIntegrationRecord."Last Synch. Modified On" := CurrentDateTime();
        CRMIntegrationRecord."Last Synch. Result" := CRMIntegrationRecord."Last Synch. Result"::Success;
        CRMIntegrationRecord.Skipped := true;
        CRMIntegrationRecord."Skip Reimport" := true;
        CRMIntegrationRecord.Modify();
    end;

    internal procedure MarkArchivedServiceOrder(ServiceHeader: Record "Service Header")
    var
        FSConnectionSetup: Record "FS Connection Setup";
        CRMIntegrationRecord: Record "CRM Integration Record";
    begin
        if not FSConnectionSetup.IsIntegrationTypeServiceEnabled() then
            exit;

        CRMIntegrationRecord.SetRange("Table ID", Database::"Service Header");
        CRMIntegrationRecord.SetRange("Integration ID", ServiceHeader.SystemId);
        if CRMIntegrationRecord.FindFirst() then begin
            CRMIntegrationRecord."Archived Service Header Id" := GetLatestServiceOrderArchiveSystemId(ServiceHeader."No.");
            CRMIntegrationRecord."Archived Service Order" := true;
            CRMIntegrationRecord.Modify();
        end;
    end;

    internal procedure MarkArchivedServiceOrderLine(var ServiceLine: Record "Service Line"; var ServiceLineArchive: Record "Service Line Archive")
    var
        FSConnectionSetup: Record "FS Connection Setup";
        CRMIntegrationRecord: Record "CRM Integration Record";
    begin
        if not FSConnectionSetup.IsIntegrationTypeServiceEnabled() then
            exit;

        CRMIntegrationRecord.SetRange("Table ID", Database::"Service Line");
        CRMIntegrationRecord.SetRange("Integration ID", ServiceLine.SystemId);
        if CRMIntegrationRecord.FindFirst() then begin
            CRMIntegrationRecord."Archived Service Line Id" := ServiceLineArchive.SystemId;
            CRMIntegrationRecord.Modify();
        end;
    end;

    local procedure GetLatestServiceOrderArchiveSystemId(OrderNo: Code[20]): Guid
    var
        ServiceHeaderArchive: Record "Service Header Archive";
        EmptyGuid: Guid;
    begin
        ServiceHeaderArchive.SetRange("Document Type", ServiceHeaderArchive."Document Type"::Order);
        ServiceHeaderArchive.SetRange("No.", OrderNo);
        if not ServiceHeaderArchive.FindLast() then
            exit(EmptyGuid);

        exit(ServiceHeaderArchive.SystemId);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CRM Integration Management", 'OnBeforeOpenCoupledNavRecordPage', '', true, false)]
    local procedure OnBeforeOpenCoupledNavRecordPage(CRMID: Guid; CRMEntityTypeName: Text; var Result: Boolean; var IsHandled: Boolean)
    begin
        if IsHandled or Result or (CRMEntityTypeName <> 'msdyn_workorder') then
            exit;

        if not OnlyServiceHeaderArchiveExists(CRMID) then
            exit;
        Result := OpenServiceHeaderArchive(CRMID);

        IsHandled := Result;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CRM Integration Management", 'OnBeforeOpenRecordCardPage', '', true, false)]
    local procedure OnBeforeOpenRecordCardPage(RecordID: RecordID; var IsHandled: Boolean)
    var
        ServiceHeader: Record "Service Header";
        RecordRef: RecordRef;
    begin
        RecordRef := RecordID.GetRecord();
        case RecordID.TableNo of
            Database::"Service Header":
                begin
                    RecordRef.SetTable(ServiceHeader);
                    Page.Run(Page::"Service Order", ServiceHeader);
                    IsHandled := true;
                end;
        end;
    end;

    local procedure OnlyServiceHeaderArchiveExists(CRMID: Guid): Boolean
    var
        CRMIntegrationRecord: Record "CRM Integration Record";
        ServiceHeader: Record "Service Header";
        ServiceHeaderArchive: Record "Service Header Archive";
    begin
        CRMIntegrationRecord.SetRange("Table ID", Database::"Service Header");
        CRMIntegrationRecord.SetRange("CRM ID", CRMID);
        if not CRMIntegrationRecord.FindFirst() then
            exit(false);

        if ServiceHeader.GetBySystemId(CRMIntegrationRecord."Integration ID") then
            exit(false);

        if ServiceHeaderArchive.GetBySystemId(CRMIntegrationRecord."Archived Service Header Id") then
            exit(true);
    end;

    local procedure OpenServiceHeaderArchive(CRMID: Guid): Boolean
    var
        CRMIntegrationRecord: Record "CRM Integration Record";
        ServiceHeaderArchive: Record "Service Header Archive";
    begin
        CRMIntegrationRecord.SetRange("Table ID", Database::"Service Header");
        CRMIntegrationRecord.SetRange("CRM ID", CRMID);
        if not CRMIntegrationRecord.FindFirst() then
            exit(false);

        if not ServiceHeaderArchive.GetBySystemId(CRMIntegrationRecord."Archived Service Header Id") then
            exit(false);

        Page.Run(Page::"Service Order Archive", ServiceHeaderArchive);
        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetUpNewLineOnNewLine(var JobJournalLine: Record "Job Journal Line"; var JobJournalTemplate: Record "Job Journal Template"; var JobJournalBatch: Record "Job Journal Batch"; var Handled: Boolean);
    begin
    end;
}