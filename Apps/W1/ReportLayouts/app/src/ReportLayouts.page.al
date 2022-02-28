// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
/// <summary>
/// The report layouts page, used for adding/deleting/editing user and extension defined report layouts.
/// </summary>
page 9660 "Report Layouts"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Report Layouts';
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = true;
    PromotedActionCategories = 'New,Process,Report,Approve';
    AdditionalSearchTerms = 'Custom Report Layouts, Report Layout Selection';
    PageType = List;
    SourceTable = "Report Layout List";
    SourceTableView = Sorting("Report ID", "Layout Format");
    UsageCategory = Administration;
    Extensible = true;
    Permissions = tabledata "Tenant Report Layout" = rd;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Report ID"; Rec."Report ID")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the object ID of the report.';
                }
                field("Report Name"; Rec."Report Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Caption = 'Report Name';
                    ToolTip = 'Specifies the name of the report.';
                }
                field("Layout Name"; Rec."Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Caption = 'Layout Name';
                    ToolTip = 'Specifies the unique name of the layout.';
                }
                field(Description; Rec."Description")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Caption = 'Description';
                    ToolTip = 'Specifies a description of the report layout.';
                }
                field("Layout Publisher"; Rec."Layout Publisher")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Caption = 'Extension';
                    ToolTip = 'Specifies the name and publisher of the extension that the layout belongs to. If this field is empty, it means that layout is user-defined and does not belong to an extension.';
                }
                field("Layout Format"; Rec."Layout Format")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Caption = 'Type';
                    OptionCaption = 'RDLC,Word,Excel,External';
                    ToolTip = 'Specifies the format of the report layout.';
                }
                field("User Defined"; Rec."User Defined")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies whether the layout was created by a user.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control11; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
            systempart(Control12; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(NewLayout)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'New Layout';
                Image = NewDocument;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                Scope = Repeater;
                PromotedCategory = Process;
                ToolTip = 'Create a new layout.';

                trigger OnAction()
                var
                    ReturnReportID: Integer;
                    ReturnLayoutName: Text;
                begin
                    ReportLayoutsImpl.CreateNewReportLayout(Rec, ReturnReportID, ReturnLayoutName);
                    SetFocusedRecord(ReturnReportID, ReturnLayoutName);
                end;
            }

            action(EditLayout)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Edit Info';
                Image = Edit;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                Scope = Repeater;
                PromotedCategory = Process;
                ToolTip = 'Edit layout information.';

                trigger OnAction()
                var
                    NewEditedLayoutName: Text;
                begin
                    if not "User Defined" then begin
                        if Dialog.Confirm(EditInfoExtensionLayoutTxt, false) then
                            ReportLayoutsImpl.EditReportLayout(Rec, NewEditedLayoutName);
                    end else
                        ReportLayoutsImpl.EditReportLayout(Rec, NewEditedLayoutName);
                    SetFocusedRecord(Rec."Report ID", NewEditedLayoutName);
                end;
            }

            action(RunReport)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Run Report';
                Image = "Report";
                PromotedOnly = true;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                ToolTip = 'Run the report using the selected layout.';

                trigger OnAction()
                begin
                    ReportLayoutsImpl.RunCustomReport(Rec);
                end;
            }

            action(DefaulLayoutSelection)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Set Default';
                Image = ListPage;
                PromotedOnly = true;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                ToolTip = 'Set the current layout as the default layout for the specified report.';

                trigger OnAction()
                begin
                    ReportLayoutsImpl.SetDefaultReportLayoutSelection(Rec);
                end;
            }

            action(ExportLayout)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Export Layout';
                Image = Export;
                PromotedOnly = true;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                ToolTip = 'Export the selected layout file.';

                trigger OnAction()
                begin
                    ReportLayoutsImpl.ExportReportLayout(Rec);
                end;
            }

            action(ReplaceLayout)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Replace Layout';
                Image = Import;
                PromotedOnly = true;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                ToolTip = 'Replace the existing layout file.';

                trigger OnAction()
                var
                    ReturnReportID: Integer;
                    ReturnLayoutName: Text;
                begin
                    if not "User Defined" then
                        Error(ModifyNonUserLayoutErr);

                    if Dialog.Confirm(ReplaceConfirmationTxt, false) then
                        ReportLayoutsImpl.UploadNewLayout("Report ID", "Name", "Description", "Layout Format", ReturnReportID, ReturnLayoutName);
                end;
            }
        }
    }

    views
    {
        view(UserDefined)
        {
            Caption = 'User-Defined';
            Filters = where("User Defined" = Const(true));
        }
        view(Extensions)
        {
            Caption = 'Extensions';
            Filters = where("User Defined" = Const(false));
        }
    }

    trigger OnOpenPage()
    begin
        ReportLayoutsImpl.SetSelectedCompany(CompanyName);
    end;

    trigger OnDeleteRecord(): Boolean
    var
        TenantReportLayout: Record "Tenant Report Layout";
    begin
        TenantReportLayout.Init();
        if TenantReportLayout.Get("Report ID", "Name", EmptyGuid) then
            TenantReportLayout.Delete(true)
        else
            Error(ModifyNonUserLayoutErr);

        CurrPage.Update(false);
        exit(false);
    end;

    var
        ReportLayoutsImpl: Codeunit "Report Layouts Impl.";
        EmptyGuid: Guid;
        ModifyNonUserLayoutErr: Label 'Only user-defined layouts can be modified or removed.';
        EditInfoExtensionLayoutTxt: Label 'Extension layouts info cannot be modified. Do you want to edit a copy of the layout instead ?';
        ReplaceConfirmationTxt: Label 'This action will replace the layout file of the currently selected layout. Do you want to continue ?';

    local procedure SetFocusedRecord(ReportID: Integer; LayoutName: Text)
    var
        CurrReportLayoutList: Record "Report Layout List";
    begin
        if CurrReportLayoutList.get(ReportID, LayoutName, EmptyGuid) then begin
            CurrPage.SetRecord(CurrReportLayoutList);
            CurrPage.Update(false);
        end;
    end;
}