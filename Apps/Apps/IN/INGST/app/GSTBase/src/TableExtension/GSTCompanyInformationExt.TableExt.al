// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Company;

using Microsoft.Finance.GST.Base;

tableextension 18001 "GST Company Information Ext" extends "Company Information"
{
    fields
    {
        field(18000; "GST Registration No."; code[20])
        {
            Caption = 'GST Registration No.';
            DataClassification = CustomerContent;
            TableRelation = "GST Registration Nos." where("State Code" = field("State Code"));
        }
        field(18001; "ARN No."; code[20])
        {
            Caption = 'ARN No.';
            DataClassification = CustomerContent;
        }
        field(18002; "Trading Co."; Boolean)
        {
            Caption = 'Trading Co.';
            DataClassification = CustomerContent;
        }
    }
}
