// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

page 42002 "SL FiscalPeriodsTable"
{
    ApplicationArea = All;
    Caption = 'Fiscal Periods Table';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    PromotedActionCategories = 'Related Entities';
    SourceTable = "SL Fiscal Periods";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(PeriodID; Rec.PeriodID) { ToolTip = 'Fiscal Period'; }
                field(Year1; Rec.Year1) { ToolTip = 'Year'; }
                field(PeriodDT; Rec.PeriodDT) { ToolTip = 'Period Start Date'; }
                field(PERDENDT; Rec.PerEndDT) { ToolTip = 'Period End'; }
            }
        }
    }
}