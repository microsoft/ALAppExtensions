page 20197 "Script Context"
{
    PageType = Card;
    SourceTable = "Script Context";
    RefreshOnActivate = true;
    DeleteAllowed = false;
    Caption = 'Script';
    DataCaptionExpression = 'Script';
    layout
    {
        area(Content)
        {
            part(OpenUseCaseTaxRules; "Script Editor")
            {
                Caption = 'Computation Rules';
                ApplicationArea = Basic, Suite;
                SubPageLink = "Case ID" = field("Case ID"), "Script ID" = field(ID);
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Variables)
            {
                ApplicationArea = Basic, Suite;
                Image = VariableList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Add a variable for usage in the script.';
                RunObject = page "Script Variables Part";
                RunPageLink = "Case ID" = field("Case ID"), "Script ID" = field(ID);
            }
        }
    }
}