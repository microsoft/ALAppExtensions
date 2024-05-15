// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.Foundation.Address;
using Microsoft.Inventory.Intrastat;

tableextension 11755 "Sales Line CZL" extends "Sales Line"
{
    fields
    {
        field(11769; "Negative CZL"; Boolean)
        {
            Caption = 'Negative';
            DataClassification = CustomerContent;
        }
        field(31064; "Physical Transfer CZL"; Boolean)
        {
            Caption = 'Physical Transfer';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
        field(31065; "Tariff No. CZL"; Code[20])
        {
            Caption = 'Tariff No.';
            TableRelation = "Tariff Number";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                TariffNumber: Record "Tariff Number";
            begin
                if (Type = Type::"G/L Account") and ("Tariff No. CZL" <> xRec."Tariff No. CZL") then begin
                    if not TariffNumber.Get("Tariff No. CZL") then
                        TariffNumber.Init();

                    if ("Job Contract Entry No." <> 0) and
                       (TariffNumber."VAT Stat. UoM Code CZL" <> '') and
                       (TariffNumber."VAT Stat. UoM Code CZL" <> "Unit of Measure Code")
                    then
                        TestField("Unit of Measure Code", TariffNumber."VAT Stat. UoM Code CZL");

                    if "Job Contract Entry No." = 0 then
                        Validate("Unit of Measure Code", TariffNumber."VAT Stat. UoM Code CZL");
                end;
            end;
        }
        field(31066; "Statistic Indication CZL"; Code[10])
        {
            Caption = 'Statistic Indication';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
        field(31067; "Country/Reg. of Orig. Code CZL"; Code[10])
        {
            Caption = 'Country/Region of Origin Code';
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions. This field is not used any more.';
        }
    }
}
