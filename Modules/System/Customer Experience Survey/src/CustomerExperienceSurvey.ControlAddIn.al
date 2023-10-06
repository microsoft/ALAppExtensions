// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Feedback;

controladdin CustomerExperienceSurvey
{
    VerticalStretch = true;
    HorizontalStretch = true;
    StartupScript = 'ControlAddIns\js\CustomerExperienceSurveyStartup.js';
    Scripts = 'ControlAddIns\js\CustomerExperienceSurvey.js', 'https://mfpembedcdnmsit.azureedge.net/mfpembedcontmsit/Embed.js';
    StyleSheets = 'https://mfpembedcdnmsit.azureedge.net/mfpembedcontmsit/Embed.css';

    event ControlReady();
    procedure renderSurvey(ParentElementId: Text; SurveyId: Text; TenantId: Text; FormsProEligibilityId: Text; Locale: Text);
}