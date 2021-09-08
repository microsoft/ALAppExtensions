// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

controladdin SatisfactionSurveyAsync
{
    Scripts = 'js\SATAsync.js';
    RequestedWidth = 0;
    RequestedHeight = 0;
    HorizontalStretch = false;
    VerticalStretch = false;

    procedure SendRequest(Url: Text; Timeout: Integer);
    event ResponseReceived(Status: Integer; Response: Text);
    event ControlAddInReady();
}