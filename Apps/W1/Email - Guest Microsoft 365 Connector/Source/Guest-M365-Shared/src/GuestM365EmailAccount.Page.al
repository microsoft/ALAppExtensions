page 89202 "LGS Guest M365 Email Account"
{
    Caption = 'Guest Microsoft 365 Email Account';
    SourceTable = "LGS Email Guest Outlook Acc.";
    PageType = Card;
    Extensible = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            field(NameField; Rec.Name)
            {
                ApplicationArea = All;
                Caption = 'Account Name';
                ToolTip = 'The name of the account.';
                ShowMandatory = true;
                NotBlank = true;
                trigger OnValidate()
                begin
                    UpdateEmailAccount();
                end;
            }
            field(EmailAddress; Rec."Email Address")
            {
                ApplicationArea = All;
                Caption = 'Email Address';
                ToolTip = 'Specifies the email address of the account.';
                ShowMandatory = true;
                NotBlank = true;
                trigger OnValidate()
                begin
                    UpdateEmailAccount();
                end;
            }
        }
    }

    local procedure UpdateEmailAccount()
    var
        GuestOutlookApiHelper: Codeunit "LGS Guest Outlook - API Helper";
    begin
        GuestOutlookApiHelper.UpdateEmailAccount(Rec);
    end;
}
