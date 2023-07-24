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
#if not CLEAN23
            field(SalesStandardTaxCode; "Sales SAF-T Standard Tax Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code of the VAT posting setup that will be used for the StandardTaxCode XML node in the SAF-T file for the sales VAT entries.';
                ObsoleteReason = 'Use the field "Sale VAT Reporting Code" in BaseApp W1.';
                ObsoleteState = Pending;
                ObsoleteTag = '23.0';
            }
            field(PurchaseStandardTaxCode; "Purch. SAF-T Standard Tax Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code of the VAT posting setup that will be used for the StandardTaxCode XML node in the SAF-T file for the purchase VAT entries.';
                ObsoleteReason = 'Use the field "Purch. VAT Reporting Code" in BaseApp W1.';
                ObsoleteState = Pending;
                ObsoleteTag = '23.0';
            }
#endif
        }
    }
}