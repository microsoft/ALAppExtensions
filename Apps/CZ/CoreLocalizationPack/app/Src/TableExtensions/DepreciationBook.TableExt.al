// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.Depreciation;

tableextension 11791 "Depreciation Book CZL" extends "Depreciation Book"
{
    fields
    {
        field(31046; "Mark Reclass. as Correct. CZL"; Boolean)
        {
            Caption = 'Mark Reclass. as Corrections';
            DataClassification = CustomerContent;
        }
    }
}
