// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.WithholdingTax;

using Microsoft.WithholdingTax;

codeunit 6790 "WHT Purch. Tax Inv.-Printed"
{
    Permissions = TableData "WHT Purch. Tax Inv. Header" = rimd;
    TableNo = "WHT Purch. Tax Inv. Header";

    trigger OnRun()
    begin
        Rec.Find();
        Rec."No. Printed" := Rec."No. Printed" + 1;
        Rec.Modify();
        Commit();
    end;
}