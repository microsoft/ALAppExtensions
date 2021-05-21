// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality to manage configuration settings of Email Printers.
/// </summary>
table 2650 "Email Printer Settings"
{
    fields
    {
        field(1; ID; code[250])
        {
            Caption = 'Printer ID';
            NotBlank = true;
        }
        field(2; Description; Text[250])
        {
            Caption = 'Printer Description';
        }
        field(3; "Email Address"; Text[250])
        {
            Caption = 'Printer Email Address';
        }
        field(4; "Email Subject"; Text[250])
        {
            Caption = 'Email Subject';
        }
        field(5; "Email Body"; Text[2048])
        {
            Caption = 'Email Body';
        }
        field(6; "Paper Size"; Enum "Printer Paper Kind")
        {
            Caption = 'Paper Size';
        }
        field(7; "Paper Height"; Decimal)
        {
            Caption = 'Printer Paper Height';
            DecimalPlaces = 0 : 2;
        }
        field(8; "Paper Width"; Decimal)
        {
            Caption = 'Printer Paper Width';
            DecimalPlaces = 0 : 2;
        }
        field(9; "Paper Unit"; Enum "Email Printer Paper Unit")
        {
            Caption = 'Printer Paper Units';
        }
        field(10; Landscape; Boolean)
        {
            Caption = 'Landscape';
        }
    }

    keys
    {
        key(pk; ID)
        {
            Clustered = true;
        }
    }
}