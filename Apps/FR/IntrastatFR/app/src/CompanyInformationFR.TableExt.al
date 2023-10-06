// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Foundation.Company;

tableextension 10852 "Company Information FR" extends "Company Information"
{
    fields
    {
        field(10851; "Last Intr. Declaration ID"; Integer)
        {
            Caption = 'Last Used Intrastat Declaration ID';
            DataClassification = SystemMetadata;
        }
    }
}