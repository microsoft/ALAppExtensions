// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Integration.Dataverse;
using Microsoft.Projects.Project.Job;
using Microsoft.Foundation.NoSeries;
using Microsoft.Projects.Project.Setup;
using Microsoft.Service.Item;
using Microsoft.Integration.SyncEngine;
using Microsoft.Sales.Customer;
using System.Telemetry;
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

codeunit 6610 "FS Int. Table Subscriber"
{
    SingleInstance = true;

    var
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
        MultiCompanySyncEnabledTxt: Label 'Multi-Company Synch Enabled', Locked = true;
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

    [EventSubscriber(ObjectType::Table, Database::"Integration Table Mapping", 'OnBeforeModifyEvent', '', false, false)]
    local procedure IntegrationTableMappingOnBeforeModifyEvent(var Rec: Record "Integration Table Mapping"; RunTrigger: Boolean)
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
        if ServiceItem.GetFilter("Service Item Components") = '' then
            Error(MandatoryFilterErr, ServiceItem.FieldCaption("Service Item Components"));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnBeforeTransferRecordFields', '', false, false)]
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
                    if CRMIntegrationRecord.FindByCRMID(FSWorkOrderProduct.WorkOrderIncident) then
                        ServiceItemLine.GetBySystemId(CRMIntegrationRecord."Integration ID");

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
                    if CRMIntegrationRecord.FindByCRMID(FSWorkOrderService.WorkOrderIncident) then
                        ServiceItemLine.GetBySystemId(CRMIntegrationRecord."Integration ID");

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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnAfterTransferRecordFields', '', false, false)]
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

                    UpdateQuantities(FSWorkOrderProduct, ServiceLine);
                    AdditionalFieldsWereModified := true;

                    DestinationRecordRef.GetTable(ServiceLine);
                end;

            'FS Work Order Service-Service Line':
                begin
                    SourceRecordRef.SetTable(FSWorkOrderService);
                    DestinationRecordRef.SetTable(ServiceLine);

                    UpdateQuantities(FSWorkOrderService, ServiceLine);
                    AdditionalFieldsWereModified := true;

                    DestinationRecordRef.GetTable(ServiceLine);
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Record Synch.", 'OnTransferFieldData', '', false, false)]
    local procedure OnTransferFieldData(SourceFieldRef: FieldRef; DestinationFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        CRMIntegrationRecord: Record "CRM Integration Record";
        FSWorkOrder: Record "FS Work Order";
        FSWorkOrderService: Record "FS Work Order Service";
        FSWorkOrderProduct: Record "FS Work Order Product";
        FSBookableResourceBooking: Record "FS Bookable Resource Booking";
        JobJournalLine: Record "Job Journal Line";
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

        if (SourceFieldRef.Record().Number = Database::"Service Line") and
            (DestinationFieldRef.Record().Number = Database::"FS Work Order Product") then
            case DestinationFieldRef.Name() of
                FSWorkOrderProduct.FieldName(EstimateQuantity):
                    begin
                        DestinationRecordRef := DestinationFieldRef.Record();
                        DestinationRecordRef.SetTable(FSWorkOrderProduct);
                        // only update estimated quantity if the line status is estimated
                        if FSWorkOrderProduct.LineStatus <> FSWorkOrderProduct.LineStatus::Estimated then begin
                            NewValue := FSWorkOrderProduct.EstimateQuantity;
                            IsValueFound := true;
                            NeedsConversion := false;
                        end;
                    end;
            end;

        if (SourceFieldRef.Record().Number = Database::"Service Line") and
            (DestinationFieldRef.Record().Number = Database::"FS Work Order Service") then
            case DestinationFieldRef.Name() of
                FSWorkOrderService.FieldName(EstimateDuration):
                    begin
                        DestinationRecordRef := DestinationFieldRef.Record();
                        DestinationRecordRef.SetTable(FSWorkOrderService);
                        // only update estimated quantity if the line status is estimated
                        if FSWorkOrderService.LineStatus <> FSWorkOrderService.LineStatus::Estimated then begin
                            NewValue := FSWorkOrderService.EstimateDuration;
                            IsValueFound := true;
                            NeedsConversion := false;
                            exit;
                        end;

                        SourceRecordRef := SourceFieldRef.Record();
                        SourceRecordRef.SetTable(ServiceLine);
                        DurationInHours := ServiceLine.Quantity;
                        DurationInMinutes := DurationInHours * 60;
                        NewValue := DurationInMinutes;
                        IsValueFound := true;
                        NeedsConversion := false;
                    end;
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
        if (SourceFieldRef.Record().Number = Database::"FS Bookable Resource Booking") then
            case SourceFieldRef.Name() of
                FSBookableResourceBooking.FieldName(Duration):
                    begin
                        SourceRecordRef := SourceFieldRef.Record();
                        SourceRecordRef.SetTable(FSBookableResourceBooking);
                        DurationInMinutes := FSBookableResourceBooking.Duration;
                        DurationInHours := (DurationInMinutes / 60);
                        NewValue := DurationInHours;
                        IsValueFound := true;
                        NeedsConversion := false;
                    end;
            end;
    end;

    local procedure UpdateQuantities(FSWorkOrderProduct: Record "FS Work Order Product"; var ServiceLine: Record "Service Line")
    begin
        ServiceLine.Validate(Quantity, GetMaxQuantity(FSWorkOrderProduct.EstimateQuantity, FSWorkOrderProduct.Quantity, FSWorkOrderProduct.QtyToBill));
        ServiceLine.Validate("Qty. to Ship", GetMaxQuantity(FSWorkOrderProduct.Quantity, FSWorkOrderProduct.QtyToBill) - ServiceLine."Quantity Shipped");
        ServiceLine.Validate("Qty. to Invoice", FSWorkOrderProduct.QtyToBill - ServiceLine."Quantity Invoiced");
    end;

    local procedure UpdateQuantities(FSWorkOrderProduct: Record "FS Work Order Service"; var ServiceLine: Record "Service Line")
    begin
        ServiceLine.Validate(Quantity, GetMaxQuantity(FSWorkOrderProduct.EstimateDuration, FSWorkOrderProduct.Duration, FSWorkOrderProduct.DurationToBill) / 60);
        ServiceLine.Validate("Qty. to Ship", GetMaxQuantity(FSWorkOrderProduct.Duration, FSWorkOrderProduct.DurationToBill) / 60 - ServiceLine."Quantity Shipped");
        ServiceLine.Validate("Qty. to Invoice", FSWorkOrderProduct.DurationToBill / 60 - ServiceLine."Quantity Invoiced");
    end;

    local procedure UpdateQuantities(FSBookableResourceBooking: Record "FS Bookable Resource Booking"; var ServiceLine: Record "Service Line")
    begin
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CRM Int. Table. Subscriber", 'OnFindNewValueForCoupledRecordPK', '', false, false)]
    local procedure OnFindNewValueForCoupledRecordPK(IntegrationTableMapping: Record "Integration Table Mapping"; SourceFieldRef: FieldRef; DestinationFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        CRMIntegrationRecord: Record "CRM Integration Record";
        FSWorkOrderService: Record "FS Work Order Service";
        FSWorkOrderProduct: Record "FS Work Order Product";
        ServiceLine: Record "Service Line";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        CRMUom: Record "CRM Uom";
        SourceRecordRef: RecordRef;
        NAVItemUomRecordId: RecordId;
        NAVItemUomId: Guid;
        NotCoupledCRMUomErr: Label 'The unit is not coupled to a unit of measure.';
    begin
        if not FSConnectionSetup.IsEnabled() then
            exit;

        if (SourceFieldRef.Record().Number = Database::"FS Work Order Product") then
            case SourceFieldRef.Name() of
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
        if (SourceFieldRef.Record().Number = Database::"FS Work Order Service") then
            case SourceFieldRef.Name() of
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
        if (SourceFieldRef.Record().Number = Database::"Service Line") then
            case SourceFieldRef.Name() of
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnAfterInsertRecord', '', false, false)]
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
                                        if not TryModifyWorkOrderProduct(FSWorkOrderProduct) then begin
                                            Session.LogMessage('0000MMV', UnableToModifyWOPTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                                            ClearLastError();
                                        end;
                                    end
                                    else
                                        if FSWorkorderService.Get(JobUsageLink."External Id") then begin
                                            FSWorkorderService.DurationInvoiced += (JobPlanningLineInvoice."Quantity Transferred" * 60);
                                            if not TryModifyWorkOrderService(FSWorkOrderService) then begin
                                                Session.LogMessage('0000MMW', UnableToModifyWOSTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                                                ClearLastError();
                                            end;
                                        end;
                        until JobPlanningLineInvoice.Next() = 0;
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

    local procedure BudgetJobJournalLineNoOffset(): Integer
    begin
        // When a Work Order Service that has a coupled bookable resource is synchronized to BC
        // Two project journal lines are coupled: one billable line for the service item and one budget line for the resource
        // This is the offset number of the second line no. from the first line no.
        exit(37);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnBeforeIgnoreUnchangedRecordHandled', '', false, false)]
    local procedure HandleOnBeforeIgnoreUnchangedRecordHandled(SourceRecordRef: RecordRef; DestinationRecordRef: RecordRef)
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
                    ResetFSWorkOrderIncidentFromServiceOrderItemLine(SourceRecordRef, DestinationRecordRef);
                    ResetFSWorkOrderProductFromServiceOrderLine(SourceRecordRef, DestinationRecordRef);
                    ResetFSWorkOrderServiceFromServiceOrderLine(SourceRecordRef, DestinationRecordRef);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnAfterUnchangedRecordHandled', '', false, false)]
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
        ServiceLine.SetRange("Item Type", ServiceLine."Item Type"::Inventory);
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
                FSWorkOrderProductIdList.Add(FSWorkOrderProduct.WorkOrderProductId)
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
        ServiceLine.SetFilter("Item Type", '%1|%2', ServiceLine."Item Type"::Service, ServiceLine."Item Type"::"Non-Inventory");
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
                FSWorkOrderServiceIdList.Add(FSWorkOrderService.WorkOrderServiceId)
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
                        if ServiceLineToDelete.GetBySystemId(ServiceLine.SystemId) then
                            ServiceLineToDelete.Delete(true);
                    end;
                end;
            until ServiceLine.Next() = 0;

        FSBookableResourceBooking.Reset();
        FSBookableResourceBooking.SetRange(WorkOrder, FSWorkOrder.WorkOrderId);
        if FSBookableResourceBooking.FindSet() then begin
            repeat
                FSBookableResourceBookingIdList.Add(FSBookableResourceBooking.BookableResourceBookingId)
            until FSBookableResourceBooking.Next() = 0;

            foreach FSBookableResourceBookingId in FSBookableResourceBookingIdList do
                FSBookableResourceBookingIdFilter += FSBookableResourceBookingId + '|';
            FSBookableResourceBookingIdFilter := FSBookableResourceBookingIdFilter.TrimEnd('|');

            FSBookableResourceBooking2.SetFilter(BookableResourceBookingId, FSBookableResourceBookingIdFilter);
            FSBookableResourceBookingRecordRef.GetTable(FSBookableResourceBooking2);
            CRMIntegrationTableSynch.SynchRecordsFromIntegrationTable(FSBookableResourceBookingRecordRef, Database::"Service Line", false, false);
        end;
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

    local procedure ArchiveServiceOrder(ServiceHeader: Record "Service Header"; ArchivedServiceOrders: List of [Code[20]])
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnBeforeModifyRecord', '', false, false)]
    local procedure HandleOnBeforeModifyRecord(IntegrationTableMapping: Record "Integration Table Mapping"; SourceRecordRef: RecordRef; var DestinationRecordRef: RecordRef)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        SourceDestCode: Text;
    begin
        if not FSConnectionSetup.IsEnabled() then
            exit;

        SourceDestCode := GetSourceDestCode(SourceRecordRef, DestinationRecordRef);

        case SourceDestCode of
            'FS Work Order Service-Job Journal Line':
                UpdateCorrelatedJobJournalLine(SourceRecordRef, DestinationRecordRef);
        end;
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnAfterModifyRecord', '', false, false)]
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
                if FSWorkOrderProduct.LineStatus = FSWorkOrderProduct.LineStatus::Used then
                    JobJnlPostLine.RunWithCheck(JobJournalLine);
            "FS Work Order Line Post Rule"::WorkOrderCompleted:
                if FSWorkOrderProduct.WorkOrderStatus in [FSWorkOrderProduct.WorkOrderStatus::Completed] then
                    JobJnlPostLine.RunWithCheck(JobJournalLine);
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

        // Work Order Services couple to two Project Journal Lines (one budget line for the resource and one billable line for the item of type service)
        // we must find the other coupled lines and post them as well.
        CRMIntegrationRecord.SetRange("Table ID", Database::"Job Journal Line");
        CRMIntegrationRecord.SetRange("CRM ID", FSWorkOrderService.WorkOrderServiceId);
        if CRMIntegrationRecord.FindSet() then
            repeat
                if CRMIntegrationRecord."Integration ID" <> JobJournalLine.SystemId then
                    if CorrelatedJobJournalLine.GetBySystemId(CRMIntegrationRecord."Integration ID") then
                        JobJnlPostLine.RunWithCheck(CorrelatedJobJournalLine);
            until CRMIntegrationRecord.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnBeforeInsertRecord', '', false, false)]
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
        JobsSetup: Record "Jobs Setup";
        Resource: Record Resource;
        FSBookableResource: Record "FS Bookable Resource";
        LastJobJournalLine: Record "Job Journal Line";
        FSWorkOrderIncident: Record "FS Work Order Incident";
        FSWorkOrderProduct: Record "FS Work Order Product";
        FSWorkOrderService: Record "FS Work Order Service";
        FSBookableResourceBooking: Record "FS Bookable Resource Booking";
        ServiceItemLine: Record "Service Item Line";
        ServiceLine: Record "Service Line";
        CRMProductName: Codeunit "CRM Product Name";
        NoSeries: Codeunit "No. Series";
        FSIntegrationMgt: Codeunit "FS Integration Mgt.";
        RecID: RecordId;
        SourceDestCode: Text;
        BillingAccId: Guid;
        ServiceAccId: Guid;
        WorkOrderId: Guid;
        WorkOrderIncidentId: Guid;
        Handled: Boolean;
    begin
        if not FSConnectionSetup.IsEnabled() then
            exit;

        SourceDestCode := GetSourceDestCode(SourceRecordRef, DestinationRecordRef);

        case SourceDestCode of
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
                                FSBookableResource.ResourceType := FSBookableResource.ResourceType::Generic;
                    end;
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
                        FSBookableResource.ResourceType::Generic:
                            Resource.Type := Resource.Type::Person;
                    end;
                    Resource."Base Unit of Measure" := FSConnectionSetup."Hour Unit of Measure";
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
                        JobsSetup.Get();
                        Job.Get(JobJournalLine."Job No.");
                        if not JobJournalTemplate.Get(FSConnectionSetup."Job Journal Template") then
                            Error(JobJournalIncorrectSetupErr, JobJournalTemplate.TableCaption(), FSConnectionSetup.TableCaption());
                        if not JobJournalBatch.Get(FSConnectionSetup."Job Journal Template", FSConnectionSetup."Job Journal Batch") then
                            Error(JobJournalIncorrectSetupErr, JobJournalBatch.TableCaption(), FSConnectionSetup.TableCaption());
                        JobJournalLine."Journal Template Name" := JobJournalTemplate.Name;
                        JobJournalLine."Journal Batch Name" := JobJournalBatch.Name;
                        LastJobJournalLine.SetRange("Journal Template Name", JobJournalTemplate.Name);
                        LastJobJournalLine.SetRange("Journal Batch Name", JobJournalBatch.Name);
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
            'Service Item Line-FS Work Order Incident':
                begin
                    SourceRecordRef.SetTable(ServiceItemLine);
                    DestinationRecordRef.SetTable(FSWorkOrderIncident);
                    if CRMIntegrationRecord.FindIDFromRecordID(GetServiceOrderRecordId(ServiceItemLine."Document No."), WorkOrderId) then
                        FSWorkOrderIncident.WorkOrder := WorkOrderId;
                    FSWorkOrderIncident.IncidentType := FSIntegrationMgt.GetDefaultWorkOrderIncident();
                    DestinationRecordRef.GetTable(FSWorkOrderIncident);
                end;
            'Service Line-FS Work Order Product':
                begin
                    SourceRecordRef.SetTable(ServiceLine);
                    DestinationRecordRef.SetTable(FSWorkOrderProduct);
                    if CRMIntegrationRecord.FindIDFromRecordID(GetServiceOrderRecordId(ServiceLine."Document No."), WorkOrderId) then
                        FSWorkOrderProduct.WorkOrder := WorkOrderId;
                    if CRMIntegrationRecord.FindIDFromRecordID(GetServiceOrderItemLineRecordId(ServiceLine."Document No.", ServiceLine."Service Item Line No."), WorkOrderIncidentId) then
                        FSWorkOrderProduct.WorkOrderIncident := WorkOrderIncidentId;
                    DestinationRecordRef.GetTable(FSWorkOrderProduct);
                end;
            'Service Line-FS Work Order Service':
                begin
                    SourceRecordRef.SetTable(ServiceLine);
                    DestinationRecordRef.SetTable(FSWorkOrderService);
                    if CRMIntegrationRecord.FindIDFromRecordID(GetServiceOrderRecordId(ServiceLine."Document No."), WorkOrderId) then
                        FSWorkOrderService.WorkOrder := WorkOrderId;
                    if CRMIntegrationRecord.FindIDFromRecordID(GetServiceOrderItemLineRecordId(ServiceLine."Document No.", ServiceLine."Service Item Line No."), WorkOrderIncidentId) then
                        FSWorkOrderService.WorkOrderIncident := WorkOrderIncidentId;
                    DestinationRecordRef.GetTable(FSWorkOrderService);
                end;
        end;
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnDeletionConflictDetectedSetRecordStateAndSynchAction', '', false, false)]
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

        // write back consumption data to Field Service
        if not FSWorkOrderProduct.WritePermission() then
            exit;
        if not FSWorkOrderService.WritePermission() then
            exit;
        if FSWorkOrderProduct.Get(CRMIntegrationRecord."CRM ID") then begin
            FSWorkOrderProduct.QuantityConsumed += JobPlanningLine.Quantity;
            if not TryModifyWorkOrderProduct(FSWorkOrderProduct) then begin
                Session.LogMessage('0000MMZ', UnableToModifyWOPTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                ClearLastError();
            end;
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

            FSWorkOrderService.DurationConsumed += (60 * JobPlanningLine.Quantity);
            if not TryModifyWorkOrderService(FSWorkOrderService) then begin
                Session.LogMessage('0000MN0', UnableToModifyWOSTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                ClearLastError();
            end;
        end;
    end;

    [TryFunction]
    local procedure TryModifyWorkOrderProduct(var FSWorkOrderProduct: Record "FS Work Order Product")
    begin
        FSWorkOrderProduct.Modify();
    end;

    [TryFunction]
    local procedure TryModifyWorkOrderService(var FSWorkOrderService: Record "FS Work Order Service")
    begin
        FSWorkOrderService.Modify();
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
        BookableResourceCoupled: Boolean;
        BookableResourceCoupledToDeleted: Boolean;
        FSQuantity: Decimal;
        FSQuantityToBill: Decimal;
        QuantityCurrentlyConsumed: Decimal;
        QuantityCurrentlyInvoiced: Decimal;
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
                    if Item.Type = Item.Type::"Non-Inventory" then
                        JobJournalLine.Validate("Line Type", JobJournalLine."Line Type"::" ")
                    else
                        JobJournalLine.Validate("Line Type", JobJournalLine."Line Type"::Billable);
                    // set Item, but for work order products we must keep its Business Central Unit Cost
                    JobJournalLine.Validate("No.", Item."No.");
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
                    JobJournalLine.Validate("Qty. to Transfer to Invoice", FSQuantityToBill - QuantityCurrentlyInvoiced);
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

    local procedure IgnorePostedJobJournalLinesOnQueryPostFilterIgnoreRecord(SourceRecordRef: RecordRef; var IgnoreRecord: Boolean)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        FSWorkOrderProduct: Record "FS Work Order Product";
        FSWorkOrderService: Record "FS Work Order Service";
        FieldServiceId: Guid;
        QuantityCurrentlyConsumed: Decimal;
        QuantityCurrentlyInvoiced: Decimal;
        FSQuantityToConsume: Decimal;
        FSQuantityToInvoice: Decimal;
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
                    FieldServiceId := FSWorkOrderProduct.WorkOrderProductId;
                    if FSWorkOrderProduct.LineStatus = FSWorkOrderProduct.LineStatus::Used then begin
                        FSQuantityToConsume := FSWorkOrderProduct.Quantity;
                        FSQuantityToInvoice := FSWorkOrderProduct.QtyToBill;
                    end;
                end;
            Database::"FS Work Order Service":
                begin
                    SourceRecordRef.SetTable(FSWorkOrderService);
                    FieldServiceId := FSWorkOrderService.WorkOrderServiceId;
                    if FSWorkOrderService.LineStatus = FSWorkOrderService.LineStatus::Used then begin
                        FSQuantityToConsume := FSWorkOrderService.Duration / 60;
                        FSQuantityToInvoice := FSWorkOrderService.DurationToBill / 60;
                    end;
                end;
        end;

        SetCurrentProjectPlanningQuantities(SourceRecordRef, QuantityCurrentlyConsumed, QuantityCurrentlyInvoiced);

        if (QuantityCurrentlyConsumed = FSQuantityToConsume) and (QuantityCurrentlyInvoiced = FSQuantityToInvoice) then
            IgnoreRecord := true;
    end;

    local procedure IgnoreArchievedServiceOrdersOnQueryPostFilterIgnoreRecord(SourceRecordRef: RecordRef; var IgnoreRecord: Boolean)
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

    local procedure IgnoreArchievedCRMWorkOrdersOnQueryPostFilterIgnoreRecord(SourceRecordRef: RecordRef; var IgnoreRecord: Boolean)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        FSWorkOrder: Record "FS Work Order";
        CRMIntegrationRecord: Record "CRM Integration Record";
    begin
        if not FSConnectionSetup.IsEnabled() then
            exit;

        if IgnoreRecord then
            exit;

        SourceRecordRef.SetTable(FSWorkOrder);
        if not CRMIntegrationRecord.FindByCRMID(FSWorkOrder.WorkOrderId) then
            exit;

        if CRMIntegrationRecord."Archived Service Order" then
            IgnoreRecord := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Table Synch.", 'OnAfterInitSynchJob', '', true, true)]
    local procedure LogTelemetryOnAfterInitSynchJob(ConnectionType: TableConnectionType; IntegrationTableID: Integer)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        IntegrationTableMapping: Record "Integration Table Mapping";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        IntegrationRecordRef: RecordRef;
        TelemetryCategories: Dictionary of [Text, Text];
        IntegrationTableName: Text;
    begin
        if ConnectionType <> TableConnectionType::CRM then
            exit;

        if FSConnectionSetup.IsEnabled() then
            exit;

        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::Dataverse);
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        IntegrationTableMapping.SetRange("Multi Company Synch. Enabled", true);
        IntegrationTableMapping.SetRange("Table ID", IntegrationTableID);
        if not IntegrationTableMapping.IsEmpty() then begin
            FeatureTelemetry.LogUptake('0000LCO', 'Dataverse Multi-Company Synch', Enum::"Feature Uptake Status"::Used);
            FeatureTelemetry.LogUsage('0000LCQ', 'Dataverse Multi-Company Synch', 'Entity sync');
            Session.LogMessage('0000LCS', MultiCompanySyncEnabledTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        end;
        IntegrationTableMapping.SetRange("Table ID");
        IntegrationTableMapping.SetRange("Integration Table ID", IntegrationTableID);
        if not IntegrationTableMapping.IsEmpty() then begin
            FeatureTelemetry.LogUptake('0000LCP', 'Dataverse Multi-Company Synch', Enum::"Feature Uptake Status"::Used);
            FeatureTelemetry.LogUsage('0000LCR', 'Dataverse Multi-Company Synch', 'Entity sync');
            Session.LogMessage('0000LCT', MultiCompanySyncEnabledTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        end;

        TelemetryCategories.Add('Category', CategoryTok);
        TelemetryCategories.Add('IntegrationTableID', Format(IntegrationTableID));
        if TryCalculateTableName(IntegrationRecordRef, IntegrationTableID, IntegrationTableName) then
            TelemetryCategories.Add('IntegrationTableName', IntegrationTableName);

        if IntegrationTableID in [
                Database::"FS Project Task",
                Database::"FS Work Order Product",
                Database::"FS Work Order Service",
                Database::"FS Customer Asset",
                Database::"FS Bookable Resource",
                Database::"FS Resource Pay Type",
                Database::"FS Warehouse"] then begin
            Session.LogMessage('0000M9F', FSEntitySynchTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, TelemetryCategories);
            FeatureTelemetry.LogUsage('0000M9E', 'Field Service Integration', 'Entity synch');
            FeatureTelemetry.LogUptake('0000M9D', 'Field Service Integration', Enum::"Feature Uptake Status"::Used);
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CRM Integration Management", 'OnIsCRMIntegrationRecord', '', false, false)]
    local procedure HandleOnIsCRMIntegrationRecord(TableID: Integer; var isIntegrationRecord: Boolean)
    begin
        if TableID = Database::"Service Header Archive" then
            isIntegrationRecord := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterDeleteEvent', '', false, false)]
    local procedure HandleOnAfterDeleteAfterPosting(var Rec: Record "Service Header")
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

    procedure MarkArchivedServiceOrder(ServiceHeader: Record "Service Header")
    var
        FSConnectionSetup: Record "FS Connection Setup";
        CRMIntegrationRecord: Record "CRM Integration Record";
    begin
        if not FSConnectionSetup.IsEnabled() then
            exit;

        CRMIntegrationRecord.SetRange("Table ID", Database::"Service Header");
        CRMIntegrationRecord.SetRange("Integration ID", ServiceHeader.SystemId);
        if CRMIntegrationRecord.FindFirst() then begin
            CRMIntegrationRecord."Archived Service Order" := true;
            CRMIntegrationRecord.Modify();
        end;
    end;

    local procedure MarkArchivedServiceOrderLine(var ServiceLine: Record "Service Line"; var ServiceLineArchive: Record "Service Line Archive")
    var
        FSConnectionSetup: Record "FS Connection Setup";
        CRMIntegrationRecord: Record "CRM Integration Record";
    begin
        if not FSConnectionSetup.IsEnabled() then
            exit;

        CRMIntegrationRecord.SetRange("Table ID", Database::"Service Line");
        CRMIntegrationRecord.SetRange("Integration ID", ServiceLine.SystemId);
        if CRMIntegrationRecord.FindFirst() then begin
            CRMIntegrationRecord."Archived Service Line Id" := ServiceLineArchive.SystemId;
            CRMIntegrationRecord.Modify();
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetUpNewLineOnNewLine(var JobJournalLine: Record "Job Journal Line"; var JobJournalTemplate: Record "Job Journal Template"; var JobJournalBatch: Record "Job Journal Batch"; var Handled: Boolean);
    begin
    end;
}