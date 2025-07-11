// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ESGReporting;

codeunit 6259 "Sust. ESG Reporting Management"
{
    Permissions = TableData "Sust. ESG Reporting Template" = rimd,
                  TableData "Sust. ESG Reporting Name" = rimd;

    var
        ESGLbl: Label 'ESG', Locked = true;
        ESGReportingLbl: Label 'ESG Reporting', Locked = true;
        DefaultLbl: Label 'DEFAULT', Locked = true;
        DefaultESGReportingLbl: Label 'Default ESG Reporting', Locked = true;
        OpenFromBatch: Boolean;

    internal procedure TemplateSelection(PageID: Integer; var ESGReportingLine: Record "Sust. ESG Reporting Line"; var ESGReportingSelected: Boolean)
    var
        ESGReportingTemplate: Record "Sust. ESG Reporting Template";
    begin
        ESGReportingSelected := true;

        ESGReportingTemplate.Reset();
        ESGReportingTemplate.SetRange("Page ID", PageID);

        case ESGReportingTemplate.Count of
            0:
                begin
                    InsertDefaultESGReportingTemplate(ESGReportingTemplate);
                    Commit();
                end;
            1:
                ESGReportingTemplate.FindFirst();
            else
                ESGReportingSelected := Page.RunModal(0, ESGReportingTemplate) = Action::LookupOK
        end;

        if ESGReportingSelected then begin
            ESGReportingLine.FilterGroup(2);
            ESGReportingLine.SetRange("ESG Reporting Template Name", ESGReportingTemplate.Name);
            ESGReportingLine.FilterGroup(0);
            if OpenFromBatch then begin
                ESGReportingLine."ESG Reporting Template Name" := '';
                Page.Run(ESGReportingTemplate."Page ID", ESGReportingLine);
            end;
        end;
    end;

    internal procedure TemplateSelectionFromBatch(var ESGReportingName: Record "Sust. ESG Reporting Name")
    var
        ESGReportingLine: Record "Sust. ESG Reporting Line";
        ESGReportingTemplate: Record "Sust. ESG Reporting Template";
    begin
        OpenFromBatch := true;
        ESGReportingTemplate.Get(ESGReportingName."ESG Reporting Template Name");
        ESGReportingTemplate.TestField("Page ID");
        ESGReportingName.TestField(Name);

        ESGReportingLine.FilterGroup := 2;
        ESGReportingLine.SetRange("ESG Reporting Template Name", ESGReportingTemplate.Name);
        ESGReportingLine.FilterGroup := 0;

        ESGReportingLine."ESG Reporting Template Name" := '';
        ESGReportingLine."ESG Reporting Name" := ESGReportingName.Name;
        Page.Run(ESGReportingTemplate."Page ID", ESGReportingLine);
    end;

    internal procedure OpenESGReporting(var CurrentESGReportingName: Code[10]; var ESGReportingLine: Record "Sust. ESG Reporting Line")
    begin
        CheckTemplateName(ESGReportingLine.GetRangeMax("ESG Reporting Template Name"), CurrentESGReportingName);
        ESGReportingLine.FilterGroup(2);
        ESGReportingLine.SetRange("ESG Reporting Name", CurrentESGReportingName);
        ESGReportingLine.FilterGroup(0);
    end;

    internal procedure OpenESGReportingBatch(var ESGReportingName: Record "Sust. ESG Reporting Name")
    var
        ESGReportingTemplate: Record "Sust. ESG Reporting Template";
        ESGReportingLine: Record "Sust. ESG Reporting Line";
        JnlSelected: Boolean;
    begin
        if ESGReportingName.GetFilter("ESG Reporting Template Name") <> '' then
            exit;

        ESGReportingName.FilterGroup(2);
        if ESGReportingName.GetFilter("ESG Reporting Template Name") <> '' then begin
            ESGReportingName.FilterGroup(0);
            exit;
        end;

        ESGReportingName.FilterGroup(0);
        if not ESGReportingName.FindFirst() then begin
            if ESGReportingTemplate.IsEmpty() then
                TemplateSelection(0, ESGReportingLine, JnlSelected);
            if ESGReportingTemplate.FindFirst() then
                CheckTemplateName(ESGReportingTemplate.Name, ESGReportingName.Name);
        end;

        ESGReportingName.FindFirst();
        JnlSelected := true;
        if ESGReportingName.GetFilter("ESG Reporting Template Name") <> '' then
            ESGReportingTemplate.SetRange(Name, ESGReportingName.GetFilter("ESG Reporting Template Name"));

        case ESGReportingTemplate.Count of
            1:
                ESGReportingTemplate.FindFirst();
            else
                JnlSelected := Page.RunModal(0, ESGReportingTemplate) = Action::LookupOK;
        end;

        if not JnlSelected then
            Error('');

        ESGReportingName.FilterGroup(0);
        ESGReportingName.SetRange("ESG Reporting Template Name", ESGReportingTemplate.Name);
        ESGReportingName.FilterGroup(2);
    end;

    internal procedure CheckName(CurrentESGReportingName: Code[10]; var ESGReportingLine: Record "Sust. ESG Reporting Line")
    var
        ESGReportingName: Record "Sust. ESG Reporting Name";
    begin
        ESGReportingName.Get(ESGReportingLine.GetRangeMax("ESG Reporting Template Name"), CurrentESGReportingName);
    end;

    internal procedure SetName(CurrentESGReportingName: Code[10]; var ESGReportingLine: Record "Sust. ESG Reporting Line")
    begin
        ESGReportingLine.FilterGroup(2);
        ESGReportingLine.SetRange("ESG Reporting Name", CurrentESGReportingName);
        ESGReportingLine.FilterGroup(0);
        if ESGReportingLine.FindFirst() then;
    end;

    internal procedure LookupName(CurrentESGReportingTemplateName: Code[10]; CurrentESGReportingName: Code[10]; var EnteredESGReportingName: Text[10]): Boolean
    var
        ESGReportingName: Record "Sust. ESG Reporting Name";
    begin
        ESGReportingName."ESG Reporting Template Name" := CurrentESGReportingTemplateName;
        ESGReportingName.Name := CurrentESGReportingName;
        ESGReportingName.FilterGroup(2);
        ESGReportingName.SetRange("ESG Reporting Template Name", CurrentESGReportingTemplateName);
        ESGReportingName.FilterGroup(0);
        if Page.RunModal(0, ESGReportingName) <> Action::LookupOK then
            exit(false);

        EnteredESGReportingName := ESGReportingName.Name;
        exit(true);
    end;

    internal procedure PrintESGReportingName(ESGReportingName: Record "Sust. ESG Reporting Name")
    var
        ESGReportingTemplate: Record "Sust. ESG Reporting Template";
    begin
        ESGReportingName.SetRecFilter();
        ESGReportingTemplate.Get(ESGReportingName."ESG Reporting Template Name");
        ESGReportingTemplate.TestField("ESG Reporting Report ID");
        Report.Run(ESGReportingTemplate."ESG Reporting Report ID", true, false, ESGReportingName);
    end;

    local procedure CheckTemplateName(CurrentESGReportingTemplateName: Code[10]; var CurrentESGReportingName: Code[10])
    var
        ESGReportingTemplate: Record "Sust. ESG Reporting Template";
        ESGReportingName: Record "Sust. ESG Reporting Name";
    begin
        ESGReportingName.SetRange("ESG Reporting Template Name", CurrentESGReportingTemplateName);
        if not ESGReportingName.Get(CurrentESGReportingTemplateName, CurrentESGReportingName) then begin
            if not ESGReportingName.FindFirst() then begin
                ESGReportingTemplate.Get(CurrentESGReportingTemplateName);

                InsertDefaultESGReportingName(ESGReportingName, ESGReportingTemplate);
                Commit();
            end;
            CurrentESGReportingName := ESGReportingName.Name;
        end;
    end;

    local procedure InsertDefaultESGReportingTemplate(var ESGReportingTemplate: Record "Sust. ESG Reporting Template")
    begin
        ESGReportingTemplate.Init();
        ESGReportingTemplate.Name := ESGLbl;
        ESGReportingTemplate.Description := ESGReportingLbl;
        ESGReportingTemplate.Validate("Page ID");
        ESGReportingTemplate.Insert();
    end;

    local procedure InsertDefaultESGReportingName(var ESGReportingName: Record "Sust. ESG Reporting Name"; var ESGReportingTemplate: Record "Sust. ESG Reporting Template")
    begin
        ESGReportingName.Init();
        ESGReportingName."ESG Reporting Template Name" := ESGReportingTemplate.Name;
        ESGReportingName.Name := DefaultLbl;
        ESGReportingName.Description := DefaultESGReportingLbl;
        ESGReportingName.Insert();
    end;
}