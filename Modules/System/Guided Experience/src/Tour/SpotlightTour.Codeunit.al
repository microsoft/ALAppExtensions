// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Environment.Configuration;

/// <summary>
/// Provides functionality to use spotlight tours
/// </summary>
codeunit 3727 "Spotlight Tour"
{

    /// <summary>
    /// Start spotlight tour on specific page.
    /// </summary>
    /// <param name="PageId">Page to run tour on.</param>
    /// <param name="SpotlightTourType">Type of tour.</param>
    /// <param name="Title1">Title for step 1.</param>
    /// <param name="Text1">Text for step 1.</param>
    /// <param name="Title2">Title for step 2.</param>
    /// <param name="Text2">Text for step 2.</param>
    procedure Start(PageId: Integer; SpotlightTourType: Enum "Spotlight Tour Type"; Title1: Text; Text1: Text; Title2: Text; Text2: Text)
    begin
        SpotlightTourImpl.Start(PageId, SpotlightTourType, Title1, Text1, Title2, Text2);
    end;

    var
        SpotlightTourImpl: Codeunit "Spotlight Tour Impl.";

}