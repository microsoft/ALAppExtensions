namespace Microsoft.SubscriptionBilling;

page 8027 "Item Templ. Serv. Comm. P."
{
    ApplicationArea = All;
    Caption = 'Item Template Service Commitment Packages';
    PageType = ListPart;
    SourceTable = "Item Templ. Serv. Comm. Pack.";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies a code to identify this service commitment package.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Description"; Rec."Description")
                {
                    ToolTip = 'Specifies a description of the service commitment package.';
                }
                field("Standard"; Rec."Standard")
                {
                    ToolTip = 'Specifies whether the package service commitments should be automatically added to the sales process when the item is sold. If the checkbox is not set, the package service commitments can be added manually in the sales process.';
                }
                field("Price Group"; Rec."Price Group")
                {
                    ToolTip = 'Specifies the customer price group that will be used for the invoicing of services.';
                }
            }
        }
    }

}
