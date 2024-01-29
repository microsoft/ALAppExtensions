namespace Microsoft.Sustainability.Calculation;

using Microsoft.Sustainability.Account;
using Microsoft.Finance.GeneralLedger.Ledger;

page 6224 "Collect Amount from G/L Entry"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Collect Amount from General Ledger';
    PageType = ListPlus;
    SourceTable = "Sustain. Account Category";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("G/L Account Filter"; Rec."G/L Account Filter")
                {
                    Editable = false;
                    ToolTip = 'Specifies a general ledger account number filter.';
                }
                field("Global Dimension 1 Filter"; Rec."Global Dimension 1 Filter")
                {
                    Editable = false;
                    ToolTip = 'Specifies a global dimension 1 filter.';
                }
                field("Global Dimension 2 Filter"; Rec."Global Dimension 2 Filter")
                {
                    Editable = false;
                    ToolTip = 'Specifies a global dimension 2 filter.';
                }
                field(FromDate; FromDate)
                {
                    Caption = 'From Date';
                    ToolTip = 'Specifies a from date.';

                    trigger OnValidate()
                    begin
                        UpdateSubformForDateFilter();
                    end;
                }
                field(ToDate; ToDate)
                {
                    Caption = 'To Date';
                    ToolTip = 'Specifies a to date.';

                    trigger OnValidate()
                    begin
                        UpdateSubformForDateFilter();
                    end;
                }
            }
            part(GLAccountsSubform; "G/L Accounts Subform")
            {
                Caption = 'G/L Accounts';
                SubPageLink = "No." = field(filter("G/L Account Filter")),
                    "Global Dimension 1 Filter" = field(filter("Global Dimension 1 Filter")),
                    "Global Dimension 2 Filter" = field(filter("Global Dimension 2 Filter"));
            }
            group(Total)
            {
                ShowCaption = false;
                field(TotalAmount; SustainabilityCalcMgt.GetCollectableGLAmount(Rec, FromDate, ToDate))
                {
                    Caption = 'Total Amount';
                    Editable = false;
                    DrillDown = true;
                    ToolTip = 'Specifies a total calculated amount to be added to sustainability journal line.';

                    trigger OnDrillDown()
                    var
                        GLEntry: Record "G/L Entry";
                    begin
                        SustainabilityCalcMgt.FilterGLEntry(Rec, FromDate, ToDate, GLEntry);
                        Page.RunModal(0, GLEntry);
                    end;
                }
            }
        }
    }

    var
        SustainabilityCalcMgt: Codeunit "Sustainability Calc. Mgt.";
        FromDate, ToDate : Date;

    internal procedure GetDates(var FromDate2: Date; var ToDate2: Date)
    begin
        FromDate2 := FromDate;
        ToDate2 := ToDate;
    end;

    local procedure UpdateSubformForDateFilter()
    begin
        CurrPage.GLAccountsSubform.Page.ApplyDateFilter(FromDate, ToDate);
    end;
}