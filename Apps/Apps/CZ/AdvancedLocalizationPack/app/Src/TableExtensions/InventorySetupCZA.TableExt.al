// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Setup;

using Microsoft.Finance.GeneralLedger.Setup;

tableextension 31250 "Inventory Setup CZA" extends "Inventory Setup"
{
    fields
    {
        field(31061; "Use GPPG from SKU CZA"; Boolean)
        {
            Caption = 'Use Gen. Prod. Posting Group from Stockkeeping Unit';
            DataClassification = CustomerContent;
        }
        field(31067; "Skip Update SKU on Posting CZA"; Boolean)
        {
            Caption = 'Skip Update SKU on Posting';
            DataClassification = CustomerContent;
        }
        field(31068; "Exact Cost Revers. Mandat. CZA"; Boolean)
        {
            Caption = 'Exact Cost Reversing Mandatory';
            DataClassification = CustomerContent;
        }
        field(31069; "Def.G.Bus.P.Gr.-Dir.Trans. CZA"; Code[20])
        {
            Caption = 'Default Gen. Bus. Posting Group for Direct Transfer';
            TableRelation = "Gen. Business Posting Group";
            DataClassification = CustomerContent;
        }
    }
}
