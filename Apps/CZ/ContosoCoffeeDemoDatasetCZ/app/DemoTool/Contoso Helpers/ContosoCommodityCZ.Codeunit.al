// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoTool.Helpers;

using Microsoft.Finance.VAT.Reporting;

codeunit 31223 "Contoso Commodity CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Commodity CZL" = rim,
        tabledata "Commodity Setup CZL" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertCommodity(Code: Code[10]; Description: Text[50])
    var
        CommodityCZL: Record "Commodity CZL";
        Exists: Boolean;
    begin
        if CommodityCZL.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        CommodityCZL.Validate(Code, Code);
        CommodityCZL.Validate(Description, Description);

        if Exists then
            CommodityCZL.Modify(true)
        else
            CommodityCZL.Insert(true);
    end;

    procedure InsertCommoditySetup(CommodityCode: Code[10]; ValidFrom: Date; CommodityLimitAmount: Decimal)
    var
        CommoditySetupCZL: Record "Commodity Setup CZL";
        Exists: Boolean;
    begin
        if CommoditySetupCZL.Get(CommodityCode, ValidFrom) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        CommoditySetupCZL.Validate("Commodity Code", CommodityCode);
        CommoditySetupCZL.Validate("Valid From", ValidFrom);
        CommoditySetupCZL.Validate("Commodity Limit Amount LCY", CommodityLimitAmount);

        if Exists then
            CommoditySetupCZL.Modify(true)
        else
            CommoditySetupCZL.Insert(true);
    end;
}
