// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

tableextension 13631 "OIOUBL-Sales Invoice Line" extends "Sales Invoice Line"
{
    fields
    {
        field(13631; "OIOUBL-Account Code"; Text[30])
        {
            Caption = 'Account Code';
        }
    }
}