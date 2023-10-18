// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Feedback;

using System.Feedback;

codeunit 138078 "Sat. Survey Test Library"
{
    var
        SatisfactionSurveyImpl: Codeunit "Satisfaction Survey Impl.";

    procedure GetRenderUrl(): Text
    begin
        exit(SatisfactionSurveyImpl.GetRenderUrl());
    end;
}