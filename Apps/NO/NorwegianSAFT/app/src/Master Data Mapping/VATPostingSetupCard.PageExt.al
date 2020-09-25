pageextension 10683 "SAF-T Tax Setup Card" extends "VAT Posting Setup Card"
{
    layout
    {
        addlast(General)
        {
            field(SalesSAFTTaxCode; "Sales SAF-T Tax Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code of the VAT posting setup that will be used for the TaxCode XML node in the SAF-T file for the sales VAT entries.';
            }
            field(PurchaseSAFTTaxCode; "Purchase SAF-T Tax Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code of the VAT posting setup that will be used for the TaxCode XML node in the SAF-T file for the purchase VAT entries.';
            }
            field(SalesStandardTaxCode; "Sales SAF-T Standard Tax Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code of the VAT posting setup that will be used for the StandardTaxCode XML node in the SAF-T file for the sales VAT entries.';
            }
            field(PurchaseStandardTaxCode; "Purch. SAF-T Standard Tax Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code of the VAT posting setup that will be used for the StandardTaxCode XML node in the SAF-T file for the purchase VAT entries.';
            }
        }
    }
}