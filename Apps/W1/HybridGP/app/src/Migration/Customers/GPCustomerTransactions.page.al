page 4094 "GP Customer Transactions"
{
    PageType = List;
    SourceTable = "GP Customer Transactions";
    Caption = 'Customer Transactions';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Id; Id) { ApplicationArea = All; ToolTip = 'Id'; }
                field(CUSTNMBR; CUSTNMBR) { ApplicationArea = All; ToolTip = 'Customer Number'; }
                field(DOCNUMBR; DOCNUMBR) { ApplicationArea = All; ToolTip = 'Document Number'; }
                field(DOCDATE; DOCDATE) { ApplicationArea = All; ToolTip = 'Document Date'; }
                field(DUEDATE; DUEDATE) { ApplicationArea = All; ToolTip = 'Due Date'; }
                field(CURTRXAM; CURTRXAM) { ApplicationArea = All; ToolTip = 'Customer Transaction Amount'; }
                field(RMDTYPAL; RMDTYPAL) { ApplicationArea = All; ToolTip = 'RMDTYPAL'; }
                field(GLDocNo; GLDocNo) { ApplicationArea = All; ToolTip = 'GL Document Number'; }
                field(TransType; TransType) { ApplicationArea = All; ToolTip = 'Transaction Type'; }
                field(SLPRSNID; SLPRSNID) { ApplicationArea = All; ToolTip = 'Salesperson Id'; }
                field(PYMTRMID; PYMTRMID) { ApplicationArea = All; ToolTip = 'PYMTRMID'; }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            group(SupportingPages)
            {
                Caption = 'Supporting Pages';

                action(AccountSetup)
                {
                    ApplicationArea = All;
                    Caption = 'Posting Accounts';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Image = EntriesList;
                    RunObject = Page "GP Posting Accounts";
                    RunPageMode = Edit;
                    ToolTip = 'Posting Account Setup';
                }
            }
        }
    }
}