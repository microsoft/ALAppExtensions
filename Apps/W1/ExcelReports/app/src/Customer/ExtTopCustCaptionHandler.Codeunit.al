// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Sales.ExcelReports;

codeunit 4405 "EXT Top Cust. Caption Handler"
{
    EventSubscriberInstance = Manual;
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"EXR Top Customer Report Buffer", 'OnGetAmount1Caption', '', false, false)]
    local procedure GetAmount1Caption(var NewCaption: Text; var Handled: Boolean)
    begin
        if (EXTTopReportBuffer."Ranking Based On" = EXTTopReportBuffer."Ranking Based On"::"Balance (LCY)") then begin
            NewCaption := BalanceLCYTok;
            Handled := true;
            exit;
        end;

        NewCaption := SalesLCYTok;
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"EXR Top Customer Report Buffer", 'OnGetAmount2Caption', '', false, false)]
    local procedure GetAmount2Caption(var NewCaption: Text; var Handled: Boolean)
    begin
        if EXTTopReportBuffer."Ranking Based On" <> EXTTopReportBuffer."Ranking Based On"::"Balance (LCY)" then begin
            NewCaption := BalanceLCYTok;
            Handled := true;
            exit;
        end;

        NewCaption := SalesLCYTok;
        Handled := true;
    end;

    internal procedure SetRankingBasedOn(NewRankingBasedOn: Option)
    begin
        EXTTopReportBuffer."Ranking Based On" := NewRankingBasedOn;
    end;

    var
        EXTTopReportBuffer: Record "EXR Top Customer Report Buffer";
        BalanceLCYTok: Label 'Balance (LCY)';
        SalesLCYTok: Label 'Sales (LCY)';

}