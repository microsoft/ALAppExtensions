page 20106 "AMC Bank Assist Bank Account"
{
    Caption = ' ';
    PageType = ListPart;
    SourceTable = "Online Bank Acc. Link";
    SourceTableTemporary = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = true;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = ' ';
                InstructionalText = 'Select which bank accounts to set up.';
                field("No."; "No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field(Name; Name)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the name of the bank where you have the bank account.';
                }
                field(CurrencyCode; "Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Caption = 'Currency Code';
                    ToolTip = 'Specifies the relevant currency code for the bank account.';
                }
                field("Bank Account No."; "Bank Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the number used by the bank for the bank account.';
                }
                field(Chose; "Automatic Logon Possible")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = true;
                    Caption = 'Update';
                    ToolTip = 'Select bank account to set up with Data Exch. Def. for AMC Banking.';
                }
            }
        }
    }
    procedure ClearRecs()
    begin
        if (not Rec.IsEmpty()) then
            rec.DeleteAll();
    end;

    procedure SetRecs(var OnlineBankAccLink: Record "Online Bank Acc. Link")
    begin
        Rec.DeleteAll();
        OnlineBankAccLink.Reset();
        OnlineBankAccLink.FindSet();
        repeat
            Rec := OnlineBankAccLink;
            Insert();
        until OnlineBankAccLink.Next() = 0
    end;

    procedure GetRecs(var OnlineBankAccLink: Record "Online Bank Acc. Link")
    begin
        if (not Rec.IsEmpty()) then begin
            OnlineBankAccLink.DeleteAll();
            Rec.Reset();
            Rec.FindSet();
            repeat
                OnlineBankAccLink := Rec;
                OnlineBankAccLink.Insert();
            until Rec.Next() = 0
        end;
    end;
}