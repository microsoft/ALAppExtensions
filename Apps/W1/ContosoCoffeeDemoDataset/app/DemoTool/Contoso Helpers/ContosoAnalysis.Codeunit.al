// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DemoTool.Helpers;

using Microsoft.Finance.Analysis;

codeunit 5452 "Contoso Analysis"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Analysis View" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertAnalysisView(Code: Code[10]; Name: Text[50]; AccountFilter: Code[250]; StartingDate: Date; DateCompression: Integer; Dimension1Code: Code[20]; Dimension2Code: Code[20]; Dimension3Code: Code[20])
    var
        AnalysisView: Record "Analysis View";
        Exists: Boolean;
    begin
        if AnalysisView.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        AnalysisView.Validate(Code, Code);
        AnalysisView.Validate(Name, Name);
        AnalysisView."Account Filter" := AccountFilter;
        AnalysisView.Validate("Starting Date", StartingDate);
        AnalysisView.Validate("Date Compression", DateCompression);

        if Exists then
            AnalysisView.Modify(true)
        else
            AnalysisView.Insert(true);

        AnalysisView.Validate("Dimension 1 Code", Dimension1Code);
        AnalysisView.Validate("Dimension 2 Code", Dimension2Code);
        AnalysisView.Validate("Dimension 3 Code", Dimension3Code);
        AnalysisView.Modify(true);
    end;
}
