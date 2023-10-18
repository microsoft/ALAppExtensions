// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Visualization;

using System.Visualization;
codeunit 135058 "Cues And KPIs Test Library"
{
    procedure DeleteAllSetup()
    var
        CueSetup: Record "Cue Setup";
    begin
        CueSetup.DeleteAll();
    end;
}