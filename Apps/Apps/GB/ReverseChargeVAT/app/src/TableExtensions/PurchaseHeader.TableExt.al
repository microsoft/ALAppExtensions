// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Purchases.Document;

tableextension 10568 "Purchase Header" extends "Purchase Header"
{
    var
        ReverseCharge: Decimal;
        TotalReverseCharge: Decimal;

    procedure SetReverseCharge(RevCharge: Decimal)
    begin
        ReverseCharge := RevCharge;
    end;

    procedure GetReverseCharge(): Decimal
    begin
        exit(ReverseCharge);
    end;

    procedure SetTotalReverseCharge(TotalRevCharge: Decimal)
    begin
        TotalReverseCharge := TotalRevCharge;
    end;

    procedure GetTotalReverseCharge(): Decimal
    begin
        exit(TotalReverseCharge);
    end;
}