// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

page 18549 "Tax Accounting Periods"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Tax Accounting Period";
    RefreshOnActivate = true;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Tax Type Code"; Rec."Tax Type Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the tax type for the accounting period.';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the date that the accounting period will begin.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the date that the accounting period will end.';
                }
                field("Financial Year"; Rec."Financial Year")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the name of the accounting period.';
                }
                field(Quarter; Rec.Quarter)
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quarter this accounting period belongs to.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the accounting period.';
                }
                field("New Fiscal Year"; Rec."New Fiscal Year")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether to use the accounting period to start a fiscal year.';
                }
                field(Closed; Rec.Closed)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies if the accounting period belongs to a closed fiscal year.';
                }
                field("Date Locked"; Rec."Date Locked")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if you can change the starting date for the accounting period.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Create Year")
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Create Year';
                Ellipsis = true;
                Image = CreateYear;
                PromotedOnly = true;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Report "Create Tax Accounting Period";
                ToolTip = 'Open a new fiscal year and define its accounting periods so you can start posting documents.';
            }
            action("Close Year")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'C&lose Year';
                Image = CloseYear;
                PromotedOnly = true;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Codeunit "Tax Fiscal Year Close";
                ToolTip = 'Close the current fiscal year. A confirmation message will display that tells you which year will be closed. You cannot reopen the year after it has been closed.';
            }
        }
    }
}
