// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Foundation.AuditCodes;

tableextension 11779 "Source Code Setup CZP" extends "Source Code Setup"
{
    fields
    {
        field(11740; "Cash Desk CZP"; Code[10])
        {
            Caption = 'Cash Desk';
            TableRelation = "Source Code";
            DataClassification = CustomerContent;
        }
    }
}
