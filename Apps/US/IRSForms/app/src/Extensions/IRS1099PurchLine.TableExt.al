// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Document;
using Microsoft.Finance.Currency;

tableextension 10055 "IRS 1099 Purch. Line" extends "Purchase Line"
{
    fields
    {
        field(10030; "1099 Liable"; Boolean)
        {
            DataClassification = CustomerContent;
            ToolTip = 'Specifies if the amount is to be a 1099 amount.';

            trigger OnValidate()
            var
                PurchHeader: Record "Purchase Header";
            begin
                Rec.GetPurchHeader(PurchHeader, Currency);
                if PurchHeader."IRS 1099 Form Box No." = '' then
                    Error('You cannot set the "1099 Liable" field because the "IRS 1099 Form Box No." field on the purchase header is blank.');
            end;
        }
    }

    trigger OnInsert()
    var
        PurchHeader: Record "Purchase Header";
        Currency: Record Currency;
    begin
        Rec.GetPurchHeader(PurchHeader, Currency);
        "1099 Liable" := (PurchHeader."IRS 1099 Form Box No." <> '')
    end;
}