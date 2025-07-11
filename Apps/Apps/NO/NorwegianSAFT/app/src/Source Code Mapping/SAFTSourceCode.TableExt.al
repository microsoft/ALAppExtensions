// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.AuditCodes;

using Microsoft.Finance.AuditFileExport;

tableextension 10680 "SAF-T Source Code" extends "Source Code"
{
    fields
    {
        field(10670; "SAF-T Source Code"; Code[9])
        {
            DataClassification = CustomerContent;
            Caption = 'SAF-T Source Code';
            TableRelation = "SAF-T Source Code";
        }
    }

}
