namespace Microsoft.SubscriptionBilling;

page 8032 "Generic Import Settings Card"
{
    Caption = 'Generic Import Settings';
    PageType = Card;
    SourceTable = "Generic Import Settings";
    InsertAllowed = false;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Data Exchange Definition"; Rec."Data Exchange Definition")
                {
                    ToolTip = 'Specifies the definition based on which the billing data will be imported.';
                }
                field("Create Customers"; Rec."Create Customers")
                {
                    ToolTip = 'Defines whether the associated customers should also be created as usage data when importing the billing data.';
                }
                field("Create Subscriptions"; Rec."Create Subscriptions")
                {
                    ToolTip = 'Specifies whether the associated subscriptions should also be created as usage data when importing the billing data.';
                }
                field("Process without UsageDataBlobs"; Rec."Process without UsageDataBlobs")
                {
                    ToolTip = 'Specifies that no data from the associated blob field is used as the basis for processing the usage data. This is the case, for example, when the usage data is imported via API.';
                }
                field("Additional Processing"; Rec."Additional Processing")
                {
                    ToolTip = 'Specifies which additional steps are taken into consideration when processing usage data.';
                    Importance = Additional;
                    Visible = false;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get(Rec.GetUsageDataSupplierNoFromFilter()) then
            Rec.Insert(true);
    end;
}
