// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135094 "Environment Info Test Library"
{
    EventSubscriberInstance = Manual;
    SingleInstance = true;

    var
        EnvironmentInformationImpl: Codeunit "Environment Information Impl.";
        TestAppId: Text;

    /// <summary>
    /// Sets the testability sandbox flag.
    /// </summary>
    /// <remarks>
    /// This functions should only be used for testing purposes.
    /// </remarks>
    /// <param name="EnableSandboxForTest">The value to be set to the testability sandbox flag.</param>
    [Scope('OnPrem')]
    procedure SetTestabilitySandbox(EnableSandboxForTest: Boolean)
    begin
        EnvironmentInformationImpl.SetTestabilitySandbox(EnableSandboxForTest);
    end;

    /// <summary>
    /// Sets the testability SaaS flag.
    /// </summary>
    /// <remarks>
    /// This functions should only be used for testing purposes.
    /// </remarks>
    /// <param name="EnableSoftwareAsAServiceForTest">The value to be set to the testability SaaS flag.</param>
    [Scope('OnPrem')]
    procedure SetTestabilitySoftwareAsAService(EnableSoftwareAsAServiceForTest: Boolean)
    begin
        EnvironmentInformationImpl.SetTestabilitySoftwareAsAService(EnableSoftwareAsAServiceForTest);
    end;

    /// <summary>
    /// Sets the App ID that of the current application (for example, 'FIN' - Financials) when the sunscription is bound.
    /// Uses <see cref="OnBeforeGetApplicationIdentifier"/> event.
    /// </summary>
    /// <param name="NewAppId">The desired ne App ID.</param>
    [Scope('OnPrem')]
    procedure SetAppId(NewAppId: Text)
    begin
        TestAppId := NewAppId;
    end;

    /// <summary>
    /// Overwrite the current App ID.
    /// </summary>
    /// <param name="AppId">The current App ID.</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Information Impl.", 'OnBeforeGetApplicationIdentifier', '', false, false)]
    local procedure SetAppIdOnBeforeGetApplicationIdentifier(var AppId: Text)
    begin
        AppId := TestAppId;
    end;
}

