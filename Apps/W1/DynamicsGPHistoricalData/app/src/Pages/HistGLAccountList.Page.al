namespace Microsoft.DataMigration.GP.HistoricalData;

page 41009 "Hist. G/L Account List"
{
    Caption = 'Historical G/L Accounts';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "Hist. G/L Account";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field.';
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(ViewDetails)
            {
                ApplicationArea = All;
                Caption = 'View Details';
                ToolTip = 'View more details about this transaction.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = Find;
                ShortcutKey = Return;

                trigger OnAction()
                var
                    HistGLAcctJrnlLines: Page "Hist. Gen. Journal Lines";
                begin
                    HistGLAcctJrnlLines.SetFilterAccountNo(Rec."No.");
                    HistGLAcctJrnlLines.Run();
                end;
            }
        }
    }
}