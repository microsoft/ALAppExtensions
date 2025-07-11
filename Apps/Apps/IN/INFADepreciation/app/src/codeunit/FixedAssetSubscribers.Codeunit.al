// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.FADepreciation;

using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Depreciation;

codeunit 18637 "Fixed Asset Subscribers"
{
    Permissions = tabledata "Fixed Asset" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Depreciation Book", 'OnAfterValidateEvent', 'Fiscal Year 365 Days', false, false)]
    local procedure OnAfterValidateFiscalYr365DysDeprBk(var Rec: Record "Depreciation Book")
    begin
        if Rec."Fiscal Year 365 Days" then
            Rec.TestField(Rec."FA Book Type", 0);
    end;

    [EventSubscriber(ObjectType::Table, database::"FA Depreciation Book", 'OnAfterValidateEvent', 'Depreciation Book Code', false, false)]
    local procedure OnAfterValidateDeprBookCode(var Rec: Record "FA Depreciation Book")
    var
        DeprBookCode: Record "Depreciation Book";
        FixedAsset: Record "Fixed Asset";
    begin
        if Rec."Depreciation Book Code" <> DeprBookCode.Code then
            DeprBookCode.Get(Rec."Depreciation Book Code");

        if FixedAsset.Get(Rec."FA No.") then
            if (Rec."FA Block Code" = '') or (Rec."FA Block Code" <> FixedAsset."FA Block Code") then
                Rec."FA Block Code" := FixedAsset."FA Block Code";
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Depreciation Book", 'OnAfterValidateEvent', 'Depreciation Method', false, false)]
    local procedure OnAfterValidateDeprMethod(var Rec: Record "FA Depreciation Book")
    begin
        Rec.UpdateDeprPercent();
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Depreciation Book", 'OnBeforeValidateEvent', 'Straight-Line %', false, false)]
    local procedure OnBeforeValidateStraightLinePercentage(var Rec: Record "FA Depreciation Book")
    begin
        Rec.TestField("FA Book Type", Rec."FA Book Type"::" ");
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Depreciation Book", 'OnBeforeValidateEvent', 'Declining-Balance %', false, false)]
    local procedure OnBeforeValidateDecliningBalancePercentage(var Rec: Record "FA Depreciation Book")
    begin
        Rec.TestField("FA Book Type", Rec."FA Book Type"::" ");
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Depreciation Book", 'OnBeforeValidateEvent', 'Depreciation ending Date', false, false)]
    local procedure OnBeforeValidateDeprEndingDate(var Rec: Record "FA Depreciation Book")
    begin
        Rec.TestField("FA Book Type", Rec."FA Book Type"::" ");
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Depreciation Book", 'OnBeforeCalculateDepreEndingDate', '', false, false)]
    local procedure OnBeforeCalculateDepreEndingDate(
        var FADeprBook: Record "FA Depreciation Book";
        DeprEndDate: Date;
        var IsHandled: Boolean)
    begin
        UpdateFADepreciationBook(FADeprBook, IsHandled);
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Depreciation Book", 'OnBeforeValidateNoOfDepreYears', '', false, false)]
    local procedure OnBeforeValidateNoOfDepreYears(FANo: Code[20]; DeprecBook: Record "Depreciation Book"; var IsHandled: Boolean)
    begin
        if DeprecBook."Fiscal Year 365 Days" then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Depreciation Book", 'OnBeforeValidateNoOfDeprMonths', '', false, false)]
    local procedure OnBeforeValidateNoOfDeprMonths(FANo: Code[20]; DeprecBook: Record "Depreciation Book"; var IsHandled: Boolean)
    begin
        if DeprecBook."Fiscal Year 365 Days" then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Depreciation Book", 'OnBeforeModifyFaDeprBook', '', false, false)]
    local procedure OnBeforeModifyFADepreciationBook(FADepreBook: Record "FA Depreciation Book"; var IsHandled: Boolean)
    var
        DeprBook: Record "Depreciation Book";
    begin
        DeprBook.Get(FADepreBook."Depreciation Book Code");
        if DeprBook."Fiscal Year 365 Days" then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Depreciation Book", 'OnAfterValidateEvent', 'Fiscal Year 365 Days', false, false)]
    local procedure OnAfterValidateEventFiscalYear365Days(var Rec: Record "Depreciation Book")
    var
        FADepreBookExt: Record "FA Depreciation Book";
    begin
        FADepreBookExt.SetCurrentKey("Depreciation Book Code", "FA No.");
        FADepreBookExt.SetRange("Depreciation Book Code", Rec.Code);
        if FADepreBookExt.FindSet(true) then
            repeat
                CalcDepreciationPeriod(FADepreBookExt);
                FADepreBookExt.Modify();
            until FADepreBookExt.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Depreciation Book", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertEventFADeprBook(var Rec: Record "FA Depreciation Book"; RunTrigger: Boolean)
    var
        FixedAsset: Record "Fixed Asset";
        DepreBook: Record "Depreciation Book";
    begin
        if RunTrigger then begin
            Rec.TestField("FA No.");
            FixedAsset.Get(Rec."FA No.");
            if (Rec."FA Block Code" = '') or (Rec."FA Block Code" <> FixedAsset."FA Block Code") then
                Rec."FA Block Code" := FixedAsset."FA Block Code";

            if Rec."Depreciation Book Code" <> '' then begin
                DepreBook.Get(Rec."Depreciation Book Code");
                Rec."FA Book Type" := DepreBook."FA Book Type";
            end;

            Rec.UpdateDeprPercent();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Depreciation Book", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyEventFADeprBook(var Rec: Record "FA Depreciation Book"; RunTrigger: Boolean)
    var
        FixedAsset: Record "Fixed Asset";
        DepreBook: Record "Depreciation Book";
    begin
        if RunTrigger then begin
            Rec.TestField("FA No.");
            FixedAsset.Get(Rec."FA No.");
            if (Rec."FA Block Code" = '') or (Rec."FA Block Code" <> FixedAsset."FA Block Code") then
                Rec."FA Block Code" := FixedAsset."FA Block Code";

            DepreBook.Get(Rec."Depreciation Book Code");
            Rec."FA Book Type" := DepreBook."FA Book Type";
        end;

        Rec.UpdateDeprPercent();
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Depreciation Book", 'OnBeforeInsertFADeprBook', '', false, false)]
    local procedure OnBeforeInsertFADeprBook(FADepreciationBook: Record "FA Depreciation Book"; var IsHandled: Boolean)
    begin
        if (FADepreciationBook."No. of Depreciation Years" <> 0) or (FADepreciationBook."No. of Depreciation Months" <> 0) then
            IsHandled := true;
    end;

    local procedure CalcDepreciationPeriod(var FixedAssetDeprBook: Record "FA Depreciation Book")
    var
        DepreciationBook: Record "Depreciation Book";
        DepreciationCalculation: Codeunit "Depreciation Calculation";
        Text002Err: Label '%1 is later than %2.', Comment = '%1 date Field caption, %2= date field caption';
    begin
        if FixedAssetDeprBook."Depreciation Starting Date" = 0D then begin
            FixedAssetDeprBook."Depreciation Ending Date" := 0D;
            FixedAssetDeprBook."No. of Depreciation Years" := 0;
            FixedAssetDeprBook."No. of Depreciation Months" := 0;
        end;

        if (FixedAssetDeprBook."Depreciation Starting Date" = 0D) or (FixedAssetDeprBook."Depreciation Ending Date" = 0D) then begin
            FixedAssetDeprBook."No. of Depreciation Years" := 0;
            FixedAssetDeprBook."No. of Depreciation Months" := 0;
        end else begin
            if FixedAssetDeprBook."Depreciation Starting Date" > FixedAssetDeprBook."Depreciation Ending Date" then
                Error(
                  Text002Err,
                  FixedAssetDeprBook.FieldCaption("Depreciation Starting Date"), FixedAssetDeprBook.FieldCaption("Depreciation Ending Date"));

            DepreciationBook.Get(FixedAssetDeprBook."Depreciation Book Code");
            FixedAssetDeprBook."No. of Depreciation Months" :=
              DepreciationCalculation.DeprDays(FixedAssetDeprBook."Depreciation Starting Date", FixedAssetDeprBook."Depreciation Ending Date", false) / 30;
            FixedAssetDeprBook."No. of Depreciation Months" := Round(FixedAssetDeprBook."No. of Depreciation Months", 0.00000001);
            FixedAssetDeprBook."No. of Depreciation Years" := Round(FixedAssetDeprBook."No. of Depreciation Months" / 12, 0.00000001);
            FixedAssetDeprBook."Straight-Line %" := 0;
            FixedAssetDeprBook."Fixed Depr. Amount" := 0;
        end;
        FixedAssetDeprBook.Modify();
    end;

    local procedure UpdateFADepreciationBook(
        var FADeprBook: Record "FA Depreciation Book";
        var IsHandled: Boolean)
    var
        DeprBook: Record "Depreciation Book";
        DepreciationCalculation: Codeunit "Depreciation Calculation";
        Text002Err: Label '%1 is later than %2.', Comment = '%1 date Field caption, %2= date field caption';
    begin
        DeprBook.Get(FADeprBook."Depreciation Book Code");
        if (DeprBook."Fiscal Year 365 Days") then begin
            if FADeprBook."Depreciation Starting Date" = 0D then begin
                FADeprBook."Depreciation Ending Date" := 0D;
                FADeprBook."No. of Depreciation Years" := 0;
                FADeprBook."No. of Depreciation Months" := 0;
            end;

            if (FADeprBook."Depreciation Starting Date" = 0D) or (FADeprBook."Depreciation Ending Date" = 0D) then begin
                FADeprBook."No. of Depreciation Years" := 0;
                FADeprBook."No. of Depreciation Months" := 0;
            end else begin
                if FADeprBook."Depreciation Starting Date" > FADeprBook."Depreciation Ending Date" then
                    Error(
                      Text002Err,
                      FADeprBook.FieldCaption("Depreciation Starting Date"), FADeprBook.FieldCaption("Depreciation Ending Date"));

                FADeprBook."No. of Depreciation Months" :=
                  DepreciationCalculation.DeprDays(FADeprBook."Depreciation Starting Date", FADeprBook."Depreciation Ending Date", false) / 30;
                FADeprBook."No. of Depreciation Months" := Round(FADeprBook."No. of Depreciation Months", 0.00000001);
                FADeprBook."No. of Depreciation Years" := Round(FADeprBook."No. of Depreciation Months" / 12, 0.00000001);
                FADeprBook."Straight-Line %" := 0;
                FADeprBook."Fixed Depr. Amount" := 0;
            end;
            IsHandled := true;
        end;
    end;
}
