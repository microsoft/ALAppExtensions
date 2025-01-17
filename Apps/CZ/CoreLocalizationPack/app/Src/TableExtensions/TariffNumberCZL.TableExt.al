// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Finance.VAT.Reporting;
using Microsoft.Foundation.UOM;

tableextension 11753 "Tariff Number CZL" extends "Tariff Number"
{
    fields
    {
        field(11765; "Statement Code CZL"; Code[10])
        {
            Caption = 'Statement Code';
            TableRelation = "Commodity CZL".Code;
            DataClassification = CustomerContent;
        }
        field(11766; "VAT Stat. UoM Code CZL"; Code[10])
        {
            Caption = 'VAT Stat. Unit of Measure Code';
            TableRelation = "Unit of Measure";
            DataClassification = CustomerContent;
        }
        field(11767; "Allow Empty UoM Code CZL"; Boolean)
        {
            Caption = 'Allow Empty Unit of Measure Code';
            DataClassification = CustomerContent;
        }
        field(11768; "Statement Limit Code CZL"; Code[10])
        {
            Caption = 'Statement Limit Code';
            TableRelation = "Commodity CZL".Code;
            DataClassification = CustomerContent;
        }
        field(11795; "Description EN CZL"; Text[100])
        {
            Caption = 'Description EN';
            DataClassification = CustomerContent;
        }
#if not CLEANSCHEMA25
        field(31065; "Suppl. Unit of Meas. Code CZL"; Code[10])
        {
            Caption = 'Supplementary Unit of Measure Code';
            TableRelation = "Unit of Measure";
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
#endif
    }
}
