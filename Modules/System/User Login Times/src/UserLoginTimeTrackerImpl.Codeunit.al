// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9013 "User Login Time Tracker Impl."
{
    Access = Internal;
    Permissions = TableData "User Login" = rim;

    trigger OnRun()
    begin
    end;

    procedure IsFirstLogin(UserSecurityID: Guid): Boolean
    var
        UserLogin: Record "User Login";
    begin
        // if the user exists in the UserLogin table, they have logged in in the past
        UserLogin.SetRange("User SID", UserSecurityID);
        exit(UserLogin.IsEmpty());
    end;

    procedure AnyUserLoggedInSinceDate(FromDate: Date): Boolean
    var
        UserLogin: Record "User Login";
        FromEventDateTime: DateTime;
    begin
        FromEventDateTime := CreateDateTime(FromDate, 0T);

        UserLogin.SetFilter("Last Login Date", '>=%1', FromEventDateTime);

        exit(not UserLogin.IsEmpty());
    end;

    procedure UserLoggedInSinceDateTime(FromDateTime: DateTime): Boolean
    var
        UserLogin: Record "User Login";
    begin
        if not UserLogin.Get(UserSecurityId()) then
            exit(false);

        exit(UserLogin."Last Login Date" >= FromDateTime);
    end;

    procedure GetPenultimateLoginDateTime(UserSecurityId: Guid): DateTime
    var
        UserLogin: Record "User Login";
    begin
        if UserLogin.Get(UserSecurityId) then
            exit(UserLogin."Penultimate Login Date");

        exit(0DT);
    end;

    procedure CreateOrUpdateLoginInfo()
    var
        UserLogin: Record "User Login";
        UserLoginTimeTracker: Codeunit "User Login Time Tracker";
    begin
        UserLogin.LockTable(); // to ensure that the latest version is picked up and the other users logging in wait here

        if UserLogin.Get(UserSecurityId()) then begin
            UserLogin."Penultimate Login Date" := UserLogin."Last Login Date";
            UserLogin."Last Login Date" := CurrentDateTime();
            UserLogin.Modify(true);
        end else begin
            UserLogin.Init();
            UserLogin."User SID" := UserSecurityId();
            UserLogin."First Login Date" := Today();
            UserLogin."Penultimate Login Date" := 0DT;
            UserLogin."Last Login Date" := CurrentDateTime();
            UserLogin.Insert(true);
        end;

        UserLoginTimeTracker.OnAfterCreateorUpdateLoginInfo(UserSecurityId());
    end;
}

