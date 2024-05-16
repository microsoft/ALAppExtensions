// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

table 18009 "HSN/SAC"
{
    Caption = 'HSN/SAC';
    DataCaptionFields = "GST Group Code", Code;
    LookupPageId = "HSN/SAC";
    DrillDownPageId = "HSN/SAC";

    fields
    {
#pragma warning disable AS0118
        field(1; "GST Group Code"; Code[20])
        {
            Caption = 'GST Group Code';
            NotBlank = true;
            DataClassification = CustomerContent;
            TableRelation = "GST Group";
        }
#pragma warning restore AS0118
        field(2; "Code"; code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(3; "Description"; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(4; "Type"; enum "GST Goods And Services Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "GST Group Code", Code)
        {
            Clustered = true;
        }
    }
}
