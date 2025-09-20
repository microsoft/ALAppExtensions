// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.PowerBIReports.Test;

using Microsoft.Finance.PowerBIReports;
using Microsoft.PowerBIReports;
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
                exit(GetQueryUrlFromObjectId(Query::"Vendor Ledg. Entries - PBI API"));
            PowerBIEndpoint::"Customer Ledger Entries":
                exit(GetQueryUrlFromObjectId(Query::"Customer Ledger Entries"));
            PowerBIEndpoint::"G/L Accounts":
                exit(GetQueryUrlFromObjectId(Query::"G/L Accounts"));
            PowerBIEndpoint::"G/L Account Categories":
                exit(GetQueryUrlFromObjectId(Query::"G/L Account Categories"));
            PowerBIEndpoint::"G/L Budgets":
                exit(GetQueryUrlFromObjectId(Query::"G/L Budgets"));
            PowerBIEndpoint::"G/L Budget Entries":
                exit(GetQueryUrlFromObjectId(Query::"G/L Budget Entries - PBI API"));
            PowerBIEndpoint::"G/L Entries - Income Statement":
                exit(GetQueryUrlFromObjectId(Query::"G/L Income Statement - PBI API"));
            PowerBIEndpoint::"G/L Entries - Balance Sheet":
                exit(GetQueryUrlFromObjectId(Query::"G\L Entries - Balance Sheet"));
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
                exit(GetQueryUrlFromObjectId(Query::"Item Ledger Entries - PBI API"));
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
                exit(GetQueryUrlFromObjectId(Query::"Job Ledger Entries - PBI API"));
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
            PowerBIEndpoint::"Purch. Lines - Item Received":
                exit(GetQueryUrlFromObjectId(Query::"Purch. Lines - Item Received"));
            PowerBIEndpoint::"Sales Line - Item Outstanding":
                exit(GetQueryUrlFromObjectId(Query::"Sales Line - Item Outstanding"));
            PowerBIEndpoint::"Item Budget Entries - Sales":
                exit(GetQueryUrlFromObjectId(Query::"Item Budget Entries - Sales"));
            PowerBIEndpoint::"Sales Line - Item Shipped":
                exit(GetQueryUrlFromObjectId(Query::"Sales Line - Item Shipped"));
            PowerBIEndpoint::"Manufacturing Setup":
                exit(GetQueryUrlFromObjectId(Query::"Manufacturing Setup - PBI API"));
            PowerBIEndpoint::"Production Orders":
                exit(GetQueryUrlFromObjectId(Query::"Prod. Orders - PBI API"));
            PowerBIEndpoint::"Routing Links":
                exit(GetQueryUrlFromObjectId(Query::"Routing Links - PBI API"));
            PowerBIEndpoint::Routings:
                exit(GetQueryUrlFromObjectId(Query::"Routings - PBI API"));
            PowerBIEndpoint::"Value Entries - Manuf.":
                exit(GetQueryUrlFromObjectId(Query::"Manuf. Value Entries - PBI API"));
            PowerBIEndpoint::"Work Center Groups":
                exit(GetQueryUrlFromObjectId(Query::"Work Center Groups - PBI API"));
            PowerBIEndpoint::"Opportunity":
                exit(GetQueryUrlFromObjectId(Query::"Opportunity - PBI API"));
            PowerBIEndpoint::"Opportunity Entries":
                exit(GetQueryUrlFromObjectId(Query::"Opportunity Entries - PBI API"));
            PowerBIEndpoint::Contacts:
                exit(GetPageUrlFromObjectId(Page::"Contacts - PBI API"));
            PowerBIEndpoint::"Item Categories":
                exit(GetPageUrlFromObjectId(Page::"Item Category - PBI API"));
            PowerBIEndpoint::"Return Reason Codes":
                exit(GetPageUrlFromObjectId(Page::"Return Reason Code - PBI API"));
            PowerBIEndpoint::"Inv. Adj. Ent Order":
                exit(GetQueryUrlFromObjectId(Query::"Inv. Adj. Ent Order - PBI API"));
            PowerBIEndpoint::"Close Opporturnity Codes":
                exit(GetPageUrlFromObjectId(Page::"Close Opp. Code - PBI API"));
            PowerBIEndpoint::"Sales Cycle Stages":
                exit(GetPageUrlFromObjectId(Page::"Sales Cycle Stage - PBI API"));
            PowerBIEndpoint::Resources:
                exit(GetQueryUrlFromObjectId(Query::"Resources - PBI API"));
            PowerBIEndpoint::"Purchase Lines":
                exit(GetQueryUrlFromObjectId(Query::"Purchase Lines - PBI API"));
            PowerBIEndpoint::"Purchase Invoice Lines":
                exit(GetQueryUrlFromObjectId(Query::"Purchase Invoice Lines"));
            PowerBIEndpoint::"Purchase Credit Lines":
                exit(GetQueryUrlFromObjectId(Query::"Purchase Credit Lines"));
            PowerBIEndpoint::"Sales Credit Lines":
                exit(GetQueryUrlFromObjectId(Query::"Sales Credit Lines - PBI API"));
            PowerBIEndpoint::"Sales Cr Project Ledger Entries":
                exit(GetQueryUrlFromObjectId(Query::"Sales Cr Project Ledger Entry"));
            PowerBIEndpoint::"Sales Invoice Lines":
                exit(GetQueryUrlFromObjectId(Query::"Sales Invoice Lines - PBI API"));
            PowerBIEndpoint::"Sales Inv Project Ledger Entry":
                exit(GetQueryUrlFromObjectId(Query::"Sales Inv Project Ledger Entry"));
            PowerBIEndpoint::"Sales Lines V2":
                exit(GetQueryUrlFromObjectId(Query::"Sales Line V2 - PBI API"));
            PowerBIEndpoint::"Sales Value Entries":
                exit(GetQueryUrlFromObjectId(Query::"Sales Value Entries - PBI API"));
            PowerBIEndpoint::"Purch. Value Entries":
                exit(GetQueryUrlFromObjectId(Query::"Purch. Value Entries - PBI API"));
        end;
    end;

    procedure GetEndpointURLForAPIObject(ObjectType: ObjectType; ObjectId: Integer): Text
    begin
        case ObjectType of
            ObjectType::Page:
                exit(GetPageUrlFromObjectId(ObjectId));
            ObjectType::Query:
                exit(GetQueryUrlFromObjectId(ObjectId));
            else
                Error('Invalid object type for getting a URL endpoint');
        end;
    end;

    local procedure GetQueryUrlFromObjectId(ObjectId: Integer): Text
    var
        LibGraphMgt: Codeunit "Library - Graph Mgt";
    begin
        exit(LibGraphMgt.CreateQueryTargetURL(ObjectId, ''));
    end;

    local procedure GetPageUrlFromObjectId(ObjectId: Integer): Text
    var
        LibGraphMgt: Codeunit "Library - Graph Mgt";
    begin
        exit(LibGraphMgt.CreateTargetURL('', ObjectId, ''));
    end;
}