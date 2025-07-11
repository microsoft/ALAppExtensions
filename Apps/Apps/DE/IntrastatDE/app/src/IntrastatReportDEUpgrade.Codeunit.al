// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using System.IO;
using System.Upgrade;

codeunit 11034 IntrastatReportDEUpgrade
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpdateLinesType();
    end;

    local procedure UpdateLinesType()
    var
        DataExchColumnDef: Record "Data Exch. Column Def";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetIntrastatTypeUpdateTag()) then
            exit;

        DataExchColumnDef.SetRange("Data Exch. Def Code", 'INTRA-2022-DE');
        DataExchColumnDef.SetFilter("Column No.", '8|9|10|11');
        if DataExchColumnDef.FindSet() then
            repeat
                if DataExchColumnDef."Data Type" = DataExchColumnDef."Data Type"::Decimal then begin
                    DataExchColumnDef.Validate("Data Type", DataExchColumnDef."Data Type"::Text);
                    DataExchColumnDef.Modify(true);
                end;
            until DataExchColumnDef.Next() = 0;

        UpgradeTag.SetUpgradeTag(GetIntrastatTypeUpdateTag());
    end;

    internal procedure GetIntrastatTypeUpdateTag(): Code[250]
    begin
        exit('MS-481518-IntrastatTypeUpdateDE-20230818');
    end;
}
