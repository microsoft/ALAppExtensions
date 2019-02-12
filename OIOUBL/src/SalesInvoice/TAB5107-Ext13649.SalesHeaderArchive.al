// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

tableextension 13649 "OIOUBL-Sales Header Archive" extends "Sales Header Archive"
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
        field(13635; "OIOUBL-Sell-to Contact Phone No."; Text[30])
        {
            Caption = 'Sell-to Contact Phone No.';
            ExtendedDatatype = PhoneNo;
        }
        field(13636; "OIOUBL-Sell-to Contact Fax No."; Text[30])
        {
            Caption = 'Sell-to Contact Fax No.';
        }
        field(13637; "OIOUBL-Sell-to Contact E-Mail"; Text[80])
        {
            Caption = 'Sell-to Contact E-Mail';
            ExtendedDatatype = EMail;
        }
        field(13638; "OIOUBL-Sell-to Contact Role"; Option)
        {
            Caption = 'Sell-to Contact Role';
            OptionMembers = " ",,,"Purchase Responsible",,,Accountant,,,"Budget Responsible",,,Requisitioner;
        }
    }
    keys
    {
    }
}