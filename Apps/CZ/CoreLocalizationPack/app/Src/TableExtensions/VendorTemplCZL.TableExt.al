// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

tableextension 31038 "Vendor Templ. CZL" extends "Vendor Templ."
{
    fields
    {
        field(11772; "Validate Registration No. CZL"; Boolean)
        {
            Caption = 'Validate Registration No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Validate Registration No. CZL" then
                    TestField("Validate EU Vat Reg. No.", false);
            end;
        }
    }
}
