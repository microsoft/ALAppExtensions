// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Archive;

using Microsoft.Service.Reports;

tableextension 5040 "Serv. Decl. Serv. Line Archive" extends "Service Line Archive"
{
    fields
    {
        field(5010; "Service Transaction Type Code"; Code[20])
        {
            Caption = 'Service Transaction Type Code';
            DataClassification = CustomerContent;
            TableRelation = "Service Transaction Type";
        }
        field(5011; "Applicable For Serv. Decl."; Boolean)
        {
            Caption = 'Applicable For Service Declaration';
            DataClassification = CustomerContent;
        }
    }
}