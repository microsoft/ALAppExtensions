// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.History;

using Microsoft.Service.Reports;

tableextension 5035 "SD Serv. Cr. Memo Line" extends "Service Cr.Memo Line"
{
    fields
    {
        field(5010; "Service Transaction Type Code"; Code[20])
        {
            Caption = 'Service Transaction Type Code';
            TableRelation = "Service Transaction Type";
            Editable = false;
        }
        field(5011; "Applicable For Serv. Decl."; Boolean)
        {
            Caption = 'Applicable For Service Declaration';
            Editable = false;
        }
    }
}
