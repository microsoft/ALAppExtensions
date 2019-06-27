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

    [EventSubscriber(ObjectType::Codeunit, 2000000003, 'OnCompanyOpen', '', false, false)]
    local procedure Init()
    var
        SystemInitialization: Codeunit "System Initialization";
    begin
        InitializationInProgress := true;
        // Initialization logic goes heres

        SystemInitialization.OnAfterInitialization();

        InitializationInProgress := false;
    end;

    [Scope('OnPrem')]
    procedure IsInProgress(): Boolean
    begin
        exit(InitializationInProgress);
    end;
}

