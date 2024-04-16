namespace Microsoft.Integration.Shopify;

page 30161 "Shpfy Disputes"
{
    Editable = false;
    PageType = List;
    UsageCategory = None;
    SourceTable = "Shpfy Dispute";
    Caption = 'Disputes';

    layout
    {
        area(Content)
        {
            repeater(control01)
            {

                field(Id; Rec.Id)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Id field.';
                }
                field("Source Order Id"; Rec."Source Order Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Source Order Id field.';
                }
                field("Type"; Rec."Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field.';
                }
                field(Currency; Rec.Currency)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency field.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field.';
                }
                field(Reason; Rec.Reason)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shpfy Dispute Reason field.';
                }
                field("Network Reason Code"; Rec."Network Reason Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Network Reason Code field.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field.';
                }
                field("Evidence Due By"; Rec."Evidence Due By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Evidence Due By field.';
                }
                field("Evidence Sent On"; Rec."Evidence Sent On")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Evidence Sent On field.';
                }
                field("Finalized On"; Rec."Finalized On")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Finalized On field.';
                }
            }
        }
    }
}