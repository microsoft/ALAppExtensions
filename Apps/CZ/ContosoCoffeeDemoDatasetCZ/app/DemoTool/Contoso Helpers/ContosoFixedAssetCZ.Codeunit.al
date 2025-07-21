// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoTool.Helpers;

using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;

codeunit 31218 "Contoso Fixed Asset CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "FA Depreciation Book" = rim,
        tabledata "FA Posting Group" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertFAPostingGroup(GroupCode: Code[20]; AcquisitionCostAccount: Code[20]; AccumDepreciationAccount: Code[20]; WriteDownAccount: Code[20]; Custom2Account: Code[20]; AcqCostAccOnDisposal: Code[20]; AccumDeprAccOnDisposal: Code[20]; WriteDownAccOnDisposal: Code[20]; Custom2AccountOnDisposal: Code[20]; GainsAccOnDisposal: Code[20]; LossesAccOnDisposal: Code[20]; BookValAccOnDispGain: Code[20]; BookValAccOnDispLoss: Code[20];
                                   SalesAccOnDispGain: Code[20]; SalesAccOnDispLoss: Code[20]; MaintenanceExpenseAccount: Code[20]; DepreciationExpenseAcc: Code[20]; AcquisitionCostBalAcc: Code[20]; ApprecBalAccOnDisp: Code[20]; AppreciationAccOnDisposal: Code[20]; AppreciationAccount: Code[20]; AppreciationBalAccount: Code[20]; SalesBalAcc: Code[20])
    var
        FAPostingGroup: Record "FA Posting Group";
        Exists: Boolean;
    begin
        if FAPostingGroup.Get(GroupCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        FAPostingGroup.Validate(Code, GroupCode);
        FAPostingGroup.Validate("Acquisition Cost Account", AcquisitionCostAccount);
        FAPostingGroup.Validate("Accum. Depreciation Account", AccumDepreciationAccount);
        FAPostingGroup.Validate("Write-Down Account", WriteDownAccount);
        FAPostingGroup.Validate("Custom 2 Account", Custom2Account);
        FAPostingGroup.Validate("Acq. Cost Acc. on Disposal", AcqCostAccOnDisposal);
        FAPostingGroup.Validate("Accum. Depr. Acc. on Disposal", AccumDeprAccOnDisposal);
        FAPostingGroup.Validate("Write-Down Acc. on Disposal", WriteDownAccOnDisposal);
        FAPostingGroup.Validate("Custom 2 Account on Disposal", Custom2AccountOnDisposal);
        FAPostingGroup.Validate("Gains Acc. on Disposal", GainsAccOnDisposal);
        FAPostingGroup.Validate("Losses Acc. on Disposal", LossesAccOnDisposal);
        FAPostingGroup.Validate("Book Val. Acc. on Disp. (Gain)", BookValAccOnDispGain);
        FAPostingGroup.Validate("Book Val. Acc. on Disp. (Loss)", BookValAccOnDispLoss);
        FAPostingGroup.Validate("Sales Acc. on Disp. (Gain)", SalesAccOnDispGain);
        FAPostingGroup.Validate("Sales Acc. on Disp. (Loss)", SalesAccOnDispLoss);
        FAPostingGroup.Validate("Maintenance Expense Account", MaintenanceExpenseAccount);
        FAPostingGroup.Validate("Depreciation Expense Acc.", DepreciationExpenseAcc);
        FAPostingGroup.Validate("Acquisition Cost Bal. Acc.", AcquisitionCostBalAcc);
        FAPostingGroup.Validate("Apprec. Bal. Acc. on Disp.", ApprecBalAccOnDisp);
        FAPostingGroup.Validate("Appreciation Acc. on Disposal", AppreciationAccOnDisposal);
        FAPostingGroup.Validate("Appreciation Account", AppreciationAccount);
        FAPostingGroup.Validate("Appreciation Bal. Account", AppreciationBalAccount);
        FAPostingGroup.Validate("Sales Bal. Acc.", SalesBalAcc);

        if Exists then
            FAPostingGroup.Modify(true)
        else
            FAPostingGroup.Insert(true);
    end;

    procedure DeleteFADepreciationBook(FixedAssetNo: Code[20]; DepreciationBookCode: Code[20])
    var
        FADepreciationBook: Record "FA Depreciation Book";
    begin
        if FADepreciationBook.Get(FixedAssetNo, DepreciationBookCode) then
            FADepreciationBook.Delete(true);
    end;
}
