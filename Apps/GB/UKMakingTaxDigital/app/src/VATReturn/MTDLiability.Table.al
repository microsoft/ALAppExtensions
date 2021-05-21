// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 10530 "MTD Liability"
{
    Caption = 'VAT Liability';
    LookupPageID = "MTD Liabilities";

    fields
    {
        field(1; "From Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(2; "To Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(3; Type; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = " ","VAT Return Debit Charge";
        }
        field(4; "Original Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(5; "Outstanding Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(6; "Due Date"; Date)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "From Date", "To Date")
        {
        }
    }

    fieldgroups
    {
    }

    internal procedure DiffersFromLiability(MTDLiability: Record "MTD Liability"): Boolean
    begin
        exit(
          (Type <> MTDLiability.Type) OR
          ("Original Amount" <> MTDLiability."Original Amount") OR
          ("Outstanding Amount" <> MTDLiability."Outstanding Amount") OR
          ("Due Date" <> MTDLiability."Due Date"));
    end;
}

