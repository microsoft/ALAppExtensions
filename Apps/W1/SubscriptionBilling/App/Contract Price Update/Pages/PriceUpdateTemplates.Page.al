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
                    ToolTip = 'Determines whether the template applies to customer or vendor contracts.';
                }
                field("Contract Filter"; Rec."Contract Filter".HasValue())
                {
                    Caption = 'Contract Filter';
                    ToolTip = 'Shows if a filters has been defined for the template.';

                    trigger OnDrillDown()
                    begin
                        Rec.EditFilter(Rec.FieldNo("Contract Filter"));
                    end;
                }
                field("Service Commitment Filter"; Rec."Service Commitment Filter".HasValue())
                {
                    Caption = 'Service Commitment Filter';
                    ToolTip = 'Shows if a filters has been defined for the template.';
                    trigger OnDrillDown()
                    begin
                        Rec.EditFilter(Rec.FieldNo("Service Commitment Filter"));
                    end;
                }
                field("Service Object Filter"; Rec."Service Object Filter".HasValue())
                {
                    Caption = 'Service Object Filter';
                    ToolTip = 'Shows if a filters has been defined for the template.';
                    trigger OnDrillDown()
                    begin
                        Rec.EditFilter(Rec.FieldNo("Service Object Filter"));
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
