// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Sales.Document;

tableextension 10567 "Sales Header" extends "Sales Header"
{
    var
        ReverseChargeApplies: Boolean;

    procedure SetReverseChargeApplies(ReverseChargeApplies2: Boolean)
    begin
        ReverseChargeApplies := ReverseChargeApplies2;
    end;

    procedure GetReverseChargeApplies(): Boolean
    begin
        exit(ReverseChargeApplies);
    end;
}