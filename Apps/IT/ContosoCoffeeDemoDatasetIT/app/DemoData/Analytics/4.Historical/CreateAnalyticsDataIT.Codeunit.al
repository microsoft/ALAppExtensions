// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Analytics;

using Microsoft.DemoData.Foundation;
using Microsoft.Foundation.NoSeries;

codeunit 12254 "Create Analytics Data IT"
{
    SingleInstance = true;
    InherentEntitlements = X;
    InherentPermissions = X;
    EventSubscriberInstance = Manual;
    Permissions = tabledata "No. Series Line" = rm;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Posted Analytics Data", OnBeforePostPurchaseOrdersForAnalytics, '', false, false)]
    local procedure OnBeforePostPurchaseOrdersForAnalytics()
    begin
        NoSeriesLine.SetCurrentKey("Series Code", "Starting Date");
        NoSeriesLine.SetFilter("Series Code", '%1|%2|%3',
            CreateNoSeriesIT.InvCrMemoVATNoforItalianVend(),
            CreateNoSeriesIT.InvCrMemoVATNoforEUVend(),
            CreateNoSeriesIT.InvCrMemoVATNoforExtraEUVendors());
        if NoSeriesLine.FindSet(true) then
            repeat
                case NoSeriesLine."Series Code" of
                    CreateNoSeriesIT.InvCrMemoVATNoforItalianVend():
                        LastUsedDates[1] := NoSeriesLine."Last Date Used";
                    CreateNoSeriesIT.InvCrMemoVATNoforEUVend():
                        LastUsedDates[2] := NoSeriesLine."Last Date Used";
                    CreateNoSeriesIT.InvCrMemoVATNoforExtraEUVendors():
                        LastUsedDates[3] := NoSeriesLine."Last Date Used";
                end;

                NoSeriesLine.Validate("Last Date Used", 0D);
                NoSeriesLine.Modify(true);
            until NoSeriesLine.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Posted Analytics Data", OnAfterPostPurchaseOrdersForAnalytics, '', false, false)]
    local procedure OnAfterPostPurchaseOrdersForAnalytics()
    begin
        NoSeriesLine.SetCurrentKey("Series Code", "Starting Date");
        NoSeriesLine.SetFilter("Series Code", '%1|%2|%3',
            CreateNoSeriesIT.InvCrMemoVATNoforItalianVend(),
            CreateNoSeriesIT.InvCrMemoVATNoforEUVend(),
            CreateNoSeriesIT.InvCrMemoVATNoforExtraEUVendors());
        if NoSeriesLine.FindSet(true) then
            repeat
                case NoSeriesLine."Series Code" of
                    CreateNoSeriesIT.InvCrMemoVATNoforItalianVend():
                        NoSeriesLine.Validate("Last Date Used", LastUsedDates[1]);
                    CreateNoSeriesIT.InvCrMemoVATNoforEUVend():
                        NoSeriesLine.Validate("Last Date Used", LastUsedDates[2]);
                    CreateNoSeriesIT.InvCrMemoVATNoforExtraEUVendors():
                        NoSeriesLine.Validate("Last Date Used", LastUsedDates[3]);
                end;
                NoSeriesLine.Modify(true);
            until NoSeriesLine.Next() = 0;
    end;

    var
        NoSeriesLine: Record "No. Series Line";
        CreateNoSeriesIT: Codeunit "Create No. Series IT";
        LastUsedDates: array[3] of Date;
}