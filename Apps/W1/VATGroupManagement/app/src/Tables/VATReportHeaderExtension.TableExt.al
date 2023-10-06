// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Group;

using Microsoft.Finance.VAT.Reporting;

tableextension 4700 "VAT Report Header Extension" extends "VAT Report Header"
{
    fields
    {
        field(4700; "VAT Group Return"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'VAT Group Return';

        }
        field(4701; "VAT Group Status"; Text[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'VAT Group Return Status';
        }
        field(4702; "VAT Group Settlement Posted"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'VAT Group Settlement Posted';
        }
    }
}