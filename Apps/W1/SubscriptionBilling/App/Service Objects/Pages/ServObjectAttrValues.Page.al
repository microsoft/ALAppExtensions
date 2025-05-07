namespace Microsoft.SubscriptionBilling;

page 8010 "Serv. Object Attr. Values"
{
    Caption = 'Subscription Attribute Values';
    PageType = StandardDialog;
    SourceTable = "Subscription Header";
    layout
    {
        area(content)
        {
            part(ServiceObjectAttributeValueList; "Serv. Object Attribute Values")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        CurrPage.ServiceObjectAttributeValueList.Page.LoadAttributes(Rec."No.");
    end;
}

