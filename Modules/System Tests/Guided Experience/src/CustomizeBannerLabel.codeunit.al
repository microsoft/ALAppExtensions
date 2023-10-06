// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Environment.Configuration;

using System.Environment.Configuration;


codeunit 132621 "Customize Banner Label"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Checklist Banner", 'OnBeforeUpdateBannerLabels', '', false, false)]
    local procedure TrackingSpecificationClearTracking(var IsHandled: Boolean; IsEvaluationCompany: Boolean; var TitleTxt: Text; var TitleCollapsedTxt: Text; var HeaderTxt: Text; var HeaderCollapsedTxt: Text; var DescriptionTxt: Text)
    begin
        IsHandled := true;

        TitleTxt := 'Title Text';
        TitleCollapsedTxt := 'Title Collap Text';

        HeaderTxt := 'Header Text';
        HeaderCollapsedTxt := 'Header Collap Text';

        DescriptionTxt := 'Description Text';
    end;


}