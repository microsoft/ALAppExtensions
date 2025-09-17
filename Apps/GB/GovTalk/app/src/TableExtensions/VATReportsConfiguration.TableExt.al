// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using Microsoft.Finance.VAT.Reporting;

tableextension 10569 "VAT Reports Configuration" extends "VAT Reports Configuration"
{
    fields
    {
        field(10501; "Content Max Lines GB"; Integer)
        {
            Caption = 'Content Max Lines';
            DataClassification = CustomerContent;
        }
    }
}