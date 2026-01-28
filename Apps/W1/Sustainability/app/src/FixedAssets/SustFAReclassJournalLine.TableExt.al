// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.FixedAssets;

using Microsoft.FixedAssets.Journal;
using Microsoft.Sustainability.Account;

tableextension 6265 "Sust. FA Reclass. Journal Line" extends "FA Reclass. Journal Line"
{
    fields
    {
        field(6210; "Sust. Account No."; Code[20])
        {
            Caption = 'Sustainability Account No.';
            TableRelation = "Sustainability Account" where("Account Type" = const(Posting), Blocked = const(false));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Sust. Account No." <> '' then
                    ValidateEmissionPrerequisite(Rec, Rec.FieldNo("Sust. Account No."));
            end;
        }
        field(6211; "New Sust. Account No."; Code[20])
        {
            Caption = 'New Sustainability Account No.';
            TableRelation = "Sustainability Account" where("Account Type" = const(Posting), Blocked = const(false));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."New Sust. Account No." <> '' then
                    ValidateEmissionPrerequisite(Rec, Rec.FieldNo("New Sust. Account No."));
            end;
        }
    }

    local procedure ValidateEmissionPrerequisite(FAReclassJournalLine: Record "FA Reclass. Journal Line"; CurrentFieldNo: Integer)
    begin
        case CurrentFieldNo of
            FAReclassJournalLine.FieldNo("Sust. Account No."):
                begin
                    FAReclassJournalLine.TestField("FA No.");

                    CheckSustainabilityAccount(FAReclassJournalLine."Sust. Account No.");
                end;
            FAReclassJournalLine.FieldNo("New Sust. Account No."):
                begin
                    FAReclassJournalLine.TestField("New FA No.");

                    CheckSustainabilityAccount(FAReclassJournalLine."New Sust. Account No.");
                end;
        end;
    end;

    internal procedure CheckSustainabilityAccount(AccountNo: Code[20])
    var
        SustainabilityAccount: Record "Sustainability Account";
        SustAccountCategory: Record "Sustain. Account Category";
    begin
        SustainabilityAccount.Get(AccountNo);
        SustainabilityAccount.CheckAccountReadyForPosting();
        SustainabilityAccount.TestField("Direct Posting", true);

        if SustAccountCategory.Get(SustainabilityAccount.Category) then
            if SustAccountCategory."Water Intensity" or SustAccountCategory."Waste Intensity" or SustAccountCategory."Discharged Into Water" then
                Error(NotAllowedToUseSustAccountForWaterOrWasteErr, AccountNo);
    end;

    var
        NotAllowedToUseSustAccountForWaterOrWasteErr: Label 'It is not allowed to use Sustainability Account %1 for water or waste in Sales document.', Comment = '%1 = Sust. Account No.';
}