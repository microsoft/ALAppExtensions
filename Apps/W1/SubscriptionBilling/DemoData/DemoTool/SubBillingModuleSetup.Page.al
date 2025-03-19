namespace Microsoft.SubscriptionBilling;

page 8101 "Sub. Billing Module Setup"
{
    PageType = Card;
    ApplicationArea = All;
    Caption = 'Sub. Billing Module Setup';
    SourceTable = "Sub. Billing Module Setup";
    Extensible = false;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Create entries in Job Queue"; Rec."Create entries in Job Queue")
                {
                }
                field("Import Data Exch. Definition"; Rec."Import Data Exch. Definition")
                {
                }
                field("Import reconciliation file"; Rec."Import reconciliation file")
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.InitRecord();
    end;
}