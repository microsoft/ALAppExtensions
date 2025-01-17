namespace Microsoft.Integration.Shopify;

/// <summary>
/// Page Shpfy Order Attributes (ID 30114).
/// </summary>
page 30114 "Shpfy Order Attributes"
{

    Caption = 'Shopify Order Attributes';
    PageType = ListPart;
    SourceTable = "Shpfy Order Attribute";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Key"; Rec."Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the key or name of the attribute.';
                }
#if not CLEAN24
                field(Value; Rec.Value)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the attribute.';
                    Visible = not ReplaceOrderAtributeValueEnabled;
                    ObsoleteReason = 'Replaced with "Attribute Value" field.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '24.0';
                }
#endif
                field("Attribute Value"; Rec."Attribute Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the attribute.';
#if not CLEAN24
                    Visible = ReplaceOrderAtributeValueEnabled;
#endif
                }
            }
        }
    }

#if not CLEAN24
    trigger OnAfterGetRecord()
    var
        Shop: Record "Shpfy Shop";
        OrderHeader: Record "Shpfy Order Header";
        OrdersToImport: Record "Shpfy Orders To Import";
    begin
        if OrderHeader.Get(Rec."Order Id") then
            if Shop.Get(OrderHeader."Shop Code") then begin
                ReplaceOrderAtributeValueEnabled := Shop."Replace Order Attribute Value";
                exit;
            end;
        OrdersToImport.SetRange(Id, Rec."Order Id");
        if OrdersToImport.FindFirst() then
            if Shop.Get(OrdersToImport."Shop Code") then
                ReplaceOrderAtributeValueEnabled := Shop."Replace Order Attribute Value";
    end;

    var
        ReplaceOrderAtributeValueEnabled: Boolean;
#endif
}
