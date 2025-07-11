// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;
table 10049 "IRS 1099 Vend. Entry Buffer"
{
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; Integer)
        {

        }
        field(2; "Vendor No."; Code[20])
        {

        }
        field(3; "IRS 1099 Form No."; Code[20])
        {

        }
        field(4; "IRS 1099 Form Box No."; Code[20])
        {

        }
        field(50; Amount; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
        }
        field(51; "Amount to Apply"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
        }
        field(52; "Pmt. Disc. Rcd.(LCY)"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
        }
        field(53; "IRS 1099 Reporting Amount"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
        }
        field(100; "Currency Code"; Code[10])
        {
        }
    }
}