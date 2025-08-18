// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.DemoTool.Helpers;
using Microsoft.Foundation.NoSeries;

codeunit 4845 "Create Intrastat No. Series"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoNoSeries: Codeunit "Contoso No Series";
    begin
        ContosoNoSeries.InsertNoSeries(Intrastat(), IntrastatLbl, 'INTRA00001', 'INTRA99999', '', '', 1, enum::"No. Series Implementation"::Sequence, true);
    end;

    procedure Intrastat(): Code[20]
    begin
        exit(IntrastatTok);
    end;

    var
        IntrastatTok: Label 'INTRA', MaxLength = 20;
        IntrastatLbl: Label 'Intrastat', MaxLength = 100;
}