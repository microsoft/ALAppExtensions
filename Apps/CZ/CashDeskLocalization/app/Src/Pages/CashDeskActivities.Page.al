page 31154 "Cash Desk Activities CZP"
{
    Caption = 'Cash Desk Activities';
    PageType = CardPart;
    SourceTable = "Cash Desk Cue CZP";

    layout
    {
        area(content)
        {
            cuegroup(Unposted)
            {
                Caption = 'Unposted';
                field("Open Documents"; Rec."Open Documents")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies number of cash desk documents with status open.';
                }
                field("Released Documents"; Rec."Released Documents")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies number of cash desk documents with status released.';
                }
            }
            cuegroup(Posted)
            {
                Caption = 'Posted';
                field("Posted Documents"; Rec."Posted Documents")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies number of cash desk documents with status posted.';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        CashDeskManagementCZP: Codeunit "Cash Desk Management CZP";
        CashDeskFilter: Text;
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;

        Rec.FilterGroup(2);
        CashDeskFilter := CashDeskManagementCZP.GetCashDesksFilter();
        if CashDeskFilter <> '' then
            Rec.SetFilter("Cash Desk Filter", CashDeskFilter)
        else
            Rec.SetRange("Cash Desk Filter", '');
        Rec.SetRange("Date Filter", WorkDate());
        Rec.FilterGroup(0);
    end;
}
