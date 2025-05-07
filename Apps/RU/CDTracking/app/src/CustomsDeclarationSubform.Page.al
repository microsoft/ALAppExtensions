#pragma warning disable AA0247
page 14105 "Customs Declaration Subform"
{
    Caption = 'Lines';
    PageType = ListPart;
    PopulateAllFields = true;
    SourceTable = "Package No. Information";

    layout
    {
        area(content)
        {
            repeater(Control1210000)
            {
                ShowCaption = false;
                field("No."; Rec."Item No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the variant of the item on the line.';
                }
                field("Package No."; Rec."Package No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the customs declaration number.';
                }
                field("CD Header Number"; Rec."CD Header Number")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the customs declaration. ';
                }
                field("Temporary CD Number"; Rec."Temporary CD Number")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the temporary number of the customs declaration. ';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description associated with this line.';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country/region of the address.';
                }
                field(Inventory; Rec.Inventory)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the item quantity on hand associated with this line.';
                    Visible = false;
                }
                field("Purchases (Qty)"; Rec."Purchases (Qty)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the item quantity of the posted purchase invoice associated with this line.';
                    Visible = false;
                }
                field("Sales (Qty)"; Rec."Sales (Qty)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the item quantity of the posted sales invoice associated with this line.';
                    Visible = false;
                }
                field("Positive Adjmt. (Qty)"; Rec."Positive Adjmt. (Qty)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the item quantity of the posted positive adjustments associated with this line.';
                    Visible = false;
                }
                field("Negative Adjmt. (Qty)"; Rec."Negative Adjmt. (Qty)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the item quantity of the posted negative adjustments associated with this line.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }

    procedure UpdateForm()
    begin
        CurrPage.Update();
    end;

    procedure Navigate()
    var
        ItemTrackingSetup: Record "Item Tracking Setup";
        NavigatePage: Page Navigate;
    begin
        ItemTrackingSetup."Package No." := Rec."Package No.";
        NavigatePage.SetTracking(ItemTrackingSetup);
        NavigatePage.Run();
    end;
}

