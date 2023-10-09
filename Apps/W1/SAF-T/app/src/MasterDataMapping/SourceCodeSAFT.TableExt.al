// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.AuditCodes;

using Microsoft.Finance.AuditFileExport;

tableextension 5281 "Source Code SAF-T" extends "Source Code"
{
    fields
    {
        field(5280; "Source Code SAF-T"; Code[9])
        {
            Caption = 'SAF-T Source Code';
            TableRelation = "Source Code SAF-T";
        }
    }
}
