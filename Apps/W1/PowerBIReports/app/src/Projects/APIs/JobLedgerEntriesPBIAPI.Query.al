// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Projects.PowerBIReports;

using Microsoft.Projects.Project.Ledger;

query 36992 "Job Ledger Entries - PBI API"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Project Ledger Entry';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'jobLedgerEntry';
    EntitySetName = 'jobLedgerEntries';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(jobLedgerEntry; "Job Ledger Entry")
        {
            column(jobNo; "Job No.")
            {
            }
            column(jobTaskNo; "Job Task No.")
            {
            }
            column(postingDate; "Posting Date")
            {
            }
            column(entryType; "Entry Type")
            {
            }
            column(type; Type)
            {
            }
            column(no; "No.")
            {
            }
            column(description; Description)
            {
            }
            column(locationCode; "Location Code")
            {
            }
            column(unitOfMeasureCode; "Unit of Measure Code")
            {
            }
            column(quantity; Quantity)
            {
            }
            column(unitCostLCY; "Unit Cost (LCY)")
            {
            }
            column(totalCostLCY; "Total Cost (LCY)")
            {
            }
            column(unitPrice; "Unit Price (LCY)")
            {
            }
            column(totalPriceLCY; "Total Price (LCY)")
            {
            }
            column(dimensionSetID; "Dimension Set ID")
            {
            }
        }
    }

    trigger OnBeforeOpen()
    var
        PBIMgt: Codeunit "Project Filter Helper";
        DateFilterText: Text;
    begin
        DateFilterText := PBIMgt.GenerateJobLedgerDateFilter();
        if DateFilterText <> '' then
            CurrQuery.SetFilter(postingDate, DateFilterText);
    end;
}
