// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9013 "User Login Time Tracker Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "User Login" = rim,
                  tabledata "User Environment Login" = ri;

    [InherentPermissions(PermissionObjectType::TableData, Database::"User Login", 'r')]
    procedure IsFirstLogin(UserSecurityID: Guid): Boolean
    var
        UserLogin: Record "User Login";
    begin
        // if the user exists in the User Login table, they have logged in to the current company in the past.
        UserLogin.SetRange("User SID", UserSecurityID);

        exit(UserLogin.IsEmpty());
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::"User Login", 'r')]
    procedure AnyUserLoggedInSinceDate(FromDate: Date): Boolean
    var
        UserLogin: Record "User Login";
        FromEventDateTime: DateTime;
    begin
        FromEventDateTime := CreateDateTime(FromDate, 0T);

        UserLogin.SetFilter("Last Login Date", '>=%1', FromEventDateTime);

        exit(not UserLogin.IsEmpty());
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::"User Login", 'r')]
    procedure UserLoggedInSinceDateTime(FromDateTime: DateTime): Boolean
    var
        UserLogin: Record "User Login";
    begin
        if not UserLogin.Get(UserSecurityId()) then
            exit(false);

        exit(UserLogin."Last Login Date" >= FromDateTime);
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::"User Environment Login", 'r')]
    procedure UserLoggedInEnvironment(UserSecurityID: Guid): Boolean
    var
        UserEnvironmentLogin: Record "User Environment Login";
    begin
        // if the user exists in the User Login Times table, they have logged in in the past
        UserEnvironmentLogin.SetRange("User SID", UserSecurityID);

        exit(not UserEnvironmentLogin.IsEmpty());
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::"User Login", 'r')]
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

        SelectLatestVersion();
        if UserLogin.Get(UserSecurityId()) and (UserLogin."Last Login Date" <> 0DT) then // 0DT is a null datetime and cannot be added with 60.000 below
            if (Now < UserLogin."Last Login Date" + 60000) and (DT2Date(Now) = DT2Date(UserLogin."Last Login Date")) then // every 1 min on same day must be enough
                exit;

        // Create or update the company login information
        UserLogin.LockTable(); // to ensure that the latest version is picked up and the other users logging in wait here
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
            if UserLogin.Insert(true) then;

            // Create login information for the environment
            if not UserEnvironmentLogin.Get(UserSecurityId()) then begin
                UserEnvironmentLogin."User SID" := UserSecurityId();
                if UserEnvironmentLogin.Insert(true) then; // "if" to cater for race conditions
            end;
        end;
        Commit();

#if not CLEAN21
#pragma warning disable AL0432
        UserLoginTimeTracker.OnAfterCreateorUpdateLoginInfo(UserSecurityId());
#pragma warning restore AL0432
#endif
    end;
}
