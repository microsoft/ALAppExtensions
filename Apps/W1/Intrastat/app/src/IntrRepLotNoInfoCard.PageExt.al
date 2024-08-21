// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Inventory.Tracking;

pageextension 4825 "Intr. Rep. Lot No. Info Card" extends "Lot No. Information Card"
{
    layout
    {
        addafter(Blocked)
        {
            field("Country/Region Code"; Rec."Country/Region Code")
            {
                ApplicationArea = BasicEU, BasicCH, BasicNO;
                ToolTip = 'Specifies a code of the country/region where the item was produced or processed.';
            }
        }
    }

    trigger OnOpenPage()
    begin
        IntrReportTrackingMgt.SetCountryRegionCode(TrackingSpecification);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Country/Region Code" := IntrReportTrackingMgt.GetCurrentCountryRegionCode();
    end;

    trigger OnClosePage()
    begin
        IntrReportTrackingMgt.ClearCountryRegionCode();
    end;

    var
        IntrReportTrackingMgt: Codeunit IntrastatReportItemTracking;
}