// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 10532 "MTD Return Details"
{
    Caption = 'Submitted VAT Return';

    fields
    {
        field(1; "Start Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(2; "End Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(3; "Period Key"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(4; "VAT Due Sales"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(5; "VAT Due Acquisitions"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(6; "Total VAT Due"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(7; "VAT Reclaimed Curr Period"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(8; "Net VAT Due"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(9; "Total Value Sales Excl. VAT"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(10; "Total Value Purchases Excl.VAT"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(11; "Total Value Goods Suppl. ExVAT"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(12; "Total Acquisitions Excl. VAT"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(13; Finalised; Boolean)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Start Date", "End Date")
        {
        }
    }

    fieldgroups
    {
    }

    internal procedure DiffersFromReturn(MTDReturnDetails: Record "MTD Return Details"): Boolean
    begin
        exit(
          ("Period Key" <> MTDReturnDetails."Period Key") or
          ("VAT Due Sales" <> MTDReturnDetails."VAT Due Sales") or
          ("VAT Due Acquisitions" <> MTDReturnDetails."VAT Due Acquisitions") or
          ("Total VAT Due" <> MTDReturnDetails."Total VAT Due") or
          ("VAT Reclaimed Curr Period" <> MTDReturnDetails."VAT Reclaimed Curr Period") or
          ("Net VAT Due" <> MTDReturnDetails."Net VAT Due") or
          ("Total Value Sales Excl. VAT" <> MTDReturnDetails."Total Value Sales Excl. VAT") or
          ("Total Value Purchases Excl.VAT" <> MTDReturnDetails."Total Value Purchases Excl.VAT") or
          ("Total Value Goods Suppl. ExVAT" <> MTDReturnDetails."Total Value Goods Suppl. ExVAT") or
          ("Total Acquisitions Excl. VAT" <> MTDReturnDetails."Total Acquisitions Excl. VAT") or
          (Finalised <> MTDReturnDetails.Finalised));
    end;
}

