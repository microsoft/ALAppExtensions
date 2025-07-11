namespace Microsoft.Sustainability.RoleCenters;

using Microsoft.Assembly.Document;
using Microsoft.EServices.EDocument;
using Microsoft.Foundation.Task;
using Microsoft.Inventory.Transfer;
using Microsoft.Manufacturing.Document;
using Microsoft.Purchases.Document;
using Microsoft.Sales.Document;
using Microsoft.Sustainability.Ledger;
using System.Automation;
using System.Device;

page 6236 "Sustainability Activities"
{
    PageType = CardPart;
    SourceTable = "Sustainability Cue";
    RefreshOnActivate = true;
    Caption = 'Activities';

    layout
    {
        area(Content)
        {
            cuegroup(General)
            {
                CuegroupLayout = Wide;
                Caption = 'Emissions';
                ShowCaption = true;

                field("Emission CO2"; EmissionCO2)
                {
                    ApplicationArea = All;
                    Caption = 'CO2 This Month';
                    StyleExpr = EmissionCO2StyleText;
                    DecimalPlaces = 2 : 2;
                    DrillDownPageId = "Sustainability Ledger Entries";
                    ToolTip = 'Specifies the value of the CO2 This Month field.';

                    trigger OnDrillDown()
                    begin
                        ShowSustainabilityLedgerEntry();
                    end;
                }
                field("Emission CH4"; EmissionCH4)
                {
                    ApplicationArea = All;
                    Caption = 'CH4 This Month';
                    DecimalPlaces = 2 : 2;
                    Style = None;
                    DrillDownPageId = "Sustainability Ledger Entries";
                    ToolTip = 'Specifies the value of the CH4 This Month field.';

                    trigger OnDrillDown()
                    begin
                        ShowSustainabilityLedgerEntry();
                    end;
                }
                field("Emission N2O"; EmissionN2O)
                {
                    ApplicationArea = All;
                    Caption = 'N2O This Month';
                    Style = None;
                    DecimalPlaces = 2 : 2;
                    DrillDownPageId = "Sustainability Ledger Entries";
                    ToolTip = 'Specifies the value of the N2O This Month field.';

                    trigger OnDrillDown()
                    begin
                        ShowSustainabilityLedgerEntry();
                    end;
                }
            }
            cuegroup(Other)
            {
                CuegroupLayout = Wide;
                Caption = 'Other';
                ShowCaption = true;

                field("Water Intensity"; WaterIntensity)
                {
                    ApplicationArea = All;
                    Caption = 'Water This Month';
                    Style = None;
                    DecimalPlaces = 2 : 2;
                    DrillDownPageId = "Sustainability Ledger Entries";
                    ToolTip = 'Specifies the value of the Water This Month field.';

                    trigger OnDrillDown()
                    begin
                        ShowSustainabilityLedgerEntry();
                    end;
                }
                field("Waste Intensity"; WasteIntensity)
                {
                    ApplicationArea = All;
                    Caption = 'Waste This Month';
                    Style = None;
                    DecimalPlaces = 2 : 2;
                    DrillDownPageId = "Sustainability Ledger Entries";
                    ToolTip = 'Specifies the value of the Waste This Month field.';

                    trigger OnDrillDown()
                    begin
                        ShowSustainabilityLedgerEntry();
                    end;
                }
            }
            cuegroup("Ongoing Purchases")
            {
                Caption = 'Ongoing Purchases';
                field("Ongoing Purchase Orders"; Rec."Ongoing Purchase Orders")
                {
                    ApplicationArea = Suite;
                    Style = None;
                    DrillDownPageID = "Purchase Order List";
                    ToolTip = 'Specifies purchases orders that are not posted or only partially posted.';
                }
                field("Ongoing Purchase Invoices"; Rec."Ongoing Purchase Invoices")
                {
                    ApplicationArea = Basic, Suite;
                    Style = None;
                    DrillDownPageID = "Purchase Invoices";
                    ToolTip = 'Specifies purchases invoices that are not posted or only partially posted.';
                }
                field("Purch. Invoices Due Next Week"; Rec."Purch. Invoices Due Next Week")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = PurchInvDueNextWeekStyleText;
                    ToolTip = 'Specifies the number of payments to vendors that are due next week.';
                }
            }
            cuegroup("Incoming Documents")
            {
                Caption = 'Incoming Documents';
                field("My Incoming Documents"; Rec."My Incoming Documents")
                {
                    ApplicationArea = Suite;
                    Style = None;
                    ToolTip = 'Specifies incoming documents that are assigned to you.';
                }
                field("Awaiting Verfication"; Rec."Inc. Doc. Awaiting Verfication")
                {
                    ApplicationArea = Suite;
                    DrillDown = true;
                    Style = None;
                    ToolTip = 'Specifies incoming documents in OCR processing that require you to log on to the OCR service website to manually verify the OCR values before the documents can be received.';
                    Visible = ShowAwaitingIncomingDoc;

                    trigger OnDrillDown()
                    var
                        OCRServiceSetup: Record "OCR Service Setup";
                    begin
                        if not OCRServiceSetup.Get() then
                            exit;

                        if OCRServiceSetup.Enabled then
                            HyperLink(OCRServiceSetup."Sign-in URL");
                    end;
                }
            }
            cuegroup(Camera)
            {
                Caption = 'Scan documents';
                Visible = HasCamera;

                actions
                {
                    action(CreateIncomingDocumentFromCamera)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Create Incoming Doc. from Camera';
                        Image = TileCamera;
                        ToolTip = 'Create an incoming document by taking a photo of the document with your device camera. The photo will be attached to the new document.';

                        trigger OnAction()
                        var
                            IncomingDocument: Record "Incoming Document";
                            Camera: Codeunit Camera;
                            InStr: InStream;
                            PictureName: Text;
                        begin
                            if not Camera.GetPicture(InStr, PictureName) then
                                exit;

                            IncomingDocument.CreateIncomingDocument(InStr, PictureName);
                            CurrPage.Update();
                        end;
                    }
                }
            }
            cuegroup("Value Chain")
            {
                Caption = 'Value Chain';
                field("Ongoing Sales Orders"; Rec."Ongoing Sales Orders")
                {
                    ApplicationArea = Suite;
                    DrillDownPageID = "Sales Order List";
                    Style = None;
                    ToolTip = 'Specifies Sales orders that are not posted or only partially posted.';
                }
                field("Ongoing Sales Invoices"; Rec."Ongoing Sales Invoices")
                {
                    ApplicationArea = Basic, Suite;
                    Style = None;
                    DrillDownPageID = "Sales Invoice List";
                    ToolTip = 'Specifies Sales invoices that are not posted or only partially posted.';
                }
                field("Sales Invoices Due Next Week"; Rec."Sales Invoices Due Next Week")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = SalesInvDueNextWeekStyleText;
                    ToolTip = 'Specifies the number of payments to customer that are due next week.';
                }
                field("Released Prod. Orders"; Rec."Released Prod. Orders")
                {
                    ApplicationArea = All;
                    Caption = 'Released Prod. Orders This Month';
                    Style = None;
                    DrillDownPageId = "Released Production Orders";
                    ToolTip = 'Specifies the value of the Released Production Orders This Month field.';
                }
                field("Assembly Orders"; Rec."Assembly Orders")
                {
                    ApplicationArea = All;
                    Caption = 'Assembly Orders This Month';
                    Style = None;
                    DrillDownPageId = "Assembly Orders";
                    ToolTip = 'Specifies the value of the Assembly Orders This Month field.';
                }
                field("Ongoing Transfer Orders"; Rec."Ongoing Transfer Orders")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "Transfer Orders";
                    Style = None;
                    ToolTip = 'Specifies Transfer Orders that are not posted or only partially posted.';
                }
            }
            cuegroup("Approvals")
            {
                Caption = 'Approvals';
                field("Requests Sent for Approval"; Rec."Requests Sent for Approval")
                {
                    ApplicationArea = Suite;
                    DrillDownPageID = "Approval Entries";
                    StyleExpr = RequestsSentForApprovalStyleText;
                    ToolTip = 'Specifies requests for certain documents, cards, or journal lines that your approver must approve before you can proceed.';
                }
                field("Requests to Approve"; Rec."Requests to Approve")
                {
                    ApplicationArea = Suite;
                    DrillDownPageID = "Requests to Approve";
                    StyleExpr = RequestsToApprovalStyleText;
                    ToolTip = 'Specifies requests for certain documents, cards, or journal lines that you must approve for other users before they can proceed.';
                }
            }
            cuegroup("My User Tasks")
            {
                Caption = 'My User Tasks';
                field("UserTaskManagement.GetMyPendingUserTasksCount"; UserTaskManagement.GetMyPendingUserTasksCount())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pending User Tasks';
                    Image = Checklist;
                    Style = None;
                    ToolTip = 'Specifies the number of pending tasks that are assigned to you or to a group that you are a member of.';

                    trigger OnDrillDown()
                    var
                        UserTaskList: Page "User Task List";
                    begin
                        UserTaskList.SetPageToShowMyPendingUserTasks();
                        UserTaskList.Run();
                    end;
                }
                field("GetMyPendingUserTasksThisMonthCount"; Rec.GetMyPendingUserTasksThisMonthCount())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Tasks This Month';
                    StyleExpr = TasksThisMonthStyleText;
                    ToolTip = 'Specifies the number of pending tasks this month that are assigned to you or to a group that you are a member of.';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowMyPendingUserTasksThisMonthCount();
                    end;
                }
                field("GetMyOverDueUserTasksCount"; Rec.GetMyOverDueUserTasksCount())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Overdue User Tasks';
                    Image = Checklist;
                    StyleExpr = OverdueTasksStyleText;
                    ToolTip = 'Specifies the number of pending tasks that are assigned to you due this week or to a group that you are a member of.';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowMyPendingUserTasksOverDueCount();
                    end;
                }
            }
        }
    }

    var
        UserTaskManagement: Codeunit "User Task Management";
        HasCamera: Boolean;
        ShowAwaitingIncomingDoc: Boolean;
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        WaterIntensity: Decimal;
        WasteIntensity: Decimal;
        EmissionCO2StyleText: Text;
        PurchInvDueNextWeekStyleText: Text;
        SalesInvDueNextWeekStyleText: Text;
        RequestsSentForApprovalStyleText, RequestsToApprovalStyleText, TasksThisMonthStyleText, OverdueTasksStyleText : Text;

    trigger OnOpenPage()
    var
        OCRServiceMgt: Codeunit "OCR Service Mgt.";
        CameraMgt: Codeunit Camera;
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
        ShowAwaitingIncomingDoc := OCRServiceMgt.OcrServiceIsEnable();
        HasCamera := CameraMgt.IsAvailable();

        ApplyDateFilter();
        Rec.SetRange("User ID Filter", UserId);

        SaveEmissionValues();
    end;

    trigger OnAfterGetRecord()
    begin
        SetControlAppearance();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetControlAppearance();
    end;

    local procedure ApplyDateFilter()
    begin
        Rec.SetRange("Date Filter", CalcDate('<-CM>', WorkDate()), CalcDate('<CM>', WorkDate()));
        Rec.Setfilter("DateTime Filter", Format(CalcDate('<-CM>', WorkDate())) + '..' + Format(CalcDate('<CM>', WorkDate())));
        Rec.CalcFields("Emission CO2", "Emission CH4", "Emission N2O", "Waste Intensity", "Water Intensity");

        Rec.SetFilter("Due Next Week Filter", '%1..%2', CalcDate('<1D>', WorkDate()), CalcDate('<1W>', WorkDate()));
    end;

    local procedure SaveEmissionValues()
    begin
        EmissionCO2 := Rec."Emission CO2";
        EmissionCH4 := Rec."Emission CH4";
        EmissionN2O := Rec."Emission N2O";
        WaterIntensity := Rec."Water Intensity";
        WasteIntensity := Rec."Waste Intensity";

        SetControlAppearance();
    end;

    local procedure ShowSustainabilityLedgerEntry()
    var
        SustLedgerEntry: Record "Sustainability Ledger Entry";
    begin
        SustLedgerEntry.SetRange("Posting Date", CalcDate('<-CM>', WorkDate()), CalcDate('<CM>', WorkDate()));

        Page.Run(Page::"Sustainability Ledger Entries", SustLedgerEntry);
    end;

    local procedure SetControlAppearance()
    begin
        EmissionCO2StyleText := Rec.GetEmissionCO2Style();
        PurchInvDueNextWeekStyleText := Rec.GetPurchInvDueNextWeekStyle();
        SalesInvDueNextWeekStyleText := Rec.GetSalesInvDueNextWeekStyle();
        RequestsSentForApprovalStyleText := Rec.GetRequestsSentForApprovalStyle();
        RequestsToApprovalStyleText := Rec.GetRequestsToApprovalStyle();
        TasksThisMonthStyleText := Rec.GetTasksThisMonthStyle();
        OverdueTasksStyleText := Rec.GetOverdueTasksStyle();
    end;
}