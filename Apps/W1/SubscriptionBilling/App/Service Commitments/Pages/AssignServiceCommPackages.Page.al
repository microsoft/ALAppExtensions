namespace Microsoft.SubscriptionBilling;

page 8093 "Assign Service Comm. Packages"
{
    Caption = 'Assign Subscription Packages';
    InsertAllowed = false;
    DeleteAllowed = false;
    PageType = List;
    SourceTable = "Subscription Package";
    SourceTableTemporary = true;
    ApplicationArea = All;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Selected; Rec.Selected)
                {
                    ToolTip = 'Specifies which additional Subscription Packages are taken into account when creating the Subscription.';
                }
                field("Code"; Rec.Code)
                {
                    ShowMandatory = true;
                    ToolTip = 'Specifies a code to identify this Subscription Package.';
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the Subscription Package.';
                    Editable = false;
                }
                field("Price Group"; Rec."Price Group")
                {
                    ToolTip = 'Specifies the customer price group that will be used for the invoicing of Subscription Lines.';
                    Editable = false;
                }
            }
        }
    }
}
