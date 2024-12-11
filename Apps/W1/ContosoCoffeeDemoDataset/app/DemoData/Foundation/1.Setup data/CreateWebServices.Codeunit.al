codeunit 5690 "Create Web Services"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        WebService: Record "Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        WebServiceManagement.CreateWebService(WebService."Object Type"::Codeunit, Codeunit::"Company Setup Service", 'CompanySetupService', true);
        WebServiceManagement.CreateWebService(WebService."Object Type"::Codeunit, Codeunit::"Exchange Service Setup", 'ExchangeServiceSetup', true);
        WebServiceManagement.CreateWebService(WebService."Object Type"::Codeunit, Codeunit::"Page Summary Provider", 'SummaryProvider', true);
        WebServiceManagement.CreateWebService(WebService."Object Type"::Codeunit, Codeunit::"Page Action Provider", 'PageActionProvider', true);
        CreatePowerBIWebServices();
        CreateSegmentWebService();
        CreateJobWebServices();
        CreatePowerBITenantWebServices();
        CreateAccountantPortalWebServices();
        CreateWorkflowWebhookWebServices();
        CreateExcelTemplateWebServices();
    end;

    procedure CreatePowerBIWebServices()
    var
        WebService: Record "Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Page, PAGE::"Acc. Sched. KPI WS Dimensions", PowerBIFinance(), true);
        WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Query, QUERY::"Dimension Sets", '', true);

        WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Query, QUERY::"Top Customer Overview", '', true);
        WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Query, QUERY::"Sales Dashboard", '', true);
        WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Query, QUERY::"Item Sales by Customer", 'ItemSalesByCustomer', true);
        WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Query, QUERY::"Item Sales and Profit", 'ItemSalesAndProfit', true);
        WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Query, QUERY::"Sales Orders by Sales Person", 'SalesOrdersBySalesPerson', true);
        WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Query, QUERY::"Sales Opportunities", '', true);
    end;

    procedure CreateSegmentWebService()
    var
        TenantWebService: Record "Tenant Web Service";
        TenantWebServiceOData: Record "Tenant Web Service OData";
        WebServiceManagement: Codeunit "Web Service Management";
        metaData: DotNet QueryMetadataReader;
        SelectText: Text;
        ODataV3FilterText: Text;
        ODataV4FilterText: Text;
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Query, QUERY::"Segment Lines", SegmentLines(), true);

        TenantWebService.Get(TenantWebService."Object Type"::Query, SegmentLines());
        ODataUtility.GetTenantWebServiceMetadata(TenantWebService, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, 1, DATABASE::"Segment Line", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, 3, DATABASE::"Segment Line", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, 5, DATABASE::"Segment Line", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, 6, DATABASE::"Segment Line", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, 12, DATABASE::"Segment Line", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, 18, DATABASE::"Segment Line", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, 19, DATABASE::"Segment Line", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, 27, DATABASE::"Segment Line", metaData);

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

    procedure CreateJobWebServices()
    var
        TenantWebService: Record "Tenant Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"Job List", JobListTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Page, JobListTxt);
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 1, DATABASE::Job);
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 3, DATABASE::Job);
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 5, DATABASE::Job);
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 19, DATABASE::Job);
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 20, DATABASE::Job);
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 2, DATABASE::Job);
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 1036, DATABASE::Job);

        CreateTenantWebServiceOData(TenantWebService);

        Clear(TenantWebService);

        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"Job Task Lines", JobTaskLinesTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Page, JobTaskLinesTxt);
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 1, DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 2, DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 3, DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 4, DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 21, DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 7, DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 6, DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 9, DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 66, DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 67, DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 10, DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 11, DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 12, DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 13, DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 14, DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 15, DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 17, DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 16, DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 64, DATABASE::"Job Task");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 65, DATABASE::"Job Task");

        CreateTenantWebServiceOData(TenantWebService);

        Clear(TenantWebService);

        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PAGE::"Job Planning Lines", JobPlanningLinesTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Page, JobPlanningLinesTxt);
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 1000, DATABASE::"Job Planning Line");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 3, DATABASE::"Job Planning Line");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 5794, DATABASE::"Job Planning Line");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 4, DATABASE::"Job Planning Line");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 5, DATABASE::"Job Planning Line");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 7, DATABASE::"Job Planning Line");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 8, DATABASE::"Job Planning Line");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 9, DATABASE::"Job Planning Line");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 1060, DATABASE::"Job Planning Line");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 1002, DATABASE::"Job Planning Line");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 1003, DATABASE::"Job Planning Line");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 1004, DATABASE::"Job Planning Line");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 1006, DATABASE::"Job Planning Line");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 1071, DATABASE::"Job Planning Line");
        WebServiceManagement.CreateTenantWebServiceColumnForPage(TenantWebService.RecordId, 1035, DATABASE::"Job Planning Line");

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreateTenantWebServiceOData(TenantWebService: Record "Tenant Web Service")
    var
        TenantWebServiceOData: Record "Tenant Web Service OData";
        WebServiceManagement: Codeunit "Web Service Management";
        SelectText: Text;
    begin
        TenantWebServiceOData.Init();
        TenantWebServiceOData.TenantWebServiceID := TenantWebService.RecordId;
        if not TenantWebServiceOData.Insert() then;
        ODataUtility.GenerateSelectText(TenantWebService."Service Name", TenantWebService."Object Type", SelectText);
        WebServiceManagement.SetODataSelectClause(TenantWebServiceOData, SelectText);
        TenantWebServiceOData.Modify();
    end;

    procedure CreatePowerBITenantWebServices()
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
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Page, PAGE::"Chart of Accounts", PowerBIChartOfAccountsTxt, true);
    end;

    local procedure CreatePowerBICustomerList()
    var
        TenantWebService: Record "Tenant Web Service";
        Customer: Record Customer;
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
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
        WebServiceManagement: Codeunit "Web Service Management";
        metaData: DotNet QueryMetadataReader;
    begin
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Query, QUERY::"Power BI Vendor List", PowerBIVendorListTxt, true);

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
        WebServiceManagement: Codeunit "Web Service Management";
        metaData: DotNet QueryMetadataReader;
    begin
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Query, QUERY::"Power BI Sales List", PowerBISalesListTxt, true);

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
        WebServiceManagement: Codeunit "Web Service Management";
        metaData: DotNet QueryMetadataReader;
    begin
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Query, QUERY::"Power BI Purchase List", PowerBIPurchaseListTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Query, PowerBIPurchaseListTxt);
        ODataUtility.GetTenantWebServiceMetadata(TenantWebService, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, PurchaseHeader.FieldNo("No."),
          DATABASE::"Purchase Header", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, PurchaseHeader.FieldNo("Order Date"),
          DATABASE::"Purchase Header", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, PurchaseHeader.FieldNo("Expected Receipt Date"),
          DATABASE::"Purchase Header", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, PurchaseHeader.FieldNo("Due Date"),
          DATABASE::"Purchase Header", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, PurchaseHeader.FieldNo("Pmt. Discount Date"),
          DATABASE::"Purchase Header", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, PurchaseLine.FieldNo(Quantity),
          DATABASE::"Purchase Line", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, PurchaseLine.FieldNo(Amount),
          DATABASE::"Purchase Line", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, PurchaseLine.FieldNo("No."),
          DATABASE::"Purchase Line", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, PurchaseLine.FieldNo(Description),
          DATABASE::"Purchase Line", metaData);

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreatePowerBIItemPurchaseList()
    var
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        TenantWebService: Record "Tenant Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
        metaData: DotNet QueryMetadataReader;
    begin
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Query, QUERY::"Power BI Item Purchase List", PowerBIItemPurchasesListTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Query, PowerBIItemPurchasesListTxt);
        ODataUtility.GetTenantWebServiceMetadata(TenantWebService, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Item.FieldNo("No."), DATABASE::Item, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Item.FieldNo("Search Description"),
          DATABASE::Item, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, ItemLedgerEntry.FieldNo("Posting Date"),
          DATABASE::"Item Ledger Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, ItemLedgerEntry.FieldNo("Invoiced Quantity"),
          DATABASE::"Item Ledger Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, ItemLedgerEntry.FieldNo("Entry No."),
          DATABASE::"Item Ledger Entry", metaData);

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreatePowerBIItemSalesList()
    var
        Item: Record Item;
        ValueEntry: Record "Value Entry";
        TenantWebService: Record "Tenant Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
        metaData: DotNet QueryMetadataReader;
    begin
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Query, QUERY::"Power BI Item Sales List", PowerBIItemSalesListTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Query, PowerBIItemSalesListTxt);
        ODataUtility.GetTenantWebServiceMetadata(TenantWebService, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Item.FieldNo("No."), DATABASE::Item, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, Item.FieldNo("Search Description"),
          DATABASE::Item, metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, ValueEntry.FieldNo("Posting Date"),
          DATABASE::"Value Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, ValueEntry.FieldNo("Invoiced Quantity"),
          DATABASE::"Value Entry", metaData);
        WebServiceManagement.CreateTenantWebServiceColumnForQuery(TenantWebService.RecordId, ValueEntry.FieldNo("Entry No."),
          DATABASE::"Value Entry", metaData);

        CreateTenantWebServiceOData(TenantWebService);
    end;

    local procedure CreatePowerBIGLAmountList()
    var
        GLAccount: Record "G/L Account";
        GLEntry: Record "G/L Entry";
        TenantWebService: Record "Tenant Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
        metaData: DotNet QueryMetadataReader;
    begin
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Query, QUERY::"Power BI GL Amount List", PowerBIGLAmountListTxt, true);

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
        WebServiceManagement: Codeunit "Web Service Management";
        metaData: DotNet QueryMetadataReader;
    begin
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Query, QUERY::"Power BI GL Budgeted Amount", PowerBIGLBudgetedAmountListTxt, true);

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
        WebServiceManagement: Codeunit "Web Service Management";
        metaData: DotNet QueryMetadataReader;
    begin
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Query, QUERY::"Power BI Sales Hdr. Cust.", PowerBISalesHdrCustTxt, true);

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
        WebServiceManagement: Codeunit "Web Service Management";
        metaData: DotNet QueryMetadataReader;
    begin
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Query, QUERY::"Power BI Cust. Item Ledg. Ent.", PowerBICustItemLedgEntTxt, true);

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
        WebServiceManagement: Codeunit "Web Service Management";
        metaData: DotNet QueryMetadataReader;
    begin
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Query, QUERY::"Power BI Cust. Ledger Entries", PowerBICustLedgerEntriesTxt, true);

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
        WebServiceManagement: Codeunit "Web Service Management";
        metaData: DotNet QueryMetadataReader;
    begin
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Query, QUERY::"Power BI Vendor Ledger Entries", PowerBIVendorLedgerEntriesTxt, true);

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
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Page, PAGE::"PBI Aged Acc. Payable", PowerBIAgedAccPayableTxt, true);

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
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Page, PAGE::"PBI Aged Acc. Receivable", PowerBIAgedAccReceivableTxt, true);

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
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Page, PAGE::"PBI Aged Inventory Chart", PowerBIAgedInventoryChartTxt, true);

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
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Page, PAGE::"PBI Job Act. v. Budg. Price", PowerBIJobActBudgPriceTxt, true);

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
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Page, PAGE::"PBI Job Profitability", PowerBIJobProfitabilityTxt, true);

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
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Page, PAGE::"PBI Job Act. v. Budg. Cost", PowerBIJobActBudgCostTxt, true);

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
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Page, PAGE::"PBI Sales Pipeline", PowerBISalesPipelineTxt, true);

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
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Page, PAGE::"PBI Top 5 Opportunities", PowerBITop5OpportunitiesTxt, true);

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
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Page, PAGE::"PBI WorkDate Calc.", PowerBIWorkDateCalcTxt, true);

        TenantWebService.Get(TenantWebService."Object Type"::Page, PowerBIWorkDateCalcTxt);

        CreateTenantWebServiceOData(TenantWebService);
    end;

    procedure CreateAccountantPortalWebServices()
    begin
        CreateAccountantPortalWebService(AccountantPortalActivityCuesTxt, PAGE::"AccountantPortal Activity Cues");
        CreateAccountantPortalWebService(AccountantPortalFinanceCuesTxt, PAGE::"Accountant Portal Finance Cues");
        CreateAccountantPortalWebService(AccountantPortalUserTasksTxt, PAGE::"Accountant Portal User Tasks");
        CreateAccountantPortalWebService(UserTaskSetCompleteTxt, PAGE::"User Task List");
    end;

    local procedure CreateAccountantPortalWebService(ObjectName: Text; PageID: Integer)
    var
        WebService: Record "Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        Clear(WebService);
        WebServiceManagement.CreateWebService(WebService."Object Type"::Page, PageID, ObjectName, true);
    end;

    procedure CreateWorkflowWebhookWebServices()
    var
        TenantWebService: Record "Tenant Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Page, PAGE::"Sales Document Entity", 'salesDocuments', true);
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Page, PAGE::"Sales Document Line Entity", 'salesDocumentLines', true);
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Page, PAGE::"Purchase Document Entity", 'purchaseDocuments', true);
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Page, PAGE::"Purchase Document Line Entity", 'purchaseDocumentLines', true);
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Page, PAGE::"Sales Document Entity", 'workflowSalesDocuments', true);
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Page, PAGE::"Sales Document Line Entity", 'workflowSalesDocumentLines', true);
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Page, PAGE::"Purchase Document Entity", 'workflowPurchaseDocuments', true);
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Page, PAGE::"Purchase Document Line Entity", 'workflowPurchaseDocumentLines', true);
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Page, PAGE::"Gen. Journal Batch Entity", 'workflowGenJournalBatches', true);
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Page, PAGE::"Gen. Journal Line Entity", 'workflowGenJournalLines', true);
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Page, PAGE::"Workflow - Customer Entity", 'workflowCustomers', true);
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Page, PAGE::"Workflow - Item Entity", 'workflowItems', true);
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Page, PAGE::"Workflow - Vendor Entity", 'workflowVendors', true);
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Page, PAGE::"Workflow Webhook Subscriptions", 'workflowWebhookSubscriptions', true);
        WebServiceManagement.CreateTenantWebService(
          TenantWebService."Object Type"::Codeunit, CODEUNIT::"Workflow Webhook Subscription", 'WorkflowActionResponse', true);
    end;

    procedure CreateExcelTemplateWebServices()
    begin
        CreateExcelTemplateWebService(ExcelTemplateIncomeStatementTxt, PAGE::"Income Statement Entity");
        CreateExcelTemplateWebService(ExcelTemplateBalanceSheetTxt, PAGE::"Balance Sheet Entity");
        CreateExcelTemplateWebService(ExcelTemplateTrialBalanceTxt, PAGE::"Trial Balance Entity");
        CreateExcelTemplateWebService(ExcelTemplateRetainedEarningsStatementTxt, PAGE::"Retained Earnings Entity");
        CreateExcelTemplateWebService(ExcelTemplateCashFlowStatementTxt, PAGE::"Cash Flow Statement Entity");
        CreateExcelTemplateWebService(ExcelTemplateAgedAccountsReceivableTxt, PAGE::"Aged AR Entity");
        CreateExcelTemplateWebService(ExcelTemplateAgedAccountsPayableTxt, PAGE::"Aged AP Entity");
        CreateExcelTemplateWebService(ExcelTemplateCompanyInformationTxt, PAGE::ExcelTemplateCompanyInfo);
    end;

    local procedure CreateExcelTemplateWebService(ObjectName: Text; PageID: Integer)
    var
        TenantWebService: Record "Tenant Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        Clear(TenantWebService);
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, PageID, ObjectName, true)
    end;

    procedure PowerBIFinance(): Text
    begin
        exit('powerbifinance');
    end;

    procedure SegmentLines(): Text
    begin
        exit('SegmentLines');
    end;

    var
        ODataUtility: Codeunit ODataUtility;
        JobListTxt: Label 'Job List', Locked = true;
        JobTaskLinesTxt: Label 'Job Task Lines', Locked = true;
        JobPlanningLinesTxt: Label 'Job Planning Lines', Locked = true;
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
        ExcelTemplateIncomeStatementTxt: Label 'ExcelTemplateIncomeStatement', Locked = true;
        ExcelTemplateBalanceSheetTxt: Label 'ExcelTemplateBalanceSheet', Locked = true;
        ExcelTemplateTrialBalanceTxt: Label 'ExcelTemplateTrialBalance', Locked = true;
        ExcelTemplateRetainedEarningsStatementTxt: Label 'ExcelTemplateRetainedEarnings', Locked = true;
        ExcelTemplateCashFlowStatementTxt: Label 'ExcelTemplateCashFlowStatement', Locked = true;
        ExcelTemplateAgedAccountsReceivableTxt: Label 'ExcelTemplateAgedAccountsReceivable', Locked = true;
        ExcelTemplateAgedAccountsPayableTxt: Label 'ExcelTemplateAgedAccountsPayable', Locked = true;
        ExcelTemplateCompanyInformationTxt: Label 'ExcelTemplateViewCompanyInformation', Locked = true;
        AccountantPortalUserTasksTxt: Label 'AccountantPortalUserTasks', Locked = true;
        UserTaskSetCompleteTxt: Label 'UserTaskSetComplete', Locked = true;
        PowerBIChartOfAccountsTxt: Label 'Chart of Accounts', Locked = true;
}

