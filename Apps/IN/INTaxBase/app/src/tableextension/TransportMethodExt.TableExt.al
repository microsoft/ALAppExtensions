// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Finance.TaxBase;

tableextension 18549 "Transport Method Ext" extends "Transport Method"
{
    fields
    {
        field(18543; "Transportation Mode"; Enum "Transportation Mode")
        {
            DataClassification = EndUserIdentifiableInformation;
        }
    }
}
