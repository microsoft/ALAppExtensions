// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Purchases.ExcelReports;

codeunit 4404 "EXT Top Vendor Caption Handler"
{
    EventSubscriberInstance = Manual;
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"EXR Top Vendor Report Buffer", 'OnGetAmount1Caption', '', false, false)]
    local procedure GetAmount1Caption(var NewCaption: Text; var Handled: Boolean)
    begin
        if (EXTTopReportBuffer."Ranking Based On" = EXTTopReportBuffer."Ranking Based On"::"Balance (LCY)") then begin
            NewCaption := BalanceLCYTok;
            Handled := true;
            exit;
        end;

        NewCaption := PurchasesLCYTok;
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"EXR Top Vendor Report Buffer", 'OnGetAmount2Caption', '', false, false)]
    local procedure GetAmount2Caption(var NewCaption: Text; var Handled: Boolean)
    begin
        if EXTTopReportBuffer."Ranking Based On" <> EXTTopReportBuffer."Ranking Based On"::"Balance (LCY)" then begin
            NewCaption := BalanceLCYTok;
            Handled := true;
            exit;
        end;

        NewCaption := PurchasesLCYTok;
        Handled := true;
    end;

    internal procedure SetRankingBasedOn(NewRankingBasedOn: Option)
    begin
        EXTTopReportBuffer."Ranking Based On" := NewRankingBasedOn;
    end;

    var
        EXTTopReportBuffer: Record "EXR Top Vendor Report Buffer";
        BalanceLCYTok: Label 'Balance (LCY)';
        PurchasesLCYTok: Label 'Purchases (LCY)';

}