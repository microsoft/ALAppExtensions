// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.Depreciation;

pageextension 31145 "Depreciation Book Card CZF" extends "Depreciation Book Card"
{
    layout
    {
        addlast(General)
        {
            field("Deprec. from 1st Month Day CZF"; Rec."Deprec. from 1st Month Day CZF")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies if the asset will be depreciated already in month of acquisiton.';
            }
            field("Deprec. from 1st Year Day CZF"; Rec."Deprec. from 1st Year Day CZF")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies if the asset in acquisition year will be depreciated for the whole year or only for part of the year.';
            }
            field("Check Deprec. on Disposal CZF"; Rec."Check Deprec. on Disposal CZF")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies if all depreciation are to be posted before disposal.';
            }
            field("Check Acq. Appr. bef. Dep. CZF"; Rec."Check Acq. Appr. bef. Dep. CZF")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies if the new aqcuisition or appreciation entry is not posting before already posted depreciation in time.';
            }
            field("All Acquisit. in same Year CZF"; Rec."All Acquisit. in same Year CZF")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies if all acquisition has to be posted in the same year.';
            }
            field("Corresp. G/L Entries Disp. CZF"; Rec."Corresp. G/L Entries Disp. CZF")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies if disposal the same type of FA entries will be used.';
            }
            field("Corresp. FA Entries Disp. CZF"; Rec."Corresp. FA Entries Disp. CZF")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies if disposal the same type of FA entries will be used.';
            }
            field("Mark Errors as Corrections CZF"; Rec."Mark Errors as Corrections")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies if the correction will be posted on the same side of account (credit, debit).';
            }
        }
    }
}
