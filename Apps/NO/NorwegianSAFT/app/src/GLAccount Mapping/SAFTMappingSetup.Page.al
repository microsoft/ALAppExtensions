// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

page 10679 "SAF-T Mapping Setup"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "SAF-T Mapping Range";
    Caption = 'SAF-T Mapping Setup';
    CardPageId = "SAF-T Mapping Setup Card";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(MappingSetup)
            {
                Caption = 'Mapping Range';
                field(Code; Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the mapping range code that represents the SAF-T reporting period.';
                }
                field("Mapping Type"; "Mapping Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of mapping.';
                }
                field(RangeType; "Range Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the range type.';
                }
                field(AccountingPeriod; "Accounting Period")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the starting date of the accounting period that will be used as SAF-T reporting period.';
                }
                field(StartingDate; "Starting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the starting date of the SAF-T reporting period.';
                }
                field(EndingDate; "Ending Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ending date of the SAF-T reporting period.';
                }
            }
        }
    }
}
