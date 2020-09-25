// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

tableextension 13638 "OIOUBL-Issued Reminder Header" extends "Issued Reminder Header"
{
    fields
    {
        field(13630; "OIOUBL-GLN"; Code[13])
        {
            Caption = 'GLN';
        }
        field(13631; "OIOUBL-Account Code"; Text[30])
        {
            Caption = 'Account Code';
        }
        field(13634; "OIOUBL-Electronic Reminder Created"; Boolean)
        {
            Caption = 'Electronic Reminder Created';
            Editable = false;
        }
        field(13635; "OIOUBL-Contact Phone No."; Text[30])
        {
            Caption = 'Contact Phone No.';
            ExtendedDatatype = PhoneNo;
        }
        field(13636; "OIOUBL-Contact Fax No."; Text[30])
        {
            Caption = 'Contact Fax No.';
        }
        field(13637; "OIOUBL-Contact E-Mail"; Text[80])
        {
            Caption = 'Contact E-Mail';
            ExtendedDatatype = EMail;
        }
        field(13638; "OIOUBL-Contact Role"; Option)
        {
            Caption = 'Contact Role';
            OptionMembers = " ",,,"Purchase Responsible",,,Accountant,,,"Budget Responsible",,,Requisitioner;
        }
    }
    keys
    {
    }
}