namespace Microsoft.SubscriptionBilling;

page 8026 "Price Update Templates"
{
    ApplicationArea = All;
    UsageCategory = None;
    LinksAllowed = false;
    Caption = 'Price Update Templates';
    PageType = List;
    SourceTable = "Price Update Template";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the unique code of the Price Update Template.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the template.';
                }
                field(Partner; Rec.Partner)
                {
                    ToolTip = 'Specifies whether the template applies to customer or Vendor Subscription Contracts.';
                }
                field("Contract Filter"; Rec."Subscription Contract Filter".HasValue())
                {
                    Caption = 'Contract Filter';
                    ToolTip = 'Specifies if a filter has been defined for the template.';

                    trigger OnDrillDown()
                    begin
                        Rec.EditFilter(Rec.FieldNo("Subscription Contract Filter"));
                    end;
                }
                field("Service Commitment Filter"; Rec."Subscription Line Filter".HasValue())
                {
                    Caption = 'Subscription Line Filter';
                    ToolTip = 'Specifies if a filter has been defined for the template.';
                    trigger OnDrillDown()
                    begin
                        Rec.EditFilter(Rec.FieldNo("Subscription Line Filter"));
                    end;
                }
                field("Service Object Filter"; Rec."Subscription Filter".HasValue())
                {
                    Caption = 'Subscription Filter';
                    ToolTip = 'Specifies if a filter has been defined for the template.';
                    trigger OnDrillDown()
                    begin
                        Rec.EditFilter(Rec.FieldNo("Subscription Filter"));
                    end;
                }
                field("Price Update Method"; Rec."Price Update Method")
                {
                    ToolTip = 'Specifies the method to update prices. The method determines which field will be updated by which value.';
                }
                field("Update Value %"; Rec."Update Value %")
                {
                    ToolTip = 'Specifies the value, the price or Calculation Base % will be changed by.';
                    Editable = Rec."Price Update Method" <> Enum::"Price Update Method"::"Recent Item Prices";
                }
                field("Perform Update on Formula"; Rec."Perform Update on Formula")
                {
                    ToolTip = 'Specifies the optional formula to set Perform Price on Formula.';
                }
                field(InclContrLinesUpToDateFormula; Rec.InclContrLinesUpToDateFormula)
                {
                    ToolTip = 'Specifies the optional formula to set the Include Contract lines up to date.';
                }
                field("Price Binding Period"; Rec."Price Binding Period")
                {
                    ToolTip = 'Specifies the period the price will not be changed after the price update. It sets a new "Next Price Update" in the contract line after the price update has been performed.';
                }
                field("Group by"; Rec."Group by")
                {
                    ToolTip = 'Specifies the option for grouping contract billing lines.';
                }
            }
        }
    }
}
