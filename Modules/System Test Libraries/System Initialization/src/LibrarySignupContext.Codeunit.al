// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Environment.Configuration;

using System.Environment.Configuration;
using System.TestLibraries.Utilities;

codeunit 130046 "Library - Signup Context"
{
    Access = Public;

    var
        Any: Codeunit Any;
        SystemInitializationImpl: Codeunit "System Initialization Impl.";
        nameTok: Label 'name', Locked = true;
        viralTok: Label 'viral', Locked = true;
        TestValueTok: Label 'Test Value', Locked = true;

    /// <summary>
    /// Sets the signup context record with values for the Test Value signup context
    /// </summary>
    procedure SetTestValueSignupContext()
    begin
        SetSignupContext(nameTok, TestValueTok)
    end;

    /// <summary>
    /// Sets the signup context record with values for the Viral signup context
    /// </summary>
    procedure SetViralSignupContext()
    begin
        SetSignupContext(nameTok, viralTok)
    end;

    /// <summary>
    /// Sets the signup context record with values when there is no signup context
    /// </summary>
    procedure SetBlankSignupContext()
    begin
        SetSignupContext('', '')
    end;

    /// <summary>
    /// Sets the signup context record with values for an unknown signup context
    /// </summary>
    procedure SetUnknownSignupContext()
    begin
        SetSignupContext(nameTok, CopyStr(Any.UnicodeText(2000), 1, 2000))
    end;

    /// <summary>
    /// Sets the signup context record with values for the specified signup context
    /// Use this method to assign additional values passed in the signup context
    /// </summary>
    procedure SetSignupContext(SignupContextKey: Text[128]; SignupContextValue: Text[2000])
    var
        SignupContext: Record "Signup Context";
    begin
        SignupContext.KeyName := lowercase(SignupContextKey);
        SignupContext.Value := SignupContextValue;
        SignupContext.Insert();
    end;

    procedure DeleteSignupContext()
    var
        SignupContext: Record "Signup Context";
        SignupContextValues: Record "Signup Context Values";
    begin
        SignupContext.DeleteAll();
        SignupContextValues.DeleteAll();
    end;

    /// <summary>
    /// Disables the check for System User (i.e. default system super user) so the signup context can be set for testing purposes
    /// </summary>
    procedure SetDisableSystemUserCheck()
    begin
        SystemInitializationImpl.SetDisableSystemUserCheck()
    end;
}