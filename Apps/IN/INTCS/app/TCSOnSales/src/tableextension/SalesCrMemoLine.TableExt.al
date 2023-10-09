// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.History;

tableextension 18842 "Sales Cr. Memo Line" extends "Sales Cr.Memo Line"
{
    fields
    {
        field(18838; "TCS Nature of Collection"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18839; "Assessee Code"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
    }
}
