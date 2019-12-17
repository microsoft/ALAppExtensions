// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides the functionality for generating and validating passwords.
/// </summary>
codeunit 1284 "Password Handler"
{
    Access = Public;

    var
        PasswordHandlerImpl: Codeunit "Password Handler Impl.";

    /// <summary>
    /// Generates a password that consists of a number of characters defined by the <see cref="GetPasswordMinLength"/> method,
    /// and meets the <see cref="IsPasswordStrong"/> conditions.
    /// </summary>
    /// <error>The length is less than the minimum defined in <see cref="OnSetMinPasswordLength"/> event.</error>
    /// <returns>The generated password.</returns>
    procedure GeneratePassword(): Text;
    begin
        exit(PasswordHandlerImpl.GeneratePassword());
    end;

    /// <summary>
    /// Generates a password that consists of a user-defined number of characters, and meets the <see cref="IsPasswordStrong"/> conditions.
    /// </summary>
    /// <param name="Length">The number of characters in the password. Passwords must contain at least eight characters.</param>
    /// <error>The length is less than the minimum defined in <see cref="OnSetMinPasswordLength"/> event.</error>
    /// <returns>The generated password.</returns>
    procedure GeneratePassword(Length: Integer): Text;
    begin
        exit(PasswordHandlerImpl.GeneratePassword(Length));
    end;

    /// <summary>
    /// Check whether the password meets the following conditions:
    /// - Contains at least the number characters defined by <see cref="OnSetMinPasswordLength"/> event, but it cannot be less than eight.
    /// - Contains uppercase and lowercase characters, digits, and special characters.
    /// - Does not contain sequences of characters. For example, aaa or 123.
    /// </summary>
    /// <param name="Password">The password to check.</param>
    /// <returns>True if the password meets the conditions for strong passwords.</returns>
    procedure IsPasswordStrong(Password: Text): Boolean;
    begin
        exit(PasswordHandlerImpl.IsPasswordStrong(Password));
    end;

    /// <summary>
    /// Gets the minimum length of the password. It is defined by <see cref="OnSetMinPasswordLength"/> event, but it cannot be less than eight.
    /// </summary>
    /// <returns>The minimum length of the password. Eight by default.</returns>
    procedure GetPasswordMinLength(): Integer
    begin
        exit(PasswordHandlerImpl.GetPasswordMinLength());
    end;
}

