namespace Microsoft.Finance.GeneralLedger.Review;

page 22206 "G/L Entry Review Setup"
{
    AdditionalSearchTerms = 'review,apply,gl entries, review gl';
    ApplicationArea = Basic, Suite;
    Caption = 'G/L Entry Review Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    Permissions = tabledata "G/L Entry Review Setup" = rim;
    SourceTable = "G/L Entry Review Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Review Engine"; Rec.GLEntryReviewer)
                {
                    ToolTip = 'Specifies which review implementation the review system uses';
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then
            Rec.Insert();
    end;
}