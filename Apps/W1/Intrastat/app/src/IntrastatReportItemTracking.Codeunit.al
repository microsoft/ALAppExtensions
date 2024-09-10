// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 4811 IntrastatReportItemTracking
{
    SingleInstance = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeCheckItemTrackingInformation', '', true, true)]
    local procedure OnBeforeCheckItemTrackingInformation(var ItemJnlLine2: Record "Item Journal Line"; var TrackingSpecification: Record "Tracking Specification"; var ItemTrackingSetup: Record "Item Tracking Setup"; var SignFactor: Decimal; var ItemTrackingCode: Record "Item Tracking Code"; var IsHandled: Boolean; var GlobalItemTrackingCode: Record "Item Tracking Code")
    var
        SerialNoInfo: Record "Serial No. Information";
        LotNoInfo: Record "Lot No. Information";
    begin
        if ItemJnlLine2."Entry Type" = ItemJnlLine2."Entry Type"::Purchase then
            if IntrastatReportSetup.Get() and (IntrastatReportSetup."Def. Country Code for Item Tr." = IntrastatReportSetup."Def. Country Code for Item Tr."::"Purchase Header") then begin
                SerialNoInfo.SetRange("Item No.", TrackingSpecification."Item No.");
                SerialNoInfo.SetRange("Variant Code", TrackingSpecification."Variant Code");
                SerialNoInfo.SetRange("Serial No.", TrackingSpecification."Serial No.");
                SerialNoInfoExistsBefore := not SerialNoInfo.IsEmpty();

                LotNoInfo.SetRange("Item No.", TrackingSpecification."Item No.");
                LotNoInfo.SetRange("Variant Code", TrackingSpecification."Variant Code");
                LotNoInfo.SetRange("Lot No.", TrackingSpecification."Lot No.");
                LotNoInfoExistsBefore := not LotNoInfo.IsEmpty();
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterCheckItemTrackingInformation', '', true, true)]
    local procedure OnAfterCheckItemTrackingInformation(var ItemJnlLine2: Record "Item Journal Line"; var TrackingSpecification: Record "Tracking Specification"; ItemTrackingSetup: Record "Item Tracking Setup"; Item: Record Item)
    var
        ItemTrackingCode: Record "Item Tracking Code";
        SerialNoInfo: Record "Serial No. Information";
        LotNoInfo: Record "Lot No. Information";
    begin
        if ItemJnlLine2."Entry Type" = ItemJnlLine2."Entry Type"::Purchase then
            if IntrastatReportSetup.Get() and (IntrastatReportSetup."Def. Country Code for Item Tr." = IntrastatReportSetup."Def. Country Code for Item Tr."::"Purchase Header") then
                if ItemTrackingCode.Get(Item."Item Tracking Code") then begin
                    if ItemTrackingCode."Create SN Info on Posting" and (not SerialNoInfoExistsBefore) then
                        if SerialNoInfo.Get(TrackingSpecification."Item No.", TrackingSpecification."Variant Code", TrackingSpecification."Serial No.") then
                            if SerialNoInfo."Country/Region Code" = '' then begin
                                SerialNoInfo."Country/Region Code" := ItemJnlLine2."Country/Region Code";
                                SerialNoInfo.Modify();
                            end;

                    if ItemTrackingCode."Create Lot No. Info on posting" and (not LotNoInfoExistsBefore) then
                        if LotNoInfo.Get(TrackingSpecification."Item No.", TrackingSpecification."Variant Code", TrackingSpecification."Lot No.") then
                            if LotNoInfo."Country/Region Code" = '' then begin
                                LotNoInfo."Country/Region Code" := ItemJnlLine2."Country/Region Code";
                                LotNoInfo.Modify();
                            end;
                end;
    end;

    procedure SetCountryRegionCode(TrackingSpecification: Record "Tracking Specification")
    var
        CountryCode2: Code[10];
    begin
        CountryCode2 := GetCountryRegionCode(TrackingSpecification);
        if CountryCode2 <> '' then
            CountryCode := CountryCode2;
    end;

    procedure GetCurrentCountryRegionCode() CountryCode2: Code[10]
    begin
        CountryCode2 := CountryCode;
    end;

    procedure ClearCountryRegionCode()
    begin
        CountryCode := '';
    end;

    local procedure GetCountryRegionCode(TrackingSpecification: Record "Tracking Specification") CountryCode2: Code[10]
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if TrackingSpecification."Source Type" = Database::"Purchase Line" then
            if IntrastatReportSetup.Get() and (IntrastatReportSetup."Def. Country Code for Item Tr." = IntrastatReportSetup."Def. Country Code for Item Tr."::"Purchase Header") then begin
                PurchaseHeader.SetLoadFields("Buy-from Country/Region Code");
                if PurchaseHeader.Get(TrackingSpecification."Source Subtype", TrackingSpecification."Source ID") then
                    CountryCode2 := PurchaseHeader."Buy-from Country/Region Code";
            end;
    end;

    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        CountryCode: Code[10];
        SerialNoInfoExistsBefore, LotNoInfoExistsBefore : Boolean;
}