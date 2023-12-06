// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Inventory.Intrastat;

table 31090 "Commodity CZL"
{
    Caption = 'Commodity';
    DataCaptionFields = Code;
    DrillDownPageId = "Commodities CZL";
    LookupPageId = "Commodities CZL";

    fields
    {
        field(1; Code; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        CommoditySetupCZL: Record "Commodity Setup CZL";
        TariffNumber: Record "Tariff Number";
    begin
        CommoditySetupCZL.SetRange("Commodity Code", Code);
        CommoditySetupCZL.DeleteAll();

        TariffNumber.SetRange("Statement Code CZL", Code);
        if not TariffNumber.IsEmpty() then
            Error(CommodityUsedErr);

        TariffNumber.Reset();
        TariffNumber.SetRange("Statement Limit Code CZL", Code);
        if not TariffNumber.IsEmpty() then
            Error(CommodityUsedErr);
    end;

    var
        CommodityUsedErr: Label 'The Commodity code is used in the Tariff Number and therefore cannot be removed.';
}
