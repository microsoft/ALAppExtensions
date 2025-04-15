// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using System.Integration;
using Microsoft.CRM.Segment;
using System;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Project.Planning;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Payables;
using Microsoft.Projects.Project.Ledger;
using Microsoft.Sales.Document;
using Microsoft.Purchases.Document;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Budget;
using Microsoft.Integration.PowerBI;
using Microsoft.Finance.FinancialReports;
using Microsoft.Sales.RoleCenters;
using Microsoft.Inventory;
using Microsoft.CRM.Opportunity;
using Microsoft.Utilities;
using Microsoft.Finance.Dimension;
using Microsoft.Bank.Ledger;
using Microsoft.FixedAssets.Ledger;
using Microsoft.Projects.Resources.Ledger;
using Microsoft.AccountantPortal;
using Microsoft.Foundation.Task;
using Microsoft.Integration.Entity;
using System.Automation;

codeunit 5690 "Create Web Services"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Description = 'This codeunit should only be called in codeunit 5691 "Create Contoso Tenant Data"';

    trigger OnRun()
    begin
        CreatePowerBIWebServices();
        CreateSegmentWebService();
        CreateJobWebServices();
        CreatePowerBITenantWebServices();
        CreateAccountantPortalWebServices();
        CreateWorkflowWebhookWebServices();
        CreateExcelTemplateWebServices();
        CreateExtraWebServices();
    end;

    local procedure CreatePowerBIWebServices()
    var
        WebService: Record "Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        WebServiceManagement.CreateWebService(WebService."Object Type"::Page, PAGE::"Acc. Sched. KPI Web Service", PowerBIFinance(), true);

        WebServiceManagement.CreateWebService(WebService."Object Type"::Query, QUERY::"Top Customer Overview", '', true);
        WebServiceManagement.CreateWebService(WebService."Object Type"::Query, QUERY::"Sales Dashboard", '', true);
        WebServiceManagement.CreateWebService(WebService."Object Type"::Query, QUERY::"Item Sales by Customer", 'ItemSalesByCustomer', true);
        WebServiceManagement.CreateWebService(WebService."Object Type"::Query, QUERY::"Item Sales and Profit", 'ItemSalesAndProfit', true);
        WebServiceManagement.CreateWebService(WebService."Object Type"::Query, QUERY::"Sales Orders by Sales Person", 'SalesOrdersBySalesPerson', true);
        WebServiceManagement.CreateWebService(WebService."Object Type"::Query, QUERY::"Sales Opportunities", '', true);
    end;

    local procedure CreateExtraWebServices()
    var
        WebService: Record "Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        WebServiceManagement.CreateWebService(WebService."Object Type"::Codeunit, Codeunit::"Company Setup Service", 'CompanySetupService', true);
        WebServiceManagement.CreateWebService(WebService."Object Type"::Codeunit, Codeunit::"Exchange Service Setup", 'ExchangeServiceSetup', true);
        WebServiceManagement.CreateWebService(WebService."Object Type"::Codeunit, Codeunit::"Page Summary Provider", 'SummaryProvider', true);
        WebServiceManagement.CreateWebService(WebService."Object Type"::Codeunit, Codeunit::"Page Action Provider", 'PageActionProvider', true);

        WebServiceManagement.CreateWebService(WebService."Object Type"::Query, QUERY::"Dimension Sets", '', true);
        WebServiceManagement.CreateWebService(WebService."Object Type"::Page, PAGE::"Sales Order", '', true);
    end;

    local procedure CreateSegmentWebService()
    var
        TenantWebService: Record "Tenant Web Service";
        TenantWebServiceOData: Record "Tenant Web Service OData";
        SegmentLine: Record "Segment Line";
        WebServiceManagement: Codeunit "Web Service Management";
        ODataUtility: Codeunit ODataUtility;
        metaData: DotNet QueryMetadataReader;
        SelectText: Text;
        ODataV3FilterText: Text;
        ODataV4FilterText: Text;
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Query, QUERY::"Segment Lines", SegmentLines(), true);

        TenantWebService.Get(TenantWebService."Object Type"::Query, SegmentLines());

        ODataUtility.GetTenantWebServiceMetadata(TenantWebService, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, SegmentLine.FieldNo("Segment No."), Database::"Segment Line", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, SegmentLine.FieldNo("Contact No."), Database::"Segment Line", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, SegmentLine.FieldNo("Salesperson Code"), Database::"Segment Line", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, SegmentLine.FieldNo("Correspondence Type"), Database::"Segment Line", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, SegmentLine.FieldNo("Contact Name"), Database::"Segment Line", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, SegmentLine.FieldNo("Contact Company Name"), Database::"Segment Line", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, SegmentLine.FieldNo("Language Code"), Database::"Segment Line", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, SegmentLine.FieldNo("Contact Company No."), Database::"Segment Line", metaData);

        TenantWebServiceOData.Init();
        TenantWebServiceOData.TenantWebServiceID := TenantWebService.RecordId;
        if not TenantWebServiceOData.Insert() then;
        ODataUtility.GenerateSelectText(TenantWebService."Service Name", TenantWebService."Object Type", SelectText);
        ODataUtility.GenerateODataV3FilterText(TenantWebService."Service Name", TenantWebService."Object Type", ODataV3FilterText);
        ODataUtility.GenerateODataV4FilterText(TenantWebService."Service Name", TenantWebService."Object Type", ODataV4FilterText);
        WebServiceManagement.SetODataSelectClause(TenantWebServiceOData, SelectText);
        WebServiceManagement.SetODataFilterClause(TenantWebServiceOData, ODataV3FilterText);
        WebServiceManagement.SetODataV4FilterClause(TenantWebServiceOData, ODataV4FilterText);
        TenantWebServiceOData.Modify();
    end;

    local procedure CreateJobWebServices()
    begin
        CreateJobListWebService();
        CreateJobTaskLinesWebService();
        CreateJobPlanningLinesWebService();
    end;

    local procedure CreateJobListWebService()
    var
        Job: Record Job;
        TenantWebService: Record "Tenant Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"Job List", JobListTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Page, JobListTxt);
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, Job.FieldNo("No."), DATABASE::Job);
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, Job.FieldNo(Description), DATABASE::Job);
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, Job.FieldNo("Bill-to Customer No."), DATABASE::Job);
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, Job.FieldNo(Status), DATABASE::Job);
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, Job.FieldNo("Person Responsible"), DATABASE::Job);
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, Job.FieldNo("Search Description"), DATABASE::Job);
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, Job.FieldNo("Project Manager"), DATABASE::Job);

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreateJobTaskLinesWebService()
    var
        JobTask: Record "Job Task";
        TenantWebService: Record "Tenant Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"Job Task Lines", JobTaskLinesTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Page, JobTaskLinesTxt);
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobTask.FieldNo("Job No."), DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobTask.FieldNo("Job Task No."), DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobTask.FieldNo(Description), DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobTask.FieldNo("Job Task Type"), DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobTask.FieldNo(Totaling), DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobTask.FieldNo("Job Posting Group"), DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobTask.FieldNo("WIP-Total"), DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobTask.FieldNo("WIP Method"), DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobTask.FieldNo("Start Date"), DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobTask.FieldNo("End Date"), DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobTask.FieldNo("Schedule (Total Cost)"), DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobTask.FieldNo("Schedule (Total Price)"), DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobTask.FieldNo("Usage (Total Cost)"), DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobTask.FieldNo("Usage (Total Price)"), DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobTask.FieldNo("Contract (Total Cost)"), DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobTask.FieldNo("Contract (Total Price)"), DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobTask.FieldNo("Contract (Invoiced Cost)"), DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobTask.FieldNo("Contract (Invoiced Price)"), DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobTask.FieldNo("Remaining (Total Cost)"), DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobTask.FieldNo("Remaining (Total Price)"), DATABASE::"Job Task");

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreateJobPlanningLinesWebService()
    var
        JobPlanningLines: Record "Job Planning Line";
        TenantWebService: Record "Tenant Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"Job Planning Lines", JobPlanningLinesTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Page, JobPlanningLinesTxt);
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobPlanningLines.FieldNo("Job Task No."), DATABASE::"Job Planning Line");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobPlanningLines.FieldNo("Planning Date"), DATABASE::"Job Planning Line");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobPlanningLines.FieldNo("Planned Delivery Date"), DATABASE::"Job Planning Line");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobPlanningLines.FieldNo("Document No."), DATABASE::"Job Planning Line");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobPlanningLines.FieldNo(Type), DATABASE::"Job Planning Line");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobPlanningLines.FieldNo("No."), DATABASE::"Job Planning Line");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobPlanningLines.FieldNo(Description), DATABASE::"Job Planning Line");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobPlanningLines.FieldNo(Quantity), DATABASE::"Job Planning Line");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobPlanningLines.FieldNo("Remaining Qty."), DATABASE::"Job Planning Line");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobPlanningLines.FieldNo("Unit Cost"), DATABASE::"Job Planning Line");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobPlanningLines.FieldNo("Total Cost"), DATABASE::"Job Planning Line");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobPlanningLines.FieldNo("Unit Price"), DATABASE::"Job Planning Line");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobPlanningLines.FieldNo("Line Amount"), DATABASE::"Job Planning Line");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobPlanningLines.FieldNo("Qty. to Transfer to Journal"), DATABASE::"Job Planning Line");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, JobPlanningLines.FieldNo("Invoiced Amount (LCY)"), DATABASE::"Job Planning Line");

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreatePowerBITenantWebServices()
    var
        TenantWebService: Record "Tenant Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        CreatePowerBICustomerList();
        CreatePowerBIVendorList();
        CreatePowerBIJobList();
        CreatePowerBISalesList();
        CreatePowerBIPurchaseList();
        CreatePowerBIItemPurchaseList();
        CreatePowerBIItemSalesList();
        CreatePowerBIGLAmountList();
        CreatePowerBIGLBudgetedAmountList();
        CreatePowerBITopCustOverviewWebService();
        CreatePowerBISalesHdrCustWebService();
        CreatePowerBICustItemLedgEntWebService();
        CreatePowerBICustLedgerEntriesWebService();
        CreatePowerBIVendorLedgerEntriesWebService();
        CreatePowerBIPurchaseHdrVendorWebService();
        CreatePowerBIVendItemLedgEntWebService();
        CreatePowerBIAgedAccPayableWebService();
        CreatePowerBIAgedAccReceivableWebService();
        CreatePowerBIAgedInventoryChartWebService();
        CreatePowerBIJobActBudgPriceWebService();
        CreatePowerBIJobProfitabilityWebService();
        CreatePowerBIJobActBudgCostWebService();
        CreatePowerBISalesPipelineWebService();
        CreatePowerBITop5OpportunitiesWebService();
        CreatePowerBIWorkDateCalcWebService();

        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Query, QUERY::"Dimension Set Entries", '', true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Query, QUERY::"G/L Entries", '', true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Query, QUERY::"Cust. Ledger Entries", '', true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Query, QUERY::"Vendor Ledger Entries", '', true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Query, QUERY::"Bank Account Ledger Entries", '', true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Query, QUERY::"Item Ledger Entries", '', true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Query, QUERY::"Value Entries", '', true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Query, QUERY::"FA Ledger Entries", '', true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Query, QUERY::"Job Ledger Entries", '', true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Query, QUERY::"Res. Ledger Entries", '', true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Query, QUERY::"G/L Budget Entries", '', true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"Chart of Accounts", PowerBIChartOfAccountsTxt, true);
    end;

    local procedure CreatePowerBICustomerList()
    var
        TenantWebService: Record "Tenant Web Service";
        Customer: Record Customer;
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        ODataUtility: Codeunit ODataUtility;
        WebServiceManagement: Codeunit "Web Service Management";
        metaData: DotNet QueryMetadataReader;
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Query, QUERY::"Power BI Customer List", PowerBICustomerListTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Query, PowerBICustomerListTxt);
        ODataUtility.GetTenantWebServiceMetadata(TenantWebService, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Customer.FieldNo("No."), DATABASE::Customer, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Customer.FieldNo(Name), DATABASE::Customer, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Customer.FieldNo("Credit Limit (LCY)"), DATABASE::Customer, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Customer.FieldNo("Balance Due"), DATABASE::Customer, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, DetailedCustLedgEntry.FieldNo("Posting Date"), DATABASE::"Detailed Cust. Ledg. Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, DetailedCustLedgEntry.FieldNo("Cust. Ledger Entry No."), DATABASE::"Detailed Cust. Ledg. Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, DetailedCustLedgEntry.FieldNo(Amount), DATABASE::"Detailed Cust. Ledg. Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, DetailedCustLedgEntry.FieldNo("Amount (LCY)"), DATABASE::"Detailed Cust. Ledg. Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, DetailedCustLedgEntry.FieldNo("Transaction No."), DATABASE::"Detailed Cust. Ledg. Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, DetailedCustLedgEntry.FieldNo("Entry No."), DATABASE::"Detailed Cust. Ledg. Entry", metaData);

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreatePowerBIVendorList()
    var
        Vendor: Record Vendor;
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        TenantWebService: Record "Tenant Web Service";
        ODataUtility: Codeunit ODataUtility;
        WebServiceManagement: Codeunit "Web Service Management";
        metaData: DotNet QueryMetadataReader;
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Query, QUERY::"Power BI Vendor List", PowerBIVendorListTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Query, PowerBIVendorListTxt);
        ODataUtility.GetTenantWebServiceMetadata(TenantWebService, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Vendor.FieldNo("No."), DATABASE::Vendor, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Vendor.FieldNo(Name), DATABASE::Vendor, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Vendor.FieldNo("Balance Due"), DATABASE::Vendor, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, DetailedVendorLedgEntry.FieldNo("Posting Date"), DATABASE::"Detailed Vendor Ledg. Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, DetailedVendorLedgEntry.FieldNo("Applied Vend. Ledger Entry No."), DATABASE::"Detailed Vendor Ledg. Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, DetailedVendorLedgEntry.FieldNo(Amount), DATABASE::"Detailed Vendor Ledg. Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, DetailedVendorLedgEntry.FieldNo("Amount (LCY)"), DATABASE::"Detailed Vendor Ledg. Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, DetailedVendorLedgEntry.FieldNo("Transaction No."), DATABASE::"Detailed Vendor Ledg. Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, DetailedVendorLedgEntry.FieldNo("Entry No."), DATABASE::"Detailed Vendor Ledg. Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, DetailedVendorLedgEntry.FieldNo("Remaining Pmt. Disc. Possible"), DATABASE::"Detailed Vendor Ledg. Entry", metaData);

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreatePowerBIJobList()
    var
        JobLedgerEntry: Record "Job Ledger Entry";
        TenantWebService: Record "Tenant Web Service";
        Job: Record Job;
        ODataUtility: Codeunit ODataUtility;
        WebServiceManagement: Codeunit "Web Service Management";
        metaData: DotNet QueryMetadataReader;
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Query, QUERY::"Power BI Jobs List", PowerBIJobsListTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Query, PowerBIJobsListTxt);
        ODataUtility.GetTenantWebServiceMetadata(TenantWebService, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Job.FieldNo("No."), DATABASE::Job, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Job.FieldNo("Search Description"), DATABASE::Job, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Job.FieldNo(Complete), DATABASE::Job, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Job.FieldNo(Status), DATABASE::Job, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, JobLedgerEntry.FieldNo("Posting Date"), DATABASE::"Job Ledger Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, JobLedgerEntry.FieldNo("Total Cost"), DATABASE::"Job Ledger Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, JobLedgerEntry.FieldNo("Entry No."), DATABASE::"Job Ledger Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, JobLedgerEntry.FieldNo("Entry Type"), DATABASE::"Job Ledger Entry", metaData);

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreatePowerBISalesList()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TenantWebService: Record "Tenant Web Service";
        ODataUtility: Codeunit ODataUtility;
        WebServiceManagement: Codeunit "Web Service Management";
        metaData: DotNet QueryMetadataReader;
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Query, QUERY::"Power BI Sales List", PowerBISalesListTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Query, PowerBISalesListTxt);
        ODataUtility.GetTenantWebServiceMetadata(TenantWebService, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, SalesHeader.FieldNo("No."), DATABASE::"Sales Header", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, SalesHeader.FieldNo("Requested Delivery Date"), DATABASE::"Sales Header", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, SalesHeader.FieldNo("Shipment Date"), DATABASE::"Sales Header", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, SalesHeader.FieldNo("Due Date"), DATABASE::"Sales Header", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, SalesLine.FieldNo(Quantity), DATABASE::"Sales Line", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, SalesLine.FieldNo(Amount), DATABASE::"Sales Line", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, SalesLine.FieldNo("No."), DATABASE::"Sales Line", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, SalesLine.FieldNo(Description), DATABASE::"Sales Line", metaData);

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreatePowerBIPurchaseList()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        TenantWebService: Record "Tenant Web Service";
        ODataUtility: Codeunit ODataUtility;
        WebServiceManagement: Codeunit "Web Service Management";
        metaData: DotNet QueryMetadataReader;
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Query, QUERY::"Power BI Purchase List", PowerBIPurchaseListTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Query, PowerBIPurchaseListTxt);
        ODataUtility.GetTenantWebServiceMetadata(TenantWebService, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, PurchaseHeader.FieldNo("No."), DATABASE::"Purchase Header", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, PurchaseHeader.FieldNo("Order Date"), DATABASE::"Purchase Header", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, PurchaseHeader.FieldNo("Expected Receipt Date"), DATABASE::"Purchase Header", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, PurchaseHeader.FieldNo("Due Date"), DATABASE::"Purchase Header", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, PurchaseHeader.FieldNo("Pmt. Discount Date"), DATABASE::"Purchase Header", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, PurchaseLine.FieldNo(Quantity), DATABASE::"Purchase Line", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, PurchaseLine.FieldNo(Amount), DATABASE::"Purchase Line", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, PurchaseLine.FieldNo("No."), DATABASE::"Purchase Line", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, PurchaseLine.FieldNo(Description), DATABASE::"Purchase Line", metaData);

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreatePowerBIItemPurchaseList()
    var
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        TenantWebService: Record "Tenant Web Service";
        ODataUtility: Codeunit ODataUtility;
        WebServiceManagement: Codeunit "Web Service Management";
        metaData: DotNet QueryMetadataReader;
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Query, QUERY::"Power BI Item Purchase List", PowerBIItemPurchasesListTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Query, PowerBIItemPurchasesListTxt);
        ODataUtility.GetTenantWebServiceMetadata(TenantWebService, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Item.FieldNo("No."), DATABASE::Item, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Item.FieldNo("Search Description"), DATABASE::Item, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, ItemLedgerEntry.FieldNo("Posting Date"), DATABASE::"Item Ledger Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, ItemLedgerEntry.FieldNo("Invoiced Quantity"), DATABASE::"Item Ledger Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, ItemLedgerEntry.FieldNo("Entry No."), DATABASE::"Item Ledger Entry", metaData);

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreatePowerBIItemSalesList()
    var
        Item: Record Item;
        ValueEntry: Record "Value Entry";
        TenantWebService: Record "Tenant Web Service";
        ODataUtility: Codeunit ODataUtility;
        WebServiceManagement: Codeunit "Web Service Management";
        metaData: DotNet QueryMetadataReader;
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Query, QUERY::"Power BI Item Sales List", PowerBIItemSalesListTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Query, PowerBIItemSalesListTxt);
        ODataUtility.GetTenantWebServiceMetadata(TenantWebService, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Item.FieldNo("No."), DATABASE::Item, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Item.FieldNo("Search Description"), DATABASE::Item, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, ValueEntry.FieldNo("Posting Date"), DATABASE::"Value Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, ValueEntry.FieldNo("Invoiced Quantity"), DATABASE::"Value Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, ValueEntry.FieldNo("Entry No."), DATABASE::"Value Entry", metaData);

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreatePowerBIGLAmountList()
    var
        GLAccount: Record "G/L Account";
        GLEntry: Record "G/L Entry";
        TenantWebService: Record "Tenant Web Service";
        ODataUtility: Codeunit ODataUtility;
        WebServiceManagement: Codeunit "Web Service Management";
        metaData: DotNet QueryMetadataReader;
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Query, QUERY::"Power BI GL Amount List", PowerBIGLAmountListTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Query, PowerBIGLAmountListTxt);
        ODataUtility.GetTenantWebServiceMetadata(TenantWebService, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, GLAccount.FieldNo("No."), DATABASE::"G/L Account", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, GLAccount.FieldNo(Name), DATABASE::"G/L Account", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, GLAccount.FieldNo("Account Type"), DATABASE::"G/L Account", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, GLAccount.FieldNo("Debit/Credit"), DATABASE::"G/L Account", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, GLEntry.FieldNo("Posting Date"), DATABASE::"G/L Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, GLEntry.FieldNo(Amount), DATABASE::"G/L Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, GLEntry.FieldNo("Entry No."), DATABASE::"G/L Entry", metaData);

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreatePowerBIGLBudgetedAmountList()
    var
        GLAccount: Record "G/L Account";
        GLBudgetEntry: Record "G/L Budget Entry";
        TenantWebService: Record "Tenant Web Service";
        ODataUtility: Codeunit ODataUtility;
        WebServiceManagement: Codeunit "Web Service Management";
        metaData: DotNet QueryMetadataReader;
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Query, QUERY::"Power BI GL Budgeted Amount", PowerBIGLBudgetedAmountListTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Query, PowerBIGLBudgetedAmountListTxt);
        ODataUtility.GetTenantWebServiceMetadata(TenantWebService, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, GLAccount.FieldNo("No."), DATABASE::"G/L Account", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, GLAccount.FieldNo(Name), DATABASE::"G/L Account", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, GLAccount.FieldNo("Account Type"), DATABASE::"G/L Account", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, GLAccount.FieldNo("Debit/Credit"), DATABASE::"G/L Account", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, GLBudgetEntry.FieldNo(Date), DATABASE::"G/L Budget Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, GLBudgetEntry.FieldNo(Amount), DATABASE::"G/L Budget Entry", metaData);

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreatePowerBITopCustOverviewWebService()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        TenantWebService: Record "Tenant Web Service";
        ODataUtility: Codeunit ODataUtility;
        WebServiceManagement: Codeunit "Web Service Management";
        metaData: DotNet QueryMetadataReader;
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Query, QUERY::"Power BI Top Cust. Overview", PowerBITopCustOverviewTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Query, PowerBITopCustOverviewTxt);
        ODataUtility.GetTenantWebServiceMetadata(TenantWebService, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, CustLedgerEntry.FieldNo("Entry No."), DATABASE::"Cust. Ledger Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, CustLedgerEntry.FieldNo("Posting Date"), DATABASE::"Cust. Ledger Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, CustLedgerEntry.FieldNo("Customer No."), DATABASE::"Cust. Ledger Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, CustLedgerEntry.FieldNo("Sales (LCY)"), DATABASE::"Cust. Ledger Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Customer.FieldNo(Name), DATABASE::Customer, metaData);

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreatePowerBISalesHdrCustWebService()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        Customer: Record Customer;
        TenantWebService: Record "Tenant Web Service";
        ODataUtility: Codeunit ODataUtility;
        WebServiceManagement: Codeunit "Web Service Management";
        metaData: DotNet QueryMetadataReader;
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Query, QUERY::"Power BI Sales Hdr. Cust.", PowerBISalesHdrCustTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Query, PowerBISalesHdrCustTxt);
        ODataUtility.GetTenantWebServiceMetadata(TenantWebService, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, SalesHeader.FieldNo("No."), DATABASE::"Sales Header", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, SalesLine.FieldNo("No."), DATABASE::"Sales Line", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, SalesLine.FieldNo(Quantity), DATABASE::"Sales Line", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, SalesLine.FieldNo("Qty. Invoiced (Base)"), DATABASE::"Sales Line", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, SalesLine.FieldNo("Qty. Shipped (Base)"), DATABASE::"Sales Line", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Item.FieldNo("Base Unit of Measure"), DATABASE::Item, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Item.FieldNo(Description), DATABASE::Item, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Item.FieldNo(Inventory), DATABASE::Item, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Item.FieldNo("Unit Price"), DATABASE::Item, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Customer.FieldNo("No."), DATABASE::Customer, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Customer.FieldNo(Name), DATABASE::Customer, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Customer.FieldNo(Balance), DATABASE::Customer, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Customer.FieldNo("Country/Region Code"), DATABASE::Customer, metaData);

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreatePowerBICustItemLedgEntWebService()
    var
        Customer: Record Customer;
        ItemLedgerEntry: Record "Item Ledger Entry";
        TenantWebService: Record "Tenant Web Service";
        ODataUtility: Codeunit ODataUtility;
        WebServiceManagement: Codeunit "Web Service Management";
        metaData: DotNet QueryMetadataReader;
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Query, QUERY::"Power BI Cust. Item Ledg. Ent.", PowerBICustItemLedgEntTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Query, PowerBICustItemLedgEntTxt);
        ODataUtility.GetTenantWebServiceMetadata(TenantWebService, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Customer.FieldNo("No."), DATABASE::Customer, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, ItemLedgerEntry.FieldNo("Item No."), DATABASE::"Item Ledger Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, ItemLedgerEntry.FieldNo(Quantity), DATABASE::"Item Ledger Entry", metaData);

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreatePowerBICustLedgerEntriesWebService()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        TenantWebService: Record "Tenant Web Service";
        ODataUtility: Codeunit ODataUtility;
        WebServiceManagement: Codeunit "Web Service Management";
        metaData: DotNet QueryMetadataReader;
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Query, QUERY::"Power BI Cust. Ledger Entries", PowerBICustLedgerEntriesTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Query, PowerBICustLedgerEntriesTxt);
        ODataUtility.GetTenantWebServiceMetadata(TenantWebService, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, CustLedgerEntry.FieldNo("Entry No."), DATABASE::"Cust. Ledger Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, CustLedgerEntry.FieldNo("Due Date"), DATABASE::"Cust. Ledger Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, CustLedgerEntry.FieldNo("Remaining Amt. (LCY)"), DATABASE::"Cust. Ledger Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, CustLedgerEntry.FieldNo(Open), DATABASE::"Cust. Ledger Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, CustLedgerEntry.FieldNo("Customer Posting Group"), DATABASE::"Cust. Ledger Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, CustLedgerEntry.FieldNo("Sales (LCY)"), DATABASE::"Cust. Ledger Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, CustLedgerEntry.FieldNo("Posting Date"), DATABASE::"Cust. Ledger Entry", metaData);

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreatePowerBIVendorLedgerEntriesWebService()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        TenantWebService: Record "Tenant Web Service";
        ODataUtility: Codeunit ODataUtility;
        WebServiceManagement: Codeunit "Web Service Management";
        metaData: DotNet QueryMetadataReader;
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Query, QUERY::"Power BI Vendor Ledger Entries", PowerBIVendorLedgerEntriesTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Query, PowerBIVendorLedgerEntriesTxt);
        ODataUtility.GetTenantWebServiceMetadata(TenantWebService, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, VendorLedgerEntry.FieldNo("Entry No."), DATABASE::"Vendor Ledger Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, VendorLedgerEntry.FieldNo("Due Date"), DATABASE::"Vendor Ledger Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, VendorLedgerEntry.FieldNo("Remaining Amt. (LCY)"), DATABASE::"Vendor Ledger Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, VendorLedgerEntry.FieldNo(Open), DATABASE::"Vendor Ledger Entry", metaData);

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreatePowerBIPurchaseHdrVendorWebService()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Item: Record Item;
        Vendor: Record Vendor;
        TenantWebService: Record "Tenant Web Service";
        ODataUtility: Codeunit ODataUtility;
        WebServiceManagement: Codeunit "Web Service Management";
        metaData: DotNet QueryMetadataReader;
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Query, QUERY::"Power BI Purchase Hdr. Vendor", PowerBIPurchaseHdrVendorTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Query, PowerBIPurchaseHdrVendorTxt);
        ODataUtility.GetTenantWebServiceMetadata(TenantWebService, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, PurchaseHeader.FieldNo("No."), DATABASE::"Purchase Header", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, PurchaseLine.FieldNo("No."), DATABASE::"Purchase Line", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, PurchaseLine.FieldNo(Quantity), DATABASE::"Purchase Line", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Item.FieldNo("Base Unit of Measure"), DATABASE::Item, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Item.FieldNo(Description), DATABASE::Item, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Item.FieldNo(Inventory), DATABASE::Item, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Item.FieldNo("Qty. on Purch. Order"), DATABASE::Item, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Item.FieldNo("Unit Price"), DATABASE::Item, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Vendor.FieldNo("No."), DATABASE::Vendor, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Vendor.FieldNo(Name), DATABASE::Vendor, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Vendor.FieldNo(Balance), DATABASE::Vendor, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Vendor.FieldNo("Country/Region Code"), DATABASE::Vendor, metaData);

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreatePowerBIVendItemLedgEntWebService()
    var
        Vendor: Record Vendor;
        ItemLedgerEntry: Record "Item Ledger Entry";
        TenantWebService: Record "Tenant Web Service";
        ODataUtility: Codeunit ODataUtility;
        WebServiceManagement: Codeunit "Web Service Management";
        metaData: DotNet QueryMetadataReader;
    begin
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Query, QUERY::"Power BI Vend. Item Ledg. Ent.", PowerBIVendItemLedgEntTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Query, PowerBIVendItemLedgEntTxt);
        ODataUtility.GetTenantWebServiceMetadata(TenantWebService, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Vendor.FieldNo("No."), DATABASE::Vendor, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, ItemLedgerEntry.FieldNo("Item No."), DATABASE::"Item Ledger Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, ItemLedgerEntry.FieldNo(Quantity), DATABASE::"Item Ledger Entry", metaData);

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreatePowerBIAgedAccPayableWebService()
    var
        PowerBIChartBuffer: Record "Power BI Chart Buffer";
        TenantWebService: Record "Tenant Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"PBI Aged Acc. Payable", PowerBIAgedAccPayableTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Page, PowerBIAgedAccPayableTxt);
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo(ID), DATABASE::"Power BI Chart Buffer");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo(Value), DATABASE::"Power BI Chart Buffer");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo("Period Type"), DATABASE::"Power BI Chart Buffer");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo(Date), DATABASE::"Power BI Chart Buffer");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo("Date Sorting"), DATABASE::"Power BI Chart Buffer");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo("Period Type Sorting"), DATABASE::"Power BI Chart Buffer");

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreatePowerBIAgedAccReceivableWebService()
    var
        PowerBIChartBuffer: Record "Power BI Chart Buffer";
        TenantWebService: Record "Tenant Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"PBI Aged Acc. Receivable", PowerBIAgedAccReceivableTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Page, PowerBIAgedAccReceivableTxt);
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo(ID), DATABASE::"Power BI Chart Buffer");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo(Value), DATABASE::"Power BI Chart Buffer");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo(Date), DATABASE::"Power BI Chart Buffer");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo("Date Sorting"), DATABASE::"Power BI Chart Buffer");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo("Period Type"), DATABASE::"Power BI Chart Buffer");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo("Period Type Sorting"), DATABASE::"Power BI Chart Buffer");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo("Measure Name"), DATABASE::"Power BI Chart Buffer");

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreatePowerBIAgedInventoryChartWebService()
    var
        PowerBIChartBuffer: Record "Power BI Chart Buffer";
        TenantWebService: Record "Tenant Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"PBI Aged Inventory Chart", PowerBIAgedInventoryChartTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Page, PowerBIAgedInventoryChartTxt);
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo(ID), DATABASE::"Power BI Chart Buffer");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo(Value), DATABASE::"Power BI Chart Buffer");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo(Date), DATABASE::"Power BI Chart Buffer");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo("Period Type"), DATABASE::"Power BI Chart Buffer");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo("Period Type Sorting"), DATABASE::"Power BI Chart Buffer");

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreatePowerBIJobActBudgPriceWebService()
    var
        PowerBIChartBuffer: Record "Power BI Chart Buffer";
        TenantWebService: Record "Tenant Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"PBI Job Act. v. Budg. Price", PowerBIJobActBudgPriceTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Page, PowerBIJobActBudgPriceTxt);
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo("Measure No."), DATABASE::"Power BI Chart Buffer");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo("Measure Name"), DATABASE::"Power BI Chart Buffer");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo(Value), DATABASE::"Power BI Chart Buffer");

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreatePowerBIJobProfitabilityWebService()
    var
        PowerBIChartBuffer: Record "Power BI Chart Buffer";
        TenantWebService: Record "Tenant Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"PBI Job Profitability", PowerBIJobProfitabilityTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Page, PowerBIJobProfitabilityTxt);
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo("Measure No."), DATABASE::"Power BI Chart Buffer");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo("Measure Name"), DATABASE::"Power BI Chart Buffer");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo(Value), DATABASE::"Power BI Chart Buffer");

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreatePowerBIJobActBudgCostWebService()
    var
        PowerBIChartBuffer: Record "Power BI Chart Buffer";
        TenantWebService: Record "Tenant Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"PBI Job Act. v. Budg. Cost", PowerBIJobActBudgCostTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Page, PowerBIJobActBudgCostTxt);
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo("Measure No."), DATABASE::"Power BI Chart Buffer");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo("Measure Name"), DATABASE::"Power BI Chart Buffer");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo(Value), DATABASE::"Power BI Chart Buffer");

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreatePowerBISalesPipelineWebService()
    var
        PowerBIChartBuffer: Record "Power BI Chart Buffer";
        TenantWebService: Record "Tenant Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"PBI Sales Pipeline", PowerBISalesPipelineTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Page, PowerBISalesPipelineTxt);
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo(ID), DATABASE::"Power BI Chart Buffer");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo("Row No."), DATABASE::"Power BI Chart Buffer");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo(Value), DATABASE::"Power BI Chart Buffer");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo("Measure Name"), DATABASE::"Power BI Chart Buffer");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo("Measure No."), DATABASE::"Power BI Chart Buffer");

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreatePowerBITop5OpportunitiesWebService()
    var
        PowerBIChartBuffer: Record "Power BI Chart Buffer";
        TenantWebService: Record "Tenant Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"PBI Top 5 Opportunities", PowerBITop5OpportunitiesTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Page, PowerBITop5OpportunitiesTxt);
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo(ID), DATABASE::"Power BI Chart Buffer");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo(Value), DATABASE::"Power BI Chart Buffer");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo("Measure Name"), DATABASE::"Power BI Chart Buffer");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, PowerBIChartBuffer.FieldNo("Measure No."), DATABASE::"Power BI Chart Buffer");

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreatePowerBIWorkDateCalcWebService()
    var
        TenantWebService: Record "Tenant Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"PBI WorkDate Calc.", PowerBIWorkDateCalcTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Page, PowerBIWorkDateCalcTxt);

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreateAccountantPortalWebServices()
    var
        WebService: Record "Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        WebServiceManagement.CreateWebService(WebService."Object Type"::Page, PAGE::"AccountantPortal Activity Cues", AccountantPortalActivityCuesTxt, true);
        WebServiceManagement.CreateWebService(WebService."Object Type"::Page, PAGE::"Accountant Portal Finance Cues", AccountantPortalFinanceCuesTxt, true);
        WebServiceManagement.CreateWebService(WebService."Object Type"::Page, PAGE::"Accountant Portal User Tasks", AccountantPortalUserTasksTxt, true);
        WebServiceManagement.CreateWebService(WebService."Object Type"::Page, PAGE::"User Task List", UserTaskSetCompleteTxt, true);
    end;

    local procedure CreateWorkflowWebhookWebServices()
    var
        TenantWebService: Record "Tenant Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"Sales Document Entity", 'salesDocuments', true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"Sales Document Line Entity", 'salesDocumentLines', true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"Purchase Document Entity", 'purchaseDocuments', true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"Purchase Document Line Entity", 'purchaseDocumentLines', true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"Sales Document Entity", 'workflowSalesDocuments', true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"Sales Document Line Entity", 'workflowSalesDocumentLines', true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"Purchase Document Entity", 'workflowPurchaseDocuments', true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"Purchase Document Line Entity", 'workflowPurchaseDocumentLines', true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"Gen. Journal Batch Entity", 'workflowGenJournalBatches', true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"Gen. Journal Line Entity", 'workflowGenJournalLines', true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"Workflow - Customer Entity", 'workflowCustomers', true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"Workflow - Item Entity", 'workflowItems', true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"Workflow - Vendor Entity", 'workflowVendors', true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"Workflow Webhook Subscriptions", 'workflowWebhookSubscriptions', true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Codeunit, CODEUNIT::"Workflow Webhook Subscription", 'WorkflowActionResponse', true);
    end;

    local procedure CreateExcelTemplateWebServices()
    var
        TenantWebService: Record "Tenant Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
        CreateMediaRepository: Codeunit "Create Media Repository";
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"Income Statement Entity", CreateMediaRepository.ExcelTemplateIncomeStatement(), true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"Balance Sheet Entity", CreateMediaRepository.ExcelTemplateBalanceSheet(), true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"Trial Balance Entity", CreateMediaRepository.ExcelTemplateTrialBalance(), true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"Retained Earnings Entity", CreateMediaRepository.ExcelTemplateRetainedEarnings(), true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"Cash Flow Statement Entity", CreateMediaRepository.ExcelTemplateCashFlowStatement(), true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"Aged AR Entity", CreateMediaRepository.ExcelTemplateAgedAccountsReceivable(), true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"Aged AP Entity", CreateMediaRepository.ExcelTemplateAgedAccountsPayable(), true);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::ExcelTemplateCompanyInfo, ExcelTemplateCompanyInformationTxt, true);
    end;


    procedure PowerBIFinance(): Text
    begin
        exit('powerbifinance');
    end;

    procedure SegmentLines(): Text
    begin
        exit('SegmentLines');
    end;

    local procedure CreateTenantWebServiceOData(TenantWebService: Record "Tenant Web Service")
    var
        TenantWebServiceOData: Record "Tenant Web Service OData";
        WebServiceManagement: Codeunit "Web Service Management";
        ODataUtility: Codeunit ODataUtility;
        SelectText: Text;
    begin
        TenantWebServiceOData.Init();
        TenantWebServiceOData.TenantWebServiceID := TenantWebService.RecordId;
        if not TenantWebServiceOData.Insert() then;
        ODataUtility.GenerateSelectText(TenantWebService."Service Name", TenantWebService."Object Type", SelectText);
        WebServiceManagement.SetODataSelectClause(TenantWebServiceOData, SelectText);
        TenantWebServiceOData.Modify();
    end;

    var
        JobListTxt: Label 'Job List', Locked = true;
        JobTaskLinesTxt: Label 'Job Task Lines', Locked = true;
        JobPlanningLinesTxt: Label 'Job Planning Lines', Locked = true;
        PowerBIChartOfAccountsTxt: Label 'Chart of Accounts', locked = true;
        PowerBICustomerListTxt: Label 'Power BI Customer List', Locked = true;
        PowerBIVendorListTxt: Label 'Power BI Vendor List', Locked = true;
        PowerBIJobsListTxt: Label 'Power BI Jobs List', Locked = true;
        PowerBISalesListTxt: Label 'Power BI Sales List', Locked = true;
        PowerBIPurchaseListTxt: Label 'Power BI Purchase List', Locked = true;
        PowerBIItemPurchasesListTxt: Label 'Power BI Item Purchase List', Locked = true;
        PowerBIItemSalesListTxt: Label 'Power BI Item Sales List', Locked = true;
        PowerBIGLAmountListTxt: Label 'Power BI GL Amount List', Locked = true;
        PowerBIGLBudgetedAmountListTxt: Label 'Power BI GL BudgetedAmount', Locked = true;
        PowerBITopCustOverviewTxt: Label 'Power BI Top Cust. Overview', Locked = true;
        PowerBISalesHdrCustTxt: Label 'Power BI Sales Hdr. Cust.', Locked = true;
        PowerBICustItemLedgEntTxt: Label 'Power BI Cust. Item Ledg. Ent.', Locked = true;
        PowerBICustLedgerEntriesTxt: Label 'Power BI Cust. Ledger Entries', Locked = true;
        PowerBIVendorLedgerEntriesTxt: Label 'Power BI Vendor Ledger Entries', Locked = true;
        PowerBIPurchaseHdrVendorTxt: Label 'Power BI Purchase Hdr. Vendor', Locked = true;
        PowerBIVendItemLedgEntTxt: Label 'Power BI Vend. Item Ledg. Ent.', Locked = true;
        PowerBIAgedAccPayableTxt: Label 'Power BI Aged Acc. Payable', Locked = true;
        PowerBIAgedAccReceivableTxt: Label 'Power BI Aged Acc. Receivable', Locked = true;
        PowerBIAgedInventoryChartTxt: Label 'Power BI Aged Inventory Chart', Locked = true;
        PowerBIJobActBudgPriceTxt: Label 'Power BI Job Act. v. Budg. Price', Locked = true;
        PowerBIJobProfitabilityTxt: Label 'Power BI Job Profitability', Locked = true;
        PowerBIJobActBudgCostTxt: Label 'Power BI Job Act. v. Budg. Cost', Locked = true;
        PowerBISalesPipelineTxt: Label 'Power BI Sales Pipeline', Locked = true;
        PowerBITop5OpportunitiesTxt: Label 'Power BI Top 5 Opportunities', Locked = true;
        PowerBIWorkDateCalcTxt: Label 'Power BI WorkDate Calc.', Locked = true;
        AccountantPortalActivityCuesTxt: Label 'AccountantPortalActivityCues', Locked = true;
        AccountantPortalFinanceCuesTxt: Label 'AccountantPortalFinanceCues', Locked = true;
        AccountantPortalUserTasksTxt: Label 'AccountantPortalUserTasks', Locked = true;
        UserTaskSetCompleteTxt: Label 'UserTaskSetComplete', Locked = true;
        ExcelTemplateCompanyInformationTxt: Label 'ExcelTemplateViewCompanyInformation', Locked = true;
}

