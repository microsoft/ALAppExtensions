// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.FixedAsset;

using Microsoft.DemoTool.Helpers;

codeunit 31498 "Create Tax Depr. Grp. CZF"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoFixedAssetCZF: Codeunit "Contoso Fixed Asset CZF";
        ContosoUtilities: Codeunit "Contoso Utilities";
    begin
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(OneR(), ContosoUtilities.AdjustDate(19020101D), OneRDescLbl, 0, 3, 0, 0, 20, 40, 33.3, 0, 0, 0, 0);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(OneR10(), ContosoUtilities.AdjustDate(19020101D), OneR10DescLbl, 0, 3, 0, 0, 30, 35, 33.3, 0, 0, 0, 0);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(OneR15(), ContosoUtilities.AdjustDate(19020101D), OneR15DescLbl, 0, 3, 0, 0, 35, 32.5, 33.3, 0, 0, 0, 0);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(OneR20(), ContosoUtilities.AdjustDate(19020101D), OneR20DescLbl, 0, 3, 0, 0, 40, 30, 33.3, 0, 0, 0, 0);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(OneZ(), ContosoUtilities.AdjustDate(19020101D), OneZDescLbl, 1, 3, 0, 0, 0, 0, 0, 3, 4, 3, 0);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(OneZ10(), ContosoUtilities.AdjustDate(19020101D), OneZ10DescLbl, 1, 3, 0, 0, 0, 0, 0, 3, 4, 3, 10);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(OneZ15(), ContosoUtilities.AdjustDate(19020101D), OneZ15DescLbl, 1, 3, 0, 0, 0, 0, 0, 3, 4, 3, 15);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(OneZ20(), ContosoUtilities.AdjustDate(19020101D), OneZ20DescLbl, 1, 3, 0, 0, 0, 0, 0, 3, 4, 3, 20);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(TwoR(), ContosoUtilities.AdjustDate(19020101D), TwoRDescLbl, 0, 5, 0, 0, 11, 22.25, 20, 0, 0, 0, 0);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(TwoR10(), ContosoUtilities.AdjustDate(19020101D), TwoR10DescLbl, 0, 5, 0, 0, 21, 19.75, 20, 0, 0, 0, 0);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(TwoR15(), ContosoUtilities.AdjustDate(19020101D), TwoR15DescLbl, 0, 5, 0, 0, 26, 18.5, 20, 0, 0, 0, 0);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(TwoR20(), ContosoUtilities.AdjustDate(19020101D), TwoR20DescLbl, 0, 5, 0, 0, 31, 17.25, 20, 0, 0, 0, 0);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(TwoZ(), ContosoUtilities.AdjustDate(19020101D), TwoZDescLbl, 1, 5, 0, 0, 0, 0, 0, 5, 6, 5, 0);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(TwoZ10(), ContosoUtilities.AdjustDate(19020101D), TwoZ10DescLbl, 1, 5, 0, 0, 0, 0, 0, 5, 6, 5, 10);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(TwoZ15(), ContosoUtilities.AdjustDate(19020101D), TwoZ15DescLbl, 1, 5, 0, 0, 0, 0, 0, 5, 6, 5, 15);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(TwoZ20(), ContosoUtilities.AdjustDate(19020101D), TwoZ20DescLbl, 1, 5, 0, 0, 0, 0, 0, 5, 6, 5, 20);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(ThreeR(), ContosoUtilities.AdjustDate(19020101D), ThreeRDescLbl, 0, 10, 0, 0, 5.5, 10.5, 10, 0, 0, 0, 0);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(ThreeR10(), ContosoUtilities.AdjustDate(19020101D), ThreeR10DescLbl, 0, 10, 0, 0, 15.4, 9.4, 10, 0, 0, 0, 0);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(ThreeR15(), ContosoUtilities.AdjustDate(19020101D), ThreeR15DescLbl, 0, 10, 0, 0, 19, 9, 10, 0, 0, 0, 0);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(ThreeR20(), ContosoUtilities.AdjustDate(19020101D), ThreeR20DescLbl, 0, 10, 0, 0, 24.4, 8.4, 10, 0, 0, 0, 0);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(ThreeZ(), ContosoUtilities.AdjustDate(19020101D), ThreeZDescLbl, 1, 10, 0, 0, 0, 0, 0, 10, 11, 10, 0);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(ThreeZ10(), ContosoUtilities.AdjustDate(19020101D), ThreeZ10DescLbl, 1, 10, 0, 0, 0, 0, 0, 10, 11, 10, 10);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(ThreeZ15(), ContosoUtilities.AdjustDate(19020101D), ThreeZ15DescLbl, 1, 10, 0, 0, 0, 0, 0, 10, 11, 10, 15);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(ThreeZ20(), ContosoUtilities.AdjustDate(19020101D), ThreeZ20DescLbl, 1, 10, 0, 0, 0, 0, 0, 10, 11, 10, 20);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(FourR(), ContosoUtilities.AdjustDate(19020101D), FourRDescLbl, 0, 20, 0, 0, 2.15, 5.15, 5, 0, 0, 0, 0);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(FourZ(), ContosoUtilities.AdjustDate(19020101D), FourZDescLbl, 1, 20, 0, 0, 0, 0, 0, 20, 21, 20, 0);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(FiveR(), ContosoUtilities.AdjustDate(19020101D), FiveRDescLbl, 0, 30, 0, 0, 1.4, 3.4, 3.4, 0, 0, 0, 0);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(FiveZ(), ContosoUtilities.AdjustDate(19020101D), FiveZDescLbl, 1, 30, 0, 0, 0, 0, 0, 30, 31, 30, 0);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(SixR(), ContosoUtilities.AdjustDate(19020101D), SixRDescLbl, 0, 50, 0, 0, 1.02, 2.02, 2, 0, 0, 0, 0);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(SixZ(), ContosoUtilities.AdjustDate(19020101D), SixZDescLbl, 1, 50, 0, 0, 0, 0, 0, 50, 51, 50, 0);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(N18(), ContosoUtilities.AdjustDate(19020101D), N18DescLbl, 2, 0, 18, 9, 0, 0, 0, 0, 0, 0, 0);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(N36(), ContosoUtilities.AdjustDate(19020101D), N36DescLbl, 2, 0, 36, 18, 0, 0, 0, 0, 0, 0, 0);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(N60(), ContosoUtilities.AdjustDate(19020101D), N60DescLbl, 2, 0, 60, 36, 0, 0, 0, 0, 0, 0, 0);
        ContosoFixedAssetCZF.InsertTaxDepreciationGroup(N72(), ContosoUtilities.AdjustDate(19020101D), N72DescLbl, 2, 0, 72, 36, 0, 0, 0, 0, 0, 0, 0);
    end;

    procedure OneR(): Code[20]
    begin
        exit(OneRTok);
    end;

    procedure OneR10(): Code[20]
    begin
        exit(OneR10Tok);
    end;

    procedure OneR15(): Code[20]
    begin
        exit(OneR15Tok);
    end;

    procedure OneR20(): Code[20]
    begin
        exit(OneR20Tok);
    end;

    procedure OneZ(): Code[20]
    begin
        exit(OneZTok);
    end;

    procedure OneZ10(): Code[20]
    begin
        exit(OneZ10Tok);
    end;

    procedure OneZ15(): Code[20]
    begin
        exit(OneZ15Tok);
    end;

    procedure OneZ20(): Code[20]
    begin
        exit(OneZ20Tok);
    end;

    procedure TwoR(): Code[20]
    begin
        exit(TwoRTok);
    end;

    procedure TwoR10(): Code[20]
    begin
        exit(TwoR10Tok);
    end;

    procedure TwoR15(): Code[20]
    begin
        exit(TwoR15Tok);
    end;

    procedure TwoR20(): Code[20]
    begin
        exit(TwoR20Tok);
    end;

    procedure TwoZ(): Code[20]
    begin
        exit(TwoZTok);
    end;

    procedure TwoZ10(): Code[20]
    begin
        exit(TwoZ10Tok);
    end;

    procedure TwoZ15(): Code[20]
    begin
        exit(TwoZ15Tok);
    end;

    procedure TwoZ20(): Code[20]
    begin
        exit(TwoZ20Tok);
    end;

    procedure ThreeR(): Code[20]
    begin
        exit(ThreeRTok);
    end;

    procedure ThreeR10(): Code[20]
    begin
        exit(ThreeR10Tok);
    end;

    procedure ThreeR15(): Code[20]
    begin
        exit(ThreeR15Tok);
    end;

    procedure ThreeR20(): Code[20]
    begin
        exit(ThreeR20Tok);
    end;

    procedure ThreeZ(): Code[20]
    begin
        exit(ThreeZTok);
    end;

    procedure ThreeZ10(): Code[20]
    begin
        exit(ThreeZ10Tok);
    end;

    procedure ThreeZ15(): Code[20]
    begin
        exit(ThreeZ15Tok);
    end;

    procedure ThreeZ20(): Code[20]
    begin
        exit(ThreeZ20Tok);
    end;

    procedure FourR(): Code[20]
    begin
        exit(FourRTok);
    end;

    procedure FourZ(): Code[20]
    begin
        exit(FourZTok);
    end;

    procedure FiveR(): Code[20]
    begin
        exit(FiveRTok);
    end;

    procedure FiveZ(): Code[20]
    begin
        exit(FiveZTok);
    end;

    procedure SixR(): Code[20]
    begin
        exit(SixRTok);
    end;

    procedure SixZ(): Code[20]
    begin
        exit(SixZTok);
    end;

    procedure N18(): Code[20]
    begin
        exit(N18Tok);
    end;

    procedure N36(): Code[20]
    begin
        exit(N36Tok);
    end;

    procedure N60(): Code[20]
    begin
        exit(N60Tok);
    end;

    procedure N72(): Code[20]
    begin
        exit(N72Tok);
    end;

    var
        OneRTok: Label '1_R', MaxLength = 20, Locked = true;
        OneR10Tok: Label '1_R10', MaxLength = 20, Locked = true;
        OneR15Tok: Label '1_R15', MaxLength = 20, Locked = true;
        OneR20Tok: Label '1_R20', MaxLength = 20, Locked = true;
        OneZTok: Label '1_Z', MaxLength = 20, Locked = true;
        OneZ10Tok: Label '1_Z10', MaxLength = 20, Locked = true;
        OneZ15Tok: Label '1_Z15', MaxLength = 20, Locked = true;
        OneZ20Tok: Label '1_Z20', MaxLength = 20, Locked = true;
        TwoRTok: Label '2_R', MaxLength = 20, Locked = true;
        TwoR10Tok: Label '2_R10', MaxLength = 20, Locked = true;
        TwoR15Tok: Label '2_R15', MaxLength = 20, Locked = true;
        TwoR20Tok: Label '2_R20', MaxLength = 20, Locked = true;
        TwoZTok: Label '2_Z', MaxLength = 20, Locked = true;
        TwoZ10Tok: Label '2_Z10', MaxLength = 20, Locked = true;
        TwoZ15Tok: Label '2_Z15', MaxLength = 20, Locked = true;
        TwoZ20Tok: Label '2_Z20', MaxLength = 20, Locked = true;
        ThreeRTok: Label '3_R', MaxLength = 20, Locked = true;
        ThreeR10Tok: Label '3_R10', MaxLength = 20, Locked = true;
        ThreeR15Tok: Label '3_R15', MaxLength = 20, Locked = true;
        ThreeR20Tok: Label '3_R20', MaxLength = 20, Locked = true;
        ThreeZTok: Label '3_Z', MaxLength = 20, Locked = true;
        ThreeZ10Tok: Label '3_Z10', MaxLength = 20, Locked = true;
        ThreeZ15Tok: Label '3_Z15', MaxLength = 20, Locked = true;
        ThreeZ20Tok: Label '3_Z20', MaxLength = 20, Locked = true;
        FourRTok: Label '4_R', MaxLength = 20, Locked = true;
        FourZTok: Label '4_Z', MaxLength = 20, Locked = true;
        FiveRTok: Label '5_R', MaxLength = 20, Locked = true;
        FiveZTok: Label '5_Z', MaxLength = 20, Locked = true;
        SixRTok: Label '6_R', MaxLength = 20, Locked = true;
        SixZTok: Label '6_Z', MaxLength = 20, Locked = true;
        N18Tok: Label 'N_18', MaxLength = 20, Locked = true;
        N36Tok: Label 'N_36', MaxLength = 20, Locked = true;
        N60Tok: Label 'N_60', MaxLength = 20, Locked = true;
        N72Tok: Label 'N_72', MaxLength = 20, Locked = true;
        OneRDescLbl: Label '1st Tax Depreciation Group - Straight-Line Depreciation', MaxLength = 100;
        OneR10DescLbl: Label '1st Tax Depreciation Group - Straight-Line Depreciation, 10% Increased Depreciation 1st Year', MaxLength = 100;
        OneR15DescLbl: Label '1st Tax Depreciation Group - Straight-Line Depreciation, 15% Increased Depreciation 1st Year', MaxLength = 100;
        OneR20DescLbl: Label '1st Tax Depreciation Group - Straight-Line Depreciation, 20% Increased Depreciation 1st Year', MaxLength = 100;
        OneZDescLbl: Label '1st Tax Depreciation Group - Declining-Balance Depreciation', MaxLength = 100;
        OneZ10DescLbl: Label '1st Tax Depreciation Group - Declining-Balance Depreciation, 10% Increased Depreciation 1st Year', MaxLength = 100;
        OneZ15DescLbl: Label '1st Tax Depreciation Group - Declining-Balance Depreciation, 15% Increased Depreciation 1st Year', MaxLength = 100;
        OneZ20DescLbl: Label '1st Tax Depreciation Group - Declining-Balance Depreciation, 20% Increased Depreciation 1st Year', MaxLength = 100;
        TwoRDescLbl: Label '2nd Tax Depreciation Group - Straight-Line Depreciation', MaxLength = 100;
        TwoR10DescLbl: Label '2nd Tax Depreciation Group - Straight-Line Depreciation, 10% Increased Depreciation 1st Year', MaxLength = 100;
        TwoR15DescLbl: Label '2nd Tax Depreciation Group - Straight-Line Depreciation, 15% Increased Depreciation 1st Year', MaxLength = 100;
        TwoR20DescLbl: Label '2nd Tax Depreciation Group - Straight-Line Depreciation, 20% Increased Depreciation 1st Year', MaxLength = 100;
        TwoZDescLbl: Label '2nd Tax Depreciation Group - Declining-Balance Depreciation', MaxLength = 100;
        TwoZ10DescLbl: Label '2nd Tax Depreciation Group - Declining-Balance Depreciation, 10% Increased Depreciation 1st Year', MaxLength = 100;
        TwoZ15DescLbl: Label '2nd Tax Depreciation Group - Declining-Balance Depreciation, 15% Increased Depreciation 1st Year', MaxLength = 100;
        TwoZ20DescLbl: Label '2nd Tax Depreciation Group - Declining-Balance Depreciation, 20% Increased Depreciation 1st Year', MaxLength = 100;
        ThreeRDescLbl: Label '3rd Tax Depreciation Group - Straight-Line Depreciation', MaxLength = 100;
        ThreeR10DescLbl: Label '3rd Tax Depreciation Group - Straight-Line Depreciation, 10% Increased Depreciation 1st Year', MaxLength = 100;
        ThreeR15DescLbl: Label '3rd Tax Depreciation Group - Straight-Line Depreciation, 15% Increased Depreciation 1st Year', MaxLength = 100;
        ThreeR20DescLbl: Label '3rd Tax Depreciation Group - Straight-Line Depreciation, 20% Increased Depreciation 1st Year', MaxLength = 100;
        ThreeZDescLbl: Label '3rd Tax Depreciation Group - Declining-Balance Depreciation', MaxLength = 100;
        ThreeZ10DescLbl: Label '3rd Tax Depreciation Group - Declining-Balance Depreciation, 10% Increased Depreciation 1st Year', MaxLength = 100;
        ThreeZ15DescLbl: Label '3rd Tax Depreciation Group - Declining-Balance Depreciation, 15% Increased Depreciation 1st Year', MaxLength = 100;
        ThreeZ20DescLbl: Label '3rd Tax Depreciation Group - Declining-Balance Depreciation, 20% Increased Depreciation 1st Year', MaxLength = 100;
        FourRDescLbl: Label '4th Tax Depreciation Group - Straight-Line Depreciation', MaxLength = 100;
        FourZDescLbl: Label '4th Tax Depreciation Group - Declining-Balance Depreciation', MaxLength = 100;
        FiveRDescLbl: Label '5th Tax Depreciation Group - Straight-Line Depreciation', MaxLength = 100;
        FiveZDescLbl: Label '5th Tax Depreciation Group - Declining-Balance Depreciation', MaxLength = 100;
        SixRDescLbl: Label '6th Tax Depreciation Group - Straight-Line Depreciation', MaxLength = 100;
        SixZDescLbl: Label '6th Tax Depreciation Group - Declining-Balance Depreciation', MaxLength = 100;
        N18DescLbl: Label 'Intangible Fixed Assets - Straight-Line 18 Months', MaxLength = 100;
        N36DescLbl: Label 'Intangible Fixed Assets - Straight-Line 36 Months', MaxLength = 100;
        N60DescLbl: Label 'Intangible Fixed Assets - Straight-Line 60 Months', MaxLength = 100;
        N72DescLbl: Label 'Intangible Fixed Assets - Straight-Line 72 Months', MaxLength = 100;
}