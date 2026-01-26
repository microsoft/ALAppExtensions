// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
tableextension 6807 "WHT Company Info Ext" extends "Company Information"
{
    fields
    {
        field(6784; "Withholding Tax Reg. ID"; Text[30])
        {
            Caption = 'Withholding Tax Registration ID';
        }
        field(6785; "WHT RDO Code"; Code[3])
        {
            Caption = 'RDO Code';
        }
        field(6786; "WHT VAT Registration Date"; Date)
        {
            Caption = 'VAT Registration Date';
        }
    }
}