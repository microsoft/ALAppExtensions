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
        UserEnvironmentLogin.ReadIsolation := UserEnvironmentLogin.ReadIsolation::ReadCommitted;
        if not UserEnvironmentLogin.IsEmpty() then
            exit(true); // Avoid locking the table if the user has logged in before

        UserEnvironmentLogin.ReadIsolation := UserEnvironmentLogin.ReadIsolation::Default;
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

    [InherentPermissions(PermissionObjectType::TableData, Database::"User Environment Login", 'ri')]
    procedure CreateEnvironmentLoginInfo()
    var
        UserEnvironmentLogin: Record "User Environment Login";
    begin
        // use relaxed read isolation
        if UserLoggedInEnvironment(UserSecurityId()) then
            exit;

        UserEnvironmentLogin.LockTable(); // prevent deadlocks
        if not UserEnvironmentLogin.Get(UserSecurityId()) then begin
            UserEnvironmentLogin."User SID" := UserSecurityId();
            if not UserEnvironmentLogin.Insert() then
                Session.LogMessage('0000KQV', CouldNotInsertEnvironmentLoginErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UserLoginCategoryLbl);

        end;

        Commit(); // release the lock
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::"User Login", 'rim')]
    procedure CreateOrUpdateLoginInfo()
    var
        UserLogin: Record "User Login";
#if not CLEAN21
        UserLoginTimeTracker: Codeunit "User Login Time Tracker";
#endif
        Now: DateTime;
    begin
        Now := CurrentDateTime();

        SelectLatestVersion();
        UserLogin.ReadIsolation := UserLogin.ReadIsolation::ReadUncommitted;
        if UserLogin.Get(UserSecurityId()) and (UserLogin."Last Login Date" <> 0DT) then // 0DT is a null datetime and cannot be added with 60.000 below
            if (Now < UserLogin."Last Login Date" + 60000) and (DT2Date(Now) = DT2Date(UserLogin."Last Login Date")) then // every 1 min on same day must be enough
                exit;

        // Create or update the company login information
        UserLogin.ReadIsolation := UserLogin.ReadIsolation::Default;
        UserLogin.LockTable(); // to ensure that the latest version is picked up and the other users logging in wait here
        if UserLogin.Get(UserSecurityId()) then begin
            UserLogin."Penultimate Login Date" := UserLogin."Last Login Date";
            UserLogin."Last Login Date" := Now;
            if not UserLogin.Modify(true) then
                Session.LogMessage('0000KQW', CouldNotModifyUserLoginErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UserLoginCategoryLbl);
        end else begin
            UserLogin.Init();
            UserLogin."User SID" := UserSecurityId();
            UserLogin."First Login Date" := DT2Date(Now);
            UserLogin."Penultimate Login Date" := 0DT;
            UserLogin."Last Login Date" := Now;
            if not UserLogin.Insert(true) then
                Session.LogMessage('0000KQX', CouldNotInsertUserLoginErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UserLoginCategoryLbl);
        end;
        Commit();

#if not CLEAN21
#pragma warning disable AL0432
        UserLoginTimeTracker.OnAfterCreateorUpdateLoginInfo(UserSecurityId());
#pragma warning restore AL0432
#endif
    end;

    var
        UserLoginCategoryLbl: Label 'User Login', Locked = true;
        CouldNotInsertEnvironmentLoginErr: Label 'Could not insert environment login information.', Locked = true;
        CouldNotModifyUserLoginErr: Label 'Could not modify user login information.', Locked = true;
        CouldNotInsertUserLoginErr: Label 'Could not insert user login information.', Locked = true;
}
