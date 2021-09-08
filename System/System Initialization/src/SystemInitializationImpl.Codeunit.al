// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 151 "System Initialization Impl."
{
    Access = Internal;
    SingleInstance = true;

    var
        InitializationInProgress: Boolean;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company Triggers", 'OnCompanyOpen', '', false, false)]
    local procedure Init()
    var
        SystemInitialization: Codeunit "System Initialization";
        UserLoginTimeTracker: Codeunit "User Login Time Tracker";
    begin
        InitializationInProgress := true;
        // Initialization logic goes here

        // This needs to be the very first thing to run before company open
        CODEUNIT.Run(CODEUNIT::"Azure AD User Management");

        if Session.CurrentClientType() in [ClientType::Web, ClientType::Windows, ClientType::Desktop, ClientType::Tablet, ClientType::Phone] then begin
            UserLoginTimeTracker.CreateOrUpdateLoginInfo();

            // This commit needs to be performed before the password modal dialog is displayed, otherwise an error occurs
            Commit();
        end;

        SystemInitialization.OnAfterInitialization();

        InitializationInProgress := false;
    end;

    procedure IsInProgress(): Boolean
    begin
        exit(InitializationInProgress);
    end;
}

