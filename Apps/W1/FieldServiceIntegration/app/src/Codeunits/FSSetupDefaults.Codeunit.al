// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Integration.Dataverse;
using Microsoft.Integration.D365Sales;
using Microsoft.Integration.SyncEngine;
using Microsoft.Utilities;
using System.Threading;
using Microsoft.Projects.Project.Job;
using Microsoft.Service.Item;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Projects.Project.Journal;
using System.Environment.Configuration;
using Microsoft.Inventory.Location;

codeunit 6611 "FS Setup Defaults"
{
    var
        CRMProductName: Codeunit "CRM Product Name";
        JobQueueCategoryLbl: Label 'BCI INTEG', Locked = true;
        OptionJobQueueCategoryLbl: Label 'BCI OPTION', Locked = true;
        CategoryTok: Label 'AL Field Service Integration', Locked = true;
        JobQueueEntryNameTok: Label ' %1 - %2 synchronization job.', Comment = '%1 = The Integration Table Name to synchronized (ex. CUSTOMER), %2 = CRM product name';
        IntegrationTablePrefixTok: Label 'Dynamics CRM', Comment = 'Product name', Locked = true;

    internal procedure ResetConfiguration(var FSConnectionSetup: Record "FS Connection Setup")
    var
        CDSIntegrationMgt: Codeunit "CDS Integration Mgt.";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetConfiguration(FSConnectionSetup, IsHandled);
        if IsHandled then
            exit;

        CDSIntegrationMgt.RegisterConnection();
        CDSIntegrationMgt.ActivateConnection();

        ResetProjectTaskMapping(FSConnectionSetup, 'PROJECTTASK', true);
        ResetProjectJournalLineWOProductMapping(FSConnectionSetup, 'PJLINE-WORDERPRODUCT', true);
        ResetProjectJournalLineWOServiceMapping(FSConnectionSetup, 'PJLINE-WORDERSERVICE', true);
        ResetServiceItemCustomerAssetMapping(FSConnectionSetup, 'SVCITEM-CUSTASSET', true);
        ResetResourceBookableResourceMapping(FSConnectionSetup, 'RESOURCE-BOOKABLERSC', true);
        ResetLocationMapping(FSConnectionSetup, 'LOCATION', true);
        SetCustomIntegrationsTableMappings(FSConnectionSetup);
    end;

    internal procedure ResetProjectTaskMapping(var FSConnectionSetup: Record "FS Connection Setup"; IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        JobTask: Record "Job Task";
        FSProjectTask: Record "FS Project Task";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeResetProjectTaskMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        JobTask.Reset();
        JobTask.SetRange("Job Task Type", JobTask."Job Task Type"::Posting);
        InsertIntegrationTableMapping(
          IntegrationTableMapping, IntegrationTableMappingName,
          Database::"Job Task", Database::"FS Project Task",
          FSProjectTask.FieldNo(ProjectTaskId), FSProjectTask.FieldNo(ModifiedOn),
          '', '', false);

        IntegrationTableMapping.SetTableFilter(
          GetTableFilterFromView(Database::"Job Task", JobTask.TableCaption(), JobTask.GetView()));
        if not ShouldResetServiceItemMapping() then
            IntegrationTableMapping."Dependency Filter" := 'CUSTOMER|RESOURCE-BOOKABLERSC'
        else
            IntegrationTableMapping."Dependency Filter" := 'CUSTOMER|RESOURCE-BOOKABLERSC|SVCITEM-CUSTASSET';
        IntegrationTableMapping.Modify();

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          JobTask.FieldNo("Job No."),
          FSProjectTask.FieldNo(ProjectNumber),
          IntegrationFieldMapping.Direction::ToIntegrationTable,
          '', true, false);

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          JobTask.FieldNo("Job Task No."),
          FSProjectTask.FieldNo(ProjectTaskNumber),
          IntegrationFieldMapping.Direction::ToIntegrationTable,
          '', true, false);

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          JobTask.FieldNo(Description),
          FSProjectTask.FieldNo(Description),
          IntegrationFieldMapping.Direction::ToIntegrationTable,
          '', true, false);

        RecreateJobQueueEntryFromIntTableMapping(IntegrationTableMapping, 1, ShouldRecreateJobQueueEntry, 5);
    end;

    internal procedure ResetProjectJournalLineWOProductMapping(var FSConnectionSetup: Record "FS Connection Setup"; IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        FSWorkOrderProduct: Record "FS Work Order Product";
        JobJournalLine: Record "Job Journal Line";
        CDSCompany: Record "CDS Company";
        CDSIntegrationMgt: Codeunit "CDS Integration Mgt.";
        IsHandled: Boolean;
        EmptyGuid: Guid;
    begin
        IsHandled := false;
        OnBeforeResetProjectJournalLineWOProductMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        FSWorkOrderProduct.Reset();
        FSWorkOrderProduct.SetRange(StateCode, FSWorkOrderProduct.StateCode::Active);
        FSWorkOrderProduct.SetFilter(ProjectTask, '<>' + Format(EmptyGuid));
        case FSConnectionSetup."Line Synch. Rule" of
            "FS Work Order Line Synch. Rule"::LineUsed:
                FSWorkOrderProduct.SetRange(LineStatus, FSWorkOrderProduct.LineStatus::Used);
            "FS Work Order Line Synch. Rule"::WorkOrderCompleted:
                FSWorkOrderProduct.SetFilter(WorkOrderStatus, Format(FSWorkOrderProduct.WorkOrderStatus::Completed) + '|' + Format(FSWorkOrderProduct.WorkOrderStatus::Posted));
        end;
        FSWorkOrderProduct.SetFilter(ProjectTask, '<>' + Format(EmptyGuid));
        if CDSIntegrationMgt.GetCDSCompany(CDSCompany) then
            FSWorkOrderProduct.SetRange(CompanyId, CDSCompany.CompanyId);

        InsertIntegrationTableMapping(
          IntegrationTableMapping, IntegrationTableMappingName,
          Database::"Job Journal Line", Database::"FS Work Order Product",
          FSWorkOrderProduct.FieldNo(WorkOrderProductId), FSWorkOrderProduct.FieldNo(ModifiedOn),
          '', '', false);

        IntegrationTableMapping.SetIntegrationTableFilter(
          GetTableFilterFromView(Database::"FS Work Order Product", FSWorkOrderProduct.TableCaption(), FSWorkOrderProduct.GetView()));
        IntegrationTableMapping."Dependency Filter" := 'CUSTOMER|ITEM-PRODUCT';
        IntegrationTableMapping.Modify();

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          JobJournalLine.FieldNo(Description),
          FSWorkOrderProduct.FieldNo(Name),
          IntegrationFieldMapping.Direction::FromIntegrationTable,
          '', true, false);

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          JobJournalLine.FieldNo("External Document No."),
          FSWorkOrderProduct.FieldNo(WorkOrderName),
          IntegrationFieldMapping.Direction::FromIntegrationTable,
          '', true, false);

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          JobJournalLine.FieldNo(Quantity),
          FSWorkOrderProduct.FieldNo(Quantity),
          IntegrationFieldMapping.Direction::FromIntegrationTable,
          '', true, false);

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          JobJournalLine.FieldNo("Qty. to Transfer to Invoice"),
          FSWorkOrderProduct.FieldNo(QtyToBill),
          IntegrationFieldMapping.Direction::FromIntegrationTable,
          '', true, false);

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          JobJournalLine.FieldNo("Currency Code"),
          FSWorkOrderProduct.FieldNo(TransactionCurrencyId),
          IntegrationFieldMapping.Direction::FromIntegrationTable,
          '', true, false);

        InsertIntegrationFieldMapping(
                 IntegrationTableMappingName,
                 JobJournalLine.FieldNo("Location Code"),
                 FSWorkOrderProduct.FieldNo(WarehouseId),
                 IntegrationFieldMapping.Direction::FromIntegrationTable,
                 '', true, false);

        OnAfterResetProjectJournalLineWOProductMapping(IntegrationTableMappingName);

        RecreateJobQueueEntryFromIntTableMapping(IntegrationTableMapping, 1, ShouldRecreateJobQueueEntry, 5);
    end;

    internal procedure ResetProjectJournalLineWOServiceMapping(var FSConnectionSetup: Record "FS Connection Setup"; IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        FSWorkOrderService: Record "FS Work Order Service";
        JobJournalLine: Record "Job Journal Line";
        CDSCompany: Record "CDS Company";
        CDSIntegrationMgt: Codeunit "CDS Integration Mgt.";
        IsHandled: Boolean;
        EmptyGuid: Guid;
    begin
        IsHandled := false;
        OnBeforeResetProjectJournalLineWOServiceMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        FSWorkOrderService.Reset();
        FSWorkOrderService.SetRange(StateCode, FSWorkOrderService.StateCode::Active);
        FSWorkOrderService.SetFilter(ProjectTask, '<>' + Format(EmptyGuid));
        case FSConnectionSetup."Line Synch. Rule" of
            "FS Work Order Line Synch. Rule"::LineUsed:
                FSWorkOrderService.SetRange(LineStatus, FSWorkOrderService.LineStatus::Used);
            "FS Work Order Line Synch. Rule"::WorkOrderCompleted:
                FSWorkOrderService.SetFilter(WorkOrderStatus, Format(FSWorkOrderService.WorkOrderStatus::Completed) + '|' + Format(FSWorkOrderService.WorkOrderStatus::Posted));
        end;
        if CDSIntegrationMgt.GetCDSCompany(CDSCompany) then
            FSWorkOrderService.SetRange(CompanyId, CDSCompany.CompanyId);
        InsertIntegrationTableMapping(
          IntegrationTableMapping, IntegrationTableMappingName,
          Database::"Job Journal Line", Database::"FS Work Order Service",
          FSWorkOrderService.FieldNo(WorkOrderServiceId), FSWorkOrderService.FieldNo(ModifiedOn),
          '', '', false);

        IntegrationTableMapping.SetIntegrationTableFilter(
          GetTableFilterFromView(Database::"FS Work Order Service", FSWorkOrderService.TableCaption(), FSWorkOrderService.GetView()));

        IntegrationTableMapping."Dependency Filter" := 'CUSTOMER|ITEM-PRODUCT|RESOURCE-BOOKABLERSC';
        IntegrationTableMapping.Modify();

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          JobJournalLine.FieldNo(Description),
          FSWorkOrderService.FieldNo(Name),
          IntegrationFieldMapping.Direction::FromIntegrationTable,
          '', true, false);

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          JobJournalLine.FieldNo("External Document No."),
          FSWorkOrderService.FieldNo(WorkOrderName),
          IntegrationFieldMapping.Direction::FromIntegrationTable,
          '', true, false);

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          JobJournalLine.FieldNo(Quantity),
          FSWorkOrderService.FieldNo(Duration),
          IntegrationFieldMapping.Direction::FromIntegrationTable,
          '', true, false);

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          JobJournalLine.FieldNo("Qty. to Transfer to Invoice"),
          FSWorkOrderService.FieldNo(DurationToBill),
          IntegrationFieldMapping.Direction::FromIntegrationTable,
          '', true, false);

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          JobJournalLine.FieldNo("Currency Code"),
          FSWorkOrderService.FieldNo(TransactionCurrencyId),
          IntegrationFieldMapping.Direction::FromIntegrationTable,
          '', true, false);

        OnAfterResetProjectJournalLineWOServiceMapping(IntegrationTableMappingName);

        RecreateJobQueueEntryFromIntTableMapping(IntegrationTableMapping, 1, ShouldRecreateJobQueueEntry, 5);
    end;

    internal procedure ResetResourceBookableResourceMapping(var FSConnectionSetup: Record "FS Connection Setup"; IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        FSBookableResource: Record "FS Bookable Resource";
        Resource: Record Resource;
        CDSCompany: Record "CDS Company";
        CDSIntegrationMgt: Codeunit "CDS Integration Mgt.";
        IsHandled: Boolean;
        EmptyGuid: Guid;
    begin
        IsHandled := false;
        OnBeforeResetResourceBookableResourceMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        Resource.SetRange(Blocked, false);
        Resource.SetRange("Use Time Sheet", false);
        Resource.SetRange("Base Unit of Measure", FSConnectionSetup."Hour Unit of Measure");

        FSBookableResource.Reset();
        FSBookableResource.SetRange(StateCode, FSBookableResource.StateCode::Active);
        FSBookableResource.SetFilter(ResourceType, Format(FSBookableResource.ResourceType::Generic) + '|' + Format(FSBookableResource.ResourceType::Account) + '|' + Format(FSBookableResource.ResourceType::Equipment));
        if CDSIntegrationMgt.GetCDSCompany(CDSCompany) then
            FSBookableResource.SetFilter(CompanyId, CDSCompany.CompanyId + '|' + Format(EmptyGuid));
        InsertIntegrationTableMapping(
          IntegrationTableMapping, IntegrationTableMappingName,
          Database::Resource, Database::"FS Bookable Resource",
          FSBookableResource.FieldNo(BookableResourceId), FSBookableResource.FieldNo(ModifiedOn),
          '', '', true);

        IntegrationTableMapping.SetTableFilter(
          GetTableFilterFromView(Database::Resource, Resource.TableCaption(), Resource.GetView()));
        IntegrationTableMapping.SetIntegrationTableFilter(
          GetTableFilterFromView(Database::"FS Bookable Resource", FSBookableResource.TableCaption(), FSBookableResource.GetView()));
        IntegrationTableMapping."Dependency Filter" := 'CUSTOMER|ITEM-PRODUCT';
        IntegrationTableMapping.Modify();

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          Resource.FieldNo(Name),
          FSBookableResource.FieldNo(Name),
          IntegrationFieldMapping.Direction::Bidirectional,
          '', true, false);

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          Resource.FieldNo("Vendor No."),
          FSBookableResource.FieldNo(AccountId),
          IntegrationFieldMapping.Direction::Bidirectional,
          '', true, false);

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          Resource.FieldNo("Unit Cost"),
          FSBookableResource.FieldNo(HourlyRate),
          IntegrationFieldMapping.Direction::Bidirectional,
          '', true, false);

        OnAfterResetResourceBookableResourceMapping(IntegrationTableMappingName);

        RecreateJobQueueEntryFromIntTableMapping(IntegrationTableMapping, 1, ShouldRecreateJobQueueEntry, 5);
    end;

    internal procedure ResetServiceItemCustomerAssetMapping(var FSConnectionSetup: Record "FS Connection Setup"; IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        FSCustomerAsset: Record "FS Customer Asset";
        ServiceItem: Record "Service Item";
        CDSCompany: Record "CDS Company";
        CDSIntegrationMgt: Codeunit "CDS Integration Mgt.";
        EmptyGuid: Guid;
        IsHandled: Boolean;
    begin
        if not ShouldResetServiceItemMapping() then begin
            Session.LogMessage('0000MMQ', 'The current company is not eligible to synchronize service items.', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit;
        end;

        IsHandled := false;
        OnBeforeResetServiceItemCustomerAssetMapping(IntegrationTableMappingName, ShouldRecreateJobQueueEntry, IsHandled);
        if IsHandled then
            exit;

        FSCustomerAsset.Reset();
        FSCustomerAsset.SetRange(StateCode, FSCustomerAsset.StateCode::Active);
        if CDSIntegrationMgt.GetCDSCompany(CDSCompany) then
            FSCustomerAsset.SetFilter(CompanyId, CDSCompany.CompanyId + '|' + EmptyGuid);

        ServiceItem.Reset();
        ServiceItem.SetRange(Blocked, ServiceItem.Blocked::" ");

        InsertIntegrationTableMapping(
          IntegrationTableMapping, IntegrationTableMappingName,
          Database::"Service Item", Database::"FS Customer Asset",
          FSCustomerAsset.FieldNo(CustomerAssetId), FSCustomerAsset.FieldNo(ModifiedOn),
          '', '', true);

        IntegrationTableMapping.SetIntegrationTableFilter(
          GetTableFilterFromView(Database::"FS Customer Asset", FSCustomerAsset.TableCaption(), FSCustomerAsset.GetView()));
        IntegrationTableMapping.SetTableFilter(
          GetTableFilterFromView(Database::"Service Item", ServiceItem.TableCaption(), ServiceItem.GetView()));
        IntegrationTableMapping."Dependency Filter" := 'CUSTOMER|ITEM-PRODUCT';
        IntegrationTableMapping.Modify();

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          ServiceItem.FieldNo(Description),
          FSCustomerAsset.FieldNo(Name),
          IntegrationFieldMapping.Direction::Bidirectional,
          '', true, false);

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          ServiceItem.FieldNo("Customer No."),
          FSCustomerAsset.FieldNo(Account),
          IntegrationFieldMapping.Direction::Bidirectional,
          '', true, false);

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          ServiceItem.FieldNo("Item No."),
          FSCustomerAsset.FieldNo(Product),
          IntegrationFieldMapping.Direction::Bidirectional,
          '', true, false);

        OnAfterResetServiceItemCustomerAssetMapping(IntegrationTableMappingName);

        RecreateJobQueueEntryFromIntTableMapping(IntegrationTableMapping, 1, ShouldRecreateJobQueueEntry, 5);
    end;

    internal procedure ResetLocationMapping(var FSConnectionSetup: Record "FS Connection Setup"; IntegrationTableMappingName: Code[20]; ShouldRecreateJobQueueEntry: Boolean)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        Location: Record Location;
        FSWarehouse: Record "FS Warehouse";
    begin
        Location.SetRange("Use As In-Transit", false);
        Location.SetFilter("Job Consump. Whse. Handling", '''' + Format(Location."Job Consump. Whse. Handling"::"No Warehouse Handling") + '''|''' +
                                    Format(Location."Job Consump. Whse. Handling"::"Warehouse Pick (optional)") + '''|''' +
                                    Format(Location."Job Consump. Whse. Handling"::"Inventory Pick") + '''');
        Location.SetFilter("Asm. Consump. Whse. Handling", '''' + Format(Location."Asm. Consump. Whse. Handling"::"No Warehouse Handling") + '''|''' +
                                    Format(Location."Asm. Consump. Whse. Handling"::"Warehouse Pick (optional)") + '''|''' +
                                    Format(Location."Asm. Consump. Whse. Handling"::"Inventory Movement") + '''');

        InsertIntegrationTableMapping(
          IntegrationTableMapping, IntegrationTableMappingName,
          Database::Location, Database::"FS Warehouse",
          FSWarehouse.FieldNo(WarehouseId), FSWarehouse.FieldNo(ModifiedOn),
          '', '', false);

        IntegrationTableMapping.SetTableFilter(
          GetTableFilterFromView(Database::Location, Location.TableCaption(), Location.GetView()));
        IntegrationTableMapping.Modify();

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          Location.FieldNo(Code),
          FSWarehouse.FieldNo(Name),
          IntegrationFieldMapping.Direction::ToIntegrationTable,
          '', true, false);

        InsertIntegrationFieldMapping(
          IntegrationTableMappingName,
          Location.FieldNo(Name),
          FSWarehouse.FieldNo(Description),
          IntegrationFieldMapping.Direction::ToIntegrationTable,
          '', true, false);

        RecreateJobQueueEntryFromIntTableMapping(IntegrationTableMapping, 1, ShouldRecreateJobQueueEntry, 5);
    end;

    local procedure ShouldResetServiceItemMapping(): Boolean
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        exit(ApplicationAreaMgmtFacade.IsPremiumExperienceEnabled());
    end;

    local procedure InsertIntegrationTableMapping(var IntegrationTableMapping: Record "Integration Table Mapping"; MappingName: Code[20]; TableNo: Integer; IntegrationTableNo: Integer; IntegrationTableUIDFieldNo: Integer; IntegrationTableModifiedFieldNo: Integer; TableConfigTemplateCode: Code[10]; IntegrationTableConfigTemplateCode: Code[10]; SynchOnlyCoupledRecords: Boolean)
    var
        CDSIntegrationMgt: Codeunit "CDS Integration Mgt.";
        UncoupleCodeunitId: Integer;
        Direction: Integer;
    begin
        Direction := GetDefaultDirection(TableNo);
        if Direction in [IntegrationTableMapping.Direction::ToIntegrationTable, IntegrationTableMapping.Direction::Bidirectional] then
            if CDSIntegrationMgt.HasCompanyIdField(IntegrationTableNo) then
                UncoupleCodeunitId := Codeunit::"CDS Int. Table Uncouple";
        IntegrationTableMapping.CreateRecord(MappingName, TableNo, IntegrationTableNo, IntegrationTableUIDFieldNo,
          IntegrationTableModifiedFieldNo, TableConfigTemplateCode, IntegrationTableConfigTemplateCode,
          SynchOnlyCoupledRecords, Direction, IntegrationTablePrefixTok,
          Codeunit::"CRM Integration Table Synch.", UncoupleCodeunitId);
    end;

    local procedure InsertIntegrationFieldMapping(IntegrationTableMappingName: Code[20]; TableFieldNo: Integer; IntegrationTableFieldNo: Integer; SynchDirection: Option; ConstValue: Text; ValidateField: Boolean; ValidateIntegrationTableField: Boolean)
    var
        IntegrationFieldMapping: Record "Integration Field Mapping";
    begin
        IntegrationFieldMapping.CreateRecord(IntegrationTableMappingName, TableFieldNo, IntegrationTableFieldNo, SynchDirection,
          ConstValue, ValidateField, ValidateIntegrationTableField);
    end;

    internal procedure CreateJobQueueEntry(IntegrationTableMapping: Record "Integration Table Mapping"; ServiceName: Text): Boolean
    begin
        exit(CreateJobQueueEntry(IntegrationTableMapping, Codeunit::"Integration Synch. Job Runner", StrSubstNo(JobQueueEntryNameTok, IntegrationTableMapping.GetTempDescription(), ServiceName)));
    end;

    local procedure CreateJobQueueEntry(var IntegrationTableMapping: Record "Integration Table Mapping"; JobCodeunitId: Integer; JobDescription: Text): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
        StartTime: DateTime;
    begin
        StartTime := CurrentDateTime() + 1000;
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", JobCodeunitId);
        JobQueueEntry.SetRange("Record ID to Process", IntegrationTableMapping.RecordId());
        JobQueueEntry.SetRange("Job Queue Category Code", JobQueueCategoryLbl);
        JobQueueEntry.SetRange(Status, JobQueueEntry.Status::Ready);
        JobQueueEntry.SetFilter("Earliest Start Date/Time", '<=%1', StartTime);
        if not JobQueueEntry.IsEmpty() then begin
            JobQueueEntry.DeleteTasks();
            Commit();
        end;

        JobQueueEntry.Init();
        Clear(JobQueueEntry.ID); // "Job Queue - Enqueue" is to define new ID
        JobQueueEntry."Earliest Start Date/Time" := StartTime;
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := JobCodeunitId;
        JobQueueEntry."Record ID to Process" := IntegrationTableMapping.RecordId();
        JobQueueEntry."Run in User Session" := false;
        JobQueueEntry."Notify On Success" := false;
        JobQueueEntry."Maximum No. of Attempts to Run" := 2;
        JobQueueEntry."Job Queue Category Code" := JobQueueCategoryLbl;
        JobQueueEntry.Status := JobQueueEntry.Status::Ready;
        JobQueueEntry."Rerun Delay (sec.)" := 30;
        JobQueueEntry.Description := CopyStr(JobDescription, 1, MaxStrLen(JobQueueEntry.Description));
        OnCreateJobQueueEntryOnBeforeJobQueueEnqueue(JobQueueEntry, IntegrationTableMapping, JobCodeunitId, JobDescription);
        exit(Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry))
    end;

    local procedure RecreateJobQueueEntryFromIntTableMapping(IntegrationTableMapping: Record "Integration Table Mapping"; IntervalInMinutes: Integer; ShouldRecreateJobQueueEntry: Boolean; InactivityTimeoutPeriod: Integer)
    begin
        RecreateJobQueueEntryFromIntTableMapping(IntegrationTableMapping, IntervalInMinutes, ShouldRecreateJobQueueEntry, InactivityTimeoutPeriod, CRMProductName.CDSServiceName(), false);
    end;

    internal procedure RecreateJobQueueEntryFromIntTableMapping(IntegrationTableMapping: Record "Integration Table Mapping"; IntervalInMinutes: Integer; ShouldRecreateJobQueueEntry: Boolean; InactivityTimeoutPeriod: Integer; ServiceName: Text; IsOption: Boolean)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Integration Synch. Job Runner");
        JobQueueEntry.SetRange("Record ID to Process", IntegrationTableMapping.RecordId());
        JobQueueEntry.DeleteTasks();

        JobQueueEntry.InitRecurringJob(IntervalInMinutes);
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"Integration Synch. Job Runner";
        JobQueueEntry."Record ID to Process" := IntegrationTableMapping.RecordId();
        JobQueueEntry."Run in User Session" := false;
        JobQueueEntry.Description :=
          CopyStr(StrSubstNo(JobQueueEntryNameTok, IntegrationTableMapping.Name, ServiceName), 1, MaxStrLen(JobQueueEntry.Description));
        JobQueueEntry."Maximum No. of Attempts to Run" := 10;
        JobQueueEntry.Status := JobQueueEntry.Status::Ready;
        JobQueueEntry."Rerun Delay (sec.)" := 30;
        JobQueueEntry."Inactivity Timeout Period" := InactivityTimeoutPeriod;
        if IsOption then
            JobQueueEntry."Job Queue Category Code" := OptionJobQueueCategoryLbl;
        if ShouldRecreateJobQueueEntry then
            Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry)
        else
            JobQueueEntry.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CRM Setup Defaults", 'OnGetCDSTableNo', '', false, false)]
    local procedure ReturnProxyTableNoOnGetCDSTableNo(BCTableNo: Integer; var CDSTableNo: Integer; var Handled: Boolean)
    var
        FSConnectionSetup: Record "FS Connection Setup";
    begin
        if Handled then
            exit;

        if not FSConnectionSetup.IsEnabled() then
            exit;

        case BCTableNo of
            Database::Resource:
                CDSTableNo := Database::"FS Bookable Resource";
            Database::"Service Item":
                CDSTableNo := Database::"FS Customer Asset";
            Database::"Job Task":
                CDSTableNo := Database::"FS Project Task";
            Database::Location:
                CDSTableNo := Database::"FS Warehouse";
        end;

        if CDSTableNo <> 0 then
            Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CRM Setup Defaults", 'OnAddEntityTableMapping', '', false, false)]
    local procedure AddProxyTablesOnAddEntityTableMapping(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        CRMSetupDefaults: Codeunit "CRM Setup Defaults";
    begin
        if not FSConnectionSetup.IsEnabled() then
            exit;

        CRMSetupDefaults.AddEntityTableMapping('bookableresource', Database::Resource, TempNameValueBuffer);
        CRMSetupDefaults.AddEntityTableMapping('bookableresource', Database::"FS Bookable Resource", TempNameValueBuffer);

        CRMSetupDefaults.AddEntityTableMapping('msdyn_customerasset', Database::"Service Item", TempNameValueBuffer);
        CRMSetupDefaults.AddEntityTableMapping('msdyn_customerasset', Database::"FS Customer Asset", TempNameValueBuffer);

        CRMSetupDefaults.AddEntityTableMapping('bcbi_projecttask', Database::"Job Task", TempNameValueBuffer);
        CRMSetupDefaults.AddEntityTableMapping('bcbi_projecttask', Database::"FS Project Task", TempNameValueBuffer);

        CRMSetupDefaults.AddEntityTableMapping('msdyn_workorderproduct', Database::"Job Journal Line", TempNameValueBuffer);
        CRMSetupDefaults.AddEntityTableMapping('msdyn_workorderproduct', Database::"FS Work Order Product", TempNameValueBuffer);

        CRMSetupDefaults.AddEntityTableMapping('msdyn_workorderservice', Database::"Job Journal Line", TempNameValueBuffer);
        CRMSetupDefaults.AddEntityTableMapping('msdyn_workorderservice', Database::"FS Work Order Service", TempNameValueBuffer);

        CRMSetupDefaults.AddEntityTableMapping('msdyn_warehouse', Database::Location, TempNameValueBuffer);
        CRMSetupDefaults.AddEntityTableMapping('msdyn_warehouse', Database::"FS Warehouse", TempNameValueBuffer);

        TempNameValueBuffer.SetRange(Name, 'product');
        TempNameValueBuffer.SetRange(Value, Format(Database::Resource));
        if TempNameValueBuffer.FindFirst() then
            TempNameValueBuffer.Delete();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CRM Setup Defaults", 'OnBeforeGetNameFieldNo', '', false, false)]
    local procedure ReturnNameFieldNoOnBeforeGetNameFieldNo(TableId: Integer; var FieldNo: Integer)
    var
        FSConnectionSetup: Record "FS Connection Setup";
        ServiceItem: Record "Service Item";
        FSCustomerAsset: Record "FS Customer Asset";
        FSBookableResource: Record "FS Bookable Resource";
        FSWorkOrderProduct: Record "FS Work Order Product";
        FSWorkOrderService: Record "FS Work Order Service";
        FSProjectTask: Record "FS Project Task";
        JobTask: Record "Job Task";
        JobJournalLine: Record "Job Journal Line";
        Location: Record Location;
        FSWarehouse: Record "FS Warehouse";
    begin
        if not FSConnectionSetup.IsEnabled() then
            exit;

        case TableId of
            Database::"Service Item":
                FieldNo := ServiceItem.FieldNo("No.");
            Database::"FS Customer Asset":
                FieldNo := FSCustomerAsset.FieldNo(Name);
            Database::"FS Bookable Resource":
                FieldNo := FSBookableResource.FieldNo(Name);
            Database::"FS Work Order Product":
                FieldNo := FSWorkOrderProduct.FieldNo(Name);
            Database::"FS Work Order Service":
                FieldNo := FSWorkOrderService.FieldNo(Name);
            Database::"FS Project Task":
                FieldNo := FSProjectTask.FieldNo(ProjectNumber);
            Database::"Job Task":
                FieldNo := JobTask.FieldNo("Job Task No.");
            Database::"Job Journal Line":
                FieldNo := JobJournalLine.FieldNo(Description);
            Database::"FS Warehouse":
                FieldNo := FSWarehouse.FieldNo(Name);
            Database::Location:
                FieldNo := Location.FieldNo(Code);
        end;
    end;

    procedure GetDefaultDirection(NAVTableID: Integer): Integer
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
    begin
        case NAVTableID of
            Database::"Service Item",
            Database::"Work Type",
            Database::"Resource":
                exit(IntegrationTableMapping.Direction::Bidirectional);
            Database::"Job Task",
            Database::Location:
                exit(IntegrationTableMapping.Direction::ToIntegrationTable);
            Database::"Job Journal Line":
                exit(IntegrationTableMapping.Direction::FromIntegrationTable);
        end;
    end;

    internal procedure GetTableFilterFromView(TableID: Integer; Caption: Text; View: Text): Text
    var
        FilterBuilder: FilterPageBuilder;
    begin
        FilterBuilder.AddTable(Caption, TableID);
        FilterBuilder.SetView(Caption, View);
        exit(FilterBuilder.GetView(Caption, false));
    end;

    internal procedure SetCustomIntegrationsTableMappings(FSConnectionSetup: Record "FS Connection Setup")
    begin
        OnAfterResetConfiguration(FSConnectionSetup);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CRM Integration Management", 'OnBeforeHandleCustomIntegrationTableMapping', '', false, false)]
    local procedure OnBeforeHandleCustomIntegrationTableMapping(var IsHandled: Boolean; IntegrationTableMappingName: Code[20])
    var
        FSConnectionSetup: Record "FS Connection Setup";
        IntegrationTableMapping: Record "Integration Table Mapping";
    begin
        if not FSConnectionSetup.IsEnabled() then
            exit;

        if not IntegrationTableMapping.Get(IntegrationTableMappingName) then
            exit;

        case IntegrationTableMapping."Table ID" of
            Database::Resource:
                if IntegrationTableMapping."Integration Table ID" = Database::"FS Bookable Resource" then
                    ResetResourceBookableResourceMapping(FSConnectionSetup, IntegrationTableMapping.Name, true);
            Database::"Job Task":
                if IntegrationTableMapping."Integration Table ID" = Database::"FS Project Task" then
                    ResetProjectTaskMapping(FSConnectionSetup, IntegrationTableMapping.Name, true);
            Database::"Service Item":
                if IntegrationTableMapping."Integration Table ID" = Database::"FS Customer Asset" then
                    ResetServiceItemCustomerAssetMapping(FSConnectionSetup, IntegrationTableMapping.Name, true);
            Database::"Job Journal Line":
                begin
                    if IntegrationTableMapping."Integration Table ID" = Database::"FS Work Order Product" then
                        ResetProjectJournalLineWOProductMapping(FSConnectionSetup, IntegrationTableMapping.Name, true);
                    if IntegrationTableMapping."Integration Table ID" = Database::"FS Work Order Service" then
                        ResetProjectJournalLineWOServiceMapping(FSConnectionSetup, IntegrationTableMapping.Name, true);
                end;
            Database::Location:
                if IntegrationTableMapping."Integration Table ID" = Database::"FS Warehouse" then
                    ResetLocationMapping(FSConnectionSetup, IntegrationTableMapping.Name, true);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterResetConfiguration(FSConnectionSetup: Record "FS Connection Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterResetProjectJournalLineWOProductMapping(IntegrationTableMappingName: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterResetProjectJournalLineWOServiceMapping(IntegrationTableMappingName: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterResetServiceItemCustomerAssetMapping(IntegrationTableMappingName: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterResetResourceBookableResourceMapping(var IntegrationTableMappingName: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeResetConfiguration(var FSConnectionSetup: Record "FS Connection Setup"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeResetProjectJournalLineWOProductMapping(var IntegrationTableMappingName: Code[20]; var ShouldRecreateJobQueueEntry: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeResetProjectJournalLineWOServiceMapping(var IntegrationTableMappingName: Code[20]; var ShouldRecreateJobQueueEntry: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeResetServiceItemCustomerAssetMapping(var IntegrationTableMappingName: Code[20]; var ShouldRecreateJobQueueEntry: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeResetProjectTaskMapping(var IntegrationTableMappingName: Code[20]; var ShouldRecreateJobQueueEntry: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeResetResourceBookableResourceMapping(var IntegrationTableMappingName: Code[20]; var ShouldRecreateJobQueueEntry: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateJobQueueEntryOnBeforeJobQueueEnqueue(var JobQueueEntry: Record "Job Queue Entry"; var IntegrationTableMapping: Record "Integration Table Mapping"; JobCodeunitId: Integer; JobDescription: Text)
    begin
    end;
}

