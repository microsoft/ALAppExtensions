// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to check whether the system is initializing as well as an event to subscribed to in order to execute logic right after the system has initialized.
/// </summary>
codeunit 150 "System Initialization"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    /// <summary>
    /// Checks whether the system initialization is currently in progress.
    /// </summary>
    /// <returns>True, if the system initialization is in progress; false, otherwise</returns>
    procedure IsInProgress(): Boolean
    var
        SystemInitializationImpl: Codeunit "System Initialization Impl.";
    begin
        exit(SystemInitializationImpl.IsInProgress());
    end;

    /// <summary>
    /// Checks whether the signup context should be considered or whether it has expired.
    /// </summary>
    /// <returns>Returns true if the signup context is still relevant for the tenant</returns>
    procedure ShouldCheckSignupContext(): Boolean
    var
        SystemInitializationImpl: Codeunit "System Initialization Impl.";
    begin
        exit(SystemInitializationImpl.ShouldCheckSignupContext())
    end;

    /// <summary>
    /// Integration event for after the system initialization.
    /// Used only for login.
    /// </summary>
#if CLEAN20
    [Scope('OnPrem')]
#else
    [Obsolete('Replaced by OnAfterLogin.', '20.0')]
#endif
    [IntegrationEvent(false, false)]
    internal procedure OnAfterInitialization()
    begin
    end;

    /// <summary>
    /// Integration event for after the login.
    /// Subscribe to this event in order to execute additional initialization steps.
    /// </summary>
    [IntegrationEvent(false, false, true)]
    internal procedure OnAfterLogin()
    begin
    end;

    /// <summary>
    /// Subscribe to this event to set the Signup Context and parse additional values.
    /// </summary>
    [IntegrationEvent(false, false)]
    internal procedure OnSetSignupContext(SignupContext: Record "Signup Context"; var SignupContextValues: Record "Signup Context Values")
    begin
    end;
}

