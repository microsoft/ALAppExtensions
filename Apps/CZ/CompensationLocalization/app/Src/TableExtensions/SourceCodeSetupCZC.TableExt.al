// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using Microsoft.Foundation.AuditCodes;

tableextension 31270 "Source Code Setup CZC" extends "Source Code Setup"
{
    fields
    {
        field(31270; "Compensation CZC"; Code[10])
        {
            Caption = 'Compensation';
            TableRelation = "Source Code";
            DataClassification = CustomerContent;
        }
    }
}
