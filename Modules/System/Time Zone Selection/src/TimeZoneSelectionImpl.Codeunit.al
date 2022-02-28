// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9199 "Time Zone Selection Impl."
{
    Access = Internal;
    Permissions = tabledata "Page Data Personalization" = r,
                  tabledata "Time Zone" = r;

    procedure LookupTimeZone(var TimeZoneText: Text[180]): Boolean
    var
        TimeZone: Record "Time Zone";
    begin
        TimeZone."No." := FindTimeZoneNo(TimeZoneText);
        if Page.RunModal(Page::"Time Zones Lookup", TimeZone) = Action::LookupOK then begin
            TimeZoneText := TimeZone.ID;
            exit(true);
        end;
    end;

    procedure ValidateTimeZone(var TimeZoneText: Text[180])
    var
        TimeZone: Record "Time Zone";
    begin
        TimeZone.Get(FindTimeZoneNo(TimeZoneText));
        TimeZoneText := TimeZone.ID;
    end;

    procedure GetTimeZoneDisplayName(TimeZoneText: Text[180]): Text[250]
    var
        TimeZone: Record "Time Zone";
    begin
        if TimeZone.Get(FindTimeZoneNo(TimeZoneText)) then
            exit(TimeZone."Display Name");
    end;

    local procedure FindTimeZoneNo(TimeZoneText: Text[180]): Integer
    var
        TimeZone: Record "Time Zone";
    begin
        TimeZone.SetRange(ID, TimeZoneText);
        if not TimeZone.FindFirst() then begin
            TimeZone.SetFilter(ID, '''@*' + TimeZoneText + '*''');
#pragma warning disable AA0181
            TimeZone.Find('=<>');
#pragma warning restore
        end;
        exit(TimeZone."No.");
    end;
}