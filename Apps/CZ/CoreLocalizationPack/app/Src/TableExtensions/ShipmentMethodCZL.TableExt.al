// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Shipping;

tableextension 11796 "Shipment Method CZL" extends "Shipment Method"
{
    fields
    {
        field(31065; "Incl. Item Charges (Amt.) CZL"; Boolean)
        {
            Caption = 'Include Item Charges (Amount)';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
        field(31066; "Intrastat Deliv. Grp. Code CZL"; Code[10])
        {
            Caption = 'Intrastat Delivery Group Code';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
        field(31067; "Incl. Item Charges (S.Val) CZL"; Boolean)
        {
            Caption = 'Incl. Item Charges (Stat.Val.)';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
        field(31068; "Adjustment % CZL"; Decimal)
        {
            Caption = 'Adjustment %';
            MaxValue = 100;
            MinValue = -100;
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
    }
}
