// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.FixedAsset;

using Microsoft.DemoData.Finance;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.Journal;

codeunit 13742 "Create FA Depreciation Book DK"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Depreciation Book", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertDepreciationBook(var Rec: Record "Depreciation Book")
    var
        CreateFADeprBook: Codeunit "Create FA Depreciation Book";
    begin
        case Rec.Code of
            CreateFADeprBook.Company():
                ValidateDepreciationBook(Rec, 10);
        end;
    end;

    local procedure ValidateDepreciationBook(var DepreciationBook: Record "Depreciation Book"; DefaultFinalRoundingAmount: Decimal)
    begin
        DepreciationBook.Validate("Default Final Rounding Amount", DefaultFinalRoundingAmount);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", OnBeforeInsertEvent, '', false, false)]
    local procedure OnBeforeInsertGenJournalLineDK(var Rec: Record "Gen. Journal Line")
    var
        CreateFAJnlTemplate: Codeunit "Create FA Jnl. Template";
        CreateGLAccDK: Codeunit "Create GL Acc. DK";
    begin
        if (Rec."Journal Template Name" = CreateFAJnlTemplate.Assets())
            and (Rec."Journal Batch Name" = CreateFAJnlTemplate.Default())
            and (Rec."Account Type" = Enum::"Gen. Journal Account Type"::"Fixed Asset")
            and (Rec."Bal. Account Type" = Enum::"Gen. Journal Account Type"::"G/L Account")
            and (Rec."FA Posting Type" = Enum::"Gen. Journal Line FA Posting Type"::"Acquisition Cost")
        then
            Rec.Validate("Bal. Account No.", CreateGLAccDK.Bank());
    end;
}
