// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to retrieve information about the user's first, penultimate and last login times.
/// </summary>
codeunit 9026 "User Login Time Tracker"
{
    Access = Public;

    /// <summary>
    /// Returns true if this is the first time the user logs in.
    /// </summary>
    /// <param name="UserSecurityID">The User Security ID.</param>
    /// <returns>True if this is the first time the user logs in and false otherwise.</returns>
    procedure IsFirstLogin(UserSecurityID: Guid): Boolean
    var
        UserLoginTimeTrackerImpl: Codeunit "User Login Time Tracker Impl.";
    begin
        exit(UserLoginTimeTrackerImpl.IsFirstLogin(UserSecurityID));
    end;

    /// <summary>
    /// Returns true if any user logged in on or after the specified date.
    /// </summary>
    /// <param name ="FromDate">The date to start searching from.</param>
    /// <returns>True if any user logged in on or after the specified date and false otherwise.</returns>
    procedure AnyUserLoggedInSinceDate(FromDate: Date): Boolean
    var
        UserLoginTimeTrackerImpl: Codeunit "User Login Time Tracker Impl.";
    begin
        exit(UserLoginTimeTrackerImpl.AnyUserLoggedInSinceDate(FromDate));
    end;

    /// <summary>
    /// Returns true if the current user logged in at or after the specified DateTime.
    /// </summary>
    /// <param name="FromDateTime">The DateTime to start searching from.</param>
    /// <returns>True if the current user logged in at or after the specified DateTime and false otherwise.</returns>
    procedure UserLoggedInSinceDateTime(FromDateTime: DateTime): Boolean
    var
        UserLoginTimeTrackerImpl: Codeunit "User Login Time Tracker Impl.";
    begin

        exit(UserLoginTimeTrackerImpl.UserLoggedInSinceDateTime(FromDateTime));
    end;

    /// <summary>
    /// Returns the penultimate login DateTime of the current user.
    /// </summary>
    /// <returns>The penultimate login DateTime of the current user, or 0DT if the user login cannot be found.</returns>
    procedure GetPenultimateLoginDateTime(): DateTime
    var
        UserLoginTimeTrackerImpl: Codeunit "User Login Time Tracker Impl.";
    begin
        exit(UserLoginTimeTrackerImpl.GetPenultimateLoginDateTime(UserSecurityId()));
    end;

    /// <summary>
    /// Returns the penultimate login DateTime of a user.
    /// </summary>
    /// <param name="UserSecurityID">The security ID of the user.</param>
    /// <returns>The penultimate login DateTime of a user, or 0DT if the user login cannot be found.</returns>
    procedure GetPenultimateLoginDateTime(UserSecurityID: Guid): DateTime
    var
        UserLoginTimeTrackerImpl: Codeunit "User Login Time Tracker Impl.";
    begin
        exit(UserLoginTimeTrackerImpl.GetPenultimateLoginDateTime(UserSecurityID));
    end;

    /// <summary>
    /// Updates or creates the last login information of the current user (first, last and penultimate login date).
    /// </summary>
    [Scope('OnPrem')]
    procedure CreateOrUpdateLoginInfo()
    var
        UserLoginTimeTrackerImpl: Codeunit "User Login Time Tracker Impl.";
    begin
        UserLoginTimeTrackerImpl.CreateOrUpdateLoginInfo();
    end;

    /// <summary>
    /// Publishes an event that is fired whenever a user's login information is created or updated.
    /// </summary>
    /// <param name="UserSecurityId">The User Security ID of the user that is being created or updated.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnAfterCreateorUpdateLoginInfo(UserSecurityId: Guid)
    begin
    end;
}

