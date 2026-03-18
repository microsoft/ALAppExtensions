// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Sales.Receivables;

tableextension 31280 "Cust. Ledger Entry CZB" extends "Cust. Ledger Entry"
{
    fields
    {
#pragma warning disable AA0232
        field(11790; "Amount on Pmt. Order (LCY) CZB"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = '';
            CalcFormula = - sum("Iss. Payment Order Line CZB"."Amount (LCY)" where(Type = const(Customer), "Applies-to C/V/E Entry No." = field("Entry No."), Status = const(" ")));
            Caption = 'Amount on Payment Order (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
#pragma warning restore
    }

    internal procedure GetRemainingAmountInclPmtDiscToDate(ReferenceDate: Date; UseLCY: Boolean): Decimal
    begin
        exit(GetRemainingAmount(UseLCY) - GetRemainingPmtDiscPossibleToDate(ReferenceDate, UseLCY));
    end;

    internal procedure GetRemainingAmount(UseLCY: Boolean): Decimal
    begin
        exit(UseLCY ? "Remaining Amt. (LCY)" : "Remaining Amount");
    end;

    internal procedure GetRemainingPmtDiscPossibleToDate(ReferenceDate: Date; UseLCY: Boolean): Decimal
    begin
        if ReferenceDate > GetPmtDiscountDate() then
            exit(0);
        exit(UseLCY ? Round("Remaining Pmt. Disc. Possible" / "Adjusted Currency Factor") : "Remaining Pmt. Disc. Possible");
    end;

    internal procedure GetPmtDiscountDate(): Date
    begin
        if "Remaining Pmt. Disc. Possible" = 0 then
            exit(0D);
        if "Pmt. Disc. Tolerance Date" >= "Pmt. Discount Date" then
            exit("Pmt. Disc. Tolerance Date");
        exit("Pmt. Discount Date");
    end;
}
