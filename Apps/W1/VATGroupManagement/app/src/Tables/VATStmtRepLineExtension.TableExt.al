// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Group;

using Microsoft.Finance.VAT.Reporting;

tableextension 4703 "VAT Stmt. Rep. Line Extension" extends "VAT Statement Report Line"
{
    fields
    {
        field(4700; "Representative Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            Caption = 'Representative Amount';
            Editable = false;
        }
        field(4701; "Group Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            Caption = 'Group Amount';
            Editable = false;
        }
    }
}