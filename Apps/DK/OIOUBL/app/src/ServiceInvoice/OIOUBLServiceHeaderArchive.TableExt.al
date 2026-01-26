// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Archive;

using Microsoft.EServices.EDocument;

tableextension 13635 "OIOUBL-Service Header Archive" extends "Service Header Archive"
{
    fields
    {
        field(13630; "OIOUBL-GLN"; Code[13])
        {
            Caption = 'GLN';
            DataClassification = CustomerContent;
        }
        field(13631; "OIOUBL-Account Code"; Text[30])
        {
            Caption = 'Account Code';
            DataClassification = CustomerContent;
        }
        field(13632; "OIOUBL-Profile Code"; Code[10])
        {
            Caption = 'Profile Code';
            DataClassification = CustomerContent;
            TableRelation = "OIOUBL-Profile";
        }
        field(13638; "OIOUBL-Contact Role"; Option)
        {
            Caption = 'Contact Role';
            DataClassification = CustomerContent;
            OptionMembers = " ",,,"Purchase Responsible",,,"Accountant",,,"Budget Responsible",,,"Requisitioner";
        }
    }
}