namespace Microsoft.Integration.Shopify;

/// <summary>
/// Page Shpfy Cancel Order (ID 30160).
/// </summary>
page 30160 "Shpfy Cancel Order"
{
    Caption = 'Shopify Cancel Order';
    Editable = true;
    InsertAllowed = false;
    ModifyAllowed = true;
    DeleteAllowed = false;
    PageType = Card;
    ShowFilter = false;
    SourceTable = "Shpfy Order Header";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            field("Shopify Order No."; Rec."Shopify Order No.")
            {
                ApplicationArea = All;
                Caption = 'Shopify Order No.';
                Editable = false;
                ToolTip = 'Specifies the Shopify order number.';
            }
            field("Notify Customer"; NotifyCustomer)
            {
                ApplicationArea = All;
                Caption = 'Notify Customer';
                ToolTip = 'Specifies whether to send a notification to the customer about the order cancellation.';
                ShowMandatory = true;
            }
            field("Cancel Reason"; CancelReason)
            {
                ApplicationArea = All;
                Caption = 'Cancel Reason';
                ToolTip = 'Specifies the reason for cancelling the order.';
                ShowMandatory = true;
            }
            field(Refund; Refund)
            {
                ApplicationArea = All;
                Caption = 'Refund';
                ToolTip = 'Specifies whether to refund the amount paid by the customer.';
                ShowMandatory = true;
            }
            field(Restock; Restock)
            {
                ApplicationArea = All;
                Caption = 'Restock';
                ToolTip = 'Specifies whether to restock the inventory commited to the order.';
                ShowMandatory = true;
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = Action::LookupOK then
            Result := OrdersApi.CancelOrder(Rec."Shopify Order Id", Rec."Shop Code", NotifyCustomer, CancelReason, Refund, Restock);
    end;

    var
        OrdersApi: Codeunit "Shpfy Orders API";
        NotifyCustomer: Boolean;
        CancelReason: Enum "Shpfy Cancel Reason";
        Refund: Boolean;
        Restock: Boolean;
        Result: Boolean;

    internal procedure SetRec(OrderHeader: Record "Shpfy Order Header")
    var
        ShpfyCustomer: Record "Shpfy Customer";
    begin
        Rec := OrderHeader;
        Rec.Insert();
        if ShpfyCustomer.Get(Rec."Customer Id") then
            NotifyCustomer := ShpfyCustomer."Accepts Marketing";
    end;

    internal procedure GetResult(): Boolean
    begin
        exit(Result);
    end;
}

