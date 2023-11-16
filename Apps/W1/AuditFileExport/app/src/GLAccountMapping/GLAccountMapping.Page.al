// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

page 5260 "G/L Account Mapping"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "G/L Account Mapping Header";
    Caption = 'G/L Account Mapping';
    CardPageId = "G/L Acc. Mapping Card";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Mapping)
            {
                Caption = 'Mapping';
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the mapping code that represents the reporting period.';
                }
                field(StandardAccountType; Rec."Standard Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of the standard general ledger accounts.';
                }
                field(PeriodType; Rec."Period Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type for an accounting period or custom period with a flexible start date/time.';
                }
                field(AccountingPeriod; Rec."Accounting Period")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the starting date of the accounting period that will be used as reporting period.';
                }
                field(StartingDate; Rec."Starting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the starting date of the reporting period.';
                }
                field(EndingDate; Rec."Ending Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ending date of the reporting period.';
                }
            }
        }
    }
}
