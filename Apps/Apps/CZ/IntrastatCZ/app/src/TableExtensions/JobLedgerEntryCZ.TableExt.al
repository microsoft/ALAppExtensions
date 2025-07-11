// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Projects.Project.Ledger;

tableextension 31305 "Job Ledger Entry CZ" extends "Job Ledger Entry"
{
    fields
    {
        field(31300; "Statistic Indication CZ"; Code[10])
        {
            Caption = 'Statistic Indication';
            TableRelation = "Statistic Indication CZ".Code;
        }
    }

    internal procedure GetIntrastatReportLineType(): Enum "Intrastat Report Line Type"
    begin
        if ("Quantity (Base)" > 0) xor "Correction CZL" then
            exit(Enum::"Intrastat Report Line Type"::Shipment);
        exit(Enum::"Intrastat Report Line Type"::Receipt);
    end;

    internal procedure GetIntrastatAmountSign(): Integer
    begin
        exit(GetIntrastatQuantitySign());
    end;

    internal procedure GetIntrastatQuantitySign(): Integer
    begin
        if "Correction CZL" then
            exit(-1);
        exit(1);
    end;
}