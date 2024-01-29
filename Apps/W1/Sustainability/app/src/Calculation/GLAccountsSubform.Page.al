namespace Microsoft.Sustainability.Calculation;

using Microsoft.Finance.GeneralLedger.Account;

page 6225 "G/L Accounts Subform"
{
    ApplicationArea = Basic, Suite;
    Editable = false;
    PageType = ListPart;
    SourceTable = "G/L Account";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                IndentationColumn = Rec.Indentation;
                IndentationControls = Name;
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Style = Strong;
                    StyleExpr = Rec."Account Type" <> Rec."Account Type"::Posting;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    Style = Strong;
                    StyleExpr = Rec."Account Type" <> Rec."Account Type"::Posting;
                    ToolTip = 'Specifies the name of the general ledger account.';
                }
                field(Totaling; Rec.Totaling)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies an account interval or a list of account numbers. The entries of the account will be totaled to give a total balance. How entries are totaled depends on the value in the Account Type field.';
                }
                field("Net Change"; Rec."Net Change")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    ToolTip = 'Specifies the net change in the account balance during the time period in the Date Filter field.';
                }
            }
        }
    }
    var
        FromToFilterLbl: Label '%1..%2', Locked = true;

    internal procedure ApplyDateFilter(FromDate: Date; ToDate: Date)
    begin
        if (FromDate <> 0D) or (ToDate <> 0D) then
            Rec.SetFilter("Date Filter", StrSubstNo(FromToFilterLbl, FromDate, ToDate));
        Rec.CalcFields("Net Change");
        CurrPage.Update(false);
    end;
}