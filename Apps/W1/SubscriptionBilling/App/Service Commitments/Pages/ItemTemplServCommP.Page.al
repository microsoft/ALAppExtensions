namespace Microsoft.SubscriptionBilling;

page 8027 "Item Templ. Serv. Comm. P."
{
    ApplicationArea = All;
    Caption = 'Item Template Subscription Packages';
    PageType = ListPart;
    SourceTable = "Item Templ. Sub. Package";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies a code to identify this Subscription Package.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Description"; Rec."Description")
                {
                    ToolTip = 'Specifies a description of the Subscription Package.';
                }
                field("Standard"; Rec."Standard")
                {
                    ToolTip = 'Specifies whether the package Subscription Lines should be automatically added to the sales process when the item is sold. If the checkbox is not set, the package Subscription Lines can be added manually in the sales process.';
                }
                field("Price Group"; Rec."Price Group")
                {
                    ToolTip = 'Specifies the customer price group that will be used for the invoicing of Subscription Lines.';
                }
            }
        }
    }

}
