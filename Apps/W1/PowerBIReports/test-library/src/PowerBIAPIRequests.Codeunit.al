namespace Microsoft.PowerBIReports.Test;

using Microsoft.Finance.PowerBIReports;
using Microsoft.Sales.PowerBIReports;
using Microsoft.Manufacturing.PowerBIReports;
using Microsoft.Projects.PowerBIReports;
using Microsoft.Purchases.PowerBIReports;
using Microsoft.Inventory.PowerBIReports;

codeunit 139792 "PowerBI API Requests"
{
    procedure GetFilterForQueryScenario(Scenario: Enum "PowerBI Filter Scenarios"): Text
    var
        FinanceFilterHelper: Codeunit "Finance Filter Helper";
        SalesFilterHelper: Codeunit "Sales Filter Helper";
        ManufacturingFilterHelper: Codeunit "Manuf. Filter Helper";
        ProjectFilterHelper: Codeunit "Project Filter Helper";
        PurchasesFilterHelper: Codeunit "Purchases Filter Helper";
    begin
        case Scenario of
            Scenario::"Finance Date":
                exit(FinanceFilterHelper.GenerateFinanceReportDateFilter());
            Scenario::"Sales Date":
                exit(SalesFilterHelper.GenerateItemSalesReportDateFilter());
            Scenario::"Manufacturing Date":
                exit(ManufacturingFilterHelper.GenerateManufacturingReportDateFilter());
            Scenario::"Manufacturing Date Time":
                exit(ManufacturingFilterHelper.GenerateManufacturingReportDateTimeFilter());
            Scenario::"Project Date":
                exit(ProjectFilterHelper.GenerateJobLedgerDateFilter());
            Scenario::"Purchases Date":
                exit(PurchasesFilterHelper.GenerateItemPurchasesReportDateFilter());
        end;
    end;

    procedure GetEndpointUrl(PowerBIEndpoint: Enum "PowerBI API Endpoints"): Text
    begin
        case PowerBIEndpoint of
            PowerBIEndpoint::"Vendor Ledger Entries":
                exit(GetQueryUrlFromObjectId(Query::"Vendor Ledger Entries"));
            PowerBIEndpoint::"Customer Ledger Entries":
                exit(GetQueryUrlFromObjectId(Query::"Customer Ledger Entries"));
            PowerBIEndpoint::"G/L Accounts":
                exit(GetQueryUrlFromObjectId(Query::"G/L Accounts"));
            PowerBIEndpoint::"G/L Account Categories":
                exit(GetQueryUrlFromObjectId(Query::"G/L Account Categories"));
            PowerBIEndpoint::"G/L Budgets":
                exit(GetQueryUrlFromObjectId(Query::"G/L Budgets"));
            PowerBIEndpoint::"G/L Budget Entries":
                exit(GetQueryUrlFromObjectId(Query::"G/L Budget Entries"));
            PowerBIEndpoint::"G/L Entries - Income Statement":
                exit(GetQueryUrlFromObjectId(Query::"G/L Entries - Income Statement"));
            PowerBIEndpoint::"G/L Entries - Balance Sheet":
                exit(GetQueryUrlFromObjectId(Query::"G\L Entries - Balance Sheet"));
            PowerBIEndpoint::"G/L Entries - Closing":
                exit(GetQueryUrlFromObjectId(Query::"G/L Entries - Closing"));
            PowerBIEndpoint::"Sales Lines - Outstanding":
                exit(GetQueryUrlFromObjectId(Query::"Sales Lines - Outstanding"));
            PowerBIEndpoint::"Purchase Lines - Outstanding":
                exit(GetQueryUrlFromObjectId(Query::"Purchase Lines - Outstanding"));
            PowerBIEndpoint::"Requisition Lines":
                exit(GetQueryUrlFromObjectId(Query::"Requisition Lines"));
            PowerBIEndpoint::"Transfer Lines":
                exit(GetQueryUrlFromObjectId(Query::"Transfer Lines"));
            PowerBIEndpoint::"Service Lines - Order":
                exit(GetQueryUrlFromObjectId(Query::"Service Lines - Order"));
            PowerBIEndpoint::"Item Ledger Entries":
                exit(GetQueryUrlFromObjectId(Query::"Item Ledger Entries"));
            PowerBIEndpoint::"Warehouse Activity Lines":
                exit(GetQueryUrlFromObjectId(Query::"Warehouse Activity Lines"));
            PowerBIEndpoint::"Warehouse Entries":
                exit(GetQueryUrlFromObjectId(Query::"Warehouse Entries"));
            PowerBIEndpoint::"Whse. Journal Lines - From Bin":
                exit(GetQueryUrlFromObjectId(Query::"Whse. Journal Lines - From Bin"));
            PowerBIEndpoint::"Whse. Journal Lines - To Bin":
                exit(GetQueryUrlFromObjectId(Query::"Whse. Journal Lines - To Bin"));
            PowerBIEndpoint::"Value Entries - Item":
                exit(GetQueryUrlFromObjectId(Query::"Value Entries - Item"));
            PowerBIEndpoint::"Assembly Headers - Order":
                exit(GetQueryUrlFromObjectId(Query::"Assembly Headers - Order"));
            PowerBIEndpoint::"Assembly Lines - Item":
                exit(GetQueryUrlFromObjectId(Query::"Assembly Lines - Item"));
            PowerBIEndpoint::"Job Planning Lines - Item":
                exit(GetQueryUrlFromObjectId(Query::"Job Planning Lines - Item"));
            PowerBIEndpoint::"Prod. Order Lines - Invt.":
                exit(GetQueryUrlFromObjectId(Query::"Prod. Order Lines - Invt."));
            PowerBIEndpoint::"Prod. Order Comp. - Invt.":
                exit(GetQueryUrlFromObjectId(Query::"Prod. Order Comp. - Invt."));
            PowerBIEndpoint::"Planning Components":
                exit(GetQueryUrlFromObjectId(Query::"Planning Components"));
            PowerBIEndpoint::Zones:
                exit(GetQueryUrlFromObjectId(Query::Zones));
            PowerBIEndpoint::Bins:
                exit(GetQueryUrlFromObjectId(Query::Bins));
            PowerBIEndpoint::"Calendar Entries":
                exit(GetQueryUrlFromObjectId(Query::"Calendar Entries"));
            PowerBIEndpoint::"Machine Centers":
                exit(GetQueryUrlFromObjectId(Query::"Machine Centers"));
            PowerBIEndpoint::"Work Centers":
                exit(GetQueryUrlFromObjectId(Query::"Work Centers"));
            PowerBIEndpoint::"Prod. Order Lines - Manuf.":
                exit(GetQueryUrlFromObjectId(Query::"Prod. Order Lines - Manuf."));
            PowerBIEndpoint::"Prod. Order Routing Lines":
                exit(GetQueryUrlFromObjectId(Query::"Prod. Order Routing Lines"));
            PowerBIEndpoint::"Item Ledger Entries - Prod.":
                exit(GetQueryUrlFromObjectId(Query::"Item Ledger Entries - Prod."));
            PowerBIEndpoint::"Capacity Ledger Entries":
                exit(GetQueryUrlFromObjectId(Query::"Capacity Ledger Entries"));
            PowerBIEndpoint::"Prod. Order Capacity Needs":
                exit(GetQueryUrlFromObjectId(Query::"Prod. Order Capacity Needs"));
            PowerBIEndpoint::"Prod. Order Comp. - Manuf.":
                exit(GetQueryUrlFromObjectId(Query::"Prod. Order Comp. - Manuf."));
            PowerBIEndpoint::Jobs:
                exit(GetQueryUrlFromObjectId(Query::Jobs));
            PowerBIEndpoint::"Job Tasks":
                exit(GetQueryUrlFromObjectId(Query::"Job Tasks"));
            PowerBIEndpoint::"Job Planning Lines":
                exit(GetQueryUrlFromObjectId(Query::"Job Planning Lines"));
            PowerBIEndpoint::"Job Ledger Entries":
                exit(GetQueryUrlFromObjectId(Query::"Job Ledger Entries"));
            PowerBIEndpoint::"Purch. Lines - Job Outstanding":
                exit(GetQueryUrlFromObjectId(Query::"Purch. Lines - Job Outstanding"));
            PowerBIEndpoint::"Purch. Lines - Job Received":
                exit(GetQueryUrlFromObjectId(Query::"Purch. Lines - Job Received"));
            PowerBIEndpoint::"Purch. Lines - Item Outstd.":
                exit(GetQueryUrlFromObjectId(Query::"Purch. Lines - Item Outstd."));
            PowerBIEndpoint::"Item Budget Names":
                exit(GetQueryUrlFromObjectId(Query::"Item Budget Names"));
            PowerBIEndpoint::"Item Budget Entries - Purch.":
                exit(GetQueryUrlFromObjectId(Query::"Item Budget Entries - Purch."));
            PowerBIEndpoint::"Value Entries - Purch.":
                exit(GetQueryUrlFromObjectId(Query::"Value Entries - Purch."));
            PowerBIEndpoint::"Purch. Lines - Item Received":
                exit(GetQueryUrlFromObjectId(Query::"Purch. Lines - Item Received"));
            PowerBIEndpoint::"Sales Line - Item Outstanding":
                exit(GetQueryUrlFromObjectId(Query::"Sales Line - Item Outstanding"));
            PowerBIEndpoint::"Item Budget Entries - Sales":
                exit(GetQueryUrlFromObjectId(Query::"Item Budget Entries - Sales"));
            PowerBIEndpoint::"Value Entries - Sales":
                exit(GetQueryUrlFromObjectId(Query::"Value Entries - Sales"));
            PowerBIEndpoint::"Sales Line - Item Shipped":
                exit(GetQueryUrlFromObjectId(Query::"Sales Line - Item Shipped"));
        end;
    end;

    local procedure GetQueryUrlFromObjectId(ObjectId: Integer): Text
    var
        LibGraphMgt: Codeunit "Library - Graph Mgt";
    begin
        exit(LibGraphMgt.CreateQueryTargetURL(ObjectId, ''));
    end;

}