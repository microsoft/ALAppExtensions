namespace Microsoft.SubscriptionBilling;

page 8028 "Change Date"
{
    Caption = 'Change Date';
    PageType = StandardDialog;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            field(Date; ChangedDate)
            {
                Caption = 'New Date';
                ToolTip = 'Specifies the new Date.';
            }
        }
    }

    trigger OnOpenPage()
    begin
        if ChangedDate = 0D then
            ChangedDate := WorkDate();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = Action::OK then
            if ChangedDate = 0D then
                Error(NoDateErr);
    end;

    var
        ChangedDate: Date;
        NoDateErr: Label 'You must enter the Date.';

    procedure GetDate(): Date
    begin
        exit(ChangedDate);
    end;

    procedure SetDate(NewDate: Date)
    begin
        ChangedDate := NewDate;
    end;
}