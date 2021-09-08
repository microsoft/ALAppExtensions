// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Management codeunit that exposes various functions to work with Satisfaction Survey.
/// </summary>
codeunit 1433 "Satisfaction Survey Mgt."
{
    Access = Public;

    var
        SatisfactionSurveyImpl: Codeunit "Satisfaction Survey Impl.";

    /// <summary>
    /// Tries to show the satisfaction survey dialog to the current user.
    /// The survey is only shown if the user is chosen for the survey. 
    /// The method sends the request to the server and checks the response to check if the user is chosen for the survey.
    /// </summary>
    /// <returns>True if the survey is shown, false otherwise.</returns>
    [Scope('OnPrem')]
    procedure TryShowSurvey(): Boolean
    begin
        exit(SatisfactionSurveyImpl.TryShowSurvey());
    end;

    /// <summary>
    /// Tries to show the satisfaction survey dialog to the current user.
    /// Decision to show the survey or not is based on the response from the server on the check request.
    /// </summary>
    /// <param name="Status">Response status code</param>
    /// <param name="Response">Response body</param>
    /// <returns>True if the survey is shown, false otherwise.</returns>
    [Scope('OnPrem')]
    procedure TryShowSurvey(Status: Integer; Response: Text): Boolean
    begin
        exit(SatisfactionSurveyImpl.TryShowSurvey(Status, Response));
    end;

    /// <summary>
    /// Gets the URL of the request to the server for checking if the dialog has to be presented to the current user.
    /// </summary>
    /// <param name="Url">The URL of the request to the server for checking if the dialog has to be presented to the current user.</param>
    /// <returns>True if the check URL is valid, false otherwise.</returns>
    [Scope('OnPrem')]
    procedure TryGetCheckUrl(var Url: Text): Boolean
    begin
        exit(SatisfactionSurveyImpl.TryGetCheckUrl(Url));
    end;

    /// <summary>
    /// Gets the asynchronous request timeout.
    /// </summary>
    /// <returns>The asynchronous request timeout in milliseconds.</returns>
    [Scope('OnPrem')]
    procedure GetRequestTimeoutAsync(): Integer
    begin
        exit(SatisfactionSurveyImpl.GetRequestTimeoutAsync());
    end;

    /// <summary>
    /// Deletes the survey state and deactivates the survey for all users.
    /// </summary>
    /// <returns>True if the survey is deactivated for all users, false otherwise.</returns>
    [Scope('OnPrem')]
    procedure ResetState(): Boolean
    begin
        exit(SatisfactionSurveyImpl.ResetState());
    end;

    /// <summary>
    /// Resets the the cached survey parameters.
    /// </summary>
    /// <returns>True if the cached survey parameters are reset, false otherwise.</returns>
    [Scope('OnPrem')]
    procedure ResetCache(): Boolean
    begin
        exit(SatisfactionSurveyImpl.ResetCache());
    end;

    /// <summary>
    /// Activates a try to show the survey for the current user.
    /// </summary>
    /// <returns>True if the survey state has been changed from inactive to active, false otherwise.</returns>
    [Scope('OnPrem')]
    procedure ActivateSurvey(): Boolean
    begin
        exit(SatisfactionSurveyImpl.ActivateSurvey());
    end;

    /// <summary>
    /// Deactivates a try to show the survey for the current user.
    /// </summary>
    /// <returns>True if the survey state has been changed from active to inactive, false otherwise.</returns>
    [Scope('OnPrem')]
    procedure DeactivateSurvey(): Boolean
    begin
        exit(SatisfactionSurveyImpl.DeactivateSurvey());
    end;
}

