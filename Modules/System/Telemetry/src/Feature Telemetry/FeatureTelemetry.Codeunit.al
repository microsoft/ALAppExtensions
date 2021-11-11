// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality for emitting telemetry in a universal format. Only system metadata is to be emitted through this codeunit.
/// </summary>
/// <remarks>
/// Every publisher needs to have an implementation of the "Telemetry Logger" interface and a subscriber 
/// to "Telemetry Loggers".OnRegisterTelemetryLogger event in one of their apps in order for this codeunit
/// to work as expected (see "System Telemetry Logger" codeunit).
/// </remarks>
codeunit 8703 "Feature Telemetry"
{
    Access = Public;

    var
        FeatureTelemetryImpl: Codeunit "Feature Telemetry Impl.";

    /// <summary>
    /// Sends telemetry about feature usage.
    /// </summary>
    /// <param name="EventId">A unique ID of the event.</param>
    /// <param name="FeatureName">The name of the feature.</param>
    /// <param name="EventName">The name of the event.</param>
    /// <example>FeatureTelemetry.LogUsage('0000XYZ', 'Emailing', 'Email sent');</example>
    procedure LogUsage(EventId: Text; FeatureName: Text; EventName: Text)
    var
        CallerModuleInfo: ModuleInfo;
        CustomDimensions: Dictionary of [Text, Text];
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        FeatureTelemetryImpl.LogUsage(EventId, FeatureName, EventName, CustomDimensions, CallerModuleInfo);
    end;

    /// <summary>
    /// Sends telemetry about feature usage.
    /// </summary>
    /// <param name="EventId">A unique ID of the event.</param>
    /// <param name="FeatureName">The name of the feature.</param>
    /// <param name="EventName">The name of the event.</param>
    /// <param name="CustomDimensions">A dictionary containing additional information about the event.</param>
    /// <remarks>Custom dimensions often contain infromation translated in different languages. It is a common practice to send telemetry in the default language (see example).</remarks>
    /// <example>
    /// TranslationHelper.SetGlobalLanguageToDefault();
    /// CustomDimensions.Add('JobQueueObjectType', Format(JobQueueEntry."Object Type to Run"));
    /// CustomDimensions.Add('JobQueueObjectId', Format(JobQueueEntry."Object ID to Run"));
    /// FeatureTelemetry.LogUsage('0000XYZ', 'Job Queue', 'Job executed', CustomDimensions);
    /// TranslationHelper.RestoreGlobalLanguage();
    /// </example>
    procedure LogUsage(EventId: Text; FeatureName: Text; EventName: Text; CustomDimensions: Dictionary of [Text, Text])
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        FeatureTelemetryImpl.LogUsage(EventId, FeatureName, EventName, CustomDimensions, CallerModuleInfo);
    end;

    /// <summary>
    /// Sends telemetry about errors happening during feature usage.
    /// </summary>
    /// <param name="EventId">A unique ID of the error.</param>
    /// <param name="FeatureName">The name of the feature.</param>
    /// <param name="EventName">The name of the event.</param>
    /// <param name="ErrorText">The text of the error.</param>
    /// <example>
    /// if not Success then
    ///     FeatureTelemetry.LogError('0000XYZ', 'Retention policies', 'Applying a policy', GetLastErrorText(true));
    /// </example>
    procedure LogError(EventId: Text; FeatureName: Text; EventName: Text; ErrorText: Text)
    var
        CallerModuleInfo: ModuleInfo;
        DummyCustomDimensions: Dictionary of [Text, Text];
        DummyErrorCallStack: Text;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        FeatureTelemetryImpl.LogError(EventId, FeatureName, EventName, ErrorText, DummyErrorCallStack, DummyCustomDimensions, CallerModuleInfo);
    end;

    /// <summary>
    /// Sends telemetry about errors happening during feature usage.
    /// </summary>
    /// <param name="EventId">A unique ID of the error.</param>
    /// <param name="FeatureName">The name of the feature.</param>
    /// <param name="EventName">The name of the event.</param>
    /// <param name="ErrorText">The text of the error.</param>
    /// <param name="ErrorCallStack">The error call stack.</param>
    /// <example>
    /// if not Success then
    ///     FeatureTelemetry.LogError('0000XYZ', 'Configuration packages', 'Importing a package', GetLastErrorText(true), GetLastErrorCallStack());
    /// </example>
    procedure LogError(EventId: Text; FeatureName: Text; EventName: Text; ErrorText: Text; ErrorCallStack: Text)
    var
        CallerModuleInfo: ModuleInfo;
        DummyCustomDimensions: Dictionary of [Text, Text];
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        FeatureTelemetryImpl.LogError(EventId, FeatureName, EventName, ErrorText, ErrorCallStack, DummyCustomDimensions, CallerModuleInfo);
    end;

    /// <summary>
    /// Sends telemetry about errors happening during feature usage.
    /// </summary>
    /// <param name="EventId">A unique ID of the error.</param>
    /// <param name="FeatureName">The name of the feature.</param>
    /// <param name="EventName">The name of the event.</param>
    /// <param name="ErrorText">The text of the error.</param>
    /// <param name="ErrorCallStack">The error call stack.</param>
    /// <param name="CustomDimensions">A dictionary containing additional information about the error.</param>
    /// <remarks>Custom dimensions often contain infromation translated in different languages. It is a common practice to send telemetry in the default language (see example).</remarks>
    /// <example>
    /// if not Success then begin
    ///     TranslationHelper.SetGlobalLanguageToDefault();
    ///     CustomDimensions.Add('UpdateEntity', Format(AzureADUserUpdateBuffer."Update Entity"));
    ///     FeatureTelemetry.LogError('0000XYZ', 'User management', 'Syncing users with M365', GetLastErrorText(true), GetLastErrorCallStack(), CustomDimensions);
    ///     TranslationHelper.RestoreGlobalLanguage();
    /// end;
    /// </example>
    procedure LogError(EventId: Text; FeatureName: Text; EventName: Text; ErrorText: Text; ErrorCallStack: Text; CustomDimensions: Dictionary of [Text, Text])
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        FeatureTelemetryImpl.LogError(EventId, FeatureName, EventName, ErrorText, ErrorCallStack, CustomDimensions, CallerModuleInfo);
    end;

    /// <summary>
    /// Sends telemetry about feature uptake.
    /// </summary>
    /// <param name="EventId">A unique ID of the event.</param>
    /// <param name="FeatureName">The name of the feature.</param>
    /// <param name="FeatureUptakeStatus">The new status of the feature uptake.</param>
    /// <remarks>
    /// This method may perform database write transactions, therefore it should not be used from within try functions.
    /// Expected feature uptake transitions:
    /// "Discovered" -> "Set up" -> "Used" (and only in this order; for example, if for a given feature the first status was logged as "Set up", no telemetry will be emitted)
    /// *Any state* -> "Undiscovered" (to reset the feature uptake status)
    /// </remarks>
    procedure LogUptake(EventId: Text; FeatureName: Text; FeatureUptakeStatus: Enum "Feature Uptake Status")
    var
        CallerModuleInfo: ModuleInfo;
        DummyCustomDimensions: Dictionary of [Text, Text];
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        FeatureTelemetryImpl.LogUptake(EventId, FeatureName, FeatureUptakeStatus, false, false, DummyCustomDimensions, CallerModuleInfo);
    end;

    /// <summary>
    /// Sends telemetry about feature uptake.
    /// </summary>
    /// <param name="EventId">A unique ID of the event.</param>
    /// <param name="FeatureName">The name of the feature.</param>
    /// <param name="FeatureUptakeStatus">The new status of the feature uptake.</param>
    /// <param name="IsPerUser">Specifies if the feature is targeted to be uptaken once for the tenant or uptaken individually by different users.</param>
    /// <remarks>
    /// This method may perform database write transactions, therefore it should not be used from within try functions.
    /// Expected feature uptake transitions:
    /// "Discovered" -> "Set up" -> "Used" (and only in this order; for example, if for a given feature the first status was logged as "Set up", no telemetry will be emitted)
    /// *Any state* -> "Undiscovered" (to reset the feature uptake status)
    /// </remarks>
    procedure LogUptake(EventId: Text; FeatureName: Text; FeatureUptakeStatus: Enum "Feature Uptake Status"; IsPerUser: Boolean)
    var
        CallerModuleInfo: ModuleInfo;
        DummyCustomDimensions: Dictionary of [Text, Text];
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        FeatureTelemetryImpl.LogUptake(EventId, FeatureName, FeatureUptakeStatus, IsPerUser, false, DummyCustomDimensions, CallerModuleInfo);
    end;

    /// <summary>
    /// Sends telemetry about feature uptake.
    /// </summary>
    /// <param name="EventId">A unique ID of the event.</param>
    /// <param name="FeatureName">The name of the feature.</param>
    /// <param name="FeatureUptakeStatus">The new status of the feature uptake.</param>
    /// <param name="IsPerUser">Specifies if the feature is targeted to be uptaken once for the tenant or uptaken individually by different users.</param>
    /// <param name="CustomDimensions">A dictionary containing additional information about the event.</param>
    /// <remarks>
    /// This method may perform database write transactions, therefore it should not be used from within try functions.
    /// Expected feature uptake transitions:
    /// "Discovered" -> "Set up" -> "Used" (and only in this order; for example, if for a given feature the first status was logged as "Set up", no telemetry will be emitted)
    /// *Any state* -> "Undiscovered" (to reset the feature uptake status)
    /// </remarks>
    procedure LogUptake(EventId: Text; FeatureName: Text; FeatureUptakeStatus: Enum "Feature Uptake Status"; IsPerUser: Boolean; CustomDimensions: Dictionary of [Text, Text])
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        FeatureTelemetryImpl.LogUptake(EventId, FeatureName, FeatureUptakeStatus, IsPerUser, false, CustomDimensions, CallerModuleInfo);
    end;

    /// <summary>
    /// Sends telemetry about feature uptake.
    /// </summary>
    /// <param name="EventId">A unique ID of the event.</param>
    /// <param name="FeatureName">The name of the feature.</param>
    /// <param name="FeatureUptakeStatus">The new status of the feature uptake.</param>
    /// <param name="IsPerUser">Specifies if the feature is targeted to be uptaken once for the tenant or uptaken individually by different users.</param>
    /// <param name="PerformWriteTransactionsInASeparateSession">Specifies if database write transactions should be performed in a separate background session.</param>
    /// <remarks>
    /// This method may perform database write transactions, therefore it should not be used from within try functions, unless PerformWriteTransactionsInASeparateSession is true.
    /// Expected feature uptake transitions:
    /// "Discovered" -> "Set up" -> "Used" (and only in this order; for example, if for a given feature the first status was logged as "Set up", no telemetry will be emitted)
    /// *Any state* -> "Undiscovered" (to reset the feature uptake status)
    /// </remarks>
    procedure LogUptake(EventId: Text; FeatureName: Text; FeatureUptakeStatus: Enum "Feature Uptake Status"; IsPerUser: Boolean; PerformWriteTransactionsInASeparateSession: Boolean)
    var
        CallerModuleInfo: ModuleInfo;
        DummyCustomDimensions: Dictionary of [Text, Text];
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        FeatureTelemetryImpl.LogUptake(EventId, FeatureName, FeatureUptakeStatus, IsPerUser, PerformWriteTransactionsInASeparateSession, DummyCustomDimensions, CallerModuleInfo);
    end;

    /// <summary>
    /// Sends telemetry about feature uptake.
    /// </summary>
    /// <param name="EventId">A unique ID of the event.</param>
    /// <param name="FeatureName">The name of the feature.</param>
    /// <param name="FeatureUptakeStatus">The new status of the feature uptake.</param>
    /// <param name="IsPerUser">Specifies if the feature is targeted to be uptaken once for the tenant or uptaken individually by different users.</param>
    /// <param name="PerformWriteTransactionsInASeparateSession">Specifies if database write transactions should be performed in a separate background session.</param>
    /// <param name="CustomDimensions">A dictionary containing additional information about the event.</param>
    /// <remarks>
    /// This method may perform database write transactions, therefore it should not be used from within try functions, unless PerformWriteTransactionsInASeparateSession is true.
    /// Expected feature uptake transitions:
    /// "Discovered" -> "Set up" -> "Used" (and only in this order; for example, if for a given feature the first status was logged as "Set up", no telemetry will be emitted)
    /// *Any state* -> "Undiscovered" (to reset the feature uptake status)
    /// </remarks>
    procedure LogUptake(EventId: Text; FeatureName: Text; FeatureUptakeStatus: Enum "Feature Uptake Status"; IsPerUser: Boolean; PerformWriteTransactionsInASeparateSession: Boolean; CustomDimensions: Dictionary of [Text, Text])
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        FeatureTelemetryImpl.LogUptake(EventId, FeatureName, FeatureUptakeStatus, IsPerUser, PerformWriteTransactionsInASeparateSession, CustomDimensions, CallerModuleInfo);
    end;
}

