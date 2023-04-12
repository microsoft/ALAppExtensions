// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 151 "System Initialization Impl."
{
    Access = Internal;
    SingleInstance = true;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        SignupContextCallerModuleInfo: ModuleInfo;
        InitializationInProgress: Boolean;
        UnknownSignupContextTxt: Label 'Request is successful.', Locked = true;
        DetectedSignupContextTxt: Label 'Detected signup context.', Locked = true;
        NoSignupContextTxt: Label 'No signup context was passed.', Locked = true;
        NoNameKeySignupContextTxt: Label 'The signup context did not contain a ''name'' key.', Locked = true;
        DisableSystemUserCheck: Boolean;

#if not CLEAN20
#pragma warning disable AL0432
#endif
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company Triggers", OnCompanyOpen, '', false, false)]
#if not CLEAN20
#pragma warning restore AL0432
#endif
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
            // Check to set signup context and commits if it updates
            SetSignupContext();
            // UserLogin commits if it updates.
            UserLoginTimeTracker.CreateOrUpdateLoginInfo();
        end;

#if not CLEAN20
#pragma warning disable AL0432
#endif
        SystemInitialization.OnAfterInitialization();
#if not CLEAN20
#pragma warning restore AL0432
#endif
        InitializationInProgress := false;
    end;

    local procedure SetSignupContext()
    var
        SignupContext: Record "Signup Context"; // system table
        SignupContextValues: Record "Signup Context Values";
        Telemetry: Codeunit "Telemetry";
    begin
        if IsSystemUser() then
            exit;

        Clear(SignupContextCallerModuleInfo);
        if not SignupContextValues.IsEmpty() then
            exit;

        if SignupContext.IsEmpty() then begin
            InsertSignupContext(SignupContextValues."Signup Context"::" ");
            Telemetry.LogMessage('0000HOI', NoSignupContextTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher);
            Commit();
            exit;
        end;

        if not SignupContext.Get('name') then begin
            InsertSignupContext(SignupContextValues."Signup Context"::" ");
            Telemetry.LogMessage('0000HOJ', NoNameKeySignupContextTxt, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher);
            Commit();
            exit;
        end;

        SetSignupContext(SignupContext, SignupContextValues);
        Commit();
    end;

    internal procedure SetSignupContext(SignupContext: Record "Signup Context"; var SignupContextValues: Record "Signup Context Values")
    var
        SystemInitialization: Codeunit "System Initialization";
        Telemetry: Codeunit "Telemetry";
        CustomDimensions: Dictionary of [Text, Text];
    begin
        case LowerCase(SignupContext.Value) of
            'viral':
                InsertSignupContext(SignupContextValues."Signup Context"::"Viral Signup");
            else
                SystemInitialization.OnSetSignupContext(SignupContext, SignupContextValues);
        end;

        if SignupContextValues.IsEmpty() then begin
            // A Signup Context was passed but nobody parsed it into Signup Context Values. The context is unknown.
            Telemetry.LogMessage('0000HMW', UnknownSignupContextTxt, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher);
            InsertSignupContext(SignupContextValues."Signup Context"::" ");
        end else begin
            CustomDimensions.Add('DetectedSignupContext', SignupContext.Value);
            CustomDimensions.Add('StoredSignupContext', Format(SignupContextValues."Signup Context"));
            CustomDimensions.Add('ConvertedByPublisher', SignupContextCallerModuleInfo.Publisher);
            CustomDimensions.Add('ConvertedByName', SignupContextCallerModuleInfo.Name);
            CustomDimensions.Add('ConvertedById', SignupContextCallerModuleInfo.Id);
            CustomDimensions.Add('ConvertedByAppVersion', Format(SignupContextCallerModuleInfo.AppVersion));
            Telemetry.LogMessage('0000HMX', DetectedSignupContextTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
        end;
    end;

    local procedure InsertSignupContext(SignupContext: Enum "Signup Context")
    var
        SignupContextValues: Record "Signup Context Values";
    begin
        SignupContextValues."Primary Key" := '';
        SignupContextValues."Signup Context" := SignupContext;
        SignupContextValues.Insert();
    end;

    procedure ShouldCheckSignupContext(): Boolean
    var
        Company: Record Company;
    begin
        if Company.Get(CompanyName()) then;
        Company.SetRange("Evaluation Company", Company."Evaluation Company");
        exit(Company.Count() <= 1);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company Triggers", OnCompanyOpenCompleted, '', false, false)]
    local procedure InitCompany()
    var
        SystemInitialization: Codeunit "System Initialization";
    begin
        InitializationInProgress := true;
        SystemInitialization.OnAfterLogin();
        InitializationInProgress := false;
    end;

    procedure IsInProgress(): Boolean
    begin
        exit(InitializationInProgress);
    end;

    local procedure IsSystemUser(): Boolean
    var
        SystemUserSID: Guid;
    begin
        if DisableSystemUserCheck then
            exit(false);
        SystemUserSID := '{00000000-0000-0000-0000-000000000001}';
        exit(UserSecurityId() = SystemUserSID)
    end;

    internal procedure SetDisableSystemUserCheck(): Boolean
    begin
        DisableSystemUserCheck := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Signup Context Values", OnBeforeInsertEvent, '', false, false)]
    local procedure SetCallerModuleOnBeforeInsertSignupContext()
    begin
        NavApp.GetCallerModuleInfo(SignupContextCallerModuleInfo);
    end;
}

