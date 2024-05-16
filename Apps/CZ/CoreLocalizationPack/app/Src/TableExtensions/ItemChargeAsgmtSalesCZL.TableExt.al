// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

tableextension 31020 "Item Charge Asgmt. (Sales) CZL" extends "Item Charge Assignment (Sales)"
{
    fields
    {
        field(31052; "Incl. in Intrastat Amount CZL"; Boolean)
        {
            Caption = 'Incl. in Intrastat Amount';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
        field(31053; "Incl. in Intrastat S.Value CZL"; Boolean)
        {
            Caption = 'Incl. in Intrastat Stat. Value';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
    }
}
