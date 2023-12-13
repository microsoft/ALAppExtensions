// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Foundation.Attachment;
using Microsoft.Foundation.Company;
using Microsoft.Utilities;

page 31138 "VIES Declaration CZL"
{
    Caption = 'VIES Declaration';
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "VIES Declaration Header CZL";
    PromotedActionCategories = 'New,Process,Report,Related';

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the number of the VIES Declaration.';
                    Visible = NoFieldVisible;

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Declaration Period"; Rec."Declaration Period")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies declaration Period (month, quarter).';
                }
                field("Declaration Type"; Rec."Declaration Type")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies type of VIES Declaration (Normal, Corrective).';

                    trigger OnValidate()
                    begin
                        if xRec."Declaration Type" <> Rec."Declaration Type" then
                            if Rec."Declaration Type" <> Rec."Declaration Type"::Corrective then
                                Rec."Corrected Declaration No." := '';
                        SetControlsEditable();
                    end;
                }
                field("Corrected Declaration No."; Rec."Corrected Declaration No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = CorrectedDeclarationNoEditable;
                    ToolTip = 'Specifies the existing VIES declaration that needs to be corrected.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies company name.';
                    Importance = Additional;
                }
                field("VAT Registration No."; Rec."VAT Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowMandatory = true;
                    ToolTip = 'Specifies company VAT Registration No.';
                    Importance = Additional;
                }
                field("Tax Office Number"; Rec."Tax Office Number")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the tax office number for reporting.';
                    Visible = false;
                }
                field("Tax Office Region Number"; Rec."Tax Office Region Number")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the tax office region number for reporting.';
                    Visible = false;
                }
                field("Trade Type"; Rec."Trade Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = TradeTypeEditable;
                    ToolTip = 'Specifies trade type for VIES declaration.';
                }
                field("EU Goods/Services"; Rec."EU Goods/Services")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = EUGoodsServicesEditable;
                    ToolTip = 'Specifies goods, services, or both. The EU requires this information for VIES reporting.';
                }
                field("Company Trade Name Appendix"; Rec."Company Trade Name Appendix")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = CompanyTradeNameAppendixEditable;
                    ToolTip = 'Specifies type of the company.';
                    Visible = false;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date on which you created the document.';
                }
                field("Period No."; Rec."Period No.")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    Editable = PeriodNoEditable;
                    Importance = Promoted;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the VAT period.';
                }
                field(Year; Rec.Year)
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    Editable = YearEditable;
                    Importance = Promoted;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the year of report.';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the declaration start date. The field is calculated based on the trade type, period no. and year fields.';
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies end date for the declaration, which is calculated based of the values of the period no. and year fields.';
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    ToolTip = 'Specifies total amounts of all reported trades for selected period.';
                }
                field("Number of Supplies"; Rec."Number of Supplies")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    ToolTip = 'Specifies number of all reported supplies for selected period.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the status of the declaration. The field will display either a status of open or released.';
                }
                field("Company Type"; Rec."Company Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies company type.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        SetControlsEditable();
                    end;
                }
            }
            part(Lines; "VIES Declaration Subform CZL")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "VIES Declaration No." = field("No.");
                UpdatePropagation = Both;
            }
            group(Address)
            {
                Caption = 'Address';
                field("Country/Region Name"; Rec."Country/Region Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country/region code.';
                }
                field(County; Rec.County)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country for the tax office.';
                }
                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the postal code.';
                }
                field(City; Rec.City)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the city for the tax office.';
                }
                field(Street; Rec.Street)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the street for the tax office.';
                }
                field("House No."; Rec."House No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company''s house number.';
                }
                field("Municipality No."; Rec."Municipality No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the municipality number fot the tax office that receives the VIES declaration.';
                }
                field("Apartment No."; Rec."Apartment No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies apartment number.';
                }
            }
            group(Persons)
            {
                Caption = 'Persons';
                field("Authorized Employee No."; Rec."Authorized Employee No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies authorized employee.';
                }
                field("Filled by Employee No."; Rec."Filled by Employee No.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the employee number for the employee who filled the declaration.';
                }
                field("Individual Employee No."; Rec."Individual Employee No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = IndividualEmployeeNoEditable;
                    ToolTip = 'Specifies employee number for the individual employee.';
                }
            }
        }
        area(FactBoxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(31075), "No." = field("No.");
            }
        }
    }
    actions
    {
        area(processing)
        {
            group("L&ines")
            {
                Caption = 'L&ines';
                action("&Suggest Lines")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '&Suggest Lines';
                    Ellipsis = true;
                    Image = SuggestLines;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ToolTip = 'This batch job creates VIES declaration lines from declaration header information and data stored in VAT tables.';

                    trigger OnAction()
                    var
                        VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL";
                    begin
                        Rec.TestField(Status, Rec.Status::Open);
                        Rec.Testfield("Period No.");
                        Rec.TestField(Year);
                        VIESDeclarationHeaderCZL.SetRange("No.", Rec."No.");
                        Report.RunModal(Report::"Suggest VIES Declaration CZL", true, false, VIESDeclarationHeaderCZL);
                    end;
                }
                action("&Get Lines for Correction")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '&Get Lines for Correction';
                    Ellipsis = true;
                    Image = GetLines;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ToolTip = 'This batch job allows you get the lines for corrective VIES declaration.';

                    trigger OnAction()
                    var
                        VIESDeclarationLinesCZL: Page "VIES Declaration Lines CZL";
                    begin
                        Rec.TestField(Status, Rec.Status::Open);
                        Rec.TestField("Corrected Declaration No.");
                        VIESDeclarationLinesCZL.SetToDeclaration(Rec);
                        VIESDeclarationLinesCZL.LookupMode := true;
                        if VIESDeclarationLinesCZL.RunModal() = ACTION::LookupOK then
                            VIESDeclarationLinesCZL.CopyLineToDeclaration();
                    end;
                }
            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("Re&lease")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Re&lease';
                    Image = ReleaseDoc;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ShortcutKey = 'Ctrl+F9';
                    ToolTip = 'Release the document to the next stage of processing. When a document is released, it will be possible to print or export declaration. You must reopen the document before you can make changes to it.';

                    trigger OnAction()
                    begin
                        ReleaseVIESDeclarationCZL.Run(Rec);
                    end;
                }
                action("Re&open")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Re&open';
                    Image = Replan;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ToolTip = 'Reopen the document to change it after it has been approved. Approved documents have tha Released status and must be opened before they can be changed.';

                    trigger OnAction()
                    begin
                        ReleaseVIESDeclarationCZL.Reopen(Rec);
                    end;
                }
                action("&Export")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '&Export';
                    Image = CreateXMLFile;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ToolTip = 'This batch job is used for VIES declaration results export in XML format.';

                    trigger OnAction()
                    begin
                        Rec.Export();
                    end;
                }
            }
        }
        area(reporting)
        {
            action("Test Report")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Test Report';
                Ellipsis = true;
                Image = TestReport;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedOnly = true;
                ToolTip = 'View a test report so that you can find and correct any errors before you issue or export document.';

                trigger OnAction()
                begin
                    Rec.PrintTestReport();
                end;
            }
            action("&Declaration")
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Declaration';
                Image = Report;
                Ellipsis = true;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedOnly = true;
                ToolTip = 'View a VIES declaration report.';

                trigger OnAction()
                begin
                    Rec.Print();
                end;
            }
            action(PrintToAttachment)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attach as PDF';
                Image = PrintAttachment;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedOnly = true;
                ToolTip = 'Create a PDF file and attach it to the document.';

                trigger OnAction()
                begin
                    Rec.PrintToDocumentAttachment();
                end;
            }
        }
        area(Navigation)
        {
            action(DocAttach)
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                Image = Attach;
                ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';

                trigger OnAction()
                var
                    DocumentAttachmentDetails: Page "Document Attachment Details";
                    RecRef: RecordRef;
                begin
                    RecRef.GetTable(Rec);
                    DocumentAttachmentDetails.OpenForRecRef(RecRef);
                    DocumentAttachmentDetails.RunModal();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetNoFieldVisible();
    end;

    trigger OnInit()
    begin
        IndividualEmployeeNoEditable := true;
        CompanyTradeNameAppendixEditable := true;
        EUGoodsServicesEditable := true;
        TradeTypeEditable := true;
        YearEditable := true;
        PeriodNoEditable := true;
        CorrectedDeclarationNoEditable := true;
    end;

    trigger OnOpenPage()
    begin
        SetNoFieldVisible();
    end;

    var
        ReleaseVIESDeclarationCZL: Codeunit "Release VIES Declaration CZL";
        DocumentNoVisibility: Codeunit DocumentNoVisibility;
        CorrectedDeclarationNoEditable: Boolean;
        PeriodNoEditable: Boolean;
        YearEditable: Boolean;
        TradeTypeEditable: Boolean;
        EUGoodsServicesEditable: Boolean;
        CompanyTradeNameAppendixEditable: Boolean;
        IndividualEmployeeNoEditable: Boolean;
        NoFieldVisible: Boolean;

    local procedure SetControlsEditable()
    var
        Corrective: Boolean;
    begin
        Corrective := Rec."Declaration Type" = Rec."Declaration Type"::Corrective;
        CorrectedDeclarationNoEditable := Corrective;
        PeriodNoEditable := not Corrective;
        YearEditable := not Corrective;
        TradeTypeEditable := not Corrective;
        EUGoodsServicesEditable := not Corrective;
        case Rec."Company Type" of
            Rec."Company Type"::Individual:
                begin
                    CompanyTradeNameAppendixEditable := false;
                    IndividualEmployeeNoEditable := true;
                end;
            Rec."Company Type"::Corporate:
                begin
                    CompanyTradeNameAppendixEditable := true;
                    IndividualEmployeeNoEditable := false;
                end;
        end;
    end;

    local procedure SetNoFieldVisible()
    begin
        if Rec."No." <> '' then
            NoFieldVisible := false
        else
            NoFieldVisible := DocumentNoVisibility.ForceShowNoSeriesForDocNo(DetermineVIESDeclarationCZLSeriesNo());
    end;

    local procedure DetermineVIESDeclarationCZLSeriesNo(): Code[20]
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL";
    begin
        StatutoryReportingSetupCZL.Get();
        DocumentNoVisibility.CheckNumberSeries(VIESDeclarationHeaderCZL, StatutoryReportingSetupCZL."VIES Declaration Nos.", VIESDeclarationHeaderCZL.FieldNo("No."));
        exit(StatutoryReportingSetupCZL."VIES Declaration Nos.");
    end;
}
