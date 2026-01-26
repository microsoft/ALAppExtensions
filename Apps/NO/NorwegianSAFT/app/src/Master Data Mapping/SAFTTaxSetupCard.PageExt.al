// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

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
        }
    }
}
