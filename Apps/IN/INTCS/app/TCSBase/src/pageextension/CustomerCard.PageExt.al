pageextension 18808 "Customer Card" extends "Customer Card"
{
    actions
    {
        addlast("&Customer")
        {
            group("TaxInformation")
            {
                Caption = 'Tax Information';
                Image = Action;

                action("TCS Allowed NOC")
                {
                    Caption = 'TCS Allowed NOC';
                    ApplicationArea = Basic, Suite;
                    Promoted = true;
                    PromotedCategory = Category9;
                    PromotedIsBig = true;
                    Image = LinkAccount;
                    RunObject = Page "Allowed NOC";
                    RunPageLink = "Customer No." = field("No.");
                    ToolTip = 'Specifies the TCS Nature of Collection on customer.';
                }
                action("TCS Customer Concessional Codes")
                {
                    Caption = 'TCS Customer Concessional Codes';
                    ApplicationArea = Basic, Suite;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category9;
                    Image = LinkAccount;
                    RunObject = Page "Customer Concessional Codes";
                    RunPageLink = "Customer No." = field("No.");
                    ToolTip = 'Specify the Concessional Code if concessional rate is applicable.';
                }
            }
        }
    }
}