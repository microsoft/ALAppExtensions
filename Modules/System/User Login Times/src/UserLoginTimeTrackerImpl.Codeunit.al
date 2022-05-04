// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9013 "User Login Time Tracker Impl."
{
    Access = Internal;
    Permissions = tabledata "User Login" = rim,
                  tabledata "User Environment Login" = ri;

    procedure IsFirstLogin(UserSecurityID: Guid): Boolean
    var
        UserLogin: Record "User Login";
    begin
        // if the user exists in the User Login table, they have logged in to the current company in the past.
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

    procedure UserLoggedInEnvironment(UserSecurityID: Guid): Boolean
    var
        UserEnvironmentLogin: Record "User Environment Login";
    begin
        // if the user exists in the User Login Times table, they have logged in in the past
        UserEnvironmentLogin.SetRange("User SID", UserSecurityID);

        exit(not UserEnvironmentLogin.IsEmpty());
    end;

    procedure GetPenultimateLoginDateTime(UserSecurityId: Guid): DateTime
    var
        UserLogin: Record "User Login";
    begin
        if UserLogin.Get(UserSecurityId) then
            exit(UserLogin."Penultimate Login Date");

        exit(0DT);
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::"User Login", 'rim')]
    [InherentPermissions(PermissionObjectType::TableData, Database::"User Environment Login", 'ri')]
    procedure CreateOrUpdateLoginInfo()
    var
        UserLogin: Record "User Login";
        UserEnvironmentLogin: Record "User Environment Login";
#if not CLEAN21
        UserLoginTimeTracker: Codeunit "User Login Time Tracker";
#endif
        Now: DateTime;
    begin
        Now := CurrentDateTime();

        UserLogin.LockTable(); // to ensure that the latest version is picked up and the other users logging in wait here

        // Create or update the company login information
        if UserLogin.Get(UserSecurityId()) then begin
            UserLogin."Penultimate Login Date" := UserLogin."Last Login Date";
            UserLogin."Last Login Date" := Now;
            UserLogin.Modify(true);
        end else begin
            UserLogin.Init();
            UserLogin."User SID" := UserSecurityId();
            UserLogin."First Login Date" := DT2Date(Now);
            UserLogin."Penultimate Login Date" := 0DT;
            UserLogin."Last Login Date" := Now;

            UserLogin.Insert(true);

            // Create login information for the environment
            UserEnvironmentLogin.LockTable();
            if not UserEnvironmentLogin.Get(UserSecurityId()) then begin
                UserEnvironmentLogin."User SID" := UserSecurityId();
                UserEnvironmentLogin.Insert(true);
            end;
        end;

#if not CLEAN21
        Commit();
        UserLoginTimeTracker.OnAfterCreateorUpdateLoginInfo(UserSecurityId());
#endif
    end;
}

