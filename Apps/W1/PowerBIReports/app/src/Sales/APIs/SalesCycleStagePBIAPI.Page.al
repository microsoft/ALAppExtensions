// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.PowerBIReports;

using Microsoft.CRM.Opportunity;

page 37082 "Sales Cycle Stage - PBI API"
{
    PageType = API;
    Caption = 'Power BI Sales Cycle Stages';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'salesCycleStage';
    EntitySetName = 'salesCycleStages';
    SourceTable = "Sales Cycle Stage";
    DelayedInsert = true;
    DataAccessIntent = ReadOnly;
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(salesCycleCode; Rec."Sales Cycle Code") { }
                field(salesCycleStage; Rec."Stage") { }
                field(salesCycleStageDescription; Rec."Description") { }
            }
        }
    }
}