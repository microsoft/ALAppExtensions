// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Inventory.Item;

tableextension 31301 "Item CZ" extends Item
{
    fields
    {
        field(31300; "Statistic Indication CZ"; Code[10])
        {
            Caption = 'Statistic Indication';
            DataClassification = CustomerContent;
            TableRelation = "Statistic Indication CZ".Code where("Tariff No." = field("Tariff No."));
        }
        field(31305; "Specific Movement CZ"; Code[10])
        {
            Caption = 'Specific Movement';
            DataClassification = CustomerContent;
            TableRelation = "Specific Movement CZ".Code;
        }
        field(31310; "Fair Market Value CZ"; Decimal)
        {
            AutoFormatType = 2;
            AutoFormatExpression = '';
            Caption = 'Fair Market Value';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the price which the system compares with the sales or purchase price from the item ledger entries with this value when generating Intrastat line suggestions. If the calculated tolerance is equal to or greater than the Minimum Tolerance from Fair Market Value (%) defined in the Intrastat Report Setup, the system will use this fair market value in the suggested lines instead of the actual sales or purchase price.';
        }
    }
}