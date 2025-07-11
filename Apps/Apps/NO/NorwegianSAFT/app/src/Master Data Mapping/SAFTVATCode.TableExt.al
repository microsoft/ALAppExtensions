// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Finance.VAT.Setup;

tableextension 10675 "SAF-T VAT Code" extends "VAT Code"
{
    fields
    {
        field(10670; Compensation; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Compensation';
        }
    }
}
