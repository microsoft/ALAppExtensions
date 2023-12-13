// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Setup;

tableextension 31247 "FA Depreciation Book CZF" extends "FA Depreciation Book"
{
    fields
    {
        field(31242; "Deprec. Interrupted up to CZF"; Date)
        {
            Caption = 'Depreciations Interrupted up to';
            DataClassification = CustomerContent;
        }
        field(31243; "Tax Deprec. Group Code CZF"; Code[20])
        {
            Caption = 'Tax Depreciation Group Code';
            TableRelation = "Tax Depreciation Group CZF".Code;
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                FixedAsset: Record "Fixed Asset";
                ClassificationCodeCZF: Record "Classification Code CZF";
                TaxDepreciationGroupCZF: Record "Tax Depreciation Group CZF";
            begin
                if "Tax Deprec. Group Code CZF" <> '' then begin
                    TaxDepreciationGroupCZF.SetRange(Code, "Tax Deprec. Group Code CZF");
                    TaxDepreciationGroupCZF.SetRange("Starting Date", 0D, WorkDate());
                    if TaxDepreciationGroupCZF.FindLast() then;
                    TaxDepreciationGroupCZF.Reset();
                end;
                FixedAsset.Get("FA No.");
                if FixedAsset."Classification Code CZF" <> '' then begin
                    ClassificationCodeCZF.Get(FixedAsset."Classification Code CZF");
                    if ClassificationCodeCZF."Depreciation Group" <> '' then
                        TaxDepreciationGroupCZF.SetRange("Depreciation Group", ClassificationCodeCZF."Depreciation Group");
                end;
                if Page.RunModal(0, TaxDepreciationGroupCZF) = Action::LookupOK then
                    Validate("Tax Deprec. Group Code CZF", TaxDepreciationGroupCZF.Code);
            end;

            trigger OnValidate()
            var
                FixedAsset: Record "Fixed Asset";
                DepreciationBook: Record "Depreciation Book";
                TaxDepreciationGroupCZF: Record "Tax Depreciation Group CZF";
                FASetup: Record "FA Setup";
                ClassificationCodeCZF: Record "Classification Code CZF";
                DeprecGroupMismatchMsg: Label 'The depreciation group (%1) associated with classification code %2 doesn''t correspond to depreciation group (%3) associated with tax depreciation group code %4.', Comment = '%1 = Classification Code Depreciation Group, %2 = Fixed Asset Clasification Code, %3 = Tax Depreciation Group Code, %4 = Tax Deprec. Group Code';
            begin
                if "Tax Deprec. Group Code CZF" <> '' then
                    TestField("Keep Deprec. Ending Date CZF", false)
                else
                    TestField("Prorated CZF", false);
                if ("Last Depreciation Date" > 0D) or
                   ("Last Write-Down Date" > 0D) or
                   ("Last Appreciation Date" > 0D) or
                   ("Last Custom 1 Date" > 0D) or
                   ("Last Custom 2 Date" > 0D) or
                   ("Disposal Date" > 0D)
                then begin
                    DepreciationBook.Get("Depreciation Book Code");
                    DepreciationBook.TestField("Allow Changes in Depr. Fields", true);
                end;

                CheckDepreciationCZF();

                if "Tax Deprec. Group Code CZF" <> '' then begin
                    TaxDepreciationGroupCZF.SetRange(Code, "Tax Deprec. Group Code CZF");
                    TaxDepreciationGroupCZF.SetRange("Starting Date", 0D, WorkDate());
                    if TaxDepreciationGroupCZF.FindLast() then begin
                        FixedAsset.Get("FA No.");
                        if FixedAsset."Classification Code CZF" <> '' then begin
                            ClassificationCodeCZF.Get(FixedAsset."Classification Code CZF");
                            if ClassificationCodeCZF."Depreciation Group" <> TaxDepreciationGroupCZF."Depreciation Group" then
                                Message(DeprecGroupMismatchMsg,
                                  ClassificationCodeCZF."Depreciation Group", FixedAsset."Classification Code CZF", TaxDepreciationGroupCZF."Depreciation Group", "Tax Deprec. Group Code CZF");
                        end;
                        if TaxDepreciationGroupCZF."Depreciation Type" = TaxDepreciationGroupCZF."Depreciation Type"::"Straight-line Intangible" then
                            Validate("No. of Depreciation Months", TaxDepreciationGroupCZF."No. of Depreciation Months");
                    end;
                end;

                if "Tax Deprec. Group Code CZF" <> xRec."Tax Deprec. Group Code CZF" then begin
                    FASetup.Get();
                    if "Depreciation Book Code" = FASetup."Tax Depreciation Book CZF" then begin
                        FixedAsset.Get("FA No.");
                        FixedAsset."Tax Deprec. Group Code CZF" := "Tax Deprec. Group Code CZF";
                        FixedAsset.Modify();
                    end;
                end;
            end;
        }
        field(31245; "Keep Deprec. Ending Date CZF"; Boolean)
        {
            Caption = 'Keep Depreciation Ending Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Tax Deprec. Group Code CZF", '');
                CheckDepreciationCZF();
            end;
        }
        field(31246; "Sum. Deprec. Entries From CZF"; Code[10])
        {
            Caption = 'Summarize Depreciation Entries From';
            TableRelation = "Depreciation Book";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                MustNotBeErr: Label 'must not be %1', Comment = '%1 = Depreciation Book Code';
            begin
                if "Sum. Deprec. Entries From CZF" = "Depreciation Book Code" then
                    FieldError("Sum. Deprec. Entries From CZF", StrSubstNo(MustNotBeErr, "Depreciation Book Code"));
            end;
        }
        field(31247; "Prorated CZF"; Boolean)
        {
            Caption = 'Prorated';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NoOfDeprMonths: Decimal;
            begin
                TestField("Tax Deprec. Group Code CZF");
                CheckDepreciationCZF();
                if "Prorated CZF" then begin
                    NoOfDeprMonths := "No. of Depreciation Months";
                    Validate("Depreciation Starting Date", CalcDate('<-CY>', "Depreciation Starting Date"));
                    Validate("No. of Depreciation Months", NoOfDeprMonths);
                end;
            end;
        }
    }

    local procedure CheckDepreciationCZF()
    var
        DepreciationsExistErr: Label 'There are depreciations for FA %1.', Comment = '%1 = Fixed Asset No.';
    begin
        CalcFields(Depreciation);
        if Depreciation <> 0 then
            Error(DepreciationsExistErr, "FA No.");
    end;

    procedure CheckDefaultFAPostingGroupCZF()
    var
        FixedAsset: Record "Fixed Asset";
        FASubclass: Record "FA Subclass";
        IsHandled: Boolean;
        FAPostingGroupMustBeSameErr: Label '%1 must be the same as the %2 in %3 ''%4''.', Comment = '%1 = field caption, %2 = field caption, %3 = table caption, %4 = fa subclass code';
    begin
        OnBeforeCheckDefaultFAPostingGroupCZF(IsHandled);
        if IsHandled then
            exit;

        if Rec."FA No." = '' then
            exit;
        if not FixedAsset.Get(Rec."FA No.") or not (FixedAsset."FA Subclass Code" <> '') then
            exit;
        if not FASubclass.Get(FixedAsset."FA Subclass Code") or not (FASubclass."Default FA Posting Group" <> '') then
            exit;
        if Rec."FA Posting Group" <> FASubclass."Default FA Posting Group" then
            Error(FAPostingGroupMustBeSameErr,
                Rec.FieldCaption("FA Posting Group"), FASubclass.FieldCaption("Default FA Posting Group"),
                FASubclass.TableCaption(), FASubclass.Code);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCheckDefaultFAPostingGroupCZF(var IsHandled: Boolean)
    begin
    end;
}
