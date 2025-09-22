// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.PowerBIReports;

using Microsoft.CRM.Opportunity;

query 37018 "Opportunity Entries - PBI API"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Opportunity Entries';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'opportunityEntry';
    EntitySetName = 'opportunityEntries';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(opportunityEntry; "Opportunity Entry")
        {
            column(opportunityEntryEntryNo; "Entry No.") { }
            column(opportunityEntryOpportunity; "Opportunity No.") { }
            column(salespersonCode; "Salesperson Code") { }
            column(opportunityEntryActive; Active) { }
            column(opportunityEntryActionTaken; "Action Taken") { }
            column(opportunityEntryDateChange; "Date of Change") { }
            column(opportunityEntryEstCloseDate; "Estimated Close Date") { }
            column(opportunityEntryEstValue; "Estimated Value (LCY)") { }
            column(opportunityEntryCalcCurrentValue; "Calcd. Current Value (LCY)") { }
            column(opportunityEntryCompleted; "Completed %") { }
            column(opportunityEntryChanceSuccess; "Chances of Success %") { }
            column(opportunityEntryProbability; "Probability %") { }
            column(opportunityEntrySalesCycleCode; "Sales Cycle Code") { }
            column(opportunityEntrySalesCycleStage; "Sales Cycle Stage") { }
            column(opportunityEntrySalesCycleStageDescription; "Sales Cycle Stage Description") { }
            column(opportunityEntryCloseOpportunityCode; "Close Opportunity Code") { }
            column(opportunityContactNo; "Contact No.") { }

        }
    }
}