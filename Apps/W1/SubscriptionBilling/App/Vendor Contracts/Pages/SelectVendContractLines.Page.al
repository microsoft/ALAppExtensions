namespace Microsoft.SubscriptionBilling;

page 8092 "Select Vend. Contract Lines"
{
    Caption = 'Select Vendor Contract Lines';
    PageType = StandardDialog;
    SourceTable = "Vendor Contract Line";
    Editable = false;
    UsageCategory = None;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Service Start Date"; ServiceCommitment."Service Start Date")
                {
                    Caption = 'Service Start Date';
                    ToolTip = 'Specifies the date from which the service is valid and will be invoiced.';
                }
                field("Service Object Description"; Rec."Service Object Description")
                {
                    ToolTip = 'Specifies a description of the service object.';

                    trigger OnAssistEdit()
                    begin
                        Rec.OpenServiceObjectCard();
                    end;
                }
                field("Service Commitment Description"; Rec."Service Commitment Description")
                {
                    ToolTip = 'Specifies the description of the service.';
                }
                field("Cancellation Possible Until"; ServiceCommitment."Cancellation Possible Until")
                {
                    Caption = 'Cancellation Possible Until';
                    ToolTip = 'Specifies the last date for a timely termination. The date is determined by the initial term, extension term and a notice period. An initial term of 12 months and a 3-month notice period means that the deadline for a notice of termination is after 9 months. An extension period of 12 months postpones this date by 12 months.';
                }
                field("Term Until"; ServiceCommitment."Term Until")
                {
                    Caption = 'Term Until';
                    ToolTip = 'Specifies the earliest regular date for the end of the service, taking into account the initial term, extension term and a notice period. An initial term of 24 months results in a fixed term of 2 years. An extension period of 12 months postpones this date by 12 months.';
                }
                field("Service Object Quantity"; ServiceObject."Quantity Decimal")
                {
                    ToolTip = 'Specifies the Quantity of the Service Object.';
                }
                field("Service Object No."; Rec."Service Object No.")
                {
                    Visible = false;
                    ToolTip = 'Specifies the number of the service object no.';
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
        ServiceObject.Get(Rec."Service Object No.");
        ServiceCommitment.Get(Rec."Service Commitment Entry No.");
    end;

    local procedure ErrorIfMoreThanOneLineIsSelected(var VendorContractLine: Record "Vendor Contract Line")
    begin
        if VendorContractLine.Count > 1 then
            Error(OnlyOneLineCanBeSelectedErr);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        VendorContractLine: Record "Vendor Contract Line";
    begin
        CurrPage.SetSelectionFilter(VendorContractLine);
        if CloseAction = Action::OK then
            ErrorIfMoreThanOneLineIsSelected(VendorContractLine);
    end;

    var
        ServiceCommitment: Record "Service Commitment";
        ServiceObject: Record "Service Object";
        OnlyOneLineCanBeSelectedErr: Label 'Only one line can be selected.';

}
