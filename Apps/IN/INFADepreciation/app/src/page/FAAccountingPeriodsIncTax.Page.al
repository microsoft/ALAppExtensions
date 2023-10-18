// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.FADepreciation;

page 18631 "FA Accounting Periods Inc. Tax"
{
    ApplicationArea = FixedAssets;
    Caption = 'Fixed Asset Accounting Periods Inc. Tax';
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "FA Accounting Period Inc. Tax";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater("")
            {
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the date that the accounting period will begin.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the accounting period.';
                }
                field("New Fiscal Year"; Rec."New Fiscal Year")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies whether to use the accounting period to start a fiscal year.';
                }
                field(Closed; Rec.Closed)
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies if the accounting period belongs to a closed fiscal year.';
                }
                field("Date Locked"; Rec."Date Locked")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies if you can change the starting date the accounting period.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("&Create Year")
            {
                Caption = '&Create Year';
                ToolTip = 'Open a new fiscal year and define its accounting periods so you can start posting documents.';
                ApplicationArea = FixedAssets;
                Ellipsis = true;
                Image = CreateYear;

                trigger OnAction()
                begin
                    CreateFAFiscalYear.Run();
                end;
            }
            action("C&lose Year")
            {
                Caption = 'C&lose Year';
                ToolTip = 'Close the current fiscal year. A confirmation message will display that tells you which year will be closed. You cannot reopen the year after it has been closed.';
                ApplicationArea = FixedAssets;
                Image = CloseYear;
                RunObject = Codeunit "Fixed Asset Fiscal Year-Close";
            }
        }
    }

    var
        CreateFAFiscalYear: Report "Create FA Fiscal Year";
}
