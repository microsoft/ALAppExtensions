// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Archive;

using Microsoft.Finance.GST.Base;

tableextension 18471 "GST Service Line Archive" extends "Service Line Archive"
{
    fields
    {
        field(18440; "GST Place Of Supply"; Enum "GST Dependency Type")
        {
            Caption = 'GST Place Of Supply';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(18441; "GST Group Code"; Code[20])
        {
            Caption = 'GST Group Code';
            TableRelation = "GST Group";
            DataClassification = CustomerContent;
        }
        field(18442; "GST Group Type"; Enum "GST Group Type")
        {
            Caption = 'GST Group Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18443; "HSN/SAC Code"; Code[10])
        {
            Caption = 'HSN/SAC Code';
            TableRelation = "HSN/SAC".Code where("GST Group Code" = field("GST Group Code"));
            DataClassification = CustomerContent;
        }
        field(18444; "GST Jurisdiction Type"; Enum "GST Jurisdiction Type")
        {
            Caption = 'GST Jurisdiction Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18445; "Invoice Type"; Enum "Sales Invoice Type")
        {
            Caption = 'Invoice Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18446; Exempted; Boolean)
        {
            Caption = 'Exempted';
            DataClassification = CustomerContent;
        }
        field(18447; "GST On Assessable Value"; Boolean)
        {
            Caption = 'GST On Assessable Value';
            DataClassification = CustomerContent;
        }
        field(18448; "GST Assessable Value (LCY)"; Decimal)
        {
            Caption = 'GST Assessable Value (LCY)';
            DataClassification = CustomerContent;
        }
        field(18449; "Non-GST Line"; Boolean)
        {
            Caption = 'Non-GST Line';
            DataClassification = CustomerContent;
        }
    }
}