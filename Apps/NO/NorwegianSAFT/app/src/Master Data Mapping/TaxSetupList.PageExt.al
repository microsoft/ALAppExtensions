// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

pageextension 10682 "SAF-T Tax Setup List" extends "VAT Posting Setup"
{
    layout
    {
        addlast(Control1)
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
