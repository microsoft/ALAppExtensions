// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.VAT.Calculation;

page 11769 "VAT Periods CZL"
{
    ApplicationArea = Basic, Suite;
    Caption = 'VAT Periods';
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "VAT Period CZL";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the starting date for the VAT period.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies name of VAT periods.';
                }
                field("New VAT Year"; Rec."New VAT Year")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the period marks the beginning of a new VAT year.';
                }
                field(Closed; Rec.Closed)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether VAT entries are closed and applied in period.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action("VAT Statement")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'VAT Statements';
                Image = VATStatement;
                RunObject = page "VAT Statement";
                ToolTip = 'Show the VAT statements.';
            }
            action("VIES Declarations")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'VIES Declarations';
                Image = VATExemption;
                RunObject = page "VIES Declarations CZL";
                ToolTip = 'Show the VIES Declarations.';
            }
            action("VAT Control Report")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'VAT Control Report';
                Image = VATLedger;
                RunObject = page "VAT Ctrl. Report List CZL";
                ToolTip = 'Show the VAT Control Reports.';
            }
            action("Non-Deductible VAT Setup CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Non-Deductible VAT Setup';
                Image = VATPostingSetup;
                RunObject = Page "Non-Deductible VAT Setup CZL";
                ToolTip = 'Set up VAT coefficient correction.';
                Visible = NonDeductibleVATVisible;
            }
        }
        area(Creation)
        {
            action("Create Periods")
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Create Periods';
                Ellipsis = true;
                Image = Period;
                RunObject = report "Create VAT Period CZL";
                ToolTip = 'This batch job automatically creates VAT periods.';
            }
        }
        area(Reporting)
        {
            action("G/L VAT Reconciliation CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'G/L VAT Reconciliation';
                Image = PrintReport;
                RunObject = report "G/L VAT Reconciliation CZL";
                ToolTip = 'This report compares general ledger entries by filtering data either by the posting date or the VAT date.';
            }
        }
        area(Processing)
        {
            action("VAT Coeff. Correction CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'VAT Coefficient Correction';
                Image = AdjustVATExemption;
                RunObject = report "VAT Coeff. Correction CZL";
                ToolTip = 'The report recalculate the value of non-deductible VAT according to settlement coeffiecient on VAT entries.';
                Visible = NonDeductibleVATVisible;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref("Create Periods_Promoted"; "Create Periods")
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        NonDeductibleVATVisible := NonDeductibleVATCZL.IsNonDeductibleVATEnabled();
    end;

    var
        NonDeductibleVATCZL: Codeunit "Non-Deductible VAT CZL";
        NonDeductibleVATVisible: Boolean;
}
