namespace Microsoft.SubscriptionBilling;

page 8091 "Select Cust. Contract Lines"
{
    Caption = 'Select Customer Subscription Contract Lines';
    PageType = StandardDialog;
    SourceTable = "Cust. Sub. Contract Line";
    Editable = false;
    UsageCategory = None;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Service Start Date"; ServiceCommitment."Subscription Line Start Date")
                {
                    Caption = 'Subscription Line Start Date';
                    ToolTip = 'Specifies the date from which the Subscription Line is valid and will be invoiced.';
                }
                field("Service Object Description"; Rec."Subscription Description")
                {
                    ToolTip = 'Specifies a description of the Subscription.';

                    trigger OnAssistEdit()
                    begin
                        Rec.OpenServiceObjectCard();
                    end;
                }
                field("Service Commitment Description"; Rec."Subscription Line Description")
                {
                    ToolTip = 'Specifies the description of the Subscription Line.';
                }
                field("Cancellation Possible Until"; ServiceCommitment."Cancellation Possible Until")
                {
                    Caption = 'Cancellation Possible Until';
                    ToolTip = 'Specifies the last date for a timely termination. The date is determined by the initial term, extension term and a notice period. An initial term of 12 months and a 3-month notice period means that the deadline for a notice of termination is after 9 months. An extension period of 12 months postpones this date by 12 months.';
                }
                field("Term Until"; ServiceCommitment."Term Until")
                {
                    Caption = 'Term Until';
                    ToolTip = 'Specifies the earliest regular date for the end of the Subscription Line, taking into account the initial term, extension term and a notice period. An initial term of 24 months results in a fixed term of 2 years. An extension period of 12 months postpones this date by 12 months.';
                }
                field("Service Object Quantity"; ServiceObject.Quantity)
                {
                    ToolTip = 'Specifies the Quantity of the Subscription.';
                }
                field("Service Object No."; Rec."Subscription Header No.")
                {
                    Visible = false;
                    ToolTip = 'Specifies the number of the Subscription.';
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        InitializePageVariables();
    end;

    local procedure InitializePageVariables()
    var
    begin
        ServiceObject.Get(Rec."Subscription Header No.");
        ServiceCommitment.Get(Rec."Subscription Line Entry No.");
    end;

    local procedure ErrorIfMoreThanOneLineIsSelected(var CustomerContractLine: Record "Cust. Sub. Contract Line")
    begin
        if CustomerContractLine.Count > 1 then
            Error(OnlyOneLineCanBeSelectedErr);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        CustomerContractLine: Record "Cust. Sub. Contract Line";
    begin
        CurrPage.SetSelectionFilter(CustomerContractLine);
        if CloseAction = Action::OK then
            ErrorIfMoreThanOneLineIsSelected(CustomerContractLine);
    end;

    var
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
        OnlyOneLineCanBeSelectedErr: Label 'Only one line can be selected.';
}
