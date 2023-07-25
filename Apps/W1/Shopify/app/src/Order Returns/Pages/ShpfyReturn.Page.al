page 30151 "Shpfy Return"
{
    ApplicationArea = All;
    Caption = 'Shopify Return';
    PageType = Document;
    SourceTable = "Shpfy Return Header";
    UsageCategory = Documents;

    layout
    {
        area(content)
        {
            Group(General)
            {
                field("Return No."; Rec."Return No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The No. of the return.';
                }
                field("Shopify Order No."; Rec."Shopify Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The unique identifier for the order that appears on the order page in the Shopify admin and the order status page. For example, "#1001", "EN1001", or "1001-A".';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'The status of the return.';
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sell-to Customer No. field.';
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sell-to Customer Name field.';
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Customer No. field.';
                }
                field("Bill-to Customer Name"; Rec."Bill-to Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Customer Name field.';
                }
                field("Decline Reason"; Rec."Decline Reason")
                {
                    ApplicationArea = All;
                    ToolTip = 'The reason the customer''s return request was declined.';
                }
                field("Total Quantity"; Rec."Total Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'The sum of all line item quantities for the return.';
                }
            }
            part(Lines; "Shpfy Return Lines")
            {
                SubPageLink = "Return Id" = field("Return Id");
            }
            group(DeclineNote)
            {
                Caption = 'Decline Note';
                Visible = HasNote;

                field("Decline Note"; Rec.GetDeclineNote())
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = 'The sum of all line item quantities for the return.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RetrievedShopifyData)
            {
                ApplicationArea = All;
                Caption = 'Retrieved Shopify Data';
                Image = Entry;
                ToolTip = 'View the data retrieved from Shopify.';
                trigger OnAction();
                var
                    DataCapture: Record "Shpfy Data Capture";
                begin
                    DataCapture.SetCurrentKey("Linked To Table", "Linked To Id");
                    DataCapture.SetRange("Linked To Table", Database::"Shpfy Return Header");
                    DataCapture.SetRange("Linked To Id", Rec.SystemId);
                    Page.Run(Page::"Shpfy Data Capture List", DataCapture);
                end;
            }
        }
        area(Promoted)
        {
            actionref(PromotedRetrievedShopifyData; RetrievedShopifyData) { }
        }
    }

    var
        HasNote: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        HasNote := Rec."Decline Note".HasValue();
    end;

}