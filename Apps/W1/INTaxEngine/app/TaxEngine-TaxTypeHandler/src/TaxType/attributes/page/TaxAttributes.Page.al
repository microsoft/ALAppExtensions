page 20258 "Tax Attributes"
{
    Caption = 'Input Parameters';
    PageType = List;
    CardPageID = "Tax Attribute";
    RefreshOnActivate = true;
    SourceTable = "Tax Attribute";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group1)
            {
                field(Name; Name)
                {
                    ToolTip = 'Specifies the name of the attribute.';
                    ApplicationArea = Basic, Suite;
                }
                field(Type; Type)
                {
                    ToolTip = 'Specifies the type of the attribute.';
                    ApplicationArea = Basic, Suite;
                }
                field(Values; GetValues())
                {
                    Caption = 'Values';
                    ToolTip = 'Specifies the values of the attribute.';
                    ApplicationArea = Basic, Suite;
                    trigger OnDrillDown();
                    begin
                        OpenAttributeValues();
                    end;
                }
                field("Visible on Interface"; "Visible on Interface")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether attribute will be visible on tax information factbox.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(ActionGroup19)
            {
                Caption = '&Attribute';
                Image = VariableList;
                action(AttributeValues)
                {
                    Caption = 'Attribute &Values';
                    Enabled = (Type = Type::Option);
                    ToolTip = 'Opens a window in which you can define the values for the selected attribute.';
                    ApplicationArea = Basic, Suite;
                    Image = "CalculateInventory";
                    RunObject = Page "Tax Attribute Values";
                    RunPageLink = "Attribute ID" = field(ID);
                }

            }
        }

    }
}