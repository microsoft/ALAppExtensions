// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Resources.Resource;
using System.Integration;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

codeunit 47006 "SL Project Migrator"
{
    Access = Internal;

    var
        NAProjectTxt: Label 'na', Locked = true;
        ProjectAddressTxt: Label 'PR', Locked = true;
        ProjectBillToAddressTxt: Label 'BI', Locked = true;
        StatusActiveTxt: Label 'A', Locked = true;
        StatusActiveHoldTxt: Label 'A|H', Locked = true;
        StatusActivePlanTxt: Label 'A|M', Locked = true;
        StatusHoldTxt: Label 'H', Locked = true;
        StatusPlanTxt: Label 'M', Locked = true;
        SLProjectCustomerTxt: Label 'SLProjectCustomer', Locked = true;
        SLProjectCustomerNameTxt: Label 'SL Internal Project Customer (created during migration)', Locked = true;

    internal procedure MigrateProjectModule()
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        Resource: Record Resource;
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
    begin
        SLCompanyAdditionalSettings.Get(CompanyName);
        if not SLCompanyAdditionalSettings.GetGLModuleEnabled() then
            exit;
        if not SLCompanyAdditionalSettings.GetProjectModuleEnabled() then
            exit;

        // Resources/Equipment
        if SLCompanyAdditionalSettings.GetResourceMasterOnly() then begin
            Resource.Reset();
            Resource.DeleteAll();
            this.MigrateProjectResources(true);
        end;

        // Projects
        if SLCompanyAdditionalSettings.GetProjectMasterOnly() then begin
            Job.Reset();
            Job.DeleteAll();
            this.MigrateProjects(true);
        end;

        // Tasks
        if SLCompanyAdditionalSettings.GetTaskMasterOnly() then begin
            JobTask.Reset();
            JobTask.DeleteAll();
            this.MigrateProjectTasks(true);
        end;
    end;

    internal procedure MigrateProjectResources(IncludeHold: Boolean)
    var
        SLPJEmploy: Record "SL PJEmploy";
        SLPJEquip: Record "SL PJEquip";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        ResourceStatusFilter: Text;
    begin
        if IncludeHold then
            ResourceStatusFilter := this.StatusActiveHoldTxt
        else
            ResourceStatusFilter := this.StatusActiveTxt;

        Clear(SLPJEmploy);
        SLPJEmploy.SetFilter(emp_status, ResourceStatusFilter);
        SLPJEmploy.SetRange(CpnyId, CompanyName);
        if not SLPJEmploy.FindSet() then
            exit;
        repeat
            DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLPJEmploy.RecordId));
            this.CreateResource(SLPJEmploy);
        until SLPJEmploy.Next() = 0;

        // Active SL PJEquip records only
        Clear(SLPJEquip);
        SLPJEquip.SetFilter(status, this.StatusActiveTxt);
        SLPJEquip.SetRange(CpnyId, CompanyName);
        if not SLPJEquip.FindSet() then
            exit;
        repeat
            DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLPJEquip.RecordId));
            this.CreateEquipmentResource(SLPJEquip);
        until SLPJEquip.Next() = 0;
    end;

    internal procedure CreateResource(SLPJEmploy: Record "SL PJEmploy")
    var
        Resource: Record Resource;
        Vendor: Record Vendor;
        SLHelperFunctions: Codeunit "SL Helper Functions";
        BaseUnitOfMeasure: Code[10];
    begin
        Clear(Resource);
        BaseUnitOfMeasure := 'HOUR';

        if not Resource.Get(SLPJEmploy.employee) then begin
            Resource.Init();
            Resource."No." := SLPJEmploy.employee;
            if SLPJEmploy.MSPType.TrimEnd() = '' then begin
                Resource.Type := Resource.Type::Person;
                Resource."Employment Date" := DT2Date(SLPJEmploy.date_hired);
            end
            else
                Resource.Type := Resource.Type::Machine;
            Resource.Name := CopyStr(SLHelperFunctions.NameFlip(SLPJEmploy.emp_name), 1, MaxStrLen(SLPJEmploy.emp_name));
            Resource."Search Name" := CopyStr(SLHelperFunctions.NameFlip(SLPJEmploy.emp_name.ToUpper()), 1, MaxStrLen(SLPJEmploy.emp_name));
            Resource."Base Unit of Measure" := BaseUnitOfMeasure;
            if SLPJEmploy.em_id01.TrimEnd() <> '' then
                if Vendor.Get(SLPJEmploy.em_id01) then begin
                    Resource."Vendor No." := Vendor."No.";
                    Resource.Address := Vendor.Address;
                    Resource."Address 2" := Vendor."Address 2";
                    Resource.City := Vendor.City;
                    Resource."Post Code" := Vendor."Post Code";
                    Resource.County := Vendor.County;
                    Resource."Country/Region Code" := Vendor."Country/Region Code";
                end;
            if SLPJEmploy.emp_status = this.StatusHoldTxt then
                Resource.Blocked := true;
            Resource."Direct Unit Cost" := this.GetResourceHourlyRate(SLPJEmploy.employee);
            Resource."Unit Cost" := this.GetResourceHourlyRate(SLPJEmploy.employee);

            Resource.Insert(true);
        end;
    end;

    internal procedure GetResourceHourlyRate(Employee: Text): Decimal
    var
        SLPJEmpPjt: Record "SL PJEmpPjt";
    begin
        Clear(SLPJEmpPjt);
        SLPJEmpPjt.SetFilter(employee, Employee);
        SLPJEmpPjt.SetFilter(project, NAProjectTxt);
        SLPJEmpPjt.SetAscending(effect_date, false);
        if not SLPJEmpPjt.FindFirst() then
            exit;
        exit(SLPJEmpPjt.labor_rate);
    end;

    internal procedure CreateEquipmentResource(SLPJEquip: Record "SL PJEquip")
    var
        Resource: Record Resource;
        SLHelperFunctions: Codeunit "SL Helper Functions";
    begin
        Clear(Resource);
        if not Resource.Get(SLPJEquip.equip_id) then begin
            Resource.Init();
            Resource."No." := SLPJEquip.equip_id;
            Resource.Type := Resource.Type::Machine;
            Resource.Name := CopyStr(SLHelperFunctions.NameFlip(SLPJEquip.equip_desc), 1, MaxStrLen(SLPJEquip.equip_desc));
            Resource."Search Name" := CopyStr(SLHelperFunctions.NameFlip(SLPJEquip.equip_desc.ToUpper()), 1, MaxStrLen(SLPJEquip.equip_desc));
            Resource."Direct Unit Cost" := this.GetEquipmentHourlyRate(SLPJEquip.equip_id);
            Resource."Unit Cost" := this.GetEquipmentHourlyRate(SLPJEquip.equip_id);

            Resource.Insert(true);
        end;
    end;

    internal procedure GetEquipmentHourlyRate(EquipmentID: Text): Decimal
    var
        SLPJEQRate: Record "SL PJEQRate";
    begin
        Clear(SLPJEQRate);
        SLPJEQRate.SetFilter(equip_id, EquipmentID);
        SLPJEQRate.SetFilter(project, this.NAProjectTxt);
        SLPJEQRate.SetAscending(effect_date, false);
        if not SLPJEQRate.FindFirst() then
            exit;
        exit(SLPJEQRate.rate1);
    end;

    internal procedure MigrateProjects(IncludePlan: Boolean);
    var
        SLPJProj: Record "SL PJProj";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        ProjectStatusFilter: Text;
    begin
        if IncludePlan then
            ProjectStatusFilter := this.StatusActivePlanTxt
        else
            ProjectStatusFilter := this.StatusActiveTxt;
        SLPJProj.SetFilter(status_pa, ProjectStatusFilter);
        SLPJProj.SetRange(CpnyId, CompanyName);
        if not SLPJProj.FindSet() then
            exit;
        repeat
            DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLPJProj.RecordId));
            this.CreateProject(SLPJProj);
        until SLPJProj.Next() = 0;
    end;

    internal procedure CreateProject(SLPJProj: Record "SL PJProj")
    var
        Customer: Record Customer;
        Job: Record Job;
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        SLPJAddr: Record "SL PJAddr";
        CustomerDataMigrationFacade: Codeunit "Customer Data Migration Facade";
        CustomerNametoSetLength: Text[50];
    begin
        Clear(Job);
        if not Job.Get(SLPJProj.project) then begin
            Job.Init();
            Job."No." := SLPJProj.project;
            Job.Description := CopyStr(SLPJProj.project_desc, 1, MaxStrLen(SLPJProj.project_desc));
            Job."Search Description" := CopyStr(SLPJProj.project_desc.ToUpper(), 1, MaxStrLen(SLPJProj.project_desc));
            if SLPJProj.customer.TrimEnd() <> '' then begin
                Clear(Customer);
                if Customer.Get(SLPJProj.customer) then begin
                    Job.Validate("Sell-to Customer No.", Customer."No.");
                    Job.Validate("Bill-to Customer No.", Customer."No.");
                end;
            end
            else
                if SLCompanyAdditionalSettings.GetTaskMasterOnly() then begin
                    CustomerDataMigrationFacade.CreateCustomerIfNeeded(this.SLProjectCustomerTxt, CopyStr(this.SLProjectCustomerNameTxt, 1, MaxStrLen(CustomerNametoSetLength)));
                    Job.Validate("Sell-to Customer No.", this.SLProjectCustomerTxt);
                    Job.Validate("Bill-to Customer No.", this.SLProjectCustomerTxt);
                end;

            // Project Address (Sell-to Address)
            Clear(SLPJAddr);
            if SLPJAddr.Get(this.ProjectAddressTxt, SLPJProj.project.TrimEnd(), this.ProjectAddressTxt) then begin
                Job.Validate("Sell-to Address", SLPJAddr.addr1);
                Job.Validate("Sell-to Address 2", CopyStr(SLPJAddr.addr2, 1, MaxStrLen(Job."Sell-to Address 2")));
                Job.Validate("Sell-to City", SLPJAddr.city);
                Job.Validate("Sell-to County", SLPJAddr.state);
                Job.Validate("Sell-to Country/Region Code", SLPJAddr.country);
                Job.Validate("Sell-to Post Code", SLPJAddr.zip);
                Job.Validate("Sell-to Phone No.", SLPJAddr.phone);
                if SLPJAddr.email.TrimEnd() <> '' then
                    Job.Validate("Sell-to E-Mail", SLPJAddr.email);
                Job.Validate("Sell-to Contact", SLPJAddr.individual);
            end;

            // Project Billing Address (Bill-to Address)
            Clear(SLPJAddr);
            if SLPJAddr.Get(this.ProjectAddressTxt, SLPJProj.project.TrimEnd(), this.ProjectBillToAddressTxt) then begin
                Job.Validate("Bill-to Address", SLPJAddr.addr1);
                Job.Validate("Bill-to Address 2", CopyStr(SLPJAddr.addr2, 1, MaxStrLen(Job."Bill-to Address 2")));
                Job.Validate("Bill-to City", SLPJAddr.city);
                Job.Validate("Bill-to County", SLPJAddr.state);
                Job.Validate("Bill-to Country/Region Code", SLPJAddr.country);
                Job.Validate("Bill-to Post Code", SLPJAddr.zip);
                Job.Validate("Bill-to Contact", SLPJAddr.individual);
            end;

            Job."Creation Date" := DT2Date(SLPJProj.crtd_datetime);
            Job."Starting Date" := DT2Date(SLPJProj.start_date);
            Job."Ending Date" := DT2Date(SLPJProj.end_date);
            if SLCompanyAdditionalSettings.GetResourceMasterOnly() then
                Job."Person Responsible" := SLPJProj.manager2;
            if SLPJProj.status_pa = this.StatusPlanTxt then
                Job.Status := Job.Status::Planning
            else
                Job.Status := Job.Status::Open;

            Job.Insert(true);
        end;
    end;

    internal procedure MigrateProjectTasks(IncludePlan: Boolean);
    var
        Job: Record Job;
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        JobStatusFilter: Text;
    begin
        if IncludePlan then
            JobStatusFilter := 'Open|Planning'
        else
            JobStatusFilter := 'Open';
        Job.SetFilter(Status, JobStatusFilter);
        If not Job.FindSet() then
            exit;
        repeat
            DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(Job.RecordId));
            this.CreateProjectTasks(Job."No.");
        until Job.Next() = 0;
    end;

    internal procedure CreateProjectTasks(JobNo: Code[20]);
    var
        ProjectTask: Record "Job Task";
        SLPJPent: Record "SL PJPent";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        Project: Text[16];
    begin
        Clear(SLPJPent);
        Project := CopyStr(JobNo, 1, MaxStrLen(Project));
        SLPJPent.SetFilter(project, Project);
        SLPJPent.SetFilter(status_pa, this.StatusActiveTxt);
        if not SLPJPent.FindSet() then
            exit;
        repeat
            DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLPJPent.RecordId));
            ProjectTask.Init();
            ProjectTask.Validate("Job No.", Project.TrimEnd());
            ProjectTask.Validate("Job Task No.", SLPJPent.pjt_entity);
            ProjectTask.Validate("Description", SLPJPent.pjt_entity_desc.TrimEnd());
            ProjectTask.Insert(true);
        until SLPJPent.Next() = 0;
    end;
}
