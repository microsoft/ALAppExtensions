// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;
using Microsoft.Finance.GST.Base;

codeunit 19024 "Create IN GST Group"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoINTaxSetup: Codeunit "Contoso IN Tax Setup";
    begin
        ContosoINTaxSetup.InsertGSTGroup(GSTGroup0988(), Enum::"GST Group Type"::Goods, Enum::"GST Dependency Type"::"Bill-to Address", GSTGroup988Lbl, false);
        ContosoINTaxSetup.InsertGSTGroup(GSTGroup0989(), Enum::"GST Group Type"::Goods, Enum::"GST Dependency Type"::" ", GSTGroup989Lbl, false);
        ContosoINTaxSetup.InsertGSTGroup(GSTGroup2089(), Enum::"GST Group Type"::Service, Enum::"GST Dependency Type"::" ", GSTGroup2089Tok, false);
        ContosoINTaxSetup.InsertGSTGroup(GSTGroup2090(), Enum::"GST Group Type"::Service, Enum::"GST Dependency Type"::" ", GSTGroup2090Tok, true);
    end;

    procedure GSTGroup0988(): Code[10]
    begin
        exit(GSTGroup0988Tok);
    end;

    procedure GSTGroup0989(): Code[10]
    begin
        exit(GSTGroup0989Tok);
    end;

    procedure GSTGroup2089(): Code[10]
    begin
        exit(GSTGroup2089Tok);
    end;

    procedure GSTGroup2090(): Code[10]
    begin
        exit(GSTGroup2090Tok);
    end;

    var
        GSTGroup0988Tok: Label '0988', MaxLength = 10;
        GSTGroup0989Tok: Label '0989', MaxLength = 10;
        GSTGroup2089Tok: Label '2089', MaxLength = 10;
        GSTGroup2090Tok: Label '2090', MaxLength = 10;
        GSTGroup988Lbl: Label '988', MaxLength = 10;
        GSTGroup989Lbl: Label '989', MaxLength = 10;

}
