pageextension 10852 "Intrastat Report FR" extends "Intrastat Report"
{
    layout
    {
        addafter("Currency Identifier")
        {
            field("Obligation Level"; Rec."Obligation Level")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the Obligation level used to filter the reported data.';
            }
            field("Transaction Specification Filter"; Rec."Trans. Spec. Filter")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies a filter for which types of transactions on Intrastat lines that will be processed for the chosen obligation level. Leave the field blank to include all transaction specifications.';
            }
        }
    }
}