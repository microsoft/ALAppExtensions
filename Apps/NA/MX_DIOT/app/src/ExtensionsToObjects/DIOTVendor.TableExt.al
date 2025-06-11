// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

tableextension 27031 "DIOT Vendor" extends Vendor
{
    fields
    {
        field(27030; "DIOT Type of Operation"; Enum "DIOT Type of Operation")
        {
            Caption = 'DIOT Type of Operation';
            DataClassification = CustomerContent;
        }
        field(27031; "Tax Effects Applied"; Boolean)
        {
            Caption = 'Tax Effects Applied';
            DataClassification = CustomerContent;
        }
        field(27032; "Tax Jurisdiction Location"; Text[300])
        {
            Caption = 'Tax Jurisdiction Location';
            DataClassification = CustomerContent;
        }
    }
}
