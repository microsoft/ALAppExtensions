// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
pageextension 4831 "Intr. Report Item Tr. Lines" extends "Item Tracking Lines"
{
    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        SerialNoInfo: Record "Serial No. Information";
        LotNoInfo: Record "Lot No. Information";
        PackageNoInfo: Record "Package No. Information";
        SerailNoCountryCode, LotNoCountryCode, PackageNoCountryCode : Code[10];
    begin
        if Rec.FindSet() then
            repeat
                SerailNoCountryCode := '';
                LotNoCountryCode := '';
                PackageNoCountryCode := '';

                if Rec."Serial No." <> '' then
                    if SerialNoInfo.Get(Rec."Item No.", Rec."Variant Code", Rec."Serial No.") then
                        SerailNoCountryCode := SerialNoInfo."Country/Region Code";

                if Rec."Lot No." <> '' then
                    if LotNoInfo.Get(Rec."Item No.", Rec."Variant Code", Rec."Lot No.") then
                        LotNoCountryCode := LotNoInfo."Country/Region Code";

                if Rec."Package No." <> '' then
                    if PackageNoInfo.Get(Rec."Item No.", Rec."Variant Code", Rec."Package No.") then
                        PackageNoCountryCode := PackageNoInfo."Country/Region Code";

                if ((SerailNoCountryCode <> '') and (LotNoCountryCode <> '') and (SerailNoCountryCode <> LotNoCountryCode)) or
                     ((SerailNoCountryCode <> '') and (PackageNoCountryCode <> '') and (SerailNoCountryCode <> PackageNoCountryCode)) or
                     ((LotNoCountryCode <> '') and (PackageNoCountryCode <> '') and (LotNoCountryCode <> PackageNoCountryCode))
                then
                    Error(CountryDoNotMatchErr, Rec."Entry No.");
            until Rec.Next() = 0;
    end;

    var
        CountryDoNotMatchErr: Label 'The Country/Region codes for the serial number, lot number, and package number do not match for Entry No. %1.', Comment = '%1 - Entry No.';
}