namespace Microsoft.SubscriptionBilling;

page 8077 "Create Vendor Billing Docs"
{

    Caption = 'Create Billing Documents';
    PageType = StandardDialog;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(DateFields)
            {
                Caption = 'Dates';
                field(DocumentDate; DocumentDate)
                {
                    Caption = 'Document Date';
                    ToolTip = 'Specifies the date which is taken over as the document date in the purchase documents.';
                }
                field(PostingDate; PostingDate)
                {
                    Caption = 'Posting Date';
                    ToolTip = 'Specifies the date which is used as the posting date in the purchase documents.';
                }
            }
            group(OptionFields)
            {
                Caption = 'Options';
                field(GroupingType; Grouping)
                {
                    Caption = 'Document per';
                    ToolTip = 'Specifies how the billing lines are grouped in the purchase documents.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        DocumentDate := WorkDate();
        PostingDate := WorkDate();
    end;

    var
        DocumentDate: Date;
        PostingDate: Date;
        Grouping: Enum "Vendor Rec. Billing Grouping";

    internal procedure GetData(var NewDocumentDate: Date; var NewPostingDate: Date; var NewGroupingType: Enum "Vendor Rec. Billing Grouping")
    begin
        NewDocumentDate := DocumentDate;
        NewPostingDate := PostingDate;
        NewGroupingType := Grouping;
    end;

}