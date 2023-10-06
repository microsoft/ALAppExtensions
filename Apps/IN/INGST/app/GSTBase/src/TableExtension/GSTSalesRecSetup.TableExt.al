// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Setup;

using Microsoft.Finance.GST.Base;

tableextension 18015 "GST Sales Rec Setup" extends "Sales & Receivables Setup"
{
    fields
    {
        field(18000; "GST Dependency Type"; Enum "GST Dependency Type")
        {
            Caption = 'GST Dependency Type';
            DataClassification = CustomerContent;
        }
    }
}
